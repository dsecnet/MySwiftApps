from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Application
    APP_NAME: str = "Menzilim API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    API_V1_PREFIX: str = "/api/v1"

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://menzilim:menzilim_secret@localhost:5432/menzilim"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # JWT
    JWT_SECRET_KEY: str = "super-secret-key-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # OTP
    OTP_LENGTH: int = 6
    OTP_EXPIRE_MINUTES: int = 5
    OTP_MAX_ATTEMPTS: int = 5
    OTP_RATE_LIMIT_MINUTES: int = 15

    # SMS Provider (placeholder)
    SMS_API_KEY: str = ""
    SMS_API_URL: str = ""
    SMS_SENDER: str = "Menzilim"

    # File Upload
    UPLOAD_DIR: str = "uploads"
    MAX_IMAGE_SIZE: int = 10 * 1024 * 1024  # 10 MB
    ALLOWED_IMAGE_TYPES: list[str] = ["image/jpeg", "image/png", "image/webp"]
    MAX_LISTING_IMAGES: int = 20

    # Apple IAP
    APPLE_SHARED_SECRET: str = ""
    APPLE_VERIFY_URL: str = "https://buy.itunes.apple.com/verifyReceipt"
    APPLE_SANDBOX_VERIFY_URL: str = "https://sandbox.itunes.apple.com/verifyReceipt"

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
        "case_sensitive": True,
    }


@lru_cache()
def get_settings() -> Settings:
    return Settings()
