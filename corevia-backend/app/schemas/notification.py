from pydantic import BaseModel
from datetime import datetime


class DeviceTokenCreate(BaseModel):
    """iOS app FCM token qeydiyyati"""
    fcm_token: str
    device_name: str | None = None
    platform: str = "ios"


class NotificationResponse(BaseModel):
    id: str
    user_id: str
    title: str
    body: str
    notification_type: str
    data: str | None = None
    is_read: bool
    is_sent: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class NotificationSend(BaseModel):
    """Trainer -> Student bildirisi gondermek"""
    student_id: str
    title: str
    body: str


class NotificationMarkRead(BaseModel):
    notification_ids: list[str]
