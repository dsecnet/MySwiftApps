from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class ActivityCreate(BaseModel):
    """Activity yaratmaq üçün schema"""
    activity_type: str = Field(..., pattern="^(call|meeting|viewing|message|email|note)$")
    title: str = Field(..., min_length=3, max_length=200)
    description: Optional[str] = None

    client_id: Optional[str] = None
    property_id: Optional[str] = None

    scheduled_at: Optional[datetime] = None
    location: Optional[str] = Field(None, max_length=500)

    # Reminder (minutes before scheduled_at)
    reminder_minutes: Optional[int] = Field(None, ge=0, le=1440)  # Max 24 hours


class ActivityUpdate(BaseModel):
    """Activity update schema"""
    title: Optional[str] = Field(None, min_length=3, max_length=200)
    description: Optional[str] = None
    status: Optional[str] = Field(None, pattern="^(scheduled|completed|cancelled|missed)$")

    scheduled_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    location: Optional[str] = Field(None, max_length=500)


class ActivityResponse(BaseModel):
    """Activity response schema"""
    id: str
    agent_id: str
    client_id: Optional[str]
    property_id: Optional[str]

    activity_type: str
    status: str
    title: str
    description: Optional[str]

    scheduled_at: Optional[datetime]
    completed_at: Optional[datetime]
    reminder_sent: bool
    reminder_at: Optional[datetime]
    location: Optional[str]

    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ActivityListResponse(BaseModel):
    """Activity list with pagination"""
    activities: list[ActivityResponse]
    total: int
    page: int
    total_pages: int


class ActivityStatsResponse(BaseModel):
    """Activity statistics"""
    total_activities: int
    by_type: dict  # {"call": 10, "meeting": 5, ...}
    by_status: dict  # {"scheduled": 8, "completed": 20, ...}

    today: int
    this_week: int
    this_month: int

    upcoming: int  # Scheduled for future
    overdue: int  # Missed scheduled activities
