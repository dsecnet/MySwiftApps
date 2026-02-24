from pydantic import BaseModel, Field
from datetime import datetime
from app.models.food_entry import MealType


class FoodEntryCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    calories: int = Field(..., ge=0, le=10000)
    protein: float | None = Field(None, ge=0.0, le=1000.0)
    carbs: float | None = Field(None, ge=0.0, le=1000.0)
    fats: float | None = Field(None, ge=0.0, le=1000.0)
    meal_type: MealType
    date: datetime | None = None
    notes: str | None = Field(None, max_length=1000)
    # On-device AI analiz nəticəsi olduqda iOS tərəfindən göndərilir
    ai_analyzed: bool = False
    ai_confidence: float | None = Field(None, ge=0.0, le=1.0)


class FoodEntryUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=200)
    calories: int | None = Field(None, ge=0, le=10000)
    protein: float | None = Field(None, ge=0.0, le=1000.0)
    carbs: float | None = Field(None, ge=0.0, le=1000.0)
    fats: float | None = Field(None, ge=0.0, le=1000.0)
    meal_type: MealType | None = None
    notes: str | None = Field(None, max_length=1000)


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
