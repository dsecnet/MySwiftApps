from pydantic import BaseModel, Field

from app.models.user import UserRole


class SendOTPRequest(BaseModel):
    phone: str = Field(
        ...,
        min_length=10,
        max_length=20,
        examples=["+994501234567"],
        description="Phone number in international format",
    )


class SendOTPResponse(BaseModel):
    message: str = "OTP sent successfully"
    expires_in: int = Field(default=300, description="OTP expiration in seconds")


class VerifyOTPRequest(BaseModel):
    phone: str = Field(..., min_length=10, max_length=20)
    code: str = Field(..., min_length=4, max_length=8)


class VerifyOTPResponse(BaseModel):
    is_valid: bool
    is_registered: bool
    message: str


class RegisterRequest(BaseModel):
    phone: str = Field(..., min_length=10, max_length=20)
    code: str = Field(..., min_length=4, max_length=8)
    full_name: str = Field(..., min_length=2, max_length=255)
    role: UserRole = Field(default=UserRole.USER)


class LoginRequest(BaseModel):
    phone: str = Field(..., min_length=10, max_length=20)
    code: str = Field(..., min_length=4, max_length=8)


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class MessageResponse(BaseModel):
    message: str
