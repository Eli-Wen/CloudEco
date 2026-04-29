import base64
import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
INPUT_PATH = BASE_DIR / "annotate_response.json"
OUTPUT_PATH = BASE_DIR / "test_assets" / "docker_annotated_output.jpg"

with open(INPUT_PATH, "r", encoding="utf-8") as f:
    data = json.load(f)

image_base64 = data["image"]
image_bytes = base64.b64decode(image_base64)

with open(OUTPUT_PATH, "wb") as f:
    f.write(image_bytes)

print(f"Saved annotated image to: {OUTPUT_PATH}")