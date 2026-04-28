from pathlib import Path
from ultralytics import YOLO

BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = BASE_DIR / "model" / "fire_m.pt"
IMAGE_PATH = BASE_DIR / "test_assets" / "image0.jpeg"

print("Model path:", MODEL_PATH)
print("Image path:", IMAGE_PATH)

model = YOLO(str(MODEL_PATH))
results = model(str(IMAGE_PATH))

r = results[0]

print("Names:", r.names)
print("Speed:", r.speed)
print("Detections:", len(r.boxes) if r.boxes is not None else 0)