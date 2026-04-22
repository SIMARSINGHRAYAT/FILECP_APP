# filecp

**Instant, Private, and Seamless File Sharing.**

A lightweight Windows desktop application for secure session-based file sharing across devices. Upload files on one device, scan a QR code, and download them on another — no accounts, no tracking, just transfer.

---

## Download

Grab the latest **[filecp.exe](dist/filecp.exe)** from the `dist/` folder and run it. No installation required.

### System Requirements

- Windows 10/11 (64-bit)
- Microsoft Edge WebView2 Runtime (pre-installed on Windows 10 1809+ and all Windows 11)

---

## Features

- **QR Code Pairing** — Scan to instantly share files between devices
- **Encrypted Transfer** — Files are encrypted at rest on the server
- **Auto-Expiry** — Sessions self-destruct after your chosen duration (1–1440 min)
- **Send & Receive** — Upload files or generate a QR code to receive files
- **Multi-Format** — Images, documents, videos, archives, anything
- **No Login Required** — Zero accounts, start sharing immediately
- **Desktop Downloads** — Files save directly to your Downloads folder with Explorer confirmation
- **Single .exe** — Portable, no installation needed

---

## How It Works

1. Open `filecp.exe`
2. Choose **Send** to upload files and get a QR code, or **Receive** to get a QR code others scan to send you files
3. Scan the QR code on your phone or another device
4. Files transfer via the cloud and download to your `Downloads` folder

---

## Build from Source

### Prerequisites

- Python 3.10+ with pip
- Windows 10/11

### Steps

```bash
# Install dependencies
pip install pywebview requests pyinstaller Pillow

# Generate icon
python generate_icon.py

# Build .exe
pyinstaller filecp.spec --noconfirm --clean
```

Or simply run:

```
build.bat
```

The output is `dist\filecp.exe`.

---

## Microsoft Store Submission

filecp supports two submission formats. **MSIX is strongly recommended** as it automatically resolves all Partner Center validation requirements.

### Option A: MSIX Package (Recommended)

MSIX is the preferred format because it automatically handles:
- ✅ Silent installation (no UI)
- ✅ Add/Remove Programs registration
- ✅ Bundleware compliance (sandboxed)
- ✅ Code signing (Microsoft re-signs during ingestion — no certificate purchase needed)

**Steps:**

1. **Install the [Windows 10 SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/)** (provides `makeappx.exe`)
2. **Register** at [Partner Center](https://partner.microsoft.com/) ($19 one-time for individuals)
3. **Reserve your app name** in Partner Center
4. **Update `AppxManifest.xml`** with your Identity Name and Publisher from Partner Center:
   ```xml
   <Identity
     Name="YOUR_IDENTITY_FROM_PARTNER_CENTER"
     Publisher="CN=YOUR_PUBLISHER_FROM_PARTNER_CENTER"
     Version="1.0.0.0"
     ProcessorArchitecture="x64" />
   ```
5. **Build the MSIX package:**
   ```
   build_msix.bat
   ```
6. **Upload** `dist\filecp.msix` to Partner Center (unsigned is fine — Microsoft re-signs it)
7. **Fill in Store listing:** description, screenshots (1366×768 minimum), privacy policy URL
8. **Submit for certification** (typically 1–3 business days)

### Option B: EXE Installer (Alternative)

Use this only if you specifically need an EXE installer submission.

> ⚠️ **Requires a CA-trusted SHA256 code signing certificate** (~$200-400/year). Self-signed certificates are NOT accepted for EXE submissions.

**Steps:**

1. **Install [Inno Setup 6](https://jrsoftware.org/isdl.php)**
2. **Purchase a code signing certificate** (DigiCert, Sectigo, etc.) or use [Azure Trusted Signing](https://learn.microsoft.com/en-us/azure/trusted-signing/)
3. **Build:**
   ```
   build_store.bat
   ```
4. **Host** `dist\filecp_setup.exe` at a public URL
5. **In Partner Center**, choose **Win32 Package** and provide:
   - Package URL: `https://github.com/SIMARSINGHRAYAT/FILECP_APP/releases/download/v1.0.0/filecp_setup.exe`
   - Silent install params: `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART`

### Validate Before Submission

Run the validation script to verify all Store requirements are met:

```
validate_store.bat
```

This checks:
- MSIX package integrity and contents
- Silent install compliance (Policy 10.2.9)
- Add/Remove Programs registration
- Digital signature status
- Required assets and manifest validity

### Troubleshooting Store Validation

| Validation Error | Cause | Fix |
|---|---|---|
| Silent install check failed | Installer shows UI during silent install | Use MSIX (inherently silent) or verify `installer.iss` has all `DisableXxxPage=yes` directives |
| Add/Remove Programs not found | App not registered in A/RP | Use MSIX (automatic) or verify `[Registry]` section in `installer.iss` |
| Bundleware check failed | Same as A/RP issue | Same fix as above |
| Code sign check failed | No digital signature | Use MSIX (Partner Center signs) or purchase CA-trusted SHA256 cert |

---

### Development Mode

```
dev.bat
```

Launches the app with DevTools enabled (right-click → Inspect).

---

## Project Structure

```
filecp/
├── main.py                  # Desktop app entry point (pywebview + download bridge)
├── app.py                   # FastAPI backend (web/server deployment + privacy policy)
├── AppxManifest.xml         # MSIX package manifest for Microsoft Store
├── filecp.spec              # PyInstaller build configuration
├── version_info.txt         # Windows exe metadata (file properties)
├── installer.iss            # Inno Setup installer script (Store Policy 10.2.9 compliant)
├── generate_icon.py         # Generates icon.ico from icons/ PNGs
├── generate_store_assets.py # Generates all Microsoft Store image assets
├── sign_exe.py              # Code signing helper utility
├── privacy.html             # Privacy policy page (for GitHub Pages / Partner Center)
├── build.bat                # One-click production build (.exe)
├── build_msix.bat           # Build MSIX package for Microsoft Store (RECOMMENDED)
├── build_store.bat          # Build signed EXE installer for Microsoft Store
├── validate_store.bat       # Validate package against Store requirements
├── dev.bat                  # Development mode launcher
├── store_submission.json    # Store listing metadata + submission guide
├── store_listing.csv        # Store listing fields reference
├── requirements.txt         # Python dependencies
├── render.yaml              # Render.com deployment config (web version)
├── icons/                   # Source icon PNGs
│   ├── icon16.png
│   ├── icon48.png
│   └── icon128.png
├── assets/
│   └── icon.ico             # Generated multi-resolution icon
├── store_assets/            # Generated Store images (by generate_store_assets.py)
└── dist/
    ├── filecp.exe           # Built application
    ├── filecp_setup.exe     # Inno Setup installer (for EXE submission)
    └── filecp.msix          # Microsoft Store MSIX package (RECOMMENDED)
```

---

## Privacy Policy

See [privacy.html](privacy.html) or visit the [hosted version](https://simarsinghrayat.github.io/Window_app_filecp/privacy.html).

---

## License

MIT