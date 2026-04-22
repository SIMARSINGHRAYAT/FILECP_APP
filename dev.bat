@echo off
REM ─────────────────────────────────────────────────────────────
REM  filecp — Development Mode Launcher
REM  Starts the desktop app with debug tools enabled.
REM ─────────────────────────────────────────────────────────────
echo [filecp] Starting in development mode...
echo [filecp] Right-click in the window to open DevTools.
set FILECP_DEBUG=1
python main.py
