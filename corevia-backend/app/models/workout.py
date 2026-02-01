import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Boolean, DateTime, Float, Enum as SAEnum, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base
import enum


class WorkoutCategory(str, enum.Enum):
    strength = "strength"
    cardio = "cardio"
    flexibility = "flexibility"
    endurance = "endurance"


class Workout(Base):
    __tablename__ = "workouts"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    category: Mapped[WorkoutCategory] = mapped_column(SAEnum(WorkoutCategory), nullable=False)
    duration: Mapped[int] = mapped_column(Integer, nullable=False)  # minutes
    calories_burned: Mapped[int | None] = mapped_column(Integer, nullable=True)
    notes: Mapped[str | None] = mapped_column(String(1000), nullable=True)
    date: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Location fields (for running/cycling)
    latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    route_data: Mapped[str | None] = mapped_column(String, nullable=True)  # JSON string of route coordinates
    distance_km: Mapped[float | None] = mapped_column(Float, nullable=True)

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="workouts")


from app.models.user import User
