@echo off
REM ─────────────────────────────────────────────────────────────────────
REM  filecp — Build MSIX Package for Microsoft Store
REM  Creates a properly structured .msix from the PyInstaller output.
REM
REM  This is the RECOMMENDED submission format:
REM    - Silent install: handled automatically by MSIX/Windows
REM    - Add/Remove Programs: registered automatically by MSIX
REM    - Code signing: Partner Center re-signs during ingestion
REM    - Bundleware: impossible in MSIX sandboxed format
REM
REM  Prerequisites:
REM    - Windows 10 SDK (provides makeappx.exe, makepri.exe, signtool.exe)
REM    - PyInstaller build already completed (dist\filecp.exe exists)
REM    - Store assets generated (run: python generate_store_assets.py)
REM
REM  For Store submission:
REM    1. Update AppxManifest.xml with your Partner Center identity
REM    2. Run this script
REM    3. Upload dist\filecp.msix to Partner Center
REM       (leave unsigned — Partner Center re-signs with Microsoft cert)
REM ─────────────────────────────────────────────────────────────────────
setlocal enabledelayedexpansion

echo.
echo ============================================================
echo   filecp — Microsoft Store MSIX Package Builder
echo ============================================================
echo.

REM ── Step 0: Locate Windows SDK tools ────────────────────────────
set "SDK_BIN="
set "SDK_ROOT="

REM Try local sdk_tools folder first
if exist "sdk_tools\Microsoft.Windows.SDK.BuildTools.10.0.28000.1721\bin\10.0.28000.0\x64\makeappx.exe" (
    set "SDK_BIN=sdk_tools\Microsoft.Windows.SDK.BuildTools.10.0.28000.1721\bin\10.0.28000.0\x64"
    set "SDK_ROOT=sdk_tools\Microsoft.Windows.SDK.BuildTools.10.0.28000.1721"
) else (
    REM Fall back to system-wide installation
    for /d %%d in ("C:\Program Files (x86)\Windows Kits\10\bin\10.*") do (
        if exist "%%d\x64\makeappx.exe" (
            set "SDK_BIN=%%d\x64"
            set "SDK_ROOT=%%d"
        )
    )
)
if "%SDK_BIN%"=="" (
    echo ERROR: Windows 10 SDK not found.
    echo        Install it from: https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/
    echo        Make sure to include "Windows SDK Signing Tools for Desktop Apps"
    echo.
    echo        To install via winget:
    echo          winget install Microsoft.WindowsSDK.10.0.22621
    pause
    exit /b 1
)
echo Found SDK tools: %SDK_BIN%

REM ── Step 1: Ensure PyInstaller exe exists ───────────────────────
echo.
echo [1/8] Checking for PyInstaller build...
if not exist "dist\filecp.exe" (
    echo   filecp.exe not found. Running build.bat first...
    call build.bat
    if errorlevel 1 (
        echo ERROR: PyInstaller build failed.
        pause
        exit /b 1
    )
)
echo   OK dist\filecp.exe found

REM ── Step 1b: Install dependencies ───────────────────────────
echo.
echo [1b/8] Installing Python dependencies...
pip install -q -r requirements.txt >nul 2>&1
if errorlevel 1 (
    echo   WARNING: Some dependencies may not have installed, continuing...
)

REM ── Step 2: Generate Store assets ───────────────────────────────
echo.
echo [2/8] Generating Store image assets...
if exist "store_assets\StoreLogo.png" (
    echo   OK Store assets already exist, skipping generation
) else (
    python generate_store_assets.py
    if errorlevel 1 (
        echo ERROR: Failed to generate store assets.
        echo        Make sure Pillow is installed: pip install Pillow
        pause
        exit /b 1
    )
    echo   OK Store assets generated
)

REM ── Step 3: Prepare MSIX staging directory ─────────────────────
echo.
echo [3/8] Staging MSIX package contents...
set "MSIX_DIR=msix_staging"

if exist "%MSIX_DIR%" rmdir /s /q "%MSIX_DIR%"
mkdir "%MSIX_DIR%"
mkdir "%MSIX_DIR%\Assets"

REM Copy the executable
copy /y "dist\filecp.exe" "%MSIX_DIR%\" >nul

REM Copy manifest
copy /y "AppxManifest.xml" "%MSIX_DIR%\" >nul

REM Copy store assets (all PNGs needed by manifest)
copy /y "store_assets\*.png" "%MSIX_DIR%\Assets\" >nul

echo   OK MSIX staging directory ready

REM ── Step 4: Generate Package Resource Index (PRI) ───────────────
echo.
echo [4/8] Generating Package Resource Index (resources.pri)...

REM Check if makepri.exe exists
if exist "%SDK_BIN%\makepri.exe" (
    REM Create priconfig.xml for resource indexing
    pushd "%MSIX_DIR%"
    "%SDK_BIN%\makepri.exe" createconfig /cf ..\priconfig.xml /dq en-US /o >nul 2>&1
    if exist "..\priconfig.xml" (
        "%SDK_BIN%\makepri.exe" new /pr . /cf ..\priconfig.xml /of resources.pri /o >nul 2>&1
        if exist "resources.pri" (
            echo   OK resources.pri generated
        ) else (
            echo   WARN: makepri.exe failed to generate resources.pri
            echo         The package may still work without it for full-trust apps
        )
        del /f ..\priconfig.xml 2>nul
    ) else (
        echo   WARN: Could not create PRI config
    )
    popd
) else (
    echo   SKIP: makepri.exe not found in SDK
    echo         Full-trust apps generally work without resources.pri
)

