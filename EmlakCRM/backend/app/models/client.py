from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, Text, JSON, ForeignKey, Enum as SAEnum
from datetime import datetime
import enum
import uuid

from app.database import Base


class ClientType(str, enum.Enum):
    buyer = "buyer"  # Alıcı
    seller = "seller"  # Satıcı
    renter = "renter"  # Kirayəçi
    landlord = "landlord"  # Ev sahibi


class LeadStatus(str, enum.Enum):
    new = "new"  # Yeni
    contacted = "contacted"  # Əlaqə saxlanılıb
    viewing_scheduled = "viewing_scheduled"  # Baxış planlaşdırılıb
    negotiating = "negotiating"  # Danışıqlar gedir
    deal_closed = "deal_closed"  # Müqavilə bağlanıb
    lost = "lost"  # İtirilib
    archived = "archived"  # Arxiv


class Client(Base):
    __tablename__ = "clients"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    agent_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Basic Info
    name = Column(String(100), nullable=False)
    phone = Column(String(20), nullable=False, index=True)
    email = Column(String(255), nullable=True)
    whatsapp = Column(String(20), nullable=True)

    # Client Type
    client_type = Column(SAEnum(ClientType), nullable=False)
    lead_status = Column(SAEnum(LeadStatus), default=LeadStatus.new, nullable=False)

    # Preferences (Buyer/Renter)
    preferred_property_type = Column(String(50), nullable=True)  # apartment, house
    preferred_city = Column(String(100), nullable=True)
    preferred_district = Column(String(100), nullable=True)
    min_price = Column(Float, nullable=True)
    max_price = Column(Float, nullable=True)
    min_rooms = Column(Integer, nullable=True)
    max_rooms = Column(Integer, nullable=True)

    # Source (Hardan gəlib)
    source = Column(String(100), nullable=True)  # bina.az, tap.az, referral, cold_call

    # Tags (JSON array for filtering)
    tags = Column(JSON, nullable=True)  # ["hot_lead", "urgent", "vip"]

    # Notes
    notes = Column(Text, nullable=True)

    # Stats
    total_viewings = Column(Integer, default=0)
    total_offers = Column(Integer, default=0)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_contacted_at = Column(DateTime, nullable=True)

    def __repr__(self):
        return f"<Client {self.name} ({self.phone})>"
