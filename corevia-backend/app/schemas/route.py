from pydantic import BaseModel
from datetime import datetime


class RouteCreate(BaseModel):
    """iOS app-dan gelen route yaratma request-i"""
    name: str | None = None
    activity_type: str = "running"  # running, cycling, walking
    start_latitude: float
    start_longitude: float
    end_latitude: float | None = None
    end_longitude: float | None = None
    polyline: str | None = None
    coordinates_json: str | None = None  # JSON array: [[lat,lng,alt,timestamp], ...]
    distance_km: float = 0.0
    duration_seconds: int = 0
    avg_pace: float | None = None
    max_pace: float | None = None
    avg_speed_kmh: float | None = None
    max_speed_kmh: float | None = None
    elevation_gain: float | None = None
    elevation_loss: float | None = None
    calories_burned: int | None = None
    workout_id: str | None = None
    started_at: datetime | None = None
    finished_at: datetime | None = None


class RouteUpdate(BaseModel):
    """Route update (meselen finish edende)"""
    name: str | None = None
    end_latitude: float | None = None
    end_longitude: float | None = None
    polyline: str | None = None
    coordinates_json: str | None = None
    distance_km: float | None = None
    duration_seconds: int | None = None
    avg_pace: float | None = None
    max_pace: float | None = None
    avg_speed_kmh: float | None = None
    max_speed_kmh: float | None = None
    elevation_gain: float | None = None
    elevation_loss: float | None = None
    calories_burned: int | None = None
    finished_at: datetime | None = None
    is_completed: bool | None = None


class RouteAssign(BaseModel):
    """Trainer -> Student route assignment"""
    student_id: str
    name: str
    activity_type: str = "running"
    start_latitude: float
    start_longitude: float
    end_latitude: float | None = None
    end_longitude: float | None = None
    polyline: str | None = None
    distance_km: float = 0.0
    assignment_notes: str | None = None


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
    """Route statistikasi"""
    total_routes: int
    total_distance_km: float
    total_duration_seconds: int
    total_calories: int
    avg_pace: float | None = None
    avg_speed_kmh: float | None = None
    longest_route_km: float
    activity_breakdown: dict  # {"running": 5, "cycling": 3, "walking": 2}
