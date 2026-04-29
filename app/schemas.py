from pydantic import BaseModel


class PredictRequest(BaseModel):
    uuid: str
    image: str