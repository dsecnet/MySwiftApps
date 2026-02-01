import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Float, DateTime, Enum as SAEnum, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base
import enum


class PlanType(str, enum.Enum):
    weight_loss = "weight_loss"
    weight_gain = "weight_gain"
    strength_training = "strength_training"


class MealPlan(Base):
    __tablename__ = "meal_plans"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    trainer_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    assigned_student_id: Mapped[str | None] = mapped_column(String, ForeignKey("users.id"), nullable=True, index=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    plan_type: Mapped[PlanType] = mapped_column(SAEnum(PlanType), nullable=False)
    daily_calorie_target: Mapped[int] = mapped_column(Integer, default=2000)
    notes: Mapped[str | None] = mapped_column(String(1000), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    items: Mapped[list["MealPlanItem"]] = relationship("MealPlanItem", back_populates="meal_plan", cascade="all, delete-orphan")


class MealPlanItem(Base):
    __tablename__ = "meal_plan_items"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    meal_plan_id: Mapped[str] = mapped_column(String, ForeignKey("meal_plans.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    calories: Mapped[int] = mapped_column(Integer, nullable=False)
    protein: Mapped[float | None] = mapped_column(Float, nullable=True)
    carbs: Mapped[float | None] = mapped_column(Float, nullable=True)
    fats: Mapped[float | None] = mapped_column(Float, nullable=True)
    meal_type: Mapped[str] = mapped_column(String(50), nullable=False)  # breakfast/lunch/dinner/snack

    # Relationships
    meal_plan: Mapped["MealPlan"] = relationship("MealPlan", back_populates="items")
