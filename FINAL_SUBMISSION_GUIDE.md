# FILECP - Microsoft Store Final Submission Guide

**Status:** ✅ READY FOR SUBMISSION  
**Date:** April 22, 2026  
**Version:** 1.0.0.0

---

## 📦 SUBMISSION PACKAGE CONTENTS

### ✅ Ready to Upload
```
dist/filecp.msix                                    67.75 MB ✓
  ├─ filecp.exe (app executable)
  ├─ AppxManifest.xml (app metadata)
  ├─ Assets/ (all store logos and icons)
  └─ All dependencies bundled
```

### ✅ Store Listing Ready
```
ReadyForStoreImport/
├─ Store listing FILECP Wed, 22 Apr 2026 16_36_54 GMT .csv  ✓
├─ MainLogo_1080.png (1080x1080)                            ✓
└─ Screenshot1.png (1366x768)                               ✓
```

### App Details Confirmed
```
Product Name:        FILECP
Publisher:          CN=filecp (Partner Center will update)
Version:            1.0.0.0
Company:            Simar Singh Rayat
Copyright:          Copyright (c) 2026 Simar Singh Rayat
Description:        Instant, Private, and Seamless File Sharing
```

---

## 🚀 SUBMISSION STEPS (Follow in Order)

### STEP 1: Verify Partner Center Account
1. Go to https://partner.microsoft.com/dashboard
2. Sign in with your Microsoft account
3. Locate or create your FILECP app submission
4. Note your **Publisher ID** (looks like: `CN=XXXXX`)

### STEP 2: Update AppxManifest.xml (CRITICAL)
**Only do this if you haven't already registered the app identity:**

Before final submission, Partner Center requires you to update the manifest with your unique identity.

**Location:** `AppxManifest.xml` (root of project)

1. From Partner Center, copy your Publisher CN value
2. Update these lines in AppxManifest.xml:

```xml
<Identity
  Name="filecp"
  Publisher="CN=<YOUR_PUBLISHER_ID_HERE>"
  Version="1.0.0.0"
  ProcessorArchitecture="x64" />

<Properties>
  <DisplayName>FILECP</DisplayName>
  <PublisherDisplayName>Your Company Name</PublisherDisplayName>
```

3. Save the file
4. Rebuild the MSIX:
```batch
build_msix.bat
```

### STEP 3: Upload MSIX Package
1. In Partner Center, go to **Packages** section
2. Click **Upload new package**
3. Select `dist/filecp.msix` (67.75 MB)
4. Partner Center will validate and automatically sign it
5. Wait for upload to complete

### STEP 4: Fill Store Listing (Choose One Method)

**Method A: Import CSV (Recommended)**
1. Go to **Store listings** section
2. Click **Import listing**
3. Upload folder: Select `ReadyForStoreImport/`
4. Confirm upload

**Method B: Manual Entry**
1. Go to **Store listings** section
2. Fill in manually:
   - **Product name:** FILECP
   - **Description:** [Full description from CSV]
   - **Short description:** "Instant, Private, and Seamless File Sharing"
   - **Upload logo:** `ReadyForStoreImport/MainLogo_1080.png`
   - **Upload screenshot:** `ReadyForStoreImport/Screenshot1.png`
   - **Search terms:** file sharing, qr code, transfer, etc.

### STEP 5: Complete Submission Form
1. **App category:** Utilities
2. **Pricing:** Free (or your choice)
3. **Age rating:** Complete the age questionnaire
4. **Content descriptors:** Check as appropriate
5. **Review policies:** Accept Microsoft Store policies
6. **Hardware requirements:** Windows 10/11 64-bit (specified in manifest)
7. **System requirements:** Edge WebView2 Runtime (included in Windows 10+)

### STEP 6: Submit for Certification
1. Review all entered information
2. Click **Submit for Store** (or similar button)
3. Wait for confirmation

### STEP 7: Monitor Certification
1. Go to **Submission status** page
2. Expected timeline: **24–48 hours**
3. You'll receive email notification when:
   - ✅ Certification passes
   - ⚠️ Issues found (review partner center for details)
4. Once approved, app goes live in Microsoft Store

---

## ⚠️ COMMON ISSUES & SOLUTIONS

### Issue: "Publisher identity does not match"
**Solution:** Update AppxManifest.xml with your Partner Center Publisher ID and rebuild with `build_msix.bat`

### Issue: "Screenshots incorrect size"
**Solution:** Already resolved. Screenshot is 1366×768 (minimum requirement met)

### Issue: "Logo incorrect dimensions"
**Solution:** Already resolved. Logo is 1080×1080 (compliant with Store requirements)

### Issue: "Code signature invalid"
**Solution:** MSIX packages don't need pre-signing. Partner Center re-signs automatically during ingestion.

### Issue: Submission rejected after upload
1. Download certification report from Partner Center
2. Review failure reasons
3. Fix issues in AppxManifest.xml or CSV
4. Rebuild: `build_msix.bat`
5. Re-upload: `dist/filecp.msix`

---

## 📋 PRE-SUBMISSION CHECKLIST

- [ ] MSIX package created: `dist/filecp.msix` (67.75 MB)
- [ ] AppxManifest.xml has correct Publisher ID from Partner Center
- [ ] Store listing CSV is valid UTF-8
- [ ] Logo is 1080×1080 pixels
- [ ] Screenshot is 1366×768 or larger
- [ ] Product name is "FILECP" (reserved)
- [ ] Description and features filled in
- [ ] Privacy policy URL ready (if required)
- [ ] Age rating completed
- [ ] Partner Center account created
- [ ] Publisher ID obtained and documented

---

## 🎯 WHAT TO UPLOAD WHERE

| What | Where | File |
|------|-------|------|
| **MSIX Package** | Packages section | `dist/filecp.msix` |
| **Store Listing** | Store listings → Import | `ReadyForStoreImport/` folder |
| **Logo** | Auto-imported or manual | `ReadyForStoreImport/MainLogo_1080.png` |
| **Screenshot** | Auto-imported or manual | `ReadyForStoreImport/Screenshot1.png` |

---

## 📁 FILE LOCATIONS (For Quick Reference)

```
C:\Users\Simar Singh Rayat\OneDrive\Documents\GitHub\FILECP_APP\
├─ dist/filecp.msix                         ← UPLOAD TO PACKAGES
├─ ReadyForStoreImport/                     ← UPLOAD TO STORE LISTINGS
│  ├─ Store listing FILECP...csv
│  ├─ MainLogo_1080.png
│  └─ Screenshot1.png
├─ AppxManifest.xml                         ← UPDATE WITH PUBLISHER ID
├─ build_msix.bat                           ← RUN IF UPDATING MANIFEST
└─ FINAL_SUBMISSION_GUIDE.md                ← THIS FILE
```

---

## 🔗 RESOURCES

- **Microsoft Partner Center:** https://partner.microsoft.com/dashboard
- **MSIX Documentation:** https://docs.microsoft.com/en-us/windows/msix/
- **Store Policies:** https://docs.microsoft.com/en-us/windows/apps/publish/microsoft-store-policies
- **Submission FAQ:** https://docs.microsoft.com/en-us/windows/apps/publish/

---

## 📞 SUPPORT

If you encounter issues:
1. Check the certification report in Partner Center
2. Review this guide's "Common Issues" section
3. Visit Microsoft Store Policy documentation
4. Contact Microsoft Partner Support through Partner Center dashboard

---

**FINAL STATUS:** ✅ ALL COMPONENTS READY  
**NEXT ACTION:** Follow STEP 1 above in Partner Center

---

*Generated: April 22, 2026*  
*FILECP v1.0.0.0*
