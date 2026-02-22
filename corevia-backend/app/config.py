from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # App
    app_name: str = "CoreVia"
    debug: bool = False

    # CORS - allowed origins (comma separated)
    cors_origins: str = "http://localhost:3000,http://localhost:8000"

    # Database
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/corevia_db"

    # JWT
    secret_key: str = ""
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    # AWS S3
    aws_access_key_id: str = ""
    aws_secret_access_key: str = ""
    aws_bucket_name: str = "corevia-uploads"
    aws_region: str = "eu-central-1"

    # OpenAI (deprecated — Claude istifade olunur)
    openai_api_key: str = ""

    # Anthropic Claude AI
    anthropic_api_key: str = ""

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # Mapbox
    mapbox_access_token: str = ""

    # Firebase
    firebase_credentials_path: str = "firebase-credentials.json"

    # Apple In-App Purchase
    apple_shared_secret: str = ""  # App Store Connect-den al
    apple_use_production: bool = False  # Production-da True et

    # Email SMTP (Gmail)
    smtp_host: str = "smtp.gmail.com"
    smtp_port: int = 587
    smtp_username: str = ""
    smtp_password: str = ""
    smtp_from_email: str = ""
    smtp_from_name: str = "CoreVia"
    email_otp_mock: bool = True  # Test üçün true, production-da false

    model_config = {"env_file": ".env", "extra": "ignore", "env_ignore_empty": True}


@lru_cache()
def get_settings() -> Settings:
    return Settings()
