import uuid
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, Enum as SAEnum, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base
from app.models.meal_plan import PlanType


class TrainingPlan(Base):
    __tablename__ = "training_plans"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    trainer_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    assigned_student_id: Mapped[str | None] = mapped_column(String, ForeignKey("users.id"), nullable=True, index=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    plan_type: Mapped[PlanType] = mapped_column(SAEnum(PlanType), nullable=False)
    notes: Mapped[str | None] = mapped_column(String(1000), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    workouts: Mapped[list["PlanWorkout"]] = relationship("PlanWorkout", back_populates="training_plan", cascade="all, delete-orphan")


class PlanWorkout(Base):
    __tablename__ = "plan_workouts"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    training_plan_id: Mapped[str] = mapped_column(String, ForeignKey("training_plans.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    sets: Mapped[int] = mapped_column(Integer, nullable=False)
    reps: Mapped[int] = mapped_column(Integer, nullable=False)
    duration: Mapped[int | None] = mapped_column(Integer, nullable=True)  # minutes

    # Relationships
    training_plan: Mapped["TrainingPlan"] = relationship("TrainingPlan", back_populates="workouts")
