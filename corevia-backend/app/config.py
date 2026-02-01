from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # App
    app_name: str = "CoreVia"
    debug: bool = True

    # Database
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/corevia_db"

    # JWT
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    # AWS S3
    aws_access_key_id: str = ""
    aws_secret_access_key: str = ""
    aws_bucket_name: str = "corevia-uploads"
    aws_region: str = "eu-central-1"

    # OpenAI
    openai_api_key: str = ""

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # Mapbox
    mapbox_access_token: str = ""

    # Firebase
    firebase_credentials_path: str = "firebase-credentials.json"

    model_config = {"env_file": ".env", "extra": "ignore"}


@lru_cache()
def get_settings() -> Settings:
    return Settings()
