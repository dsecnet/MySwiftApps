import logging
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from jose import JWTError, jwt

logger = logging.getLogger(__name__)

from app.database import get_db
from app.models.user import User, UserType, VerificationStatus
from app.models.settings import UserSettings
from app.schemas.user import UserRegister, RegisterRequestOTP, UserLogin, LoginVerifyOTP, Token, TokenRefresh, UserResponse, TrainerVerificationResponse
from app.schemas.password_reset import ForgotPasswordRequest, VerifyOTPRequest, ResetPasswordRequest, OTPResponse
from app.utils.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    get_current_user,
)
from app.services.ai_service import analyze_trainer_photo
from app.services.file_service import save_upload
from app.services.email_service import email_service
from app.config import get_settings

settings = get_settings()
router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])


@router.post("/register-request", response_model=OTPResponse)
async def register_request_otp(
    request: RegisterRequestOTP,
    db: AsyncSession = Depends(get_db)
):
    """
    Step 1: Qeydiyyat üçün OTP göndərir

    1. Email-in mövcudluğu yoxlanır
    2. Email-ə 6 rəqəmli OTP göndərilir
    3. OTP 10 dəqiqə etibarlıdır
    """

    # Check if user already exists
    result = await db.execute(select(User).where(User.email == request.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bu email artıq qeydiyyatdan keçib"
        )

    # Send OTP to Email
    otp_result = await email_service.send_otp(
        email=request.email,
        purpose='registration',
        db=db
    )

    if not otp_result['success']:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=otp_result['message']
        )

    return OTPResponse(**otp_result)


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserRegister, db: AsyncSession = Depends(get_db)):
    """
    Step 2: OTP verify edib istifadəçi yaradır

    1. OTP verify olunur
    2. Email-in mövcudluğu yenidən yoxlanır
    3. User yaradılır
    """

    # Verify OTP
    otp_result = await email_service.verify_otp(
        email=user_data.email,
        code=user_data.otp_code,
        purpose='registration',
        db=db
    )

    if not otp_result['success']:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=otp_result['message']
        )

    # Check if user exists (double check)
    result = await db.execute(select(User).where(User.email == user_data.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bu email artıq qeydiyyatdan keçib"
        )

    new_user = User(
        name=user_data.name,
        email=user_data.email,
        hashed_password=hash_password(user_data.password),
        user_type=user_data.user_type,
        verification_status=(
            VerificationStatus.pending
            if user_data.user_type == UserType.trainer
            else VerificationStatus.verified
        ),
    )
    db.add(new_user)
    await db.flush()

    user_settings = UserSettings(user_id=new_user.id)
    db.add(user_settings)
    await db.commit()

    logger.info(f"New user registered: {new_user.email}")

    return new_user


@router.post("/login", response_model=OTPResponse)
async def login(user_data: UserLogin, db: AsyncSession = Depends(get_db)):
    """
    Step 1: Login with email + password, send OTP

    1. Email və parol yoxlanır
    2. Doğrudursa email-ə OTP göndərilir
    3. OTP 10 dəqiqə etibarlıdır
    """
    result = await db.execute(select(User).where(User.email == user_data.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(user_data.password, user.hashed_password):
        logger.warning(f"Failed login attempt for: {user_data.email}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email və ya şifrə səhvdir",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Hesab deaktiv edilib",
        )

    # Send OTP for 2FA
    otp_result = await email_service.send_otp(
        email=user_data.email,
        purpose='login_2fa',
        db=db
    )

    if not otp_result['success']:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=otp_result['message']
        )

    logger.info(f"Login OTP sent to: {user.email}")

    return OTPResponse(**otp_result)


@router.post("/login-verify", response_model=Token)
async def login_verify_otp(
    verify_data: LoginVerifyOTP,
    db: AsyncSession = Depends(get_db)
):
    """
    Step 2: Verify OTP and return JWT tokens

    1. OTP verify olunur
    2. JWT token qaytarılır
    """

    # Verify OTP
    otp_result = await email_service.verify_otp(
        email=verify_data.email,
        code=verify_data.otp_code,
        purpose='login_2fa',
        db=db
    )

    if not otp_result['success']:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=otp_result['message']
        )

    # Find user
    result = await db.execute(select(User).where(User.email == verify_data.email))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="İstifadəçi tapılmadı",
        )

    logger.info(f"Successful 2FA login: {user.email}")

    token_data = {
        "sub": user.id,
        "user_type": user.user_type.value,
        "is_premium": user.is_premium,
    }
    return Token(
        access_token=create_access_token(token_data),
        refresh_token=create_refresh_token(token_data),
    )


