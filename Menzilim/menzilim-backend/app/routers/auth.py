from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.user import User, UserRole
from app.models.agent import Agent
from app.schemas.auth import (
    SendOTPRequest,
    SendOTPResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    RefreshTokenRequest,
    MessageResponse,
)
from app.services.sms_service import sms_service
from app.utils.security import (
    create_access_token,
    create_refresh_token,
    verify_refresh_token,
)
from app.config import get_settings

settings = get_settings()
router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/send-otp", response_model=SendOTPResponse)
async def send_otp(request: SendOTPRequest):
    """Send an OTP code to the provided phone number."""
    result = await sms_service.send_otp(request.phone)
    if not result["success"]:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=result["message"],
        )
    return SendOTPResponse(
        message=result["message"],
        expires_in=settings.OTP_EXPIRE_MINUTES * 60,
    )


@router.post("/verify-otp", response_model=VerifyOTPResponse)
async def verify_otp(
    request: VerifyOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    """Verify an OTP code. Returns whether the phone is already registered."""
    is_valid = sms_service.verify_otp(request.phone, request.code)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP code",
        )

    # Check if user exists
    result = await db.execute(
        select(User).where(User.phone == request.phone)
    )
    user = result.scalar_one_or_none()

    return VerifyOTPResponse(
        is_valid=True,
        is_registered=user is not None,
        message="OTP verified successfully",
    )


@router.post("/register", response_model=TokenResponse)
async def register(
    request: RegisterRequest,
    db: AsyncSession = Depends(get_db),
):
    """Register a new user after OTP verification."""
    # Verify OTP
    is_valid = sms_service.verify_otp(request.phone, request.code)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP code",
        )

    # Check if user already exists
    result = await db.execute(
        select(User).where(User.phone == request.phone)
    )
    existing_user = result.scalar_one_or_none()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User with this phone number already exists",
        )

    # Create user
    user = User(
        phone=request.phone,
        full_name=request.full_name,
        role=request.role,
        is_verified=True,
    )
    db.add(user)
    await db.flush()

    # If registering as agent, create agent profile
    if request.role == UserRole.AGENT:
        agent = Agent(
            user_id=user.id,
            level=1,
            rating=0.0,
            total_reviews=0,
            total_listings=0,
            total_sales=0,
        )
        db.add(agent)
        await db.flush()

    # Generate tokens
    access_token = create_access_token(str(user.id), user.role.value)
    refresh_token = create_refresh_token(str(user.id))

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


@router.post("/login", response_model=TokenResponse)
async def login(
    request: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    """Login with phone and OTP code."""
    # Verify OTP
    is_valid = sms_service.verify_otp(request.phone, request.code)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP code",
        )

    # Find user
    result = await db.execute(
        select(User).where(User.phone == request.phone)
    )
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found. Please register first.",
        )

    # Generate tokens
    access_token = create_access_token(str(user.id), user.role.value)
    refresh_token = create_refresh_token(str(user.id))

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    request: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
):
    """Refresh the access token using a valid refresh token."""
    payload = verify_refresh_token(request.refresh_token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
        )

    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
        )

    # Verify user still exists
    import uuid as _uuid

    result = await db.execute(
        select(User).where(User.id == _uuid.UUID(user_id))
    )
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    # Generate new tokens
    access_token = create_access_token(str(user.id), user.role.value)
    new_refresh_token = create_refresh_token(str(user.id))

    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )
