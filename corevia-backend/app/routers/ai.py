from datetime import datetime, date, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc

from app.database import get_db
from app.models.user import User
from app.models.workout import Workout
from app.models.food_entry import FoodEntry, MealType
from app.models.daily_survey import DailySurvey
from app.models.training_plan import TrainingPlan
from app.models.meal_plan import MealPlan
from app.schemas.food import FoodEntryResponse
from app.utils.security import get_current_user, get_premium_user
from app.services.ai_service import analyze_food_image, get_user_recommendations
from app.services.file_service import save_upload

router = APIRouter(prefix="/api/v1/ai", tags=["AI"])


# ──────────────────────────────────────────────
# FOOD ANALYSIS (Premium)
# ──────────────────────────────────────────────

@router.post("/analyze-food")
async def analyze_food(
    file: UploadFile = File(...),
    current_user: User = Depends(get_premium_user),
    db: AsyncSession = Depends(get_db),
):
    """Sekili upload et, AI ile analiz et — Premium lazimdir"""
    content = await file.read()

    analysis = await analyze_food_image(content)

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

    analysis = await analyze_food_image(content)

    if "error" in analysis:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=analysis["error"])

    await file.seek(0)
    file_path = await save_upload(file, "food")

    meal_type_str = analysis.get("meal_type", "lunch")
    try:
        meal_type = MealType(meal_type_str)
    except ValueError:
        meal_type = MealType.lunch

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
    await db.commit()
    await db.refresh(entry)
    return entry


# ──────────────────────────────────────────────
# RECOMMENDATIONS (Hamisi ucun — premium deYIL)
# ──────────────────────────────────────────────

@router.get("/recommendations")
async def get_recommendations(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """AI tovsiyeler — butun istifadeciler ucun (client + trainer)"""
    now = datetime.utcnow()
    week_ago = now - timedelta(days=7)
    two_weeks_ago = now - timedelta(days=14)

    # ── Bu heftenin datalari ──
    user_data = await _build_user_data(db, current_user, week_ago, now)

    # ── Kecen heftenin datalari (muqayise ucun) ──
    prev_week_data = await _build_prev_week_data(db, current_user, two_weeks_ago, week_ago)

    # ── Trainer ucun: telebe datalari ──
    students_data = None
    if current_user.user_type == "trainer":
        students_data = await _build_students_data(db, current_user.id, week_ago)

    # ── Son daily survey ──
    survey_result = await db.execute(
        select(DailySurvey)
        .where(DailySurvey.user_id == current_user.id)
        .order_by(desc(DailySurvey.date))
        .limit(1)
    )
    latest_survey = survey_result.scalar_one_or_none()

    survey_data = None
    if latest_survey:
        survey_data = {
            "energy_level": latest_survey.energy_level,
            "sleep_hours": latest_survey.sleep_hours,
            "sleep_quality": latest_survey.sleep_quality,
            "stress_level": latest_survey.stress_level,
            "muscle_soreness": latest_survey.muscle_soreness,
            "mood": latest_survey.mood,
            "water_glasses": latest_survey.water_glasses,
        }

    user_data["survey_data"] = survey_data

    # ── Dil secimi ──
    language = getattr(current_user, "language", "az") or "az"

    recommendations = await get_user_recommendations(
        user_data=user_data,
        prev_week_data=prev_week_data,
        students_data=students_data,
        language=language,
    )

    if "error" in recommendations:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=recommendations["error"],
        )

    return recommendations


# ──────────────────────────────────────────────
# HELPER FUNCTIONS
# ──────────────────────────────────────────────