@router.post("/refresh", response_model=Token)
async def refresh_token(token_data: TokenRefresh, db: AsyncSession = Depends(get_db)):
    try:
        payload = jwt.decode(
            token_data.refresh_token, settings.secret_key, algorithms=[settings.algorithm]
        )
        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")

        if user_id is None or token_type != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Etibarsiz refresh token",
            )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Etibarsiz refresh token",
        )

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User tapilmadi",
        )

    new_token_data = {
        "sub": user.id,
        "user_type": user.user_type.value,
        "is_premium": user.is_premium,
    }
    return Token(
        access_token=create_access_token(new_token_data),
        refresh_token=create_refresh_token(new_token_data),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.post("/refresh-claims", response_model=Token)
async def refresh_claims(current_user: User = Depends(get_current_user)):
    """Premium deyisdikden sonra yeni token-ler al (updated claims ile).

    Movcud access_token ile cagrilir, DB-den en son is_premium oxuyur.
    """
    new_token_data = {
        "sub": current_user.id,
        "user_type": current_user.user_type.value,
        "is_premium": current_user.is_premium,
    }
    return Token(
        access_token=create_access_token(new_token_data),
        refresh_token=create_refresh_token(new_token_data),
    )


@router.post("/verify-trainer", response_model=TrainerVerificationResponse)
async def verify_trainer(
    file: UploadFile = File(...),
    instagram: str = Form(...),
    specialization: str = Form(None),
    experience: int = Form(None),
    bio: str = Form(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Muellim verifikasiyasi — sekil yukle, AI analiz etsin.

    Addim 2: qeydiyyatdan sonra trainer beden/fitness sekili yukleyir,
    AI formasini qiymetlendirir, score-a gore avtomatik qerar verilir.
    """
    if current_user.user_type != UserType.trainer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz muellimler verifikasiya ede biler",
        )

    if current_user.verification_status == VerificationStatus.verified:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Hesabiniz artiq dogrulanib",
        )

    now = datetime.utcnow()
    if current_user.last_verification_attempt:
        time_since_last = now - current_user.last_verification_attempt
        if time_since_last < timedelta(days=1):
            if current_user.verification_attempts >= 3:
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Gunde maksimum 3 verifikasiya cehdine icaze verilir. Sabah yeniden ceht edin.",
                )
        else:
            current_user.verification_attempts = 0

    content = await file.read()
    await file.seek(0)
    file_path = await save_upload(file, "verification")

    analysis = await analyze_trainer_photo(content)

    if "error" in analysis:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI analiz xetasi: {analysis['error']}",
        )

    score = analysis.get("confidence_score", 0.0)
    red_flags = analysis.get("red_flags", [])
    photo_quality = analysis.get("photo_quality", "unknown")
    requires_manual = analysis.get("requires_manual_review", False)

    if photo_quality == "invalid":
        new_status = VerificationStatus.rejected
        message = "Yüklədiyiniz şəkil keyfiyyətsizdir. Zəhmət olmasa aydın fitness şəkli yükləyin."
    elif score >= 0.80 and not requires_manual:
        new_status = VerificationStatus.verified
        message = "Təbriklər! Hesabınız uğurla doğrulandı."
    elif score >= 0.50:
        new_status = VerificationStatus.pending
        if requires_manual:
            message = "Şəkiliniz qəbul edildi. AI analizi mövcud olmadığı üçün admin tərəfindən yoxlanılacaq."
        else:
            message = "Şəkiliniz gözdən keçirilir. Admin tərəfindən yoxlanılacaq."
    elif score >= 0.30:
        new_status = VerificationStatus.rejected
        message = "Şəkiliniz fitness müəllimi standartlarına uyğun deyil. Daha aydın idman/fitness şəkli yükləyin."
    else:
        new_status = VerificationStatus.rejected
        message = "Yüklədiyiniz şəkil verifikasiya tələblərinə uyğun deyil. Bədən formanızın aydın göründüyü fitness şəkli yükləyin."

    current_user.instagram_handle = instagram
    current_user.verification_photo_url = file_path
    current_user.verification_score = score
    current_user.verification_status = new_status
    current_user.verification_attempts = (current_user.verification_attempts or 0) + 1
    current_user.last_verification_attempt = now

    if specialization:
        current_user.specialization = specialization
    if experience is not None:
        current_user.experience = experience
    if bio:
        current_user.bio = bio

    await db.commit()
    await db.refresh(current_user)

    return TrainerVerificationResponse(
        verification_status=new_status,
        verification_score=score,
        message=message,
    )


# ============================================
# FORGOT PASSWORD - Email OTP
# ============================================

@router.post("/forgot-password", response_model=OTPResponse)
async def forgot_password(
    request: ForgotPasswordRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Şifrəni unutmuş user üçün email-ə OTP göndərir

    Steps:
    1. Email-lə user tapılır
    2. Email-ə 6 rəqəmli OTP göndərilir (mock mode-da console-a)
    3. OTP 10 dəqiqə etibarlıdır
    """

    # Check if user exists with this email
    result = await db.execute(
        select(User).where(User.email == request.email)
    )
    user = result.scalar_one_or_none()

    if not user:
        # Security: Don't reveal if user exists
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Bu email ilə istifadəçi tapılmadı"
        )

    # Send OTP to Email
    result = await email_service.send_otp(
        email=request.email,
        purpose='forgot_password',
        db=db
    )

    if not result['success']:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=result['message']
        )

    return OTPResponse(**result)


@router.post("/verify-otp", response_model=dict)
async def verify_otp(
    request: VerifyOTPRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    OTP kodunu yoxlayır (opsional - reset-password birbaşa yoxlayır)
    """

    result = await email_service.verify_otp(
        email=request.email,
        code=request.otp_code,
        purpose='forgot_password',
        db=db
    )

    if not result['success']:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=result['message']
        )

    return {"success": True, "message": "OTP təsdiqləndi"}


@router.post("/reset-password", response_model=dict)
async def reset_password(
    request: ResetPasswordRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    OTP ilə şifrəni yeniləyir

    Steps:
    1. OTP verify olunur
    2. User tapılır
    3. Yeni şifrə set olunur
    """

    # Verify OTP
    otp_result = await email_service.verify_otp(
        email=request.email,
        code=request.otp_code,
        purpose='forgot_password',
        db=db
    )

    if not otp_result['success']:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=otp_result['message']
        )

    # Find user
    result = await db.execute(
        select(User).where(User.email == request.email)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="İstifadəçi tapılmadı"
        )

    # Update password
    user.hashed_password = hash_password(request.new_password)
    await db.commit()

    logger.info(f"Password reset successful for user: {user.id}")

    return {
        "success": True,
        "message": "Şifrə uğurla yeniləndi"
    }
