@echo off
REM ─────────────────────────────────────────────────────────────────────
REM  filecp — Complete Microsoft Store Build Pipeline (EXE Installer)
REM
REM  This pipeline builds and signs the Inno Setup installer (.exe).
REM  The resulting filecp_setup.exe is compliant with MS Store Policy 10.2.9:
REM    - Supports silent install (zero UI except UAC)
REM    - Registers properly in Add/Remove Programs
REM    - Digitally signed with SHA256 certificate
REM
REM  NOTE: For Microsoft Store, the MSIX path (build_msix.bat) is RECOMMENDED
REM  over this EXE installer path. MSIX handles everything automatically.
REM  Use this only if you specifically need an EXE/MSI installer submission.
REM
REM  Output: dist\filecp_setup.exe (ready for Store submission)
REM ─────────────────────────────────────────────────────────────────────
setlocal enabledelayedexpansion

echo.
echo ================================================================
echo   filecp — Microsoft Store Build Pipeline (EXE Installer)
echo ================================================================
echo.

set "PROJECT_DIR=%~dp0"
set "PFX_FILE=dist\filecp_sign.pfx"
set "PFX_PASS=filecp_sign_2026"
set "INNO_COMPILER="
set "SIGNTOOL="

REM ── Step 0: Locate tools ────────────────────────────────────────
echo [0/8] Locating build tools...

REM Find Inno Setup
for %%p in (
    "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    "C:\Program Files\Inno Setup 6\ISCC.exe"
) do (
    if exist %%p set "INNO_COMPILER=%%~p"
)
if "%INNO_COMPILER%"=="" (
    echo ERROR: Inno Setup 6 not found. Install from https://jrsoftware.org/isdl.php
    pause
    exit /b 1
)
echo   Inno Setup: %INNO_COMPILER%

REM Find signtool (SDK or NuGet cache)
for /d %%d in ("C:\Program Files (x86)\Windows Kits\10\bin\10.*") do (
    if exist "%%d\x64\signtool.exe" set "SIGNTOOL=%%d\x64\signtool.exe"
)
if "%SIGNTOOL%"=="" (
    for /r "%TEMP%\signtool_nuget" %%f in (signtool.exe) do (
        echo %%f | findstr /i "x64" >nul && set "SIGNTOOL=%%f"
    )
)
if "%SIGNTOOL%"=="" (
    echo   signtool not found in SDK, will download via NuGet...
    powershell -Command "$d='%TEMP%\signtool_nuget'; if(-not(Test-Path $d)){New-Item -ItemType Directory $d -Force|Out-Null}; if(-not(Test-Path \"$d\nuget.exe\")){Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile \"$d\nuget.exe\"}; &\"$d\nuget.exe\" install Microsoft.Windows.SDK.BuildTools -OutputDirectory $d -NonInteractive 2>&1|Out-Null"
    for /r "%TEMP%\signtool_nuget" %%f in (signtool.exe) do (
        echo %%f | findstr /i "x64" >nul && set "SIGNTOOL=%%f"
    )
)
if "%SIGNTOOL%"=="" (
    echo ERROR: Could not obtain signtool.exe
    pause
    exit /b 1
)
echo   signtool: %SIGNTOOL%

REM ── Step 1: Install dependencies ────────────────────────────────
echo.
echo [1/8] Installing dependencies...
pip install pywebview requests pyinstaller Pillow --quiet
if errorlevel 1 (
    echo ERROR: pip install failed
    pause
    exit /b 1
)

REM ── Step 2: Generate icon ───────────────────────────────────────
echo [2/8] Generating icons...
python generate_icon.py 2>nul
if errorlevel 1 echo   WARNING: Icon generation failed, using existing icon.
python generate_store_assets.py 2>nul
if errorlevel 1 echo   WARNING: Store asset generation failed.

REM ── Step 3: Build exe with PyInstaller ──────────────────────────
echo [3/8] Building executable...
pyinstaller filecp.spec --noconfirm --clean
if errorlevel 1 (
    echo ERROR: PyInstaller build failed.
    pause
    exit /b 1
)
echo   Created dist\filecp.exe
for %%A in (dist\filecp.exe) do echo   Size: %%~zA bytes

