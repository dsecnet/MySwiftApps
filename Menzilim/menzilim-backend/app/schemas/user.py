import uuid
from datetime import datetime

from pydantic import BaseModel, Field, EmailStr

from app.models.user import UserRole


class UserResponse(BaseModel):
    id: uuid.UUID
    phone: str
    email: str | None = None
    full_name: str
    avatar_url: str | None = None
    role: UserRole
    is_verified: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class UserUpdateRequest(BaseModel):
    full_name: str | None = Field(None, min_length=2, max_length=255)
    email: str | None = Field(None, max_length=255)
    avatar_url: str | None = None


class UserPublicResponse(BaseModel):
    id: uuid.UUID
    full_name: str
    avatar_url: str | None = None
    role: UserRole
    is_verified: bool
    created_at: datetime

    model_config = {"from_attributes": True}
