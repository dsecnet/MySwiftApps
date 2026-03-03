import uuid
import enum
from datetime import datetime

from sqlalchemy import String, Text, DateTime, ForeignKey, Enum as SAEnum, func
from sqlalchemy.dialects.postgresql import UUID, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class TargetType(str, enum.Enum):
    LISTING = "listing"
    USER = "user"
    AGENT = "agent"
    REVIEW = "review"


class ComplaintType(str, enum.Enum):
    SPAM = "spam"
    FRAUD = "fraud"
    INAPPROPRIATE = "inappropriate"
    WRONG_INFO = "wrong_info"
    DUPLICATE = "duplicate"
    OTHER = "other"


class ComplaintStatus(str, enum.Enum):
    PENDING = "pending"
    REVIEWING = "reviewing"
    RESOLVED = "resolved"
    REJECTED = "rejected"


class Complaint(Base):
    __tablename__ = "complaints"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    reporter_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    target_type: Mapped[TargetType] = mapped_column(
        SAEnum(TargetType, name="target_type", create_constraint=True),
        nullable=False,
    )
    target_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), nullable=False
    )
    complaint_type: Mapped[ComplaintType] = mapped_column(
        SAEnum(ComplaintType, name="complaint_type", create_constraint=True),
        nullable=False,
    )
    description: Mapped[str] = mapped_column(Text, nullable=False)
    screenshots: Mapped[list | None] = mapped_column(JSON, default=list)
    status: Mapped[ComplaintStatus] = mapped_column(
        SAEnum(ComplaintStatus, name="complaint_status", create_constraint=True),
        default=ComplaintStatus.PENDING,
    )
    admin_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    # Relationships
    reporter: Mapped["User"] = relationship("User", foreign_keys=[reporter_id])

    def __repr__(self) -> str:
        return f"<Complaint {self.complaint_type.value} -> {self.target_type.value}>"