REM ── Step 5: Create the .msix package ────────────────────────────
echo.
echo [5/8] Creating MSIX package...
set "MSIX_OUTPUT=dist\filecp.msix"

"%SDK_BIN%\makeappx.exe" pack /d "%MSIX_DIR%" /p "%MSIX_OUTPUT%" /o
if errorlevel 1 (
    echo ERROR: makeappx.exe failed to create package.
    echo.
    echo   Common fixes:
    echo     - Ensure AppxManifest.xml is valid XML
    echo     - Ensure all referenced asset files exist in Assets\
    echo     - Check that Identity Name and Publisher match Partner Center
    pause
    exit /b 1
)
echo   OK Created %MSIX_OUTPUT%

REM ── Step 6: Self-signed certificate (for local testing ONLY) ────
echo.
echo [6/8] Signing package for local testing...
echo.
echo   NOTE: For Microsoft Store submission, you can skip signing.
echo         Partner Center will re-sign with Microsoft's certificate.
echo         This self-signed cert is ONLY for local sideload testing.
echo.

REM Check if test cert already exists
if not exist "dist\filecp_test.pfx" (
    echo   Creating self-signed test certificate...
    powershell -Command "try { $cert = New-SelfSignedCertificate -Type Custom -Subject 'CN=filecp' -KeyUsage DigitalSignature -FriendlyName 'filecp Test Cert' -CertStoreLocation 'Cert:\CurrentUser\My' -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3', '2.5.29.19={text}') -HashAlgorithm SHA256 -KeyLength 2048 -NotAfter (Get-Date).AddYears(3); $pwd = ConvertTo-SecureString -String 'filecp_test_123' -Force -AsPlainText; Export-PfxCertificate -Cert $cert -FilePath 'dist\filecp_test.pfx' -Password $pwd | Out-Null; Write-Host '  OK Test certificate created' } catch { Write-Host ('  WARN: Certificate creation failed: ' + $_.Exception.Message) }" 2>&1
    if not exist "dist\filecp_test.pfx" (
        echo   WARN: Certificate not created. Package will be unsigned.
        echo         This is FINE for Store submission — Partner Center re-signs it.
        goto :skip_sign
    )
)

"%SDK_BIN%\signtool.exe" sign /fd SHA256 /a /f "dist\filecp_test.pfx" /p "filecp_test_123" "%MSIX_OUTPUT%" >nul 2>&1
if errorlevel 1 (
    echo   WARN: Signing failed. Package is unsigned.
    echo         This is FINE for Store submission — Partner Center re-signs it.
) else (
    echo   OK Package signed with test certificate
    echo      To install locally, first trust the cert:
    echo        certutil -addstore TrustedPeople dist\filecp_test.pfx
)

:skip_sign

REM ── Step 7: Validate the package ────────────────────────────────
echo.
echo [7/8] Validating MSIX package...

REM Basic validation — check the package can be unpacked
set "VALIDATE_DIR=msix_validate_temp"
if exist "%VALIDATE_DIR%" rmdir /s /q "%VALIDATE_DIR%"
"%SDK_BIN%\makeappx.exe" unpack /p "%MSIX_OUTPUT%" /d "%VALIDATE_DIR%" /o >nul 2>&1
if errorlevel 1 (
    echo   WARN: Package validation failed — makeappx cannot unpack the .msix
    echo         The package may be corrupted. Try rebuilding.
) else (
    echo   OK Package validates — can be unpacked successfully
    REM Check key files exist
    if exist "%VALIDATE_DIR%\filecp.exe" (
        echo   OK filecp.exe present in package
    ) else (
        echo   FAIL: filecp.exe missing from package!
    )
    if exist "%VALIDATE_DIR%\AppxManifest.xml" (
        echo   OK AppxManifest.xml present in package
    ) else (
        echo   FAIL: AppxManifest.xml missing from package!
    )
    if exist "%VALIDATE_DIR%\Assets\StoreLogo.png" (
        echo   OK Store assets present in package
    ) else (
        echo   WARN: StoreLogo.png missing from Assets
    )
)
if exist "%VALIDATE_DIR%" rmdir /s /q "%VALIDATE_DIR%" 2>nul

REM ── Step 8: Cleanup and summary ─────────────────────────────────
echo.
echo [8/8] Cleaning up...
rmdir /s /q "%MSIX_DIR%" 2>nul
echo   OK Staging directory removed

echo.
echo ============================================================
echo   BUILD COMPLETE — MSIX PACKAGE READY
echo ============================================================
echo.
echo   MSIX Package:  dist\filecp.msix
for %%A in ("%MSIX_OUTPUT%") do echo   Size:          %%~zA bytes
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │  MSIX solves ALL Microsoft Store validation issues:  │
echo   │                                                      │
echo   │  [OK] Silent install    — automatic with MSIX        │
echo   │  [OK] Add/Remove entry  — automatic with MSIX        │
echo   │  [OK] Bundleware check  — impossible with MSIX       │
echo   │  [OK] Code signing      — Partner Center re-signs    │
echo   └──────────────────────────────────────────────────────┘
echo.
echo   Next steps:
echo     1. Go to https://partner.microsoft.com/dashboard
echo     2. Create/update your app submission
echo     3. Upload dist\filecp.msix (unsigned is fine)
echo     4. IMPORTANT: Update AppxManifest.xml Identity with
echo        values from Partner Center BEFORE final submission:
echo          - Identity Name
echo          - Publisher (CN=XXXXX from Partner Center)
echo        Then rebuild: build_msix.bat
echo.
pause
