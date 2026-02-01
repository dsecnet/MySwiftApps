import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Float, Boolean, DateTime, Enum as SAEnum, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base
import enum


class MealType(str, enum.Enum):
    breakfast = "breakfast"
    lunch = "lunch"
    dinner = "dinner"
    snack = "snack"


class FoodEntry(Base):
    __tablename__ = "food_entries"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    calories: Mapped[int] = mapped_column(Integer, nullable=False)
    protein: Mapped[float | None] = mapped_column(Float, nullable=True)
    carbs: Mapped[float | None] = mapped_column(Float, nullable=True)
    fats: Mapped[float | None] = mapped_column(Float, nullable=True)
    meal_type: Mapped[MealType] = mapped_column(SAEnum(MealType), nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)
    notes: Mapped[str | None] = mapped_column(String(1000), nullable=True)
    has_image: Mapped[bool] = mapped_column(Boolean, default=False)
    image_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # AI-generated fields
    ai_analyzed: Mapped[bool] = mapped_column(Boolean, default=False)
    ai_confidence: Mapped[float | None] = mapped_column(Float, nullable=True)  # 0-1

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="food_entries")


from app.models.user import User
