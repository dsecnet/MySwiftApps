import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class Subscription(Base):
    """Premium abunəlik (Apple In-App Purchase)"""
    __tablename__ = "subscriptions"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)

    # Apple IAP melumatlari
    product_id: Mapped[str] = mapped_column(String(100), nullable=False)  # com.corevia.monthly, com.corevia.yearly
    transaction_id: Mapped[str | None] = mapped_column(String(200), nullable=True, unique=True)
    original_transaction_id: Mapped[str | None] = mapped_column(String(200), nullable=True)
    receipt_data: Mapped[str | None] = mapped_column(String, nullable=True)  # Base64 receipt

    # Plan melumatlari
    plan_type: Mapped[str] = mapped_column(String(20), nullable=False)  # monthly, yearly
    price: Mapped[float] = mapped_column(Float, nullable=False)
    currency: Mapped[str] = mapped_column(String(10), default="AZN")

    # Status
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    auto_renew: Mapped[bool] = mapped_column(Boolean, default=True)
    started_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    cancelled_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    user: Mapped["User"] = relationship("User", backref="subscriptions")


from app.models.user import User
