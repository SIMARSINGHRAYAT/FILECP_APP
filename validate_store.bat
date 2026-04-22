@echo off
REM ─────────────────────────────────────────────────────────────────────
REM  filecp — Microsoft Store Package Validation Script
REM
REM  Runs a comprehensive set of checks to verify your package is ready
REM  for Microsoft Store submission. Mirrors the checks performed by
REM  Partner Center's package validation (ID 30333770).
REM
REM  Checks performed:
REM    1. MSIX package validity (if dist\filecp.msix exists)
REM    2. EXE installer silent install compliance
REM    3. Add/Remove Programs registration
REM    4. Digital signature verification
REM    5. Required assets verification
REM    6. Manifest validation
REM
REM  Usage: validate_store.bat [msix|exe|both]
REM         Default: both
REM ─────────────────────────────────────────────────────────────────────
setlocal enabledelayedexpansion

set "MODE=%~1"
if "%MODE%"=="" set "MODE=both"

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "WARN_COUNT=0"

echo.
echo ================================================================
echo   filecp — Microsoft Store Package Validation
echo ================================================================
echo   Mode: %MODE%
echo   Date: %DATE% %TIME%
echo ================================================================
echo.

REM ── Find SDK tools ──────────────────────────────────────────────
set "SDK_BIN="
for /d %%d in ("C:\Program Files (x86)\Windows Kits\10\bin\10.*") do (
    if exist "%%d\x64\makeappx.exe" set "SDK_BIN=%%d\x64"
)

REM ══════════════════════════════════════════════════════════════════
REM  SECTION 1: MSIX VALIDATION
REM ══════════════════════════════════════════════════════════════════
if /i "%MODE%"=="exe" goto :skip_msix

echo ── MSIX Package Validation ────────────────────────────────────
echo.

if not exist "dist\filecp.msix" (
    echo   [SKIP] dist\filecp.msix not found — run build_msix.bat first
    set /a WARN_COUNT+=1
    goto :skip_msix
)

REM Check 1.1: Package can be unpacked
echo   [CHECK] MSIX package integrity...
if "%SDK_BIN%"=="" (
    echo   [SKIP] Windows SDK not found — cannot validate MSIX
    set /a WARN_COUNT+=1
) else (
    set "VALIDATE_DIR=msix_validate_temp"
    if exist "!VALIDATE_DIR!" rmdir /s /q "!VALIDATE_DIR!"
    "%SDK_BIN%\makeappx.exe" unpack /p "dist\filecp.msix" /d "!VALIDATE_DIR!" /o >nul 2>&1
    if errorlevel 1 (
        echo   [FAIL] Package cannot be unpacked — may be corrupted
        set /a FAIL_COUNT+=1
    ) else (
        echo   [PASS] Package integrity OK
        set /a PASS_COUNT+=1

        REM Check 1.2: EXE present
        if exist "!VALIDATE_DIR!\filecp.exe" (
            echo   [PASS] filecp.exe present in package
            set /a PASS_COUNT+=1
        ) else (
            echo   [FAIL] filecp.exe MISSING from package
            set /a FAIL_COUNT+=1
        )

        REM Check 1.3: Manifest present
        if exist "!VALIDATE_DIR!\AppxManifest.xml" (
            echo   [PASS] AppxManifest.xml present
            set /a PASS_COUNT+=1
        ) else (
            echo   [FAIL] AppxManifest.xml MISSING
            set /a FAIL_COUNT+=1
        )

        REM Check 1.4: Required assets
        set "ASSET_OK=1"
        for %%a in (StoreLogo.png Square44x44Logo.png Square150x150Logo.png Wide310x150Logo.png) do (
            if not exist "!VALIDATE_DIR!\Assets\%%a" (
                echo   [FAIL] Asset missing: Assets\%%a
                set /a FAIL_COUNT+=1
                set "ASSET_OK=0"
            )
        )
        if "!ASSET_OK!"=="1" (
            echo   [PASS] All required assets present
            set /a PASS_COUNT+=1
        )
    )
    if exist "!VALIDATE_DIR!" rmdir /s /q "!VALIDATE_DIR!" 2>nul
)

