from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database import get_db
from app.models.user import User, UserType
from app.models.workout import Workout
from app.models.food_entry import FoodEntry
from app.models.training_plan import TrainingPlan
from app.models.meal_plan import MealPlan
from app.schemas.user import TrainerDashboardStats, StudentSummary, StatsSummary
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/trainer", tags=["Trainer Dashboard"])


@router.get("/stats", response_model=TrainerDashboardStats)
async def get_trainer_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer dashboard statistikalarini qaytarir"""

    if current_user.user_type != UserType.trainer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only trainers can access dashboard stats",
        )

    students_query = select(User).where(User.trainer_id == current_user.id)
    result = await db.execute(students_query)
    students = result.scalars().all()

    total_subscribers = len(students)

    week_ago = datetime.utcnow() - timedelta(days=7)
    active_student_ids = set()

    for student in students:
        workout_count = await db.execute(
            select(func.count(Workout.id)).where(
                Workout.user_id == student.id,
                Workout.created_at >= week_ago,
            )
        )
        if workout_count.scalar() > 0:
            active_student_ids.add(student.id)

    active_students = len(active_student_ids)

    training_plans_result = await db.execute(
        select(func.count(TrainingPlan.id)).where(
            TrainingPlan.trainer_id == current_user.id
        )
    )
    total_training_plans = training_plans_result.scalar() or 0

    meal_plans_result = await db.execute(
        select(func.count(MealPlan.id)).where(
            MealPlan.trainer_id == current_user.id
        )
    )
    total_meal_plans = meal_plans_result.scalar() or 0

    price = current_user.price_per_session or 20.0
    monthly_earnings = total_subscribers * price * 4

    student_summaries = []
    all_workouts_total = 0
    all_week_workouts = 0
    weights = []

    for student in students:
        tp_count_result = await db.execute(
            select(func.count(TrainingPlan.id)).where(
                TrainingPlan.assigned_student_id == student.id,
                TrainingPlan.trainer_id == current_user.id,
            )
        )
        tp_count = tp_count_result.scalar() or 0

        mp_count_result = await db.execute(
            select(func.count(MealPlan.id)).where(
                MealPlan.assigned_student_id == student.id,
                MealPlan.trainer_id == current_user.id,
            )
        )
        mp_count = mp_count_result.scalar() or 0

        total_workouts_result = await db.execute(
            select(func.count(Workout.id)).where(Workout.user_id == student.id)
        )
        total_workouts = total_workouts_result.scalar() or 0

        week_workouts_result = await db.execute(
            select(func.count(Workout.id)).where(
                Workout.user_id == student.id,
                Workout.created_at >= week_ago,
            )
        )
        this_week_workouts = week_workouts_result.scalar() or 0

        total_cal_result = await db.execute(
            select(func.coalesce(func.sum(FoodEntry.calories), 0)).where(
                FoodEntry.user_id == student.id
            )
        )
        total_calories = int(total_cal_result.scalar() or 0)

        student_summaries.append(
            StudentSummary(
                id=student.id,
                name=student.name,
                email=student.email,
                weight=student.weight,
                height=student.height,
                goal=student.goal,
                age=student.age,
                profile_image_url=student.profile_image_url,
                training_plans_count=tp_count,
                meal_plans_count=mp_count,
                total_workouts=total_workouts,
                this_week_workouts=this_week_workouts,
                total_calories_logged=total_calories,
            )
        )

        all_workouts_total += total_workouts
        all_week_workouts += this_week_workouts
        if student.weight:
            weights.append(student.weight)

    avg_week = (all_week_workouts / total_subscribers) if total_subscribers > 0 else 0.0
    avg_weight = (sum(weights) / len(weights)) if weights else 0.0

    stats_summary = StatsSummary(
        avg_student_workouts_per_week=round(avg_week, 1),
        total_workouts_all_students=all_workouts_total,
        avg_student_weight=round(avg_weight, 1),
    )

    return TrainerDashboardStats(
        total_subscribers=total_subscribers,
        active_students=active_students,
        monthly_earnings=round(monthly_earnings, 2),
        currency="₼",
        total_training_plans=total_training_plans,
        total_meal_plans=total_meal_plans,
        students=student_summaries,
        stats_summary=stats_summary,
    )
