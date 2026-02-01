from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models.user import User, UserType
from app.models.meal_plan import MealPlan, MealPlanItem, PlanType
from app.models.training_plan import TrainingPlan, PlanWorkout
from app.schemas.plan import (
    MealPlanCreate, MealPlanUpdate, MealPlanResponse,
    TrainingPlanCreate, TrainingPlanUpdate, TrainingPlanResponse,
)
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/plans", tags=["Plans"])


# ==================== MEAL PLANS ====================

@router.post("/meal", response_model=MealPlanResponse, status_code=status.HTTP_201_CREATED)
async def create_meal_plan(
    plan_data: MealPlanCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if current_user.user_type != UserType.trainer:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Yalniz trainer plan yarada biler")

    meal_plan = MealPlan(
        trainer_id=current_user.id,
        title=plan_data.title,
        plan_type=plan_data.plan_type,
        daily_calorie_target=plan_data.daily_calorie_target,
        notes=plan_data.notes,
        assigned_student_id=plan_data.assigned_student_id,
    )
    db.add(meal_plan)
    await db.flush()

    for item_data in plan_data.items:
        item = MealPlanItem(
            meal_plan_id=meal_plan.id,
            name=item_data.name,
            calories=item_data.calories,
            protein=item_data.protein,
            carbs=item_data.carbs,
            fats=item_data.fats,
            meal_type=item_data.meal_type,
        )
        db.add(item)

    await db.flush()

    # Reload with items
    result = await db.execute(
        select(MealPlan).options(selectinload(MealPlan.items)).where(MealPlan.id == meal_plan.id)
    )
    return result.scalar_one()


@router.get("/meal", response_model=list[MealPlanResponse])
async def get_meal_plans(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    plan_type: PlanType | None = None,
):
    if current_user.user_type == UserType.trainer:
        query = select(MealPlan).options(selectinload(MealPlan.items)).where(MealPlan.trainer_id == current_user.id)
    else:
        query = select(MealPlan).options(selectinload(MealPlan.items)).where(MealPlan.assigned_student_id == current_user.id)

    if plan_type:
        query = query.where(MealPlan.plan_type == plan_type)

    query = query.order_by(MealPlan.created_at.desc())
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/meal/{plan_id}", response_model=MealPlanResponse)
async def get_meal_plan(
    plan_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(MealPlan).options(selectinload(MealPlan.items)).where(MealPlan.id == plan_id)
    )
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meal plan tapilmadi")

    # Yalniz trainer (sahibi) ve ya assigned student gore biler
    if plan.trainer_id != current_user.id and plan.assigned_student_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Bu plana icazeniz yoxdur")

    return plan


@router.put("/meal/{plan_id}", response_model=MealPlanResponse)
async def update_meal_plan(
    plan_id: str,
    plan_data: MealPlanUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(MealPlan).options(selectinload(MealPlan.items)).where(MealPlan.id == plan_id, MealPlan.trainer_id == current_user.id)
    )
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meal plan tapilmadi")

    update_data = plan_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(plan, field, value)
    return plan


@router.delete("/meal/{plan_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_meal_plan(
    plan_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(MealPlan).where(MealPlan.id == plan_id, MealPlan.trainer_id == current_user.id)
    )
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meal plan tapilmadi")

    await db.delete(plan)


# ==================== TRAINING PLANS ====================

@router.post("/training", response_model=TrainingPlanResponse, status_code=status.HTTP_201_CREATED)
async def create_training_plan(
    plan_data: TrainingPlanCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if current_user.user_type != UserType.trainer:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Yalniz trainer plan yarada biler")

    training_plan = TrainingPlan(
        trainer_id=current_user.id,
        title=plan_data.title,
        plan_type=plan_data.plan_type,
        notes=plan_data.notes,
        assigned_student_id=plan_data.assigned_student_id,
    )
    db.add(training_plan)
    await db.flush()

    for workout_data in plan_data.workouts:
        workout = PlanWorkout(
            training_plan_id=training_plan.id,
            name=workout_data.name,
            sets=workout_data.sets,
            reps=workout_data.reps,
            duration=workout_data.duration,
        )
        db.add(workout)

    await db.flush()

    result = await db.execute(
        select(TrainingPlan).options(selectinload(TrainingPlan.workouts)).where(TrainingPlan.id == training_plan.id)
    )
    return result.scalar_one()


@router.get("/training", response_model=list[TrainingPlanResponse])
async def get_training_plans(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    plan_type: PlanType | None = None,
):
    if current_user.user_type == UserType.trainer:
        query = select(TrainingPlan).options(selectinload(TrainingPlan.workouts)).where(TrainingPlan.trainer_id == current_user.id)
    else:
        query = select(TrainingPlan).options(selectinload(TrainingPlan.workouts)).where(TrainingPlan.assigned_student_id == current_user.id)

    if plan_type:
        query = query.where(TrainingPlan.plan_type == plan_type)

    query = query.order_by(TrainingPlan.created_at.desc())
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/training/{plan_id}", response_model=TrainingPlanResponse)
async def get_training_plan(
    plan_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(TrainingPlan).options(selectinload(TrainingPlan.workouts)).where(TrainingPlan.id == plan_id)
    )
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training plan tapilmadi")

    if plan.trainer_id != current_user.id and plan.assigned_student_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Bu plana icazeniz yoxdur")

    return plan


@router.put("/training/{plan_id}", response_model=TrainingPlanResponse)
async def update_training_plan(
    plan_id: str,
    plan_data: TrainingPlanUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(TrainingPlan).options(selectinload(TrainingPlan.workouts)).where(TrainingPlan.id == plan_id, TrainingPlan.trainer_id == current_user.id)
    )
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training plan tapilmadi")

    update_data = plan_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(plan, field, value)
    return plan


@router.delete("/training/{plan_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_training_plan(
    plan_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(TrainingPlan).where(TrainingPlan.id == plan_id, TrainingPlan.trainer_id == current_user.id)
    )
    plan = result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training plan tapilmadi")

    await db.delete(plan)
