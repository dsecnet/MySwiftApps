import logging
from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config import get_settings
from app.routers import (
    auth, users, workouts, food, plans, uploads, admin, ai,
    location, notifications, premium, trainer, reviews, chat,
    content, onboarding, social, marketplace, analytics, news,
    live_sessions, daily_survey,
)
from app.routers import settings as settings_router

logger = logging.getLogger(__name__)
settings = get_settings()

# ── B-07 fix: SECRET_KEY yoxlaması debug-dan ASILI DEYİL ──────────────────
# Həmişə güclü key tələb olunur — debug rejimindən asılı olmayaraq.
_key = settings.secret_key
_WEAK_KEYS = {
    "", "your-secret-key-change-in-production",
    "dev-secret-key-for-local-testing-only-change-in-production-12345678",
    "secret", "changeme",
}
if not _key or _key in _WEAK_KEYS:
    raise RuntimeError(
        "CRITICAL: SECRET_KEY boşdur və ya standart dəyərdədir. "
        ".env faylında ən az 64 simvollu random key təyin edin.\n"
        "Generasiya: python -c \"import secrets; print(secrets.token_hex(32))\""
    )
if len(_key) < 32:
    raise RuntimeError(
        f"CRITICAL: SECRET_KEY çox qısadır ({len(_key)} simvol). "
        "Minimum 32, tövsiyə olunan 64 simvol."
    )

app = FastAPI(
    title=settings.app_name,
    description="CoreVia Fitness & Nutrition Backend API",
    version="1.0.0",
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
)

# ── Security Middleware ────────────────────────────────────────────────────
from app.middleware.security import (
    SecurityHeadersMiddleware,
    RateLimitMiddleware,
    RequestLoggingMiddleware,
    InputSanitizationMiddleware,
)

app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(RateLimitMiddleware, requests_per_minute=60)
app.add_middleware(RequestLoggingMiddleware)
app.add_middleware(InputSanitizationMiddleware)

# ── B-08 fix: CORS — allow_headers spesifikləşdirildi ─────────────────────
# "*" əvəzinə yalnız tələb olunan headerlar icazə verilir.
allowed_origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=[
        "Authorization",
        "Content-Type",
        "Accept",
        "X-Request-ID",
        "X-Client-Version",
    ],
    expose_headers=["X-Process-Time", "X-RateLimit-Limit", "X-RateLimit-Remaining"],
)

# ── Routers ───────────────────────────────────────────────────────────────
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

# ── Static files ──────────────────────────────────────────────────────────
uploads_dir = Path(__file__).parent.parent / "uploads"
uploads_dir.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")


@app.on_event("startup")
async def startup_event():
    """Server başladıqda scheduler-i işə sal."""
    # B-10 fix: production-da DEBUG=True olduqda xəbərdar et
    if settings.debug:
        logger.warning(
            "⚠️  DEBUG=True aktiv! Production deploy-da DEBUG=False olmalıdır. "
            "/docs və /redoc endpoint-ləri ictimai görünür."
        )

    from app.services.scheduler_service import init_scheduler
    init_scheduler()
    logger.info("CoreVia backend started successfully.")


@app.on_event("shutdown")
async def shutdown_event():
    from app.services.scheduler_service import scheduler
    scheduler.shutdown(wait=False)


@app.get("/")
async def root():
    return {
        "app": settings.app_name,
        "version": "1.0.0",
        "status": "running",
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
