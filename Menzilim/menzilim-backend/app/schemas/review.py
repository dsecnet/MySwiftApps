import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.schemas.user import UserPublicResponse


class ReviewCreateRequest(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    comment: str | None = Field(None, max_length=2000)


class ReviewReplyRequest(BaseModel):
    agent_reply: str = Field(..., min_length=1, max_length=2000)


class ReviewResponse(BaseModel):
    id: uuid.UUID
    agent_id: uuid.UUID
    user_id: uuid.UUID
    rating: int
    comment: str | None = None
    agent_reply: str | None = None
    created_at: datetime
    user: UserPublicResponse | None = None

    model_config = {"from_attributes": True}


class ReviewListResponse(BaseModel):
    items: list[ReviewResponse]
    total: int
    page: int
    per_page: int
    pages: int
