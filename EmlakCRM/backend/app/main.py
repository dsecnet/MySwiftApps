from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings

app = FastAPI(
    title=settings.app_name,
    description="🏠 Azərbaycan Əmlakçıları üçün CRM Sistemi",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {
        "message": "🏠 Əmlak CRM API",
        "version": "1.0.0",
        "status": "active",
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


# ============================================================
# MARK: - Routers
# ============================================================

from app.routers import auth, properties, clients, activities, deals, dashboard

app.include_router(auth.router)
app.include_router(properties.router)
app.include_router(clients.router)
app.include_router(activities.router)
app.include_router(deals.router)
app.include_router(dashboard.router)
