from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.user import User
from app.models.onboarding import UserOnboarding
from app.schemas.onboarding import OnboardingCreate, OnboardingResponse, OnboardingOptions
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/onboarding", tags=["Onboarding"])


@router.get("/options", response_model=OnboardingOptions)
async def get_onboarding_options():
    """Onboarding secimlerini getir."""
    return OnboardingOptions(
        goals=[
            {"id": "weight_loss", "name_az": "Arıqlamaq", "name_en": "Lose Weight", "name_ru": "Похудеть", "icon": "flame.fill"},
            {"id": "muscle_gain", "name_az": "Əzələ toplamaq", "name_en": "Build Muscle", "name_ru": "Набрать массу", "icon": "dumbbell.fill"},
            {"id": "stay_fit", "name_az": "Formda qalmaq", "name_en": "Stay Fit", "name_ru": "Оставаться в форме", "icon": "heart.fill"},
            {"id": "flexibility", "name_az": "Çeviklik", "name_en": "Flexibility", "name_ru": "Гибкость", "icon": "figure.yoga"},
            {"id": "endurance", "name_az": "Dözümlülük", "name_en": "Endurance", "name_ru": "Выносливость", "icon": "figure.run"},
        ],
        fitness_levels=[
            {"id": "beginner", "name_az": "Yeni başlayan", "name_en": "Beginner", "name_ru": "Новичок", "icon": "leaf.fill"},
            {"id": "intermediate", "name_az": "Orta", "name_en": "Intermediate", "name_ru": "Средний", "icon": "bolt.fill"},
            {"id": "advanced", "name_az": "İrəliləmiş", "name_en": "Advanced", "name_ru": "Продвинутый", "icon": "star.fill"},
        ],
        trainer_types=[
            {"id": "fitness", "name_az": "Fitness", "name_en": "Fitness", "name_ru": "Фитнес", "icon": "figure.strengthtraining.traditional"},
            {"id": "yoga", "name_az": "Yoga", "name_en": "Yoga", "name_ru": "Йога", "icon": "figure.yoga"},
            {"id": "cardio", "name_az": "Kardio", "name_en": "Cardio", "name_ru": "Кардио", "icon": "heart.fill"},
            {"id": "nutrition", "name_az": "Qidalanma", "name_en": "Nutrition", "name_ru": "Питание", "icon": "leaf.fill"},
            {"id": "strength", "name_az": "Güc məşqi", "name_en": "Strength", "name_ru": "Силовые", "icon": "dumbbell.fill"},
        ],
    )


@router.post("/complete", response_model=OnboardingResponse)
async def complete_onboarding(
    data: OnboardingCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Onboarding-i tamamla."""
    result = await db.execute(
        select(UserOnboarding).where(UserOnboarding.user_id == current_user.id)
    )
    existing = result.scalar_one_or_none()

    if existing:
        existing.fitness_goal = data.fitness_goal
        existing.fitness_level = data.fitness_level
        existing.preferred_trainer_type = data.preferred_trainer_type
        existing.is_completed = True
        existing.completed_at = datetime.utcnow()
        onboarding = existing
    else:
        onboarding = UserOnboarding(
            user_id=current_user.id,
            fitness_goal=data.fitness_goal,
            fitness_level=data.fitness_level,
            preferred_trainer_type=data.preferred_trainer_type,
            is_completed=True,
            completed_at=datetime.utcnow(),
        )
        db.add(onboarding)

    # User-in goal-unu da yenile
    current_user.goal = data.fitness_goal

    await db.flush()
    return onboarding


@router.get("/status", response_model=OnboardingResponse | None)
async def get_onboarding_status(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Onboarding statusunu yoxla."""
    result = await db.execute(
        select(UserOnboarding).where(UserOnboarding.user_id == current_user.id)
    )
    onboarding = result.scalar_one_or_none()
    if not onboarding:
        return None
    return onboarding
