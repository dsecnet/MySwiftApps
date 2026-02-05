from pydantic import BaseModel, Field
from datetime import datetime


class ChatMessageCreate(BaseModel):
    receiver_id: str
    message: str = Field(..., min_length=1, max_length=1000)


class ChatMessageResponse(BaseModel):
    id: str
    sender_id: str
    receiver_id: str
    sender_name: str = ""
    sender_profile_image: str | None = None
    message: str
    is_read: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class ChatConversation(BaseModel):
    user_id: str
    user_name: str
    user_profile_image: str | None = None
    last_message: str
    last_message_time: datetime
    unread_count: int


class MessageLimitResponse(BaseModel):
    daily_limit: int = 10
    used_today: int
    remaining: int
