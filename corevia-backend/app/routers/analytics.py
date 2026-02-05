"""
Analytics Router - OWASP A01:2021 Compliant
Only user can access their own analytics data
"""

import logging
from datetime import date, datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, desc
from typing import Optional

from app.database import get_db
from app.models.user import User
from app.models.analytics import DailyStats, WeeklyStats, BodyMeasurement
from app.models.workout import Workout
from app.models.food_entry import FoodEntry
from app.schemas.analytics import (
    DailyStatsResponse,
    WeeklyStatsResponse,
    BodyMeasurementCreate,
    BodyMeasurementResponse,
    AnalyticsDashboardResponse,
    ProgressTrend,
    WorkoutTrend,
    NutritionTrend,
    ComparisonPeriod,
    ProgressComparisonResponse,
)
from app.utils.security import get_current_user

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/analytics", tags=["Analytics"])


# ============================================================
# DAILY STATS (Auto-generated from workouts/food)
# ============================================================

async def calculate_daily_stats(user_id: str, target_date: date, db: AsyncSession) -> DailyStatsResponse:
    """
    Calculate daily stats from workouts and food entries
    OWASP A01 - Only for current user
    """
    # Get workouts for the day
    workout_result = await db.execute(
        select(Workout).where(
            and_(
                Workout.user_id == user_id,
                func.date(Workout.date) == target_date
            )
        )
    )
    workouts = workout_result.scalars().all()

    # Get food entries for the day
    food_result = await db.execute(
        select(FoodEntry).where(
            and_(
                FoodEntry.user_id == user_id,
                func.date(FoodEntry.date) == target_date
            )
        )
    )
    foods = food_result.scalars().all()

    # Calculate workout stats
    workouts_completed = len([w for w in workouts if w.is_completed])
    total_workout_minutes = sum(w.duration for w in workouts)
    calories_burned = sum(w.calories_burned or 0 for w in workouts)
    distance_km = sum(w.distance_km or 0 for w in workouts)

    # Calculate nutrition stats
    calories_consumed = sum(f.calories for f in foods)
    protein_g = sum(f.protein or 0 for f in foods)
    carbs_g = sum(f.carbs or 0 for f in foods)
    fats_g = sum(f.fats or 0 for f in foods)

    # Get body measurement for the day
    measurement_result = await db.execute(
        select(BodyMeasurement).where(
            and_(
                BodyMeasurement.user_id == user_id,
                BodyMeasurement.measured_at == target_date
            )
        ).order_by(desc(BodyMeasurement.created_at)).limit(1)
    )
    measurement = measurement_result.scalar_one_or_none()

    return DailyStatsResponse(
        date=target_date,
        workouts_completed=workouts_completed,
        total_workout_minutes=total_workout_minutes,
        calories_burned=calories_burned,
        distance_km=distance_km,
        calories_consumed=calories_consumed,
        protein_g=protein_g,
        carbs_g=carbs_g,
        fats_g=fats_g,
        weight_kg=measurement.weight_kg if measurement else None,
        body_fat_percent=measurement.body_fat_percent if measurement else None,
    )


