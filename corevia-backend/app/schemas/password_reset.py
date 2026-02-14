from pydantic import BaseModel, Field, EmailStr


class ForgotPasswordRequest(BaseModel):
    email: EmailStr = Field(..., description="User email address")
    phone_number: str = Field(..., description="Phone number for WhatsApp OTP (+994XXXXXXXXX)")


class VerifyOTPRequest(BaseModel):
    phone_number: str = Field(..., description="Phone number")
    otp_code: str = Field(..., min_length=6, max_length=6, description="6-digit OTP code")


class ResetPasswordRequest(BaseModel):
    email: EmailStr = Field(..., description="User email")
    phone_number: str = Field(..., description="Phone number")
    otp_code: str = Field(..., min_length=6, max_length=6, description="6-digit OTP code")
    new_password: str = Field(..., min_length=6, description="New password")


class OTPResponse(BaseModel):
    success: bool
    message: str
    code: str | None = None  # Only in mock mode
