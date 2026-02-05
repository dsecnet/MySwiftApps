from pydantic import BaseModel, Field
from datetime import datetime
from app.models.workout import WorkoutCategory


class WorkoutCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    category: WorkoutCategory
    duration: int = Field(..., ge=1, le=1440)
    calories_burned: int | None = Field(None, ge=0, le=10000)
    notes: str | None = Field(None, max_length=1000)
    date: datetime | None = None
    latitude: float | None = Field(None, ge=-90.0, le=90.0)
    longitude: float | None = Field(None, ge=-180.0, le=180.0)
    route_data: str | None = None
    distance_km: float | None = Field(None, ge=0.0, le=500.0)


class WorkoutUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    category: WorkoutCategory | None = None
    duration: int | None = Field(None, ge=1, le=1440)
    calories_burned: int | None = Field(None, ge=0, le=10000)
    notes: str | None = Field(None, max_length=1000)
    is_completed: bool | None = None
    latitude: float | None = Field(None, ge=-90.0, le=90.0)
    longitude: float | None = Field(None, ge=-180.0, le=180.0)
    route_data: str | None = None
    distance_km: float | None = Field(None, ge=0.0, le=500.0)


class WorkoutResponse(BaseModel):
    id: str
    user_id: str
    title: str
    category: WorkoutCategory
    duration: int
    calories_burned: int | None = None
    notes: str | None = None
    date: datetime
    is_completed: bool
    latitude: float | None = None
    longitude: float | None = None
    route_data: str | None = None
    distance_km: float | None = None
    created_at: datetime

    model_config = {"from_attributes": True}
