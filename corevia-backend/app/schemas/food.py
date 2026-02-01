from pydantic import BaseModel
from datetime import datetime
from app.models.food_entry import MealType


class FoodEntryCreate(BaseModel):
    name: str
    calories: int
    protein: float | None = None
    carbs: float | None = None
    fats: float | None = None
    meal_type: MealType
    date: datetime | None = None
    notes: str | None = None


class FoodEntryUpdate(BaseModel):
    name: str | None = None
    calories: int | None = None
    protein: float | None = None
    carbs: float | None = None
    fats: float | None = None
    meal_type: MealType | None = None
    notes: str | None = None


class FoodEntryResponse(BaseModel):
    id: str
    user_id: str
    name: str
    calories: int
    protein: float | None = None
    carbs: float | None = None
    fats: float | None = None
    meal_type: MealType
    date: datetime
    notes: str | None = None
    has_image: bool
    image_url: str | None = None
    ai_analyzed: bool
    ai_confidence: float | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class DailyNutritionSummary(BaseModel):
    date: str
    total_calories: int
    total_protein: float
    total_carbs: float
    total_fats: float
    meal_count: int
    daily_calorie_goal: int = 2000
    remaining_calories: int
