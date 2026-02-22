import uuid
from sqlalchemy import String, Boolean, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class UserSettings(Base):
    __tablename__ = "user_settings"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), unique=True, nullable=False, index=True)
    notifications_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    workout_reminders: Mapped[bool] = mapped_column(Boolean, default=True)
    meal_reminders: Mapped[bool] = mapped_column(Boolean, default=True)
    weekly_reports: Mapped[bool] = mapped_column(Boolean, default=False)
    language: Mapped[str] = mapped_column(String(10), default="az")
    dark_mode: Mapped[bool] = mapped_column(Boolean, default=False)

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="settings")


from app.models.user import User
