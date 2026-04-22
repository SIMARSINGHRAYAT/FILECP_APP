# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec file for filecp desktop application.
Build with:  pyinstaller filecp.spec
"""

from PyInstaller.utils.hooks import collect_data_files
import os

# Only pywebview + its Edge WebView2 backend + requests needed
hidden_imports = [
    "webview",
    "clr",
    "pythonnet",
    "requests",
    "urllib3",
    "certifi",
    "charset_normalizer",
    "idna",
]

datas = [
    ("assets", "assets"),
    ("icons", "icons"),
]
# Include certifi CA bundle so HTTPS requests work in frozen mode
datas += collect_data_files("certifi")

# Determine icon path with fallback
icon_path = os.path.join("assets", "icon.ico")
if not os.path.exists(icon_path):
    icon_path = None  # PyInstaller will use default icon

a = Analysis(
    ["main.py"],
    pathex=[],
    binaries=[],
    datas=datas,
    hiddenimports=hidden_imports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        "PyQt5", "PyQt6", "PySide2", "PySide6",
        "matplotlib", "numpy", "pandas", "scipy", "sklearn",
        "IPython", "notebook", "nbformat", "nbconvert",
        "sphinx", "docutils", "black", "yapf",
        "tkinter", "_tkinter", "zmq",
        "test", "unittest",
        "uvicorn", "fastapi", "starlette",
        "qrcode", "cryptography",
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name="filecp",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,            # No console window in production
    disable_windowed_traceback=False,
    icon=icon_path,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    version="version_info.txt",
)
