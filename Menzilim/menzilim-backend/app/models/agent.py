import uuid
from datetime import datetime

from sqlalchemy import (
    String,
    Boolean,
    Integer,
    Float,
    Text,
    DateTime,
    ForeignKey,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Agent(Base):
    __tablename__ = "agents"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )
    company_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    license_number: Mapped[str | None] = mapped_column(String(100), nullable=True)
    level: Mapped[int] = mapped_column(Integer, default=1)
    rating: Mapped[float] = mapped_column(Float, default=0.0)
    total_reviews: Mapped[int] = mapped_column(Integer, default=0)
    total_listings: Mapped[int] = mapped_column(Integer, default=0)
    total_sales: Mapped[int] = mapped_column(Integer, default=0)
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_premium: Mapped[bool] = mapped_column(Boolean, default=False)
    premium_expires_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="agent_profile")
    listings: Mapped[list["Listing"]] = relationship(
        "Listing", back_populates="agent", lazy="selectin"
    )
    reviews: Mapped[list["Review"]] = relationship(
        "Review", back_populates="agent", lazy="selectin"
    )

    def __repr__(self) -> str:
        return f"<Agent {self.company_name} (level={self.level})>"
