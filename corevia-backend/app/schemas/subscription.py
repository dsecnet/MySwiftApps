from pydantic import BaseModel
from datetime import datetime


class SubscriptionCreate(BaseModel):
    """iOS app-dan gelen satin alma melumati"""
    product_id: str  # com.corevia.monthly, com.corevia.yearly
    transaction_id: str | None = None
    original_transaction_id: str | None = None
    receipt_data: str | None = None  # Base64 Apple receipt


class SubscriptionResponse(BaseModel):
    id: str
    user_id: str
    product_id: str
    transaction_id: str | None = None
    plan_type: str
    price: float
    currency: str
    is_active: bool
    auto_renew: bool
    started_at: datetime
    expires_at: datetime
    cancelled_at: datetime | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class PremiumStatusResponse(BaseModel):
    """Istifadecinin premium statusu"""
    is_premium: bool
    plan_type: str | None = None
    expires_at: datetime | None = None
    auto_renew: bool = False
    features: list[str] = []
