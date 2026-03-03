import uuid
import enum
from datetime import datetime

from sqlalchemy import String, Text, Boolean, DateTime, ForeignKey, Enum as SAEnum, func
from sqlalchemy.dialects.postgresql import UUID, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class NotificationType(str, enum.Enum):
    LISTING_APPROVED = "listing_approved"
    LISTING_REJECTED = "listing_rejected"
    LISTING_SOLD = "listing_sold"
    NEW_REVIEW = "new_review"
    NEW_FAVORITE = "new_favorite"
    PAYMENT_SUCCESS = "payment_success"
    BOOST_EXPIRED = "boost_expired"
    PREMIUM_EXPIRED = "premium_expired"
    SYSTEM = "system"


class Notification(Base):
    __tablename__ = "notifications"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    type: Mapped[NotificationType] = mapped_column(
        SAEnum(NotificationType, name="notification_type", create_constraint=True),
        nullable=False,
    )
    data: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="notifications")

    def __repr__(self) -> str:
        return f"<Notification {self.type.value} for user={self.user_id}>"
