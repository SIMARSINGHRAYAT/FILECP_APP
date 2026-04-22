"""Generate icon.ico from the icons/ folder PNGs (run once)."""
from PIL import Image
from pathlib import Path

icons_dir = Path("icons")
assets_dir = Path("assets")
assets_dir.mkdir(exist_ok=True)

# Load the source PNGs
source_files = sorted(icons_dir.glob("icon*.png"))
if not source_files:
    raise FileNotFoundError("No icon PNGs found in icons/")

# Use the largest source as base and resize to all standard ICO sizes
base = Image.open(max(source_files, key=lambda f: Image.open(f).size[0]))
base = base.convert("RGBA")

sizes = [16, 24, 32, 48, 64, 128, 256]
images = []
for sz in sizes:
    img = base.resize((sz, sz), Image.LANCZOS)
    images.append(img)

images[0].save(
    assets_dir / "icon.ico",
    format="ICO",
    sizes=[(s, s) for s in sizes],
    append_images=images[1:],
)
print(f"Created {assets_dir / 'icon.ico'} from {[f.name for f in source_files]}")
