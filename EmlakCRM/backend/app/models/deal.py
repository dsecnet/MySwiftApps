from sqlalchemy import Column, String, Float, DateTime, Text, ForeignKey, Enum as SAEnum
from datetime import datetime
import enum
import uuid

from app.database import Base


class DealStatus(str, enum.Enum):
    pending = "pending"  # Gözləyir
    in_progress = "in_progress"  # Davam edir
    completed = "completed"  # Tamamlanıb
    cancelled = "cancelled"  # Ləğv edilib


class Deal(Base):
    __tablename__ = "deals"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    agent_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    property_id = Column(String, ForeignKey("properties.id", ondelete="CASCADE"), nullable=False)
    client_id = Column(String, ForeignKey("clients.id", ondelete="CASCADE"), nullable=False)

    # Deal Details
    status = Column(SAEnum(DealStatus), default=DealStatus.pending, nullable=False)

    # Financial
    agreed_price = Column(Float, nullable=False)
    currency = Column(String(10), default="AZN")
    commission_percentage = Column(Float, nullable=True)  # Agent komissiyası (%)
    commission_amount = Column(Float, nullable=True)  # Hesablanmış komissiya
    deposit_amount = Column(Float, nullable=True)  # Depozit

    # Contract
    contract_signed_at = Column(DateTime, nullable=True)
    contract_document_url = Column(String(500), nullable=True)

    # Notes
    notes = Column(Text, nullable=True)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    closed_at = Column(DateTime, nullable=True)

    def __repr__(self):
        return f"<Deal {self.id} - {self.agreed_price} {self.currency}>"
