from pydantic import BaseModel, EmailStr, Field, field_validator
from datetime import datetime
from app.models.user import UserType, VerificationStatus
import re


class RegisterRequestOTP(BaseModel):
    """Step 1: Request OTP for registration"""
    email: EmailStr


class UserRegister(BaseModel):
    """Step 2: Verify OTP and complete registration"""
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=128)
    user_type: UserType
    otp_code: str = Field(default="", min_length=0, max_length=6, description="6-digit OTP code (optional for trainers)")

    @field_validator("name")
    @classmethod
    def name_must_be_valid(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("Name cannot be empty")
        return v

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if len(v) < 6:
            raise ValueError("Password must be at least 6 characters")
        return v


class UserLogin(BaseModel):
    """Step 1: Login with email + password + user_type, receives OTP"""
    email: EmailStr
    password: str = Field(..., min_length=1, max_length=128)
    user_type: UserType


class LoginVerifyOTP(BaseModel):
    """Step 2: Verify OTP and receive JWT token"""
    email: EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6, description="6-digit OTP code")


class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenRefresh(BaseModel):
    refresh_token: str


class UserProfileUpdate(BaseModel):
    name: str | None = Field(None, min_length=2, max_length=100)
    age: int | None = Field(None, ge=13, le=120)
    weight: float | None = Field(None, ge=20.0, le=500.0)
    height: float | None = Field(None, ge=50.0, le=300.0)
    goal: str | None = Field(None, max_length=100)
    specialization: str | None = Field(None, max_length=100)
    experience: int | None = Field(None, ge=0, le=60)
    bio: str | None = Field(None, max_length=1000)
    price_per_session: float | None = Field(None, ge=0.0, le=10000.0)

    @field_validator("name")
    @classmethod
    def name_strip(cls, v):
        if v is not None:
            v = v.strip()
            if not v:
                raise ValueError("Name cannot be empty")
        return v


class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    user_type: UserType
    profile_image_url: str | None = None
    is_active: bool
    is_premium: bool
    created_at: datetime
    age: int | None = None
    weight: float | None = None
    height: float | None = None
    goal: str | None = None
    trainer_id: str | None = None
    specialization: str | None = None
    experience: int | None = None
    rating: float | None = None
    price_per_session: float | None = None
    bio: str | None = None
    verification_status: VerificationStatus | None = None
    instagram_handle: str | None = None
    verification_photo_url: str | None = None
    verification_score: float | None = None

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
    instagram_handle: str | None = None

    model_config = {"from_attributes": True}


class TrainerVerificationResponse(BaseModel):
    verification_status: VerificationStatus
    verification_score: float | None = None
    message: str


class StudentSummary(BaseModel):
    id: str
    name: str
    email: str
    weight: float | None = None
    height: float | None = None
    goal: str | None = None
    age: int | None = None
    profile_image_url: str | None = None
    training_plans_count: int = 0
    meal_plans_count: int = 0
    completed_training_plans: int = 0
    completed_meal_plans: int = 0
    total_workouts: int = 0
    this_week_workouts: int = 0
    total_calories_logged: int = 0

    model_config = {"from_attributes": True}


class StatsSummary(BaseModel):
    avg_student_workouts_per_week: float = 0.0
    total_workouts_all_students: int = 0
    avg_student_weight: float = 0.0


class TrainerDashboardStats(BaseModel):
    total_subscribers: int = 0
    active_students: int = 0
    monthly_earnings: float = 0.0
    currency: str = "₼"
    total_training_plans: int = 0
    total_meal_plans: int = 0
    students: list[StudentSummary] = []
    stats_summary: StatsSummary
