"""
Analytics Models - Track user progress and statistics
OWASP A01 - Only user can access own analytics
"""

import uuid
from datetime import datetime, date
from sqlalchemy import String, Integer, Float, Date, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class DailyStats(Base):
    """Daily aggregated statistics for users"""
    __tablename__ = "daily_stats"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    date: Mapped[date] = mapped_column(Date, nullable=False, index=True)

    # Workout stats
    workouts_completed: Mapped[int] = mapped_column(Integer, default=0)
    total_workout_minutes: Mapped[int] = mapped_column(Integer, default=0)
    calories_burned: Mapped[int] = mapped_column(Integer, default=0)
    distance_km: Mapped[float] = mapped_column(Float, default=0.0)

    # Food stats
    calories_consumed: Mapped[int] = mapped_column(Integer, default=0)
    protein_g: Mapped[float] = mapped_column(Float, default=0.0)
    carbs_g: Mapped[float] = mapped_column(Float, default=0.0)
    fats_g: Mapped[float] = mapped_column(Float, default=0.0)

    # Body metrics (if tracked)
    weight_kg: Mapped[float | None] = mapped_column(Float, nullable=True)
    body_fat_percent: Mapped[float | None] = mapped_column(Float, nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    user: Mapped["User"] = relationship("User")


class WeeklyStats(Base):
    """Weekly aggregated statistics"""
    __tablename__ = "weekly_stats"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    week_start: Mapped[date] = mapped_column(Date, nullable=False, index=True)  # Monday of the week
    week_end: Mapped[date] = mapped_column(Date, nullable=False)

    # Aggregated stats
    workouts_completed: Mapped[int] = mapped_column(Integer, default=0)
    total_workout_minutes: Mapped[int] = mapped_column(Integer, default=0)
    calories_burned: Mapped[int] = mapped_column(Integer, default=0)
    calories_consumed: Mapped[int] = mapped_column(Integer, default=0)
    distance_km: Mapped[float] = mapped_column(Float, default=0.0)

    # Averages
    avg_daily_calories_burned: Mapped[int] = mapped_column(Integer, default=0)
    avg_daily_calories_consumed: Mapped[int] = mapped_column(Integer, default=0)

    # Progress indicators
    weight_change_kg: Mapped[float | None] = mapped_column(Float, nullable=True)  # + gain, - loss
    workout_consistency_percent: Mapped[int] = mapped_column(Integer, default=0)  # 0-100%

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    user: Mapped["User"] = relationship("User")


class BodyMeasurement(Base):
    """Body measurements tracking (weight, body fat, etc.)"""
    __tablename__ = "body_measurements"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    measured_at: Mapped[date] = mapped_column(Date, nullable=False, index=True)

    # Measurements
    weight_kg: Mapped[float] = mapped_column(Float, nullable=False)
    body_fat_percent: Mapped[float | None] = mapped_column(Float, nullable=True)
    muscle_mass_kg: Mapped[float | None] = mapped_column(Float, nullable=True)

    # Optional measurements
    chest_cm: Mapped[float | None] = mapped_column(Float, nullable=True)
    waist_cm: Mapped[float | None] = mapped_column(Float, nullable=True)
    hips_cm: Mapped[float | None] = mapped_column(Float, nullable=True)
    arms_cm: Mapped[float | None] = mapped_column(Float, nullable=True)
    legs_cm: Mapped[float | None] = mapped_column(Float, nullable=True)

    notes: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    user: Mapped["User"] = relationship("User")


# Import to avoid circular imports
from app.models.user import User
