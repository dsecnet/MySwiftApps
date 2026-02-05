from pydantic import BaseModel, Field
from datetime import date, datetime
from typing import Optional


# ============================================================
# Daily Stats
# ============================================================

class DailyStatsResponse(BaseModel):
    date: date
    workouts_completed: int
    total_workout_minutes: int
    calories_burned: int
    distance_km: float
    calories_consumed: int
    protein_g: float
    carbs_g: float
    fats_g: float
    weight_kg: Optional[float] = None
    body_fat_percent: Optional[float] = None

    class Config:
        from_attributes = True


# ============================================================
# Weekly Stats
# ============================================================

class WeeklyStatsResponse(BaseModel):
    week_start: date
    week_end: date
    workouts_completed: int
    total_workout_minutes: int
    calories_burned: int
    calories_consumed: int
    distance_km: float
    avg_daily_calories_burned: int
    avg_daily_calories_consumed: int
    weight_change_kg: Optional[float] = None
    workout_consistency_percent: int

    class Config:
        from_attributes = True


# ============================================================
# Body Measurements
# ============================================================

class BodyMeasurementCreate(BaseModel):
    """Create body measurement - OWASP A03 validation"""
    measured_at: date
    weight_kg: float = Field(..., gt=20, lt=300)  # 20-300 kg reasonable range
    body_fat_percent: Optional[float] = Field(None, ge=0, le=100)
    muscle_mass_kg: Optional[float] = Field(None, gt=0, lt=200)
    chest_cm: Optional[float] = Field(None, gt=0, lt=300)
    waist_cm: Optional[float] = Field(None, gt=0, lt=300)
    hips_cm: Optional[float] = Field(None, gt=0, lt=300)
    arms_cm: Optional[float] = Field(None, gt=0, lt=100)
    legs_cm: Optional[float] = Field(None, gt=0, lt=200)
    notes: Optional[str] = Field(None, max_length=500)


class BodyMeasurementResponse(BaseModel):
    id: str
    user_id: str
    measured_at: date
    weight_kg: float
    body_fat_percent: Optional[float]
    muscle_mass_kg: Optional[float]
    chest_cm: Optional[float]
    waist_cm: Optional[float]
    hips_cm: Optional[float]
    arms_cm: Optional[float]
    legs_cm: Optional[float]
    notes: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================================
# Analytics Dashboard
# ============================================================

class ProgressTrend(BaseModel):
    """Weight/body fat trend over time"""
    date: date
    value: float
    change_from_previous: Optional[float] = None  # +/- change


class WorkoutTrend(BaseModel):
    """Workout activity trend"""
    date: date
    workouts_count: int
    minutes: int
    calories: int


class NutritionTrend(BaseModel):
    """Nutrition trend"""
    date: date
    calories: int
    protein: float
    carbs: float
    fats: float


class AnalyticsDashboardResponse(BaseModel):
    """Complete analytics dashboard"""
    # Current period (last 7 days)
    current_week: WeeklyStatsResponse

    # Trends (last 30 days)
    weight_trend: list[ProgressTrend]
    workout_trend: list[WorkoutTrend]
    nutrition_trend: list[NutritionTrend]

    # Summary stats
    total_workouts_30d: int
    total_minutes_30d: int
    total_calories_burned_30d: int
    avg_daily_calories: int
    workout_streak_days: int  # Current consecutive workout days


class ComparisonPeriod(BaseModel):
    """Compare two time periods"""
    period_name: str  # "This Week", "Last Week", "This Month"
    workouts: int
    minutes: int
    calories_burned: int
    calories_consumed: int
    weight_change: Optional[float]


class ProgressComparisonResponse(BaseModel):
    """Progress comparison between periods"""
    current_period: ComparisonPeriod
    previous_period: ComparisonPeriod

    # Percentage changes
    workouts_change_percent: float
    minutes_change_percent: float
    calories_burned_change_percent: float
