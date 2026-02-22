from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
import base64

from app.database import get_db
from app.models.user import User
from app.models.food_entry import FoodEntry, MealType
from app.schemas.food import FoodEntryCreate, FoodEntryUpdate, FoodEntryResponse, DailyNutritionSummary
from app.utils.security import get_current_user
from app.services.ai_food_service import ai_food_service

router = APIRouter(prefix="/api/v1/food", tags=["Food"])


@router.post("/", response_model=FoodEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_food_entry(
    food_data: FoodEntryCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    entry = FoodEntry(
        user_id=current_user.id,
        name=food_data.name,
        calories=food_data.calories,
        protein=food_data.protein,
        carbs=food_data.carbs,
        fats=food_data.fats,
        meal_type=food_data.meal_type,
        date=food_data.date or datetime.utcnow(),
        notes=food_data.notes,
    )
    db.add(entry)
    await db.flush()
    return entry


@router.get("/", response_model=list[FoodEntryResponse])
async def get_food_entries(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    meal_type: MealType | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
):
    query = select(FoodEntry).where(FoodEntry.user_id == current_user.id)

    if meal_type:
        query = query.where(FoodEntry.meal_type == meal_type)
    if date_from:
        query = query.where(FoodEntry.date >= date_from)
    if date_to:
        query = query.where(FoodEntry.date <= date_to)

    query = query.order_by(FoodEntry.date.desc())
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/today", response_model=list[FoodEntryResponse])
async def get_today_food(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)

    result = await db.execute(
        select(FoodEntry)
        .where(FoodEntry.user_id == current_user.id, FoodEntry.date >= today_start, FoodEntry.date < today_end)
        .order_by(FoodEntry.date.desc())
    )
    return result.scalars().all()


@router.get("/daily-summary", response_model=DailyNutritionSummary)
async def get_daily_summary(
    date: str | None = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if date:
        target_date = datetime.strptime(date, "%Y-%m-%d")
    else:
        target_date = datetime.utcnow()

    day_start = target_date.replace(hour=0, minute=0, second=0, microsecond=0)
    day_end = day_start + timedelta(days=1)

    result = await db.execute(
        select(
            func.count(FoodEntry.id),
            func.coalesce(func.sum(FoodEntry.calories), 0),
            func.coalesce(func.sum(FoodEntry.protein), 0.0),
            func.coalesce(func.sum(FoodEntry.carbs), 0.0),
            func.coalesce(func.sum(FoodEntry.fats), 0.0),
        ).where(
            FoodEntry.user_id == current_user.id,
            FoodEntry.date >= day_start,
            FoodEntry.date < day_end,
        )
    )
    row = result.one()

    # Kalori hedofi user weight/goal-a gore hesablanir
    daily_goal = 2000  # default
    if current_user.weight and current_user.weight > 0:
        bmr = int(current_user.weight * 24)  # Simplified Mifflin-St Jeor
        goal_str = (current_user.goal or "").lower()
        if goal_str in ("weight_loss", "lose_weight", "cut", "ariqlamaq"):
            daily_goal = int(bmr * 0.8)
        elif goal_str in ("weight_gain", "gain_weight", "bulk", "ezele_toplamaq"):
            daily_goal = int(bmr * 1.15)
        else:
            daily_goal = bmr
        daily_goal = max(1200, min(5000, daily_goal))

    return DailyNutritionSummary(
        date=day_start.strftime("%Y-%m-%d"),
        total_calories=int(row[1]),
        total_protein=float(row[2]),
        total_carbs=float(row[3]),
        total_fats=float(row[4]),
        meal_count=row[0],
        daily_calorie_goal=daily_goal,
        remaining_calories=daily_goal - int(row[1]),
    )


@router.get("/{entry_id}", response_model=FoodEntryResponse)
async def get_food_entry(
    entry_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(FoodEntry).where(FoodEntry.id == entry_id, FoodEntry.user_id == current_user.id)
    )
    entry = result.scalar_one_or_none()
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Qida qeydi tapilmadi")
    return entry


@router.put("/{entry_id}", response_model=FoodEntryResponse)
async def update_food_entry(
    entry_id: str,
    food_data: FoodEntryUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(FoodEntry).where(FoodEntry.id == entry_id, FoodEntry.user_id == current_user.id)
    )
    entry = result.scalar_one_or_none()
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Qida qeydi tapilmadi")

    update_data = food_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(entry, field, value)
    return entry


@router.delete("/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_food_entry(
    entry_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(FoodEntry).where(FoodEntry.id == entry_id, FoodEntry.user_id == current_user.id)
    )
    entry = result.scalar_one_or_none()
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Qida qeydi tapilmadi")

    await db.delete(entry)


@router.post("/analyze")
async def analyze_food_image(
    file: UploadFile = File(...),
    language: str = "az",
    current_user: User = Depends(get_current_user),
):
    """
    AI Food Analysis Endpoint

    Accepts image upload, analyzes with Claude Vision API, returns nutritional info.

    Args:
        file: Image file (JPEG, PNG)
        language: Response language (az, en, tr, ru)
        current_user: Authenticated user

    Returns:
        {
            "success": bool,
            "food_name": str,
            "calories": int,
            "protein": float,
            "carbs": float,
            "fats": float,
            "portion_size": str,
            "confidence": float
        }
    """

    # Validate file type
    if file.content_type not in ["image/jpeg", "image/jpg", "image/png"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Yalnız JPEG və PNG formatları dəstəklənir"
        )

    # Validate file size (max 10MB)
    contents = await file.read()
    if len(contents) > 10 * 1024 * 1024:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Şəkil ölçüsü 10MB-dan çox ola bilməz"
        )

    # Convert to base64
    image_base64 = base64.b64encode(contents).decode("utf-8")

    # Determine media type
    media_type = file.content_type or "image/jpeg"

    # Analyze with AI
    result = await ai_food_service.analyze_food_image(
        image_base64=image_base64,
        language=language,
        media_type=media_type,
    )

    # If AI analysis failed, return HTTP error so Android gets proper exception
    if not result.get("success", False):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=result.get("error", "AI analizi uğursuz oldu")
        )

    return result
