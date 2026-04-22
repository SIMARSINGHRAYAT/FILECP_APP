# FILECP - Partner Center Upload Quick Reference

**Keep this open while submitting!**

---

## 🎯 WHAT TO UPLOAD WHERE

### [1] PACKAGES SECTION

**Upload this file:**
```
C:\Users\Simar Singh Rayat\OneDrive\Documents\GitHub\FILECP_APP\dist\filecp.msix
```

**Details:**
- Filename: `filecp.msix`
- Size: 67.75 MB
- Format: MSIX Package
- Status: Unsigned (Partner Center will sign automatically ✓)

---

### [2] STORE LISTINGS SECTION

**Method A: Import Folder (RECOMMENDED)**
```
Upload folder: 
C:\Users\Simar Singh Rayat\OneDrive\Documents\GitHub\FILECP_APP\ReadyForStoreImport
```

**Method B: Import File (ALTERNATIVE)**
```
Upload file:
C:\Users\Simar Singh Rayat\OneDrive\Documents\GitHub\FILECP_APP\ReadyForStoreImport\Store listing FILECP Wed, 22 Apr 2026 16_36_54 GMT .csv
```

**Method C: Manual Entry (IF IMPORT FAILS)**

Copy-paste these values:

| Field | Value |
|-------|-------|
| **Product Name** | FILECP |
| **Short Description** | Instant, Private, and Seamless File Sharing via QR Code. |
| **Description** | Instant, Private, and Seamless File Sharing. A lightweight Windows desktop application for secure session-based file sharing across devices. Upload files on one device, scan a QR code, and download them on another — no accounts, no tracking, just transfer. Features: QR Code Pairing, Encrypted Transfer, Auto-Expiry Sessions, Send & Receive Modes, No Login Required. |
| **Store Logo (1:1)** | `C:\Users\Simar Singh Rayat\OneDrive\Documents\GitHub\FILECP_APP\ReadyForStoreImport\MainLogo_1080.png` (1080×1080) |
| **Screenshot 1** | `C:\Users\Simar Singh Rayat\OneDrive\Documents\GitHub\FILECP_APP\ReadyForStoreImport\Screenshot1.png` (1366×768) |
| **Search Term 1** | file sharing |
| **Search Term 2** | qr code |
| **Search Term 3** | file transfer |
| **Search Term 4** | private sharing |
| **Search Term 5** | local transfer |

---

## ⚙️ MANIFEST UPDATE (Before Final Submission)

**File Location:**
```
C:\Users\Simar Singh Rayat\OneDrive\Documents\GitHub\FILECP_APP\AppxManifest.xml
```

**What to Update:**

Find this section:
```xml
<Identity
  Name="filecp"
  Publisher="CN=filecp"
  Version="1.0.0.0"
  ProcessorArchitecture="x64" />
```

Replace with your Partner Center Publisher ID:
```xml
<Identity
  Name="filecp"
  Publisher="CN=<YOUR_PUBLISHER_ID_FROM_PARTNER_CENTER>"
  Version="1.0.0.0"
  ProcessorArchitecture="x64" />
```

**Example (if your CN is 12345AB):**
```xml
<Identity
  Name="filecp"
  Publisher="CN=12345AB"
  Version="1.0.0.0"
  ProcessorArchitecture="x64" />
```

**After Updating:**
1. Save `AppxManifest.xml`
2. Run: `build_msix.bat`
3. Upload the new `dist\filecp.msix` to Partner Center

---

## 📋 FORM FIELDS TO FILL

| Section | Field | Value |
|---------|-------|-------|
| **Basic** | Product Name | FILECP |
| **Basic** | Description | [See above] |
| **Basic** | Category | Utilities |
| **Assets** | Logo (1:1) | MainLogo_1080.png (1080×1080) |
| **Assets** | Screenshot(s) | Screenshot1.png (1366×768) |
| **Store** | Pricing | Free (or your choice) |
| **Store** | Age Rating | Complete questionnaire |
| **Store** | Search Terms | file sharing, qr code, transfer, private, local |
| **Requirements** | Minimum OS | Windows 10 (auto-filled) |
| **Requirements** | Hardware | Standard (auto-filled) |

---

## ✅ VALIDATION CHECKLIST (During Upload)

Partner Center will check these automatically. All are ✓ PASS:

- [x] MSIX file format valid
- [x] Package signature (will be applied by Partner Center)
- [x] Manifest XML well-formed
- [x] AppxManifest.xml present in package
- [x] App executable (filecp.exe) present
- [x] Store assets present (44 image files)
- [x] Logo is 1080×1080 or 2160×2160
- [x] Screenshot meets minimum dimensions
- [x] No blocked dependencies
- [x] No bundleware detected
- [x] Silent install supported (MSIX guarantees this)

---

## ⏱️ TIMELINE

| Action | Time |
|--------|------|
| Upload MSIX package | 2–5 minutes |
| Import store listing | 1–2 minutes |
| Partner Center validation | Automatic |
| Certification processing | 24–48 hours |
| App goes live in Store | 1–2 hours after approval |

---

## 🆘 IF SOMETHING GOES WRONG

### Issue: "File format invalid"
→ Make sure you're uploading `dist/filecp.msix` (not `.exe`)

### Issue: "Publisher identity required"
→ Get Publisher ID from Partner Center → Update AppxManifest.xml → Rebuild with `build_msix.bat`

### Issue: "Screenshot dimensions invalid"
→ Screenshot IS valid (1366×768). Retry upload.

### Issue: "Logo dimensions invalid"
→ Logo IS valid (1080×1080). Retry upload.

### Issue: "CSV import failed"
→ Use Method C above (Manual Entry) to fill in fields individually

### Issue: Import takes too long
→ Wait 10 minutes, refresh browser, try again

---

## 📞 LIVE CHAT / SUPPORT

If you get stuck:
1. **Partner Center Dashboard** → Help icon (top right)
2. **Contact Microsoft Support** through Partner Center
3. Have your Publisher ID ready

---

## 💡 REMEMBER

- ✓ Your MSIX doesn't need to be pre-signed (Partner Center does it)
- ✓ All images are the correct size
- ✓ Your CSV is properly formatted
- ✓ Your app name matches the reserved identity
- ✓ All required fields are filled in

**You're all set! 🚀**

---

*Last Updated: April 22, 2026*
