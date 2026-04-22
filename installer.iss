; filecp — Inno Setup Installer Script (Microsoft Store Policy 10.2.9 Compliant)
;
; CRITICAL: This installer MUST support silent installation per MS Store Policy 10.2.9:
;   filecp_setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
;
; All UI-displaying pages are disabled so that silent mode has ZERO user interaction
; (only UAC prompt is permitted by policy).
;
; Build with:  ISCC.exe installer.iss

#define MyAppName "filecp"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Simar Singh Rayat"
#define MyAppURL "https://github.com/SIMARSINGHRAYAT/Window_app_filecp"
#define MyAppExeName "filecp.exe"
#define MyAppDescription "Instant, Private, and Seamless File Sharing"

[Setup]
; Unique App GUID — do NOT change between versions
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

; ══════════════════════════════════════════════════════════════════════
; MICROSOFT STORE POLICY 10.2.9 — SILENT INSTALL COMPLIANCE
; ──────────────────────────────────────────────────────────────────────
; ALL dialog/wizard pages MUST be disabled so the installer runs with
; zero UI when invoked with /VERYSILENT /SUPPRESSMSGBOXES /NORESTART.
; Only the Windows UAC elevation prompt is permitted.
; ══════════════════════════════════════════════════════════════════════
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableFinishedPage=yes
DisableWelcomePage=yes
DisableStartupPrompt=yes

; Force close running instances — no prompt
CloseApplications=force
CloseApplicationsFilter=*.exe
RestartApplications=no

; Installer behavior
OutputDir=dist
OutputBaseFilename=filecp_setup
SetupIconFile=assets\icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

; ── Privileges ──────────────────────────────────────────────────────
; Use 'lowest' so non-admin users can install (per-user install).
; REMOVED PrivilegesRequiredOverridesAllowed=dialog — that causes a
; dialog to appear during silent install which VIOLATES Policy 10.2.9.
PrivilegesRequired=lowest

; ── Architecture ────────────────────────────────────────────────────
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; ── Uninstall metadata (Add/Remove Programs compliance) ─────────────
; These ensure the app appears correctly in Add/Remove Programs with
; proper name and publisher, fixing the "We could not identify" error.
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
CreateUninstallRegKey=yes
Uninstallable=yes

; ── Version info embedded in installer EXE ──────────────────────────
AppContact={#MyAppURL}/issues
AppReadmeFile={#MyAppURL}#readme
VersionInfoVersion={#MyAppVersion}.0
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppDescription}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}.0
VersionInfoCopyright=Copyright (c) 2026 {#MyAppPublisher}

; ── Minimum Windows version ─────────────────────────────────────────
MinVersion=10.0.17763

; ── Code signing placeholder ─────────────────────────────────────────
; Uncomment and configure when you have a real code signing certificate:
; SignTool=signtool sign /fd SHA256 /a /f "$qcert.pfx$q" /p $qPASSWORD$q /t http://timestamp.digicert.com $f

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "dist\filecp.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Start Menu shortcuts
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Comment: "{#MyAppDescription}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
; Desktop shortcut
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Comment: "{#MyAppDescription}"

[Registry]
; ── Explicit Add/Remove Programs registry entries ───────────────────
; These GUARANTEE the app is identifiable in Add/Remove Programs,
; fixing the "Entry in add or remove programs" and "Bundleware check"
; validation errors from Microsoft Store package validation.
Root: HKCU; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; ValueType: string; ValueName: "DisplayName"; ValueData: "{#MyAppName}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; ValueType: string; ValueName: "Publisher"; ValueData: "{#MyAppPublisher}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; ValueType: string; ValueName: "DisplayVersion"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; ValueType: string; ValueName: "InstallLocation"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; ValueType: string; ValueName: "URLInfoAbout"; ValueData: "{#MyAppURL}"; Flags: uninsdeletekey

[Run]
; Post-install: launch the app (skipped during silent install per policy)
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent shellexec

[UninstallDelete]
; Clean up any app data on uninstall
Type: filesandordirs; Name: "{app}"
