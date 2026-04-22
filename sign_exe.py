"""
Sign a PE executable with a self-signed SHA256 certificate (Authenticode).
Uses the Windows CryptAPI via ctypes to perform proper Authenticode signing.

Usage: python sign_exe.py <exepath> <pfxpath> <password>
"""
import ctypes
import ctypes.wintypes
import sys
import struct
from pathlib import Path

# Windows Crypto API constants
CERT_STORE_PROV_FILENAME_W = 2
CERT_STORE_OPEN_EXISTING_FLAG = 0x00004000
CERT_CLOSE_STORE_FORCE_FLAG = 1
X509_ASN_ENCODING = 0x00000001
PKCS_7_ASN_ENCODING = 0x00010000
ENCODING = X509_ASN_ENCODING | PKCS_7_ASN_ENCODING
CERT_FIND_ANY = 0
CERT_STORE_PROV_PKCS12 = ctypes.c_char_p(b"PKCS12")

# SignerSign
SPC_EXC_PE_PAGE_HASHES_FLAG = 0x10
SPC_INC_PE_IMPORT_ADDR_TABLE_FLAG = 0x20
SPC_INC_PE_DEBUG_INFO_FLAG = 0x40
SPC_INC_PE_RESOURCES_FLAG = 0x80

crypt32 = ctypes.windll.crypt32
kernel32 = ctypes.windll.kernel32


def sign_with_signtool_from_sdk():
    """Try to find and use signtool from any installed SDK."""
    import glob
    patterns = [
        r"C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe",
        r"C:\Program Files\Windows Kits\10\bin\*\x64\signtool.exe",
    ]
    for pattern in patterns:
        matches = sorted(glob.glob(pattern), reverse=True)
        if matches:
            return matches[0]
    return None


def sign_with_powershell(exe_path, pfx_path, password):
    """Sign using PowerShell as a fallback."""
    import subprocess
    # Use signtool from NuGet package
    result = subprocess.run([
        "powershell", "-Command",
        f"""
        $nugetDir = "$env:TEMP\\signtool_nuget"
        if (-not (Test-Path "$nugetDir\\Microsoft.Windows.SDK.BuildTools*\\bin\\*\\x64\\signtool.exe")) {{
            New-Item -ItemType Directory -Path $nugetDir -Force | Out-Null
            Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "$nugetDir\\nuget.exe"
            & "$nugetDir\\nuget.exe" install Microsoft.Windows.SDK.BuildTools -OutputDirectory $nugetDir -NonInteractive
        }}
        $signtool = Get-ChildItem "$nugetDir" -Recurse -Filter "signtool.exe" | Where-Object {{ $_.FullName -like "*x64*" }} | Select-Object -First 1 -ExpandProperty FullName
        if ($signtool) {{
            & $signtool sign /fd SHA256 /f "{pfx_path}" /p "{password}" /t http://timestamp.digicert.com "{exe_path}"
        }} else {{
            throw "signtool not found"
        }}
        """
    ], capture_output=True, text=True, timeout=120)
    return result.returncode == 0, result.stdout + result.stderr


def main():
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <exe_path> <pfx_path> <password>")
        sys.exit(1)

    exe_path = sys.argv[1]
    pfx_path = sys.argv[2]
    password = sys.argv[3]

    # Try SDK signtool first
    signtool = sign_with_signtool_from_sdk()
    if signtool:
        import subprocess
        result = subprocess.run([
            signtool, "sign",
            "/fd", "SHA256",
            "/f", pfx_path,
            "/p", password,
            "/t", "http://timestamp.digicert.com",
            exe_path
        ], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"Signed {exe_path} with SDK signtool")
            return
        print(f"SDK signtool failed: {result.stderr}")

    # Try NuGet signtool
    print("Downloading signtool via NuGet...")
    ok, output = sign_with_powershell(exe_path, pfx_path, password)
    if ok:
        print(f"Signed {exe_path} via NuGet signtool")
    else:
        print(f"Signing failed: {output}")
        sys.exit(1)


if __name__ == "__main__":
    main()
