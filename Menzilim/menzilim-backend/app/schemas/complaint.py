import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.complaint import TargetType, ComplaintType, ComplaintStatus


class ComplaintCreateRequest(BaseModel):
    target_type: TargetType
    target_id: uuid.UUID
    complaint_type: ComplaintType
    description: str = Field(..., min_length=10, max_length=2000)
    screenshots: list[str] = Field(default_factory=list, max_length=5)


class ComplaintResponse(BaseModel):
    id: uuid.UUID
    reporter_id: uuid.UUID
    target_type: TargetType
    target_id: uuid.UUID
    complaint_type: ComplaintType
    description: str
    screenshots: list[str] | None = None
    status: ComplaintStatus
    admin_note: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class ComplaintListResponse(BaseModel):
    items: list[ComplaintResponse]
    total: int
    page: int
    per_page: int
    pages: int
