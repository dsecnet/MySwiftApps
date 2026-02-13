"""
News Router - Fitness xəbərləri API
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import logging

from app.database import get_db
from app.models.user import User
from app.utils.security import get_current_user
from app.services.fitness_news_service import fitness_news_service

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/news", tags=["Fitness News"])


class NewsArticle(BaseModel):
    """Fitness xəbər article model"""
    id: str
    title: str
    summary: str
    category: str
    source: str
    reading_time: int  # minutes
    image_description: str
    published_at: str


class NewsResponse(BaseModel):
    """News list response"""
    articles: List[NewsArticle]
    total: int
    cache_status: str  # "fresh" or "cached"


@router.get("/", response_model=NewsResponse)
async def get_fitness_news(
    limit: int = Query(10, ge=1, le=50, description="Xəbər sayı"),
    force_refresh: bool = Query(False, description="Cache-i yenilə"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Fitness xəbərlərini gətir

    - AI ilə internetdən fitness xəbərləri toplayır
    - 2 saat cache edir (force_refresh=true ilə yeniləyə bilərsən)
    - Categories: Workout, Nutrition, Research, Tips, Lifestyle
    """
    try:
        logger.info(f"News request from user {current_user.email}, limit={limit}, force_refresh={force_refresh}")

        # Service-dən xəbərləri al
        articles_data = await fitness_news_service.get_fitness_news(
            limit=limit,
            force_refresh=force_refresh
        )

        logger.info(f"Successfully fetched {len(articles_data)} news articles")

        # Cache status təyin et
        cache_status = "fresh" if force_refresh else "cached"
        if not fitness_news_service._cache_time:
            cache_status = "fresh"

        # Response hazırla
        articles = [NewsArticle(**article) for article in articles_data]

        return NewsResponse(
            articles=articles,
            total=len(articles),
            cache_status=cache_status
        )

    except Exception as e:
        logger.error(f"Error fetching news: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Xəbərləri yükləyərkən xəta: {str(e)}"
        )


@router.get("/categories")
async def get_news_categories(
    current_user: User = Depends(get_current_user)
):
    """
    Mövcud news kategoriyaları
    """
    return {
        "categories": [
            {"id": "workout", "name": "Workout", "icon": "dumbbell"},
            {"id": "nutrition", "name": "Nutrition", "icon": "apple"},
            {"id": "research", "name": "Research", "icon": "microscope"},
            {"id": "tips", "name": "Tips", "icon": "lightbulb"},
            {"id": "lifestyle", "name": "Lifestyle", "icon": "heart"},
        ]
    }


@router.get("/{article_id}")
async def get_news_article(
    article_id: str,
    current_user: User = Depends(get_current_user)
):
    """
    Bir xəbərin detaylarını gətir
    """
    # Cache-dən tap
    articles = await fitness_news_service.get_fitness_news(limit=50)
    article = next((a for a in articles if a["id"] == article_id), None)

    if not article:
        raise HTTPException(status_code=404, detail="Xəbər tapılmadı")

    return article


@router.post("/refresh")
async def refresh_news_cache(
    current_user: User = Depends(get_current_user)
):
    """
    News cache-ini yenilə (admin/manual refresh)
    """
    try:
        articles = await fitness_news_service.get_fitness_news(
            limit=50,
            force_refresh=True
        )

        return {
            "success": True,
            "message": "Xəbərlər yeniləndi",
            "count": len(articles),
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Xəbərləri yeniləyərkən xəta: {str(e)}"
        )
