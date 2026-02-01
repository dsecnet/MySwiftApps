from pydantic import BaseModel, EmailStr
from datetime import datetime
from app.models.user import UserType, VerificationStatus


# --- Auth Schemas ---

class UserRegister(BaseModel):
    name: str
    email: EmailStr
    password: str
    user_type: UserType


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenRefresh(BaseModel):
    refresh_token: str


# --- User Schemas ---

class UserBase(BaseModel):
    name: str
    email: EmailStr
    user_type: UserType


class UserProfileUpdate(BaseModel):
    name: str | None = None
    age: int | None = None
    weight: float | None = None
    height: float | None = None
    goal: str | None = None
    specialization: str | None = None
    experience: int | None = None
    bio: str | None = None
    price_per_session: float | None = None


class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    user_type: UserType
    profile_image_url: str | None = None
    is_active: bool
    is_premium: bool
    created_at: datetime

    # Client fields
    age: int | None = None
    weight: float | None = None
    height: float | None = None
    goal: str | None = None
    trainer_id: str | None = None

    # Trainer fields
    specialization: str | None = None
    experience: int | None = None
    rating: float | None = None
    price_per_session: float | None = None
    bio: str | None = None
    verification_status: VerificationStatus | None = None

    model_config = {"from_attributes": True}


class TrainerListResponse(BaseModel):
    id: str
    name: str
    profile_image_url: str | None = None
    specialization: str | None = None
    experience: int | None = None
    rating: float | None = None
    price_per_session: float | None = None
    bio: str | None = None
    verification_status: VerificationStatus

    model_config = {"from_attributes": True}
