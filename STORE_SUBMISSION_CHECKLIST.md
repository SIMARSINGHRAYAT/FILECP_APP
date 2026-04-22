# FILECP - Microsoft Store Submission Checklist

## ✅ COMPLETED STEPS

### 1. Store Listing CSV
- [x] CSV file created: `Store listing FILECP Wed, 22 Apr 2026 16_36_54 GMT .csv`
- [x] Encoding: UTF-8 with BOM (valid for Partner Center)
- [x] ProductName: `FILECP` (matches reserved app name)
- [x] Description: Complete with features and details
- [x] StoreLogos1: `MainLogo_1080.png` (1080x1080 - compliant)
- [x] Screenshots1: `Screenshot1.png` (1366x768)
- [x] Location: `ReadyForStoreImport/` root folder

### 2. Media Assets
- [x] Main Logo: 1080x1080 pixels (compliant with Store requirements)
- [x] Screenshot: 1366x768 pixels (minimum dimension met)
- [x] Both files in same folder as CSV for easy reference

---

## ⚠️ BLOCKING ISSUES - MUST COMPLETE

### 3. EXE Signing Status
**CURRENT:** `filecp.exe` is **NOT SIGNED** (Status: NotSigned)
**REQUIRED:** Digital signature from trusted Certificate Authority

#### Option A: Create & Submit MSIX Package (RECOMMENDED ⭐)
Partner Center will automatically sign your MSIX with Microsoft's certificate.

```batch
build_msix.bat
```

This will:
1. Package your app as `.msix` format
2. Include all necessary manifests and assets
3. Create `dist\filecp.msix`
4. Partner Center will handle signing during ingestion

**Then upload:** `dist\filecp.msix` to Partner Center

#### Option B: Sign EXE with Code-Signing Certificate (Advanced)
Requires: Valid code-signing certificate in PFX format

```batch
python sign_exe.py filecp.exe path\to\certificate.pfx password
```

**Note:** You will need to obtain a code-signing certificate from a trusted CA (requires payment).

---

## 🔍 VALIDATION STEPS

Once you have signed the EXE or created the MSIX, run validation:

```batch
validate_store.bat msix
```

Or for EXE:
```batch
validate_store.bat exe
```

This checks:
- [x] Package structure validity
- [x] Required assets present
- [x] Manifest configuration
- [x] Digital signature (if present)
- [x] Add/Remove Programs compatibility

---

## 📋 FINAL SUBMISSION STEPS

1. **Choose your path:**
   - [ ] MSIX (Recommended): Run `build_msix.bat` → validates with `validate_store.bat msix` → upload `.msix`
   - [ ] EXE + Code-Signing: Obtain PFX certificate → sign with `sign_exe.py` → run `validate_store.bat exe` → upload

2. **Upload to Partner Center:**
   - Go to Partner Center → Your App → Store listing
   - For MSIX: Use Store submission flow → upload `dist\filecp.msix`
   - For signed EXE: Use Store submission flow → upload `filecp.exe`
   - Partner Center will re-run certification checks

3. **Verify CSV Import:**
   - Still have `ReadyForStoreImport/` folder ready
   - May need to import listing separately if not part of submission

4. **Monitor Certification:**
   - Partner Center will run full validation
   - Check certification report for any failures
   - Address any new issues and resubmit

---

## 📁 CURRENT FILE STATUS

```
ReadyForStoreImport/
├── Store listing FILECP Wed, 22 Apr 2026 16_36_54 GMT .csv  [✓ Valid UTF-8]
├── MainLogo_1080.png                                         [✓ 1080x1080]
├── Screenshot1.png                                           [✓ 1366x768]
├── MainLogo.png                                              [backup]
└── media/                                                     [backup folder]
```

---

## 🚀 NEXT ACTION

**Choose ONE path:**

1. **MSIX (Recommended):**
   ```batch
   build_msix.bat
   validate_store.bat msix
   ```

2. **Code-Signed EXE (if you have PFX certificate):**
   ```batch
   python sign_exe.py filecp.exe your_cert.pfx your_password
   validate_store.bat exe
   ```

---

## 📞 Resources

- Microsoft Store Partner Center: https://partner.microsoft.com/
- MSIX Overview: https://learn.microsoft.com/en-us/windows/msix/
- Code Signing: https://learn.microsoft.com/en-us/windows/win32/seccrypto/

---

**Last Updated:** 2026-04-22  
**Status:** Ready for EXE signing or MSIX packaging
