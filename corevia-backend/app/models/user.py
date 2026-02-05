import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Float, Boolean, DateTime, Enum as SAEnum, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base
import enum


class UserType(str, enum.Enum):
    client = "client"
    trainer = "trainer"


class VerificationStatus(str, enum.Enum):
    pending = "pending"
    verified = "verified"
    rejected = "rejected"


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    user_type: Mapped[UserType] = mapped_column(SAEnum(UserType), nullable=False)
    profile_image_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Client fields
    age: Mapped[int | None] = mapped_column(Integer, nullable=True)
    weight: Mapped[float | None] = mapped_column(Float, nullable=True)
    height: Mapped[float | None] = mapped_column(Float, nullable=True)
    goal: Mapped[str | None] = mapped_column(String(100), nullable=True)
    trainer_id: Mapped[str | None] = mapped_column(String, ForeignKey("users.id"), nullable=True)

    # Trainer fields
    specialization: Mapped[str | None] = mapped_column(String(100), nullable=True)
    experience: Mapped[int | None] = mapped_column(Integer, nullable=True)
    rating: Mapped[float | None] = mapped_column(Float, nullable=True)
    price_per_session: Mapped[float | None] = mapped_column(Float, nullable=True)
    bio: Mapped[str | None] = mapped_column(String(1000), nullable=True)
    verification_status: Mapped[VerificationStatus] = mapped_column(
        SAEnum(VerificationStatus), default=VerificationStatus.pending
    )
    certificate_image_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

    # Verification details
    instagram_handle: Mapped[str | None] = mapped_column(String(100), nullable=True)
    verification_photo_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    verification_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    verification_attempts: Mapped[int] = mapped_column(Integer, default=0)
    last_verification_attempt: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    # Premium
    is_premium: Mapped[bool] = mapped_column(Boolean, default=False)

    # Admin
    is_admin: Mapped[bool] = mapped_column(Boolean, default=False)

    # Relationships
    trainer: Mapped["User | None"] = relationship("User", remote_side="User.id", foreign_keys=[trainer_id])
    workouts: Mapped[list["Workout"]] = relationship("Workout", back_populates="user", cascade="all, delete-orphan")
    food_entries: Mapped[list["FoodEntry"]] = relationship("FoodEntry", back_populates="user", cascade="all, delete-orphan")
    settings: Mapped["UserSettings | None"] = relationship("UserSettings", back_populates="user", uselist=False, cascade="all, delete-orphan")


# Import here to avoid circular imports
from app.models.workout import Workout
from app.models.food_entry import FoodEntry
from app.models.settings import UserSettings
