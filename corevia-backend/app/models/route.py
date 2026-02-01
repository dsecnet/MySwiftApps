import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Boolean, DateTime, Float, Text, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class Route(Base):
    """GPS ile izlenen marsrut (qaçış, velosiped, gəzinti)"""
    __tablename__ = "routes"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    workout_id: Mapped[str | None] = mapped_column(String, ForeignKey("workouts.id"), nullable=True, index=True)

    # Route metadata
    name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    activity_type: Mapped[str] = mapped_column(String(50), nullable=False, default="running")  # running, cycling, walking

    # Start/End coordinates
    start_latitude: Mapped[float] = mapped_column(Float, nullable=False)
    start_longitude: Mapped[float] = mapped_column(Float, nullable=False)
    end_latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    end_longitude: Mapped[float | None] = mapped_column(Float, nullable=True)

    # Route data - encoded polyline (Google Polyline Algorithm) or JSON coordinate array
    polyline: Mapped[str | None] = mapped_column(Text, nullable=True)  # Encoded polyline
    coordinates_json: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON array: [[lat,lng,alt,timestamp], ...]

    # Stats
    distance_km: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    duration_seconds: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    avg_pace: Mapped[float | None] = mapped_column(Float, nullable=True)  # min/km
    max_pace: Mapped[float | None] = mapped_column(Float, nullable=True)  # min/km (en sürətli)
    avg_speed_kmh: Mapped[float | None] = mapped_column(Float, nullable=True)  # km/saat
    max_speed_kmh: Mapped[float | None] = mapped_column(Float, nullable=True)
    elevation_gain: Mapped[float | None] = mapped_column(Float, nullable=True)  # metres
    elevation_loss: Mapped[float | None] = mapped_column(Float, nullable=True)
    calories_burned: Mapped[int | None] = mapped_column(Integer, nullable=True)

    # Map snapshot
    static_map_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

    # Trainer assignment (trainer öz student-lərinə marsrut təyin edə bilər)
    is_assigned: Mapped[bool] = mapped_column(Boolean, default=False)
    assigned_by_id: Mapped[str | None] = mapped_column(String, ForeignKey("users.id"), nullable=True)
    assignment_notes: Mapped[str | None] = mapped_column(String(500), nullable=True)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)

    # Timestamps
    started_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    user: Mapped["User"] = relationship("User", foreign_keys=[user_id], backref="routes")
    assigned_by: Mapped["User"] = relationship("User", foreign_keys=[assigned_by_id])
    workout: Mapped["Workout"] = relationship("Workout", backref="route")


from app.models.user import User
from app.models.workout import Workout
