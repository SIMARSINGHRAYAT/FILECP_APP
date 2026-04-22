@echo off
REM ─────────────────────────────────────────────────────────────
REM  filecp — Build Production .exe
REM  Packages the app into dist\filecp.exe using PyInstaller.
REM ─────────────────────────────────────────────────────────────
echo.
echo ============================================
echo   filecp — Building Windows Desktop App
echo ============================================
echo.

REM Ensure dependencies are installed
echo [1/4] Installing dependencies...
pip install pywebview requests pyinstaller Pillow --quiet
if errorlevel 1 (
    echo ERROR: Failed to install dependencies.
    pause
    exit /b 1
)

REM Generate icon from PNGs
echo [2/4] Generating icon...
python generate_icon.py
if errorlevel 1 (
    echo WARNING: Icon generation failed, using existing icon.
)

REM Build with PyInstaller
echo [3/4] Building executable...
pyinstaller filecp.spec --noconfirm --clean
if errorlevel 1 (
    echo ERROR: PyInstaller build failed.
    pause
    exit /b 1
)

echo.
echo [4/4] Build complete!
echo.
echo   Output:  dist\filecp.exe
echo   Size:    
for %%A in (dist\filecp.exe) do echo            %%~zA bytes
echo.
echo   To run:  double-click dist\filecp.exe
echo.
pause
