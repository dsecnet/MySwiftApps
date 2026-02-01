from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from jose import JWTError, jwt

from app.database import get_db
from app.models.user import User, UserType, VerificationStatus
from app.models.settings import UserSettings
from app.schemas.user import UserRegister, UserLogin, Token, TokenRefresh, UserResponse
from app.utils.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    get_current_user,
)
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

    # Token-ler yarat
    token_data = {"sub": user.id, "user_type": user.user_type.value}
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

    # Yeni token-ler yarat
    new_token_data = {"sub": user.id, "user_type": user.user_type.value}
    return Token(
        access_token=create_access_token(new_token_data),
        refresh_token=create_refresh_token(new_token_data),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user
