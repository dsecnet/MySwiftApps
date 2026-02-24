from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config import get_settings
from app.routers import auth, users, workouts, food, plans, uploads, admin, ai, location, notifications, premium, trainer, reviews, chat, content, onboarding, social, marketplace, analytics, news, live_sessions, daily_survey
from app.routers import settings as settings_router

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    description="CoreVia Fitness & Nutrition Backend API",
    version="1.0.0",
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
)

# Security Middleware - OWASP Top 10 2021 Compliant
from app.middleware.security import (
    SecurityHeadersMiddleware,
    RateLimitMiddleware,
    RequestLoggingMiddleware,
    InputSanitizationMiddleware,
)

# Apply middleware in order (last added = first executed)
app.add_middleware(SecurityHeadersMiddleware)        # Security headers
app.add_middleware(RateLimitMiddleware, requests_per_minute=60)  # Rate limiting
app.add_middleware(RequestLoggingMiddleware)          # Request logging
app.add_middleware(InputSanitizationMiddleware)       # Input validation

# CORS - iOS app-dan gelen request-lere icaze ver
# Production-da .env-de CORS_ORIGINS=https://app.corevia.az,https://corevia.az
allowed_origins = [origin.strip() for origin in settings.cors_origins.split(",") if origin.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(workouts.router)
app.include_router(food.router)
app.include_router(plans.router)
app.include_router(uploads.router)
app.include_router(admin.router)
app.include_router(ai.router)
app.include_router(location.router)
app.include_router(notifications.router)
app.include_router(premium.router)
app.include_router(trainer.router)
app.include_router(reviews.router)
app.include_router(chat.router)
app.include_router(content.router)
app.include_router(onboarding.router)
app.include_router(social.router)
app.include_router(marketplace.router)
app.include_router(analytics.router)
app.include_router(news.router)
app.include_router(live_sessions.router)
app.include_router(settings_router.router)
app.include_router(daily_survey.router)

# Static files - sekilleri serve etmek ucun
uploads_dir = Path(__file__).parent.parent / "uploads"
uploads_dir.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")


@app.on_event("startup")
async def startup_event():
    """Server basladiqda scheduler-i ise sal + secret_key yoxla"""
    import logging
    logger = logging.getLogger(__name__)

    if not settings.secret_key or settings.secret_key == "your-secret-key-change-in-production":
        logger.critical("CRITICAL: secret_key is not set or is the default value! Set a strong SECRET_KEY in .env")
        if not settings.debug:
            raise RuntimeError("secret_key must be set in production! Set SECRET_KEY in .env")

    from app.services.scheduler_service import init_scheduler
    init_scheduler()


@app.on_event("shutdown")
async def shutdown_event():
    """Server baglandiqda scheduler-i durdur"""
    from app.services.scheduler_service import scheduler
    scheduler.shutdown(wait=False)


@app.get("/")
async def root():
    return {
        "app": settings.app_name,
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
