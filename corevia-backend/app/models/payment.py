import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, Float, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class Payment(Base):
    """Kapital Bank ödəniş qeydləri"""
    __tablename__ = "payments"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)

    # Kapital Bank məlumatları
    kapital_order_id: Mapped[int] = mapped_column(Integer, nullable=False, unique=True)
    kapital_password: Mapped[str | None] = mapped_column(String(200), nullable=True)

    # Plan məlumatları
    product_id: Mapped[str] = mapped_column(String(100), nullable=False)
    plan_type: Mapped[str] = mapped_column(String(20), nullable=False)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    currency: Mapped[str] = mapped_column(String(10), default="AZN")

    # Status
    status: Mapped[str] = mapped_column(String(50), default="Preparing")  # Preparing, FullyPaid, Declined, Refunded, Cancelled
    is_paid: Mapped[bool] = mapped_column(Boolean, default=False)

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    paid_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    # Relationships
    user: Mapped["User"] = relationship("User", backref="payments")


from app.models.user import User
