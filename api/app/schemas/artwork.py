from typing import Optional
from pydantic import BaseModel, ConfigDict

class ArtworkBase(BaseModel):
    title: str
    artist: str
    year: int
    image_url: str
    description: Optional[str] = None
    category_id: int

class ArtworkResponse(ArtworkBase):
    id: int

    model_config = ConfigDict(from_attributes=True)