from pydantic import BaseModel, Field
from datetime import datetime
from app.models.content import ContentType


class ContentCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    body: str | None = Field(None, max_length=5000)
    content_type: ContentType
    is_premium_only: bool = True


class ContentResponse(BaseModel):
    id: str
    trainer_id: str
    trainer_name: str = ""
    trainer_profile_image: str | None = None
    title: str
    body: str | None = None
    content_type: ContentType
    image_url: str | None = None
    is_premium_only: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class ContentUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    body: str | None = Field(None, max_length=5000)
    is_premium_only: bool | None = None
