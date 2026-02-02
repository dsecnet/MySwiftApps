from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database import get_db
from app.models.user import User
from app.models.workout import Workout
from app.models.food_entry import FoodEntry, MealType
from app.schemas.food import FoodEntryResponse
from app.utils.security import get_current_user, get_premium_user
from app.services.ai_service import analyze_food_image, get_user_recommendations
from app.services.file_service import save_upload

router = APIRouter(prefix="/api/v1/ai", tags=["AI"])


@router.post("/analyze-food")
async def analyze_food(
    file: UploadFile = File(...),
    current_user: User = Depends(get_premium_user),
    db: AsyncSession = Depends(get_db),
):
    """Sekili upload et, AI ile analiz et — Premium lazimdir"""
    content = await file.read()

    # AI analiz
    analysis = analyze_food_image(content)

    # Eger async ise await et
    if hasattr(analysis, "__await__"):
        analysis = await analysis

    if "error" in analysis:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=analysis["error"])

    return analysis


@router.post("/analyze-and-save", response_model=FoodEntryResponse)
async def analyze_and_save(
    file: UploadFile = File(...),
    current_user: User = Depends(get_premium_user),
    db: AsyncSession = Depends(get_db),
):
    """Sekili upload et, AI analiz et, saxla — Premium lazimdir"""
    content = await file.read()

    # AI analiz
    analysis = analyze_food_image(content)
    if hasattr(analysis, "__await__"):
        analysis = await analysis

    if "error" in analysis:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=analysis["error"])

    # Sekili saxla
    await file.seek(0)
    file_path = await save_upload(file, "food")

    # Meal type mapping
    meal_type_str = analysis.get("meal_type", "lunch")
    try:
        meal_type = MealType(meal_type_str)
    except ValueError:
        meal_type = MealType.lunch

    # Food entry yarat
    food_name = ", ".join(f["name"] for f in analysis.get("foods", [])) or "AI analiz olunmus yemek"

    entry = FoodEntry(
        user_id=current_user.id,
        name=food_name,
        calories=analysis.get("total_calories", 0),
        protein=analysis.get("total_protein"),
        carbs=analysis.get("total_carbs"),
        fats=analysis.get("total_fats"),
        meal_type=meal_type,
        date=datetime.utcnow(),
        has_image=True,
        image_url=file_path,
        ai_analyzed=True,
        ai_confidence=analysis.get("confidence", 0),
    )
    db.add(entry)
    await db.flush()
    return entry


@router.get("/recommendations")
async def get_recommendations(
    current_user: User = Depends(get_premium_user),
    db: AsyncSession = Depends(get_db),
):
    """AI tovsiyeler — Premium lazimdir"""
    week_ago = datetime.utcnow() - timedelta(days=7)

    # Heftelik workout stats
    workout_result = await db.execute(
        select(
            func.count(Workout.id),
            func.coalesce(func.sum(Workout.duration), 0),
            func.coalesce(func.sum(Workout.calories_burned), 0),
        ).where(Workout.user_id == current_user.id, Workout.date >= week_ago)
    )
    w = workout_result.one()

    # Heftelik nutrition stats
    food_result = await db.execute(
        select(
            func.count(FoodEntry.id),
            func.coalesce(func.sum(FoodEntry.calories), 0),
            func.coalesce(func.sum(FoodEntry.protein), 0.0),
            func.coalesce(func.sum(FoodEntry.carbs), 0.0),
            func.coalesce(func.sum(FoodEntry.fats), 0.0),
        ).where(FoodEntry.user_id == current_user.id, FoodEntry.date >= week_ago)
    )
    f = food_result.one()

    user_data = {
        "ad": current_user.name,
        "yas": current_user.age,
        "ceki": current_user.weight,
        "boy": current_user.height,
        "meqsed": current_user.goal,
        "heftelik_mesq": {
            "mesq_sayi": w[0],
            "umumi_deqiqe": int(w[1]),
            "yandirilan_kalori": int(w[2]),
        },
        "heftelik_qidalanma": {
            "yemek_sayi": f[0],
            "umumi_kalori": int(f[1]),
            "umumi_protein": float(f[2]),
            "umumi_karbohidrat": float(f[3]),
            "umumi_yag": float(f[4]),
            "gunluk_ortalama_kalori": int(f[1]) // 7 if f[1] else 0,
        },
    }

    recommendations = get_user_recommendations(user_data)
    if hasattr(recommendations, "__await__"):
        recommendations = await recommendations

    if "error" in recommendations:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=recommendations["error"])

    # User datalarini da qaytaraq ki iOS app gostere bilsin
    recommendations["user_stats"] = user_data
    return recommendations
