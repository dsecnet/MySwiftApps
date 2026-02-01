from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config import get_settings
from app.routers import auth, users, workouts, food, plans, uploads, admin, ai, location

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    description="CoreVia Fitness & Nutrition Backend API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS - iOS app-dan gelen request-lere icaze ver
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
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

# Static files - sekilleri serve etmek ucun
uploads_dir = Path(__file__).parent.parent / "uploads"
uploads_dir.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")


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
