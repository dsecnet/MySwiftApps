from sqlalchemy import Column, String, DateTime, Text, ForeignKey, Enum as SAEnum, Boolean
from datetime import datetime
import enum
import uuid

from app.database import Base


class ActivityType(str, enum.Enum):
    call = "call"  # Zəng
    meeting = "meeting"  # Görüş
    viewing = "viewing"  # Baxış
    message = "message"  # Mesaj (WhatsApp, SMS)
    email = "email"  # Email
    note = "note"  # Qeyd


class ActivityStatus(str, enum.Enum):
    scheduled = "scheduled"  # Planlaşdırılıb
    completed = "completed"  # Tamamlanıb
    cancelled = "cancelled"  # Ləğv edilib
    missed = "missed"  # Qaçırılıb


class Activity(Base):
    __tablename__ = "activities"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    agent_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    client_id = Column(String, ForeignKey("clients.id", ondelete="CASCADE"), nullable=True)
    property_id = Column(String, ForeignKey("properties.id", ondelete="SET NULL"), nullable=True)

    # Activity Details
    activity_type = Column(SAEnum(ActivityType), nullable=False)
    status = Column(SAEnum(ActivityStatus), default=ActivityStatus.scheduled, nullable=False)

    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)

    # Scheduling
    scheduled_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)

    # Reminders
    reminder_sent = Column(Boolean, default=False)
    reminder_at = Column(DateTime, nullable=True)

    # Location (for meetings/viewings)
    location = Column(String(500), nullable=True)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<Activity {self.activity_type}: {self.title}>"
