import base64
import json
import os
from pathlib import Path
from uuid import uuid4

from locust import HttpUser, between, task


REPO_ROOT = Path(__file__).resolve().parent.parent
TEST_IMAGE_PATH = REPO_ROOT / "test_assets" / "image0.jpeg"


def _load_test_image_base64() -> str:
    if not TEST_IMAGE_PATH.exists():
        raise FileNotFoundError(f"Test image not found: {TEST_IMAGE_PATH}")
    return base64.b64encode(TEST_IMAGE_PATH.read_bytes()).decode("utf-8")


IMAGE_B64 = _load_test_image_base64()
ALLOWED_ENDPOINT_MODES = {"predict", "annotate", "mixed"}


class CloudEcoUser(HttpUser):
    wait_time = between(0.5, 1.5)

    def on_start(self) -> None:
        mode = os.getenv("CLOUDECO_ENDPOINT_MODE", "predict").strip().lower()
        if mode not in ALLOWED_ENDPOINT_MODES:
            raise ValueError(
                f"Invalid CLOUDECO_ENDPOINT_MODE='{mode}'. "
                "Allowed values: predict, annotate, mixed."
            )
        self.endpoint_mode = mode

    def _payload(self) -> dict:
        return {
            "uuid": str(uuid4()),
            "image": IMAGE_B64,
        }

    @task(2)
    def predict(self) -> None:
        if self.endpoint_mode == "annotate":
            return

        payload = self._payload()
        with self.client.post(
            "/api/predict",
            json=payload,
            name="POST /api/predict",
            catch_response=True,
        ) as response:
            if response.status_code != 200:
                response.failure(f"Expected 200, got {response.status_code}")
                return

            try:
                data = response.json()
            except json.JSONDecodeError:
                response.failure("Response is not valid JSON")
                return

            required_fields = [
                "uuid",
                "count",
                "detections",
                "boxes",
                "speed_preprocess_ms",
                "speed_inference_ms",
                "speed_postprocess_ms",
            ]
            missing = [field for field in required_fields if field not in data]
            if missing:
                response.failure(f"Missing fields: {missing}")
                return

            if data["uuid"] != payload["uuid"]:
                response.failure("UUID mismatch between request and response")
                return

            response.success()

    @task(1)
    def annotate(self) -> None:
        if self.endpoint_mode == "predict":
            return

        payload = self._payload()
        with self.client.post(
            "/api/annotate",
            json=payload,
            name="POST /api/annotate",
            catch_response=True,
        ) as response:
            if response.status_code != 200:
                response.failure(f"Expected 200, got {response.status_code}")
                return

            try:
                data = response.json()
            except json.JSONDecodeError:
                response.failure("Response is not valid JSON")
                return

            required_fields = ["uuid", "image"]
            missing = [field for field in required_fields if field not in data]
            if missing:
                response.failure(f"Missing fields: {missing}")
                return

            if data["uuid"] != payload["uuid"]:
                response.failure("UUID mismatch between request and response")
                return

            if not isinstance(data["image"], str) or not data["image"].strip():
                response.failure("Annotated image field is empty or invalid")
                return

            response.success()
