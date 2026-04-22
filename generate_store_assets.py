"""
Generate all Microsoft Store required image assets from the source icon.
Run:  python generate_store_assets.py

Outputs go to store_assets/ (used by the MSIX packaging step).
"""

from pathlib import Path
from PIL import Image

ICONS_DIR = Path("icons")
OUTPUT_DIR = Path("store_assets")
OUTPUT_DIR.mkdir(exist_ok=True)

# ── Load best source icon ──────────────────────────────────────────
source_files = sorted(ICONS_DIR.glob("icon*.png"))
if not source_files:
    raise FileNotFoundError("No icon PNGs found in icons/")

base = Image.open(max(source_files, key=lambda f: Image.open(f).size[0]))
base = base.convert("RGBA")

# ── Required Store assets (name → width x height) ─────────────────
ASSETS = {
    # App tiles
    "Square44x44Logo.png": (44, 44),
    "Square44x44Logo.targetsize-16.png": (16, 16),
    "Square44x44Logo.targetsize-24.png": (24, 24),
    "Square44x44Logo.targetsize-32.png": (32, 32),
    "Square44x44Logo.targetsize-48.png": (48, 48),
    "Square44x44Logo.targetsize-256.png": (256, 256),
    "Square71x71Logo.png": (71, 71),
    "Square150x150Logo.png": (150, 150),
    "Wide310x150Logo.png": (310, 150),
    "LargeTile.png": (310, 310),
    "StoreLogo.png": (50, 50),
    "SplashScreen.png": (620, 300),

    # Scaled variants (Windows scales these for different DPI)
    "Square44x44Logo.scale-100.png": (44, 44),
    "Square44x44Logo.scale-125.png": (55, 55),
    "Square44x44Logo.scale-150.png": (66, 66),
    "Square44x44Logo.scale-200.png": (88, 88),
    "Square44x44Logo.scale-400.png": (176, 176),
    "Square71x71Logo.scale-100.png": (71, 71),
    "Square71x71Logo.scale-125.png": (89, 89),
    "Square71x71Logo.scale-150.png": (107, 107),
    "Square71x71Logo.scale-200.png": (142, 142),
    "Square71x71Logo.scale-400.png": (284, 284),
    "Square150x150Logo.scale-100.png": (150, 150),
    "Square150x150Logo.scale-125.png": (188, 188),
    "Square150x150Logo.scale-150.png": (225, 225),
    "Square150x150Logo.scale-200.png": (300, 300),
    "Square150x150Logo.scale-400.png": (600, 600),
    "Wide310x150Logo.scale-100.png": (310, 150),
    "Wide310x150Logo.scale-125.png": (388, 188),
    "Wide310x150Logo.scale-150.png": (465, 225),
    "Wide310x150Logo.scale-200.png": (620, 300),
    "Wide310x150Logo.scale-400.png": (1240, 600),
    "LargeTile.scale-100.png": (310, 310),
    "LargeTile.scale-125.png": (388, 388),
    "LargeTile.scale-150.png": (465, 465),
    "LargeTile.scale-200.png": (620, 620),
    "LargeTile.scale-400.png": (1240, 1240),
    "StoreLogo.scale-100.png": (50, 50),
    "StoreLogo.scale-125.png": (63, 63),
    "StoreLogo.scale-150.png": (75, 75),
    "StoreLogo.scale-200.png": (100, 100),
    "StoreLogo.scale-400.png": (200, 200),
    "SplashScreen.scale-100.png": (620, 300),
    "SplashScreen.scale-125.png": (775, 375),
    "SplashScreen.scale-150.png": (930, 450),
    "SplashScreen.scale-200.png": (1240, 600),
    "SplashScreen.scale-400.png": (2480, 1200),
}

# Background colour for padding (matches AppxManifest BackgroundColor)
BG_COLOR = (26, 26, 46, 255)  # #1a1a2e


def generate_asset(name: str, width: int, height: int) -> None:
    """Generate a single asset, centering the icon on the canvas."""
    canvas = Image.new("RGBA", (width, height), BG_COLOR)

    # Fit icon within 70% of the smaller dimension (padding around icon)
    icon_max = int(min(width, height) * 0.7)
    icon = base.resize((icon_max, icon_max), Image.LANCZOS)

    x = (width - icon_max) // 2
    y = (height - icon_max) // 2
    canvas.paste(icon, (x, y), icon)

    canvas.save(OUTPUT_DIR / name, format="PNG")


# ── Generate all ───────────────────────────────────────────────────
for name, (w, h) in ASSETS.items():
    generate_asset(name, w, h)
    print(f"  ✓ {name} ({w}×{h})")

print(f"\nGenerated {len(ASSETS)} assets in {OUTPUT_DIR}/")
