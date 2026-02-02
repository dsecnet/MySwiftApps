from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from jose import JWTError, jwt

from app.database import get_db
from app.models.user import User, UserType, VerificationStatus
from app.models.settings import UserSettings
from app.schemas.user import UserRegister, UserLogin, Token, TokenRefresh, UserResponse, TrainerVerificationResponse
from app.utils.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    get_current_user,
)
from app.services.ai_service import analyze_trainer_photo
from app.services.file_service import save_upload
from app.config import get_settings

settings = get_settings()
router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserRegister, db: AsyncSession = Depends(get_db)):
    # Email movcud olub-olmadigini yoxla
    result = await db.execute(select(User).where(User.email == user_data.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bu email artiq qeydiyyatdan kecib",
        )

    # Yeni user yarat
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

    # Default settings yarat
    user_settings = UserSettings(user_id=new_user.id)
    db.add(user_settings)

    return new_user


@router.post("/login", response_model=Token)
async def login(user_data: UserLogin, db: AsyncSession = Depends(get_db)):
    # Useri tap
    result = await db.execute(select(User).where(User.email == user_data.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(user_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ve ya sifre sehvdir",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Hesab deaktiv edilib",
        )

    # Token-ler yarat (is_premium claim daxil)
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

    # Userin movcudlugunu yoxla
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User tapilmadi",
        )

    # Yeni token-ler yarat (is_premium claim daxil)
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
    # 1. Yalniz trainer ola biler
    if current_user.user_type != UserType.trainer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz muellimler verifikasiya ede biler",
        )

    # 2. Artiq verified ise tekrar verifikasiya lazim deyil
    if current_user.verification_status == VerificationStatus.verified:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Hesabiniz artiq dogrulanib",
        )

    # 3. Rate limit: gunde 3 cehd
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
            # Yeni gun — saygaci sifirla
            current_user.verification_attempts = 0

    # 4. Sekili saxla
    content = await file.read()
    await file.seek(0)
    file_path = await save_upload(file, "verification")

    # 5. AI analiz
    analysis = await analyze_trainer_photo(content)

    if "error" in analysis:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI analiz xetasi: {analysis['error']}",
        )

    score = analysis.get("confidence_score", 0.0)

    # 6. Score-a gore qerar
    if score >= 0.80:
        new_status = VerificationStatus.verified
        message = "Tebrikler! Hesabiniz ugurla dogrulandi."
    elif score >= 0.50:
        new_status = VerificationStatus.pending
        message = "Sekiliniz gozden kecirilir. Admin terefinden yoxlanilacaq."
    else:
        new_status = VerificationStatus.rejected
        message = "Teessuf ki, sekiliniz verifikasiya telblerine uygun deyil. Yeniden ceht edin."

    # 7. User model-i yenile
    current_user.instagram_handle = instagram
    current_user.verification_photo_url = file_path
    current_user.verification_score = score
    current_user.verification_status = new_status
    current_user.verification_attempts = (current_user.verification_attempts or 0) + 1
    current_user.last_verification_attempt = now

    # 8. Trainer field-lerini de yenile (eger gonderilibse)
    if specialization:
        current_user.specialization = specialization
    if experience is not None:
        current_user.experience = experience
    if bio:
        current_user.bio = bio

    return TrainerVerificationResponse(
        verification_status=new_status,
        verification_score=score,
        message=message,
    )
