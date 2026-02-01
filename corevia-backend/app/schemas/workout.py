from pydantic import BaseModel
from datetime import datetime
from app.models.workout import WorkoutCategory


class WorkoutCreate(BaseModel):
    title: str
    category: WorkoutCategory
    duration: int
    calories_burned: int | None = None
    notes: str | None = None
    date: datetime | None = None
    latitude: float | None = None
    longitude: float | None = None
    route_data: str | None = None
    distance_km: float | None = None


class WorkoutUpdate(BaseModel):
    title: str | None = None
    category: WorkoutCategory | None = None
    duration: int | None = None
    calories_burned: int | None = None
    notes: str | None = None
    is_completed: bool | None = None
    latitude: float | None = None
    longitude: float | None = None
    route_data: str | None = None
    distance_km: float | None = None


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
