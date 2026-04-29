from pydantic import BaseModel
from typing import List


class PredictRequest(BaseModel):
    uuid: str
    image: str


class BoxItem(BaseModel):
    x: float
    y: float
    width: float
    height: float
    probability: float


class PredictResponse(BaseModel):
    uuid: str
    count: int
    detections: List[str]
    boxes: List[BoxItem]
    speed_preprocess_ms: float
    speed_inference_ms: float
    speed_postprocess_ms: float


class AnnotateResponse(BaseModel):
    uuid: str
    image: str