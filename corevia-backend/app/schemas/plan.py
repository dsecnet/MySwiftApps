from pydantic import BaseModel, Field
from datetime import datetime
from app.models.meal_plan import PlanType


class MealPlanItemCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    calories: int = Field(..., ge=0, le=10000)
    protein: float | None = Field(None, ge=0.0, le=1000.0)
    carbs: float | None = Field(None, ge=0.0, le=1000.0)
    fats: float | None = Field(None, ge=0.0, le=1000.0)
    meal_type: str = Field(..., max_length=50)


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
    title: str = Field(..., min_length=1, max_length=200)
    plan_type: PlanType
    daily_calorie_target: int = Field(2000, ge=500, le=10000)
    notes: str | None = Field(None, max_length=1000)
    assigned_student_id: str | None = None
    items: list[MealPlanItemCreate] = []


class MealPlanUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    plan_type: PlanType | None = None
    daily_calorie_target: int | None = Field(None, ge=500, le=10000)
    notes: str | None = Field(None, max_length=1000)
    assigned_student_id: str | None = None
    items: list[MealPlanItemCreate] | None = None


class MealPlanResponse(BaseModel):
    id: str
    trainer_id: str
    assigned_student_id: str | None = None
    title: str
    plan_type: PlanType
    daily_calorie_target: int
    notes: str | None = None
    is_completed: bool = False
    completed_at: datetime | None = None
    items: list[MealPlanItemResponse] = []
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class PlanWorkoutCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    sets: int = Field(..., ge=1, le=100)
    reps: int = Field(..., ge=1, le=1000)
    duration: int | None = Field(None, ge=1, le=1440)


class PlanWorkoutResponse(BaseModel):
    id: str
    name: str
    sets: int
    reps: int
    duration: int | None = None

    model_config = {"from_attributes": True}


class TrainingPlanCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    plan_type: PlanType
    notes: str | None = Field(None, max_length=1000)
    assigned_student_id: str | None = None
    workouts: list[PlanWorkoutCreate] = []


class TrainingPlanUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    plan_type: PlanType | None = None
    notes: str | None = Field(None, max_length=1000)
    assigned_student_id: str | None = None
    workouts: list[PlanWorkoutCreate] | None = None


class TrainingPlanResponse(BaseModel):
    id: str
    trainer_id: str
    assigned_student_id: str | None = None
    title: str
    plan_type: PlanType
    notes: str | None = None
    is_completed: bool = False
    completed_at: datetime | None = None
    workouts: list[PlanWorkoutResponse] = []
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