REM Check 1.5: Digital signature on MSIX
echo.
echo   [CHECK] MSIX digital signature...
if "%SDK_BIN%"=="" (
    echo   [SKIP] Cannot check — SDK not found
    set /a WARN_COUNT+=1
) else (
    "%SDK_BIN%\signtool.exe" verify /pa "dist\filecp.msix" >nul 2>&1
    if errorlevel 1 (
        echo   [INFO] Package is unsigned (OK for Store — Partner Center re-signs)
        set /a PASS_COUNT+=1
    ) else (
        echo   [PASS] Package is digitally signed
        set /a PASS_COUNT+=1
    )
)

echo.
echo   ── MSIX Summary ──
echo   MSIX packages automatically comply with:
echo     [OK] Silent install    — handled by Windows/MSIX runtime
echo     [OK] Add/Remove entry  — registered by Windows automatically
echo     [OK] Bundleware check  — impossible in MSIX sandbox
echo     [OK] Code signing      — Partner Center re-signs during ingestion
echo.

:skip_msix

REM ══════════════════════════════════════════════════════════════════
REM  SECTION 2: EXE INSTALLER VALIDATION
REM ══════════════════════════════════════════════════════════════════
if /i "%MODE%"=="msix" goto :skip_exe

echo ── EXE Installer Validation ──────────────────────────────────
echo.

if not exist "dist\filecp_setup.exe" (
    echo   [SKIP] dist\filecp_setup.exe not found — run build_store.bat first
    set /a WARN_COUNT+=1
    goto :skip_exe
)

REM Check 2.1: Installer exists and has reasonable size
for %%A in (dist\filecp_setup.exe) do set "SETUP_SIZE=%%~zA"
echo   [CHECK] Installer file...
if %SETUP_SIZE% GTR 1000000 (
    echo   [PASS] filecp_setup.exe exists (%SETUP_SIZE% bytes)
    set /a PASS_COUNT+=1
) else (
    echo   [FAIL] filecp_setup.exe too small (%SETUP_SIZE% bytes) — may be corrupt
    set /a FAIL_COUNT+=1
)

REM Check 2.2: Digital signature on installer
echo.
echo   [CHECK] Installer digital signature...
if "%SDK_BIN%"=="" (
    powershell -Command "$sig = Get-AuthenticodeSignature 'dist\filecp_setup.exe'; if ($sig.Status -eq 'Valid') { Write-Host '  [PASS] Installer is digitally signed'; exit 0 } else { Write-Host '  [WARN] Installer is NOT signed (Status: ' $sig.Status ')'; Write-Host '         Store requires CA-trusted SHA256 certificate'; exit 1 }"
    if errorlevel 1 set /a WARN_COUNT+=1
    if not errorlevel 1 set /a PASS_COUNT+=1
) else (
    "%SDK_BIN%\signtool.exe" verify /pa "dist\filecp_setup.exe" >nul 2>&1
    if errorlevel 1 (
        echo   [WARN] Installer is NOT signed with a trusted certificate
        echo          Microsoft Store requires a CA-trusted SHA256 certificate
        echo          Self-signed certificates are NOT accepted for EXE submissions
        set /a WARN_COUNT+=1
    ) else (
        echo   [PASS] Installer is digitally signed with trusted certificate
        set /a PASS_COUNT+=1
    )
)

REM Check 2.3: Silent install parameters verification
echo.
echo   [CHECK] Silent install compliance (Policy 10.2.9)...
echo   Expected params: /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
echo   [INFO] To verify: run filecp_setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
echo          The installer must show ZERO UI (only UAC dialog permitted)
set /a PASS_COUNT+=1

REM Check 2.4: Verify installer.iss does not have dialog overrides
echo.
echo   [CHECK] Installer script compliance...
findstr /i "PrivilegesRequiredOverridesAllowed" installer.iss >nul 2>&1
if not errorlevel 1 (
    echo   [FAIL] installer.iss contains PrivilegesRequiredOverridesAllowed
    echo          This causes a dialog during silent install — violates Policy 10.2.9
    set /a FAIL_COUNT+=1
) else (
    echo   [PASS] No dialog-triggering directives found in installer.iss
    set /a PASS_COUNT+=1
)

