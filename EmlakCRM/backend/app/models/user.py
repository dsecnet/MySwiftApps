from sqlalchemy import Column, String, Boolean, DateTime, Integer, Float, Enum as SAEnum
from sqlalchemy.sql import func
from datetime import datetime
import enum
import uuid

from app.database import Base


class UserRole(str, enum.Enum):
    admin = "admin"
    agent = "agent"  # Əmlakçı
    team_lead = "team_lead"


class SubscriptionPlan(str, enum.Enum):
    free = "free"  # 10 əmlak, 50 müştəri
    basic = "basic"  # 79 AZN/ay - 100 əmlak, 500 müştəri
    premium = "premium"  # 149 AZN/ay - limitsiz


class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    phone = Column(String(20), unique=True, nullable=True, index=True)
    hashed_password = Column(String(255), nullable=False)

    role = Column(SAEnum(UserRole), default=UserRole.agent, nullable=False)
    subscription_plan = Column(SAEnum(SubscriptionPlan), default=SubscriptionPlan.free, nullable=False)

    # Agency info
    agency_name = Column(String(200), nullable=True)
    agency_logo_url = Column(String(500), nullable=True)

    # Profile
    profile_image_url = Column(String(500), nullable=True)
    bio = Column(String(500), nullable=True)

    # Location
    city = Column(String(100), default="Bakı")

    # Stats (cached)
    total_properties = Column(Integer, default=0)
    total_clients = Column(Integer, default=0)
    total_deals = Column(Integer, default=0)
    total_revenue = Column(Float, default=0.0)

    # Status
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    email_verified = Column(Boolean, default=False)

    # Subscription
    subscription_expires_at = Column(DateTime, nullable=True)
    trial_ends_at = Column(DateTime, nullable=True)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login_at = Column(DateTime, nullable=True)

    def __repr__(self):
        return f"<User {self.name} ({self.email})>"
