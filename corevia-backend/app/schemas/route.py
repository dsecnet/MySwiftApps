from pydantic import BaseModel, Field
from datetime import datetime


class RouteCreate(BaseModel):
    name: str | None = Field(None, max_length=200)
    activity_type: str = Field("running", max_length=50)
    start_latitude: float = Field(..., ge=-90.0, le=90.0)
    start_longitude: float = Field(..., ge=-180.0, le=180.0)
    end_latitude: float | None = Field(None, ge=-90.0, le=90.0)
    end_longitude: float | None = Field(None, ge=-180.0, le=180.0)
    polyline: str | None = None
    coordinates_json: str | None = None
    distance_km: float = Field(0.0, ge=0.0, le=500.0)
    duration_seconds: int = Field(0, ge=0, le=86400)
    avg_pace: float | None = Field(None, ge=0.0, le=60.0)
    max_pace: float | None = Field(None, ge=0.0, le=60.0)
    avg_speed_kmh: float | None = Field(None, ge=0.0, le=200.0)
    max_speed_kmh: float | None = Field(None, ge=0.0, le=200.0)
    elevation_gain: float | None = Field(None, ge=0.0, le=10000.0)
    elevation_loss: float | None = Field(None, ge=0.0, le=10000.0)
    calories_burned: int | None = Field(None, ge=0, le=10000)
    workout_id: str | None = None
    started_at: datetime | None = None
    finished_at: datetime | None = None


class RouteUpdate(BaseModel):
    name: str | None = Field(None, max_length=200)
    end_latitude: float | None = Field(None, ge=-90.0, le=90.0)
    end_longitude: float | None = Field(None, ge=-180.0, le=180.0)
    polyline: str | None = None
    coordinates_json: str | None = None
    distance_km: float | None = Field(None, ge=0.0, le=500.0)
    duration_seconds: int | None = Field(None, ge=0, le=86400)
    avg_pace: float | None = Field(None, ge=0.0, le=60.0)
    max_pace: float | None = Field(None, ge=0.0, le=60.0)
    avg_speed_kmh: float | None = Field(None, ge=0.0, le=200.0)
    max_speed_kmh: float | None = Field(None, ge=0.0, le=200.0)
    elevation_gain: float | None = Field(None, ge=0.0, le=10000.0)
    elevation_loss: float | None = Field(None, ge=0.0, le=10000.0)
    calories_burned: int | None = Field(None, ge=0, le=10000)
    finished_at: datetime | None = None
    is_completed: bool | None = None


class RouteAssign(BaseModel):
    student_id: str
    name: str = Field(..., min_length=1, max_length=200)
    activity_type: str = Field("running", max_length=50)
    start_latitude: float = Field(..., ge=-90.0, le=90.0)
    start_longitude: float = Field(..., ge=-180.0, le=180.0)
    end_latitude: float | None = Field(None, ge=-90.0, le=90.0)
    end_longitude: float | None = Field(None, ge=-180.0, le=180.0)
    polyline: str | None = None
    distance_km: float = Field(0.0, ge=0.0, le=500.0)
    assignment_notes: str | None = Field(None, max_length=500)


class RouteResponse(BaseModel):
    id: str
    user_id: str
    workout_id: str | None = None
    name: str | None = None
    activity_type: str
    start_latitude: float
    start_longitude: float
    end_latitude: float | None = None
    end_longitude: float | None = None
    polyline: str | None = None
    coordinates_json: str | None = None
    distance_km: float
    duration_seconds: int
    avg_pace: float | None = None
    max_pace: float | None = None
    avg_speed_kmh: float | None = None
    max_speed_kmh: float | None = None
    elevation_gain: float | None = None
    elevation_loss: float | None = None
    calories_burned: int | None = None
    static_map_url: str | None = None
    is_assigned: bool
    assigned_by_id: str | None = None
    assignment_notes: str | None = None
    is_completed: bool
    started_at: datetime
    finished_at: datetime | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class RouteStatsResponse(BaseModel):
    total_routes: int
    total_distance_km: float
    total_duration_seconds: int
    total_calories: int
    avg_pace: float | None = None
    avg_speed_kmh: float | None = None
    longest_route_km: float
    activity_breakdown: dict