async def _build_user_data(
    db: AsyncSession, user: User, from_date: datetime, to_date: datetime
) -> dict:
    """User profil + heftelik workout/qidalanma datalarini topla"""

    # Workout stats
    workout_result = await db.execute(
        select(
            func.count(Workout.id),
            func.coalesce(func.sum(Workout.duration), 0),
            func.coalesce(func.sum(Workout.calories_burned), 0),
        ).where(
            Workout.user_id == user.id,
            Workout.date >= from_date,
            Workout.date < to_date,
        )
    )
    w = workout_result.one()

    # Food stats
    food_result = await db.execute(
        select(
            func.count(FoodEntry.id),
            func.coalesce(func.sum(FoodEntry.calories), 0),
            func.coalesce(func.sum(FoodEntry.protein), 0.0),
            func.coalesce(func.sum(FoodEntry.carbs), 0.0),
            func.coalesce(func.sum(FoodEntry.fats), 0.0),
        ).where(
            FoodEntry.user_id == user.id,
            FoodEntry.date >= from_date,
            FoodEntry.date < to_date,
        )
    )
    f = food_result.one()

    return {
        "ad": user.name,
        "yas": user.age,
        "ceki": user.weight,
        "boy": user.height,
        "meqsed": user.goal,
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


async def _build_prev_week_data(
    db: AsyncSession, user: User, from_date: datetime, to_date: datetime
) -> dict:
    """Kecen heftenin datalarini topla (muqayise ucun)"""

    workout_result = await db.execute(
        select(
            func.count(Workout.id),
            func.coalesce(func.sum(Workout.duration), 0),
            func.coalesce(func.sum(Workout.calories_burned), 0),
        ).where(
            Workout.user_id == user.id,
            Workout.date >= from_date,
            Workout.date < to_date,
        )
    )
    w = workout_result.one()

    food_result = await db.execute(
        select(
            func.count(FoodEntry.id),
            func.coalesce(func.sum(FoodEntry.calories), 0),
            func.coalesce(func.sum(FoodEntry.protein), 0.0),
            func.coalesce(func.sum(FoodEntry.carbs), 0.0),
            func.coalesce(func.sum(FoodEntry.fats), 0.0),
        ).where(
            FoodEntry.user_id == user.id,
            FoodEntry.date >= from_date,
            FoodEntry.date < to_date,
        )
    )
    f = food_result.one()

    return {
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


async def _build_students_data(
    db: AsyncSession, trainer_id: str, week_ago: datetime
) -> list:
    """Trainerin telebelerinin datalarini topla"""

    # Trainerin telebeleri
    students_result = await db.execute(
        select(User).where(
            User.trainer_id == trainer_id,
            User.is_active == True,
        )
    )
    students = students_result.scalars().all()

    if not students:
        return []

    students_data = []
    for student in students:
        # Bu heftenin mesqleri
        wk_result = await db.execute(
            select(func.count(Workout.id)).where(
                Workout.user_id == student.id,
                Workout.date >= week_ago,
            )
        )
        week_workouts = wk_result.scalar() or 0

        # Umumi mesq sayi
        total_wk_result = await db.execute(
            select(func.count(Workout.id)).where(
                Workout.user_id == student.id,
            )
        )
        total_workouts = total_wk_result.scalar() or 0

        # Teyin olunmus training plan sayi
        tp_result = await db.execute(
            select(func.count(TrainingPlan.id)).where(
                TrainingPlan.assigned_student_id == student.id,
                TrainingPlan.is_completed == False,
            )
        )
        training_plans_count = tp_result.scalar() or 0

        # Teyin olunmus meal plan sayi
        mp_result = await db.execute(
            select(func.count(MealPlan.id)).where(
                MealPlan.assigned_student_id == student.id,
                MealPlan.is_completed == False,
            )
        )
        meal_plans_count = mp_result.scalar() or 0

        students_data.append({
            "name": student.name or "Tələbə",
            "this_week_workouts": week_workouts,
            "total_workouts": total_workouts,
            "training_plans_count": training_plans_count,
            "meal_plans_count": meal_plans_count,
            "weight": student.weight,
            "goal": student.goal,
        })

    return students_data
