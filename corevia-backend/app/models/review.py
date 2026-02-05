import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Float, Text, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class Review(Base):
    __tablename__ = "reviews"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    trainer_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)
    student_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False)
    rating: Mapped[int] = mapped_column(Integer, nullable=False)  # 1-5
    comment: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    trainer: Mapped["User"] = relationship("User", foreign_keys=[trainer_id])
    student: Mapped["User"] = relationship("User", foreign_keys=[student_id])