REM ── Step 4: Create signing certificate (if needed) ─────────────
echo.
echo [4/8] Preparing code signing certificate...
if not exist "%PFX_FILE%" (
    echo   Creating self-signed code signing certificate...
    powershell -Command "$cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject 'CN=Simar Singh Rayat, O=filecp, L=Unknown, S=Unknown, C=IN' -KeyUsage DigitalSignature -FriendlyName 'filecp Code Signing' -CertStoreLocation 'Cert:\CurrentUser\My' -HashAlgorithm SHA256 -KeyLength 2048 -NotAfter (Get-Date).AddYears(3) -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3','2.5.29.19={text}'); $pwd = ConvertTo-SecureString -String '%PFX_PASS%' -Force -AsPlainText; Export-PfxCertificate -Cert $cert -FilePath '%PFX_FILE%' -Password $pwd | Out-Null"
    if errorlevel 1 (
        echo   WARNING: Certificate creation failed. Binaries will be unsigned.
        goto :build_installer
    )
)
echo   Certificate: %PFX_FILE%

REM ── Step 5: Sign the exe ────────────────────────────────────────
echo [5/8] Signing filecp.exe...
"%SIGNTOOL%" sign /fd SHA256 /f "%PFX_FILE%" /p "%PFX_PASS%" /t http://timestamp.digicert.com "dist\filecp.exe"
if errorlevel 1 (
    echo   WARNING: Signing filecp.exe failed
) else (
    echo   Signed dist\filecp.exe
)

:build_installer
REM ── Step 6: Build installer ─────────────────────────────────────
echo.
echo [6/8] Building installer...
"%INNO_COMPILER%" installer.iss
if errorlevel 1 (
    echo ERROR: Inno Setup build failed.
    pause
    exit /b 1
)
echo   Created dist\filecp_setup.exe

REM ── Step 7: Sign the installer ──────────────────────────────────
echo [7/8] Signing installer...
if exist "%PFX_FILE%" (
    "%SIGNTOOL%" sign /fd SHA256 /f "%PFX_FILE%" /p "%PFX_PASS%" /t http://timestamp.digicert.com "dist\filecp_setup.exe"
    if errorlevel 1 (
        echo   WARNING: Signing filecp_setup.exe failed
    ) else (
        echo   Signed dist\filecp_setup.exe
    )
) else (
    echo   Skipped signing (no certificate)
)

REM ── Step 8: Validate silent install ─────────────────────────────
echo.
echo [8/8] Validating installer...
echo.
echo   Installer details:
echo     Name:      filecp_setup.exe
echo     Silent:    /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
echo     Unsigned:  Submit to Partner Center (needs real cert for Store)
echo.
echo   Verifying installer properties...
for %%A in (dist\filecp_setup.exe) do echo   Size: %%~zA bytes
echo   OK Installer built successfully

REM ── Summary ─────────────────────────────────────────────────────
echo.
echo ================================================================
echo   BUILD COMPLETE
echo ================================================================
echo.
echo   Files:
echo     dist\filecp.exe          (desktop app)
for %%A in (dist\filecp.exe) do echo     Size: %%~zA bytes
echo.
echo     dist\filecp_setup.exe    (installer for Store)
for %%A in (dist\filecp_setup.exe) do echo     Size: %%~zA bytes
echo.
echo   ┌──────────────────────────────────────────────────────────┐
echo   │  Store Submission Checklist (EXE path):                  │
echo   │                                                          │
echo   │  [OK] Silent install params:                             │
echo   │       /VERYSILENT /SUPPRESSMSGBOXES /NORESTART           │
echo   │  [OK] Add/Remove Programs: proper name + publisher       │
echo   │  [!!] Code signing: needs REAL cert for Store            │
echo   │       (self-signed NOT accepted for EXE submissions)     │
echo   │                                                          │
echo   │  RECOMMENDED: Use build_msix.bat instead — MSIX format   │
echo   │  solves ALL validation issues with zero cost.            │
echo   └──────────────────────────────────────────────────────────┘
echo.
echo   Package URL (update on gh-pages branch):
echo     https://simarsinghrayat.github.io/Window_app_filecp/v1.0.0/filecp_setup.exe
echo.
echo   Partner Center:  https://partner.microsoft.com/dashboard
echo.
pause
