"""
Daily Survey Model — Günlük istifadəçi vəziyyəti sorğusu

Energy, sleep, stress, muscle soreness, mood, water intake.
ML Recommendation Engine bu datadan istifadə edib fərdi tövsiyələr verir.
"""

import uuid
from datetime import datetime, date
from sqlalchemy import String, Integer, Float, Date, DateTime, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class DailySurvey(Base):
    """Günlük vəziyyət sorğusu"""
    __tablename__ = "daily_surveys"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    date: Mapped[date] = mapped_column(Date, nullable=False, index=True)

    # Survey cavabları
    energy_level: Mapped[int] = mapped_column(Integer, nullable=False)          # 1-5
    sleep_hours: Mapped[float] = mapped_column(Float, nullable=False)           # 0-24
    sleep_quality: Mapped[int] = mapped_column(Integer, nullable=False)         # 1-5
    stress_level: Mapped[int] = mapped_column(Integer, nullable=False)          # 1-5
    muscle_soreness: Mapped[int] = mapped_column(Integer, nullable=False)       # 1-5
    mood: Mapped[int] = mapped_column(Integer, nullable=False)                  # 1-5
    water_glasses: Mapped[int] = mapped_column(Integer, nullable=False)         # 0-20

    # Optional
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    user: Mapped["User"] = relationship("User")


# Avoid circular imports
from app.models.user import User