@router.get("/daily/{date}", response_model=DailyStatsResponse)
async def get_daily_stats(
    date: date,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get daily statistics for specific date
    OWASP A01 - Authorization: Own data only
    """
    return await calculate_daily_stats(current_user.id, date, db)


@router.get("/weekly", response_model=list[DailyStatsResponse])
async def get_weekly_stats(
    start_date: Optional[date] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get daily stats for a week (7 days) - OWASP A01"""
    if start_date is None:
        start_date = date.today() - timedelta(days=6)

    stats = []
    for i in range(7):
        day = start_date + timedelta(days=i)
        daily_stat = await calculate_daily_stats(current_user.id, day, db)
        stats.append(daily_stat)

    return stats


# ============================================================
# BODY MEASUREMENTS
# ============================================================

@router.post("/measurements", response_model=BodyMeasurementResponse, status_code=status.HTTP_201_CREATED)
async def create_body_measurement(
    measurement_data: BodyMeasurementCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create body measurement
    OWASP A03 - Input validation via Pydantic
    OWASP A01 - User can only create for themselves
    """
    measurement = BodyMeasurement(
        user_id=current_user.id,
        measured_at=measurement_data.measured_at,
        weight_kg=measurement_data.weight_kg,
        body_fat_percent=measurement_data.body_fat_percent,
        muscle_mass_kg=measurement_data.muscle_mass_kg,
        chest_cm=measurement_data.chest_cm,
        waist_cm=measurement_data.waist_cm,
        hips_cm=measurement_data.hips_cm,
        arms_cm=measurement_data.arms_cm,
        legs_cm=measurement_data.legs_cm,
        notes=measurement_data.notes,
    )
    db.add(measurement)
    await db.commit()
    await db.refresh(measurement)

    logger.info(f"Body measurement created for user {current_user.id}")

    return measurement


@router.get("/measurements", response_model=list[BodyMeasurementResponse])
async def get_body_measurements(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get body measurements - OWASP A01"""
    query = select(BodyMeasurement).where(BodyMeasurement.user_id == current_user.id)

    if start_date:
        query = query.where(BodyMeasurement.measured_at >= start_date)
    if end_date:
        query = query.where(BodyMeasurement.measured_at <= end_date)

    query = query.order_by(desc(BodyMeasurement.measured_at))

    result = await db.execute(query)
    measurements = result.scalars().all()

    return [BodyMeasurementResponse.model_validate(m) for m in measurements]


@router.delete("/measurements/{measurement_id}")
async def delete_body_measurement(
    measurement_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete body measurement - OWASP A01 Ownership check"""
    result = await db.execute(
        select(BodyMeasurement).where(BodyMeasurement.id == measurement_id)
    )
    measurement = result.scalar_one_or_none()

    if not measurement:
        raise HTTPException(status_code=404, detail="Ölçü tapılmadı")

    # Authorization check - OWASP A01
    if measurement.user_id != current_user.id:
        logger.warning(f"Unauthorized delete attempt: user {current_user.id} to measurement {measurement_id}")
        raise HTTPException(status_code=403, detail="Bu ölçü sizə aid deyil")

    await db.delete(measurement)
    await db.commit()

    logger.info(f"Measurement deleted: {measurement_id} by user {current_user.id}")

    return {"message": "Ölçü silindi"}


# ============================================================
# ANALYTICS DASHBOARD
# ============================================================

@router.get("/dashboard", response_model=AnalyticsDashboardResponse)
async def get_analytics_dashboard(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Complete analytics dashboard
    OWASP A01 - Own data only
    """
    today = date.today()
    thirty_days_ago = today - timedelta(days=30)
    seven_days_ago = today - timedelta(days=6)

    # Current week stats (last 7 days)
    week_stats_list = []
    total_workouts = 0
    total_minutes = 0
    total_calories_burned = 0
    total_calories_consumed = 0

    for i in range(7):
        day = seven_days_ago + timedelta(days=i)
        daily_stat = await calculate_daily_stats(current_user.id, day, db)
        week_stats_list.append(daily_stat)
        total_workouts += daily_stat.workouts_completed
        total_minutes += daily_stat.total_workout_minutes
        total_calories_burned += daily_stat.calories_burned
        total_calories_consumed += daily_stat.calories_consumed

    current_week = WeeklyStatsResponse(
        week_start=seven_days_ago,
        week_end=today,
        workouts_completed=total_workouts,
        total_workout_minutes=total_minutes,
        calories_burned=total_calories_burned,
        calories_consumed=total_calories_consumed,
        distance_km=sum(s.distance_km for s in week_stats_list),
        avg_daily_calories_burned=total_calories_burned // 7,
        avg_daily_calories_consumed=total_calories_consumed // 7,
        weight_change_kg=None,  # TODO: Calculate from measurements
        workout_consistency_percent=(total_workouts * 100) // 7,  # Percentage of days worked out
    )

    # Weight trend (last 30 days)
    measurements_result = await db.execute(
        select(BodyMeasurement).where(
            and_(
                BodyMeasurement.user_id == current_user.id,
                BodyMeasurement.measured_at >= thirty_days_ago
            )
        ).order_by(BodyMeasurement.measured_at)
    )
    measurements = measurements_result.scalars().all()

    weight_trend = []
    prev_weight = None
    for m in measurements:
        change = (m.weight_kg - prev_weight) if prev_weight else None
        weight_trend.append(ProgressTrend(
            date=m.measured_at,
            value=m.weight_kg,
            change_from_previous=change,
        ))
        prev_weight = m.weight_kg

    # Workout trend (last 30 days)
    workout_trend = []
    for i in range(30):
        day = thirty_days_ago + timedelta(days=i)
        daily_stat = await calculate_daily_stats(current_user.id, day, db)
        workout_trend.append(WorkoutTrend(
            date=day,
            workouts_count=daily_stat.workouts_completed,
            minutes=daily_stat.total_workout_minutes,
            calories=daily_stat.calories_burned,
        ))

    # Nutrition trend (last 30 days)
    nutrition_trend = []
    for i in range(30):
        day = thirty_days_ago + timedelta(days=i)
        daily_stat = await calculate_daily_stats(current_user.id, day, db)
        nutrition_trend.append(NutritionTrend(
            date=day,
            calories=daily_stat.calories_consumed,
            protein=daily_stat.protein_g,
            carbs=daily_stat.carbs_g,
            fats=daily_stat.fats_g,
        ))

    # Summary stats
    total_workouts_30d = sum(t.workouts_count for t in workout_trend)
    total_minutes_30d = sum(t.minutes for t in workout_trend)
    total_calories_burned_30d = sum(t.calories for t in workout_trend)
    avg_daily_calories = sum(t.calories for t in nutrition_trend) // 30

    # Calculate workout streak
    workout_streak = 0
    for i in range(30):
        day = today - timedelta(days=i)
        daily_stat = await calculate_daily_stats(current_user.id, day, db)
        if daily_stat.workouts_completed > 0:
            workout_streak += 1
        else:
            break  # Streak broken

    return AnalyticsDashboardResponse(
        current_week=current_week,
        weight_trend=weight_trend,
        workout_trend=workout_trend,
        nutrition_trend=nutrition_trend,
        total_workouts_30d=total_workouts_30d,
        total_minutes_30d=total_minutes_30d,
        total_calories_burned_30d=total_calories_burned_30d,
        avg_daily_calories=avg_daily_calories,
        workout_streak_days=workout_streak,
    )


# ============================================================
# PROGRESS COMPARISON
# ============================================================

@router.get("/comparison", response_model=ProgressComparisonResponse)
async def get_progress_comparison(
    period: str = "week",  # week, month
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Compare current period with previous period
    OWASP A01 - Own data only
    """
    today = date.today()

    if period == "week":
        current_start = today - timedelta(days=6)
        current_end = today
        previous_start = today - timedelta(days=13)
        previous_end = today - timedelta(days=7)
        period_name_current = "This Week"
        period_name_previous = "Last Week"
    else:  # month
        current_start = today - timedelta(days=29)
        current_end = today
        previous_start = today - timedelta(days=59)
        previous_end = today - timedelta(days=30)
        period_name_current = "This Month"
        period_name_previous = "Last Month"

    # Calculate current period
    current_workouts = 0
    current_minutes = 0
    current_calories_burned = 0
    current_calories_consumed = 0

    days_diff = (current_end - current_start).days + 1
    for i in range(days_diff):
        day = current_start + timedelta(days=i)
        daily_stat = await calculate_daily_stats(current_user.id, day, db)
        current_workouts += daily_stat.workouts_completed
        current_minutes += daily_stat.total_workout_minutes
        current_calories_burned += daily_stat.calories_burned
        current_calories_consumed += daily_stat.calories_consumed

    # Calculate previous period
    previous_workouts = 0
    previous_minutes = 0
    previous_calories_burned = 0
    previous_calories_consumed = 0

    for i in range(days_diff):
        day = previous_start + timedelta(days=i)
        daily_stat = await calculate_daily_stats(current_user.id, day, db)
        previous_workouts += daily_stat.workouts_completed
        previous_minutes += daily_stat.total_workout_minutes
        previous_calories_burned += daily_stat.calories_burned
        previous_calories_consumed += daily_stat.calories_consumed

    # Calculate percentage changes
    workouts_change = ((current_workouts - previous_workouts) / previous_workouts * 100) if previous_workouts > 0 else 0
    minutes_change = ((current_minutes - previous_minutes) / previous_minutes * 100) if previous_minutes > 0 else 0
    calories_change = ((current_calories_burned - previous_calories_burned) / previous_calories_burned * 100) if previous_calories_burned > 0 else 0

    return ProgressComparisonResponse(
        current_period=ComparisonPeriod(
            period_name=period_name_current,
            workouts=current_workouts,
            minutes=current_minutes,
            calories_burned=current_calories_burned,
            calories_consumed=current_calories_consumed,
            weight_change=None,  # TODO: Calculate from measurements
        ),
        previous_period=ComparisonPeriod(
            period_name=period_name_previous,
            workouts=previous_workouts,
            minutes=previous_minutes,
            calories_burned=previous_calories_burned,
            calories_consumed=previous_calories_consumed,
            weight_change=None,
        ),
        workouts_change_percent=workouts_change,
        minutes_change_percent=minutes_change,
        calories_burned_change_percent=calories_change,
    )
