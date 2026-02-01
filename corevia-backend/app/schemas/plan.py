from pydantic import BaseModel
from datetime import datetime
from app.models.meal_plan import PlanType


# --- Meal Plan Schemas ---

class MealPlanItemCreate(BaseModel):
    name: str
    calories: int
    protein: float | None = None
    carbs: float | None = None
    fats: float | None = None
    meal_type: str  # breakfast/lunch/dinner/snack


class MealPlanItemResponse(BaseModel):
    id: str
    name: str
    calories: int
    protein: float | None = None
    carbs: float | None = None
    fats: float | None = None
    meal_type: str

    model_config = {"from_attributes": True}


class MealPlanCreate(BaseModel):
    title: str
    plan_type: PlanType
    daily_calorie_target: int = 2000
    notes: str | None = None
    assigned_student_id: str | None = None
    items: list[MealPlanItemCreate] = []


class MealPlanUpdate(BaseModel):
    title: str | None = None
    plan_type: PlanType | None = None
    daily_calorie_target: int | None = None
    notes: str | None = None
    assigned_student_id: str | None = None


class MealPlanResponse(BaseModel):
    id: str
    trainer_id: str
    assigned_student_id: str | None = None
    title: str
    plan_type: PlanType
    daily_calorie_target: int
    notes: str | None = None
    items: list[MealPlanItemResponse] = []
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# --- Training Plan Schemas ---

class PlanWorkoutCreate(BaseModel):
    name: str
    sets: int
    reps: int
    duration: int | None = None


class PlanWorkoutResponse(BaseModel):
    id: str
    name: str
    sets: int
    reps: int
    duration: int | None = None

    model_config = {"from_attributes": True}


class TrainingPlanCreate(BaseModel):
    title: str
    plan_type: PlanType
    notes: str | None = None
    assigned_student_id: str | None = None
    workouts: list[PlanWorkoutCreate] = []


class TrainingPlanUpdate(BaseModel):
    title: str | None = None
    plan_type: PlanType | None = None
    notes: str | None = None
    assigned_student_id: str | None = None


class TrainingPlanResponse(BaseModel):
    id: str
    trainer_id: str
    assigned_student_id: str | None = None
    title: str
    plan_type: PlanType
    notes: str | None = None
    workouts: list[PlanWorkoutResponse] = []
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
