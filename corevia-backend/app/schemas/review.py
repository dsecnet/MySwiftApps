from pydantic import BaseModel, Field
from datetime import datetime


class ReviewCreate(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    comment: str | None = Field(None, max_length=500)


class ReviewResponse(BaseModel):
    id: str
    trainer_id: str
    student_id: str
    student_name: str = ""
    student_profile_image: str | None = None
    rating: int
    comment: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class ReviewSummary(BaseModel):
    average_rating: float
    total_reviews: int
    rating_distribution: dict[int, int]  # {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}
