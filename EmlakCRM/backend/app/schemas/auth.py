from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional
from datetime import datetime


# ============================================================
# MARK: - Request Schemas
# ============================================================

class RegisterRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(..., min_length=9, max_length=20)
    password: str = Field(..., min_length=6, max_length=100)
    agency_name: Optional[str] = Field(None, max_length=200)
    city: str = Field(default="Bakı", max_length=100)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v):
        # Remove spaces and dashes
        phone = v.replace(" ", "").replace("-", "")
        if not phone.startswith("+"):
            phone = "+" + phone
        return phone


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str


# ============================================================
# MARK: - Response Schemas
# ============================================================

class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    phone: Optional[str]
    role: str
    subscription_plan: str
    agency_name: Optional[str]
    profile_image_url: Optional[str]
    city: str
    total_properties: int
    total_clients: int
    total_deals: int
    is_active: bool
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True
