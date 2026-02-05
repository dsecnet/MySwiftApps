from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database import get_db
from app.models.user import User
from app.models.workout import Workout, WorkoutCategory
from app.schemas.workout import WorkoutCreate, WorkoutUpdate, WorkoutResponse
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/workouts", tags=["Workouts"])


@router.post("/", response_model=WorkoutResponse, status_code=status.HTTP_201_CREATED)
async def create_workout(
    workout_data: WorkoutCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    workout = Workout(
        user_id=current_user.id,
        title=workout_data.title,
        category=workout_data.category,
        duration=workout_data.duration,
        calories_burned=workout_data.calories_burned,
        notes=workout_data.notes,
        date=workout_data.date or datetime.utcnow(),
        latitude=workout_data.latitude,
        longitude=workout_data.longitude,
        route_data=workout_data.route_data,
        distance_km=workout_data.distance_km,
    )
    db.add(workout)
    await db.flush()
    return workout


@router.get("/", response_model=list[WorkoutResponse])
async def get_workouts(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    category: WorkoutCategory | None = None,
    is_completed: bool | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
):
    query = select(Workout).where(Workout.user_id == current_user.id)

    if category:
        query = query.where(Workout.category == category)
    if is_completed is not None:
        query = query.where(Workout.is_completed == is_completed)
    if date_from:
        query = query.where(Workout.date >= date_from)
    if date_to:
        query = query.where(Workout.date <= date_to)

    query = query.order_by(Workout.date.desc())
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/today", response_model=list[WorkoutResponse])
async def get_today_workouts(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)

    result = await db.execute(
        select(Workout)
        .where(Workout.user_id == current_user.id, Workout.date >= today_start, Workout.date < today_end)
        .order_by(Workout.date.desc())
    )
    return result.scalars().all()


@router.get("/stats")
async def get_workout_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = today_start - timedelta(days=today_start.weekday())

    today_result = await db.execute(
        select(
            func.count(Workout.id),
            func.coalesce(func.sum(Workout.duration), 0),
            func.coalesce(func.sum(Workout.calories_burned), 0),
        ).where(
            Workout.user_id == current_user.id,
            Workout.date >= today_start,
            Workout.date < today_start + timedelta(days=1),
        )
    )
    today = today_result.one()

    week_result = await db.execute(
        select(
            func.count(Workout.id),
            func.coalesce(func.sum(Workout.duration), 0),
            func.coalesce(func.sum(Workout.calories_burned), 0),
        ).where(
            Workout.user_id == current_user.id,
            Workout.date >= week_start,
        )
    )
    week = week_result.one()

    return {
        "today": {
            "workout_count": today[0],
            "total_minutes": today[1],
            "total_calories": today[2],
        },
        "this_week": {
            "workout_count": week[0],
            "total_minutes": week[1],
            "total_calories": week[2],
        },
    }


@router.get("/{workout_id}", response_model=WorkoutResponse)
async def get_workout(
    workout_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Workout).where(Workout.id == workout_id, Workout.user_id == current_user.id)
    )
    workout = result.scalar_one_or_none()
    if not workout:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workout tapilmadi")
    return workout


@router.put("/{workout_id}", response_model=WorkoutResponse)
async def update_workout(
    workout_id: str,
    workout_data: WorkoutUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Workout).where(Workout.id == workout_id, Workout.user_id == current_user.id)
    )
    workout = result.scalar_one_or_none()
    if not workout:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workout tapilmadi")

    update_data = workout_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(workout, field, value)
    return workout


@router.patch("/{workout_id}/toggle", response_model=WorkoutResponse)
async def toggle_workout(
    workout_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Workout).where(Workout.id == workout_id, Workout.user_id == current_user.id)
    )
    workout = result.scalar_one_or_none()
    if not workout:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workout tapilmadi")

    workout.is_completed = not workout.is_completed
    return workout


@router.delete("/{workout_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_workout(
    workout_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Workout).where(Workout.id == workout_id, Workout.user_id == current_user.id)
    )
    workout = result.scalar_one_or_none()
    if not workout:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workout tapilmadi")

    await db.delete(workout)
