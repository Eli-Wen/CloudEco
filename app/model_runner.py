from pathlib import Path
from typing import Any
import base64

import cv2
import numpy as np
from ultralytics import YOLO

BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = BASE_DIR / "model" / "fire_m.pt"


class ModelRunner:
    def __init__(self) -> None:
        self.model = YOLO(str(MODEL_PATH))

    def predict_from_array(self, image_array: np.ndarray) -> Any:
        results = self.model(image_array)
        return results[0]


model_runner = ModelRunner()


def decode_base64_image(image_b64: str) -> np.ndarray:
    image_bytes = base64.b64decode(image_b64)
    np_buffer = np.frombuffer(image_bytes, dtype=np.uint8)
    image = cv2.imdecode(np_buffer, cv2.IMREAD_COLOR)

    if image is None:
        raise ValueError("Invalid image data after base64 decoding")

    return image


def encode_image_to_base64(image: np.ndarray) -> str:
    success, buffer = cv2.imencode(".jpg", image)
    if not success:
        raise ValueError("Failed to encode annotated image")
    return base64.b64encode(buffer.tobytes()).decode("utf-8")