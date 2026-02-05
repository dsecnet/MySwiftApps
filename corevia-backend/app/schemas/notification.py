from pydantic import BaseModel, Field
from datetime import datetime


class DeviceTokenCreate(BaseModel):
    fcm_token: str = Field(..., min_length=1, max_length=500)
    device_name: str | None = Field(None, max_length=100)
    platform: str = Field("ios", max_length=20)


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
    student_id: str
    title: str = Field(..., min_length=1, max_length=100)
    body: str = Field(..., min_length=1, max_length=500)


class NotificationMarkRead(BaseModel):
    notification_ids: list[str]
