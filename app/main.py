from fastapi import FastAPI, HTTPException

from app.model_runner import decode_base64_image, model_runner
from app.schemas import PredictRequest

app = FastAPI(title="CloudEco Wildfire Detection API")


@app.get("/")
def root():
    return {"message": "CloudEco API is running"}


@app.post("/api/predict")
def predict(request: PredictRequest):
    try:
        image = decode_base64_image(request.image)
        result = model_runner.predict_from_array(image)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    detections = []
    boxes = []

    if result.boxes is not None:
        for box in result.boxes:
            cls_id = int(box.cls[0].item())
            conf = float(box.conf[0].item())
            x1, y1, x2, y2 = box.xyxy[0].tolist()

            detections.append(result.names[cls_id])
            boxes.append(
                {
                    "x": x1,
                    "y": y1,
                    "width": x2 - x1,
                    "height": y2 - y1,
                    "probability": conf,
                }
            )

    return {
        "uuid": request.uuid,
        "count": len(detections),
        "detections": detections,
        "boxes": boxes,
        "speed_preprocess_ms": result.speed.get("preprocess", 0.0),
        "speed_inference_ms": result.speed.get("inference", 0.0),
        "speed_postprocess_ms": result.speed.get("postprocess", 0.0),
    }