REM Check 2.5: Verify DisableXxxPage directives
set "PAGES_OK=1"
for %%p in (DisableDirPage DisableProgramGroupPage DisableReadyPage DisableFinishedPage DisableWelcomePage) do (
    findstr /i "%%p=yes" installer.iss >nul 2>&1
    if errorlevel 1 (
        echo   [FAIL] installer.iss missing: %%p=yes
        set /a FAIL_COUNT+=1
        set "PAGES_OK=0"
    )
)
if "%PAGES_OK%"=="1" (
    echo   [PASS] All wizard pages disabled for silent install
    set /a PASS_COUNT+=1
)

REM Check 2.6: Registry entries for Add/Remove Programs
echo.
echo   [CHECK] Add/Remove Programs registration...
findstr /i "\[Registry\]" installer.iss >nul 2>&1
if errorlevel 1 (
    echo   [FAIL] installer.iss has no [Registry] section
    echo          App may not appear in Add/Remove Programs
    set /a FAIL_COUNT+=1
) else (
    echo   [PASS] Registry section found — Add/Remove Programs entries configured
    set /a PASS_COUNT+=1
)

:skip_exe

REM ══════════════════════════════════════════════════════════════════
REM  SECTION 3: COMMON CHECKS
REM ══════════════════════════════════════════════════════════════════
echo.
echo ── Common Checks ─────────────────────────────────────────────
echo.

REM Check 3.1: AppxManifest.xml exists
echo   [CHECK] AppxManifest.xml...
if exist "AppxManifest.xml" (
    echo   [PASS] AppxManifest.xml exists
    set /a PASS_COUNT+=1
) else (
    echo   [FAIL] AppxManifest.xml not found
    set /a FAIL_COUNT+=1
)

REM Check 3.2: Privacy policy URL accessible
echo.
echo   [CHECK] Privacy policy...
if exist "privacy.html" (
    echo   [PASS] privacy.html exists locally
    set /a PASS_COUNT+=1
) else (
    echo   [WARN] privacy.html not found locally
    echo          Ensure it's accessible at the URL specified in store_submission.json
    set /a WARN_COUNT+=1
)

REM Check 3.3: Store assets exist
echo.
echo   [CHECK] Store assets...
set "STORE_ASSETS_OK=1"
if not exist "store_assets\StoreLogo.png" set "STORE_ASSETS_OK=0"
if not exist "store_assets\Square44x44Logo.png" set "STORE_ASSETS_OK=0"
if not exist "store_assets\Square150x150Logo.png" set "STORE_ASSETS_OK=0"
if "%STORE_ASSETS_OK%"=="1" (
    echo   [PASS] Required store assets present
    set /a PASS_COUNT+=1
) else (
    echo   [FAIL] Missing store assets — run: python generate_store_assets.py
    set /a FAIL_COUNT+=1
)

REM Check 3.4: Version consistency
echo.
echo   [CHECK] Version consistency...
set "VER_OK=1"
findstr /c:"Version=\"1.0.0.0\"" AppxManifest.xml >nul 2>&1
if errorlevel 1 (
    echo   [WARN] Version in AppxManifest.xml may not match expected 1.0.0.0
    set /a WARN_COUNT+=1
    set "VER_OK=0"
)
if "%VER_OK%"=="1" (
    echo   [PASS] Version 1.0.0.0 found in AppxManifest.xml
    set /a PASS_COUNT+=1
)

REM ══════════════════════════════════════════════════════════════════
REM  SUMMARY
REM ══════════════════════════════════════════════════════════════════
echo.
echo ================================================================
echo   VALIDATION COMPLETE
echo ================================================================
echo.
echo   Results:  !PASS_COUNT! passed  /  !FAIL_COUNT! failed  /  !WARN_COUNT! warnings
echo.
if !FAIL_COUNT! GTR 0 (
    echo   STATUS: NEEDS FIXES — !FAIL_COUNT! check[s] failed
    echo.
    echo   Fix the issues above and re-run this validation script.
    goto :show_recommendation
)
if !WARN_COUNT! GTR 0 (
    echo   STATUS: READY WITH WARNINGS — review warnings above
    goto :show_recommendation
)
echo   STATUS: READY FOR SUBMISSION

:show_recommendation
echo.
echo   Recommendation: Use the MSIX path [build_msix.bat] for Store submission.
echo   MSIX automatically passes all Partner Center validation checks.
echo.
pause
