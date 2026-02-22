from pydantic import BaseModel, Field, EmailStr


class ForgotPasswordRequest(BaseModel):
    email: EmailStr = Field(..., description="User email address")


class VerifyOTPRequest(BaseModel):
    email: EmailStr = Field(..., description="User email address")
    otp_code: str = Field(..., min_length=6, max_length=6, description="6-digit OTP code")


class ResetPasswordRequest(BaseModel):
    email: EmailStr = Field(..., description="User email")
    otp_code: str = Field(..., min_length=6, max_length=6, description="6-digit OTP code")
    new_password: str = Field(..., min_length=6, description="New password")


class OTPResponse(BaseModel):
    success: bool
    message: str
    code: str | None = None  # Only in mock mode


class ChangePasswordRequest(BaseModel):
    current_password: str = Field(..., description="Current password")
    new_password: str = Field(..., min_length=6, description="New password (min 6 chars)")


class DeleteAccountRequest(BaseModel):
    password: str = Field(..., description="Password confirmation for account deletion")
