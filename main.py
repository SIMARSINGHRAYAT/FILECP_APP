#!/usr/bin/env python3
"""
filecp Desktop Application
Opens a native desktop window that loads the hosted web app.
Injects JS on every page load to override downloads so files save to the
user's Downloads folder and Explorer opens with the file selected.
"""

import os
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

import requests
import webview

BACKEND_URL = "https://flitto.onrender.com"

# JavaScript injected after every page load.
# It waits for pywebview.api to be ready, then replaces the download functions.
INJECT_JS = """
(function() {
    function waitForApi(cb) {
        if (window.pywebview && window.pywebview.api) { cb(); return; }
        var t = setInterval(function() {
            if (window.pywebview && window.pywebview.api) { clearInterval(t); cb(); }
        }, 100);
    }

    waitForApi(function() {
        // Override single-file download
        window.dlFile = async function(fn) {
            try {
                var sid = window.SESSION_ID || window.location.pathname.split('/').pop().toUpperCase();
                var url = '/api/download/' + sid + '/' + fn;
                var filename = decodeURIComponent(fn);
                if (typeof showToast === 'function') showToast('Downloading ' + filename + '...', 'info');
                var result = await window.pywebview.api.download_file(url, filename);
                if (result && result.startsWith('ERROR:')) {
                    if (typeof showToast === 'function') showToast('Download failed', 'error');
                } else {
                    if (typeof showToast === 'function') showToast('Saved to Downloads folder', 'success');
                }
            } catch(e) {
                if (typeof showToast === 'function') showToast('Download failed', 'error');
            }
        };

        // Override download-all
        window.downloadAll = async function() {
            try {
                var sid = window.SESSION_ID || window.location.pathname.split('/').pop().toUpperCase();
                var url = '/api/download-all/' + sid;
                var filename = 'filecp_' + sid + '.zip';
                if (typeof showToast === 'function') showToast('Downloading all files...', 'info');
                var result = await window.pywebview.api.download_file(url, filename);
                if (result && result.startsWith('ERROR:')) {
                    if (typeof showToast === 'function') showToast('Download failed', 'error');
                } else {
                    if (typeof showToast === 'function') showToast('Saved to Downloads folder', 'success');
                }
            } catch(e) {
                if (typeof showToast === 'function') showToast('Download failed', 'error');
            }
        };

        console.log('[filecp-desktop] Download functions patched');
    });
})();
"""


def get_downloads_folder() -> Path:
    downloads = Path.home() / "Downloads"
    downloads.mkdir(exist_ok=True)
    return downloads


class Api:
    """Exposed to JavaScript via pywebview's js_api."""

    def __init__(self):
        self.downloads = get_downloads_folder()

    def download_file(self, url: str, filename: str) -> str:
        """Download a file from the backend and save to Downloads folder."""
        try:
            full_url = BACKEND_URL + url
            resp = requests.get(full_url, timeout=120)
            resp.raise_for_status()

            safe_name = Path(unquote(filename)).name or "download"
            dest = self.downloads / safe_name

            # Avoid overwriting — append (1), (2), etc.
            counter = 1
            stem, suffix = dest.stem, dest.suffix
            while dest.exists():
                dest = self.downloads / f"{stem} ({counter}){suffix}"
                counter += 1

            dest.write_bytes(resp.content)

            # Open Explorer with the downloaded file selected
            subprocess.Popen(
                ["explorer", "/select,", str(dest)],
                creationflags=subprocess.CREATE_NO_WINDOW,
            )

            return str(dest)
        except Exception as e:
            return f"ERROR: {e}"


def resource_path(relative: str) -> str:
    if getattr(sys, "_MEIPASS", None):
        return os.path.join(sys._MEIPASS, relative)
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), relative)


def on_loaded(window):
    """Called every time a page finishes loading — inject download overrides."""
    window.evaluate_js(INJECT_JS)


def main():
    api = Api()

    window = webview.create_window(
        title="filecp — File Sharing",
        url=BACKEND_URL,
        width=1100,
        height=750,
        min_size=(800, 550),
        resizable=True,
        text_select=True,
        js_api=api,
    )

    window.events.loaded += lambda: on_loaded(window)

    webview.start(
        debug=os.environ.get("FILECP_DEBUG", "") == "1",
        gui="edgechromium",
    )


if __name__ == "__main__":
    main()
