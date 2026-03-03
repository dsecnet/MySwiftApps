import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.schemas.user import UserPublicResponse


class AgentResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    company_name: str | None = None
    license_number: str | None = None
    level: int
    rating: float
    total_reviews: int
    total_listings: int
    total_sales: int
    bio: str | None = None
    is_premium: bool
    premium_expires_at: datetime | None = None
    created_at: datetime
    updated_at: datetime
    user: UserPublicResponse | None = None

    model_config = {"from_attributes": True}


class AgentUpdateRequest(BaseModel):
    company_name: str | None = Field(None, max_length=255)
    license_number: str | None = Field(None, max_length=100)
    bio: str | None = Field(None, max_length=2000)


class AgentListResponse(BaseModel):
    items: list[AgentResponse]
    total: int
    page: int
    per_page: int
    pages: int
