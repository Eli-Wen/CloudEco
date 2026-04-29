import base64
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
IMAGE_PATH = BASE_DIR / "test_assets" / "image0.jpeg"

with open(IMAGE_PATH, "rb") as f:
    encoded = base64.b64encode(f.read()).decode("utf-8")

print(encoded)
