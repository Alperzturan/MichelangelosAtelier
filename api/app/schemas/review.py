from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator


class ReviewCreate(BaseModel):
    artwork_id: int = Field(..., gt=0, description="Değerlendirilen sanat eserinin ID'si")
    rating: int = Field(..., ge=1, le=5, description="1 ile 5 arasında yıldız puanı")
    comment: str = Field(..., min_length=1, max_length=500, description="Eser eleştirisi / yorumu")

    @field_validator("comment")
    @classmethod
    def comment_must_not_be_blank(cls, value: str) -> str:
        cleaned = value.strip()
        if not cleaned:
            raise ValueError("Yorum metni boş olamaz.")
        return cleaned


class ReviewResponse(BaseModel):
    id: int
    user_id: int
    artwork_id: int
    rating: int
    comment: Optional[str] = ""
    created_at: datetime
    user_name: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
