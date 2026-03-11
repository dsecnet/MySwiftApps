from pydantic import BaseModel
from datetime import datetime


class PaymentCreateRequest(BaseModel):
    """iOS app-dan gələn ödəniş yaratma sorğusu"""
    product_id: str  # com.corevia.monthly, com.corevia.yearly


class PaymentCreateResponse(BaseModel):
    """Ödəniş yaradıldıqdan sonra qaytarılan cavab"""
    payment_id: str
    kapital_order_id: int
    redirect_url: str  # İstifadəçini yönləndirmək üçün bank URL-i
    amount: float
    currency: str
    status: str


class PaymentStatusResponse(BaseModel):
    """Ödəniş statusu cavabı"""
    payment_id: str
    kapital_order_id: int
    product_id: str
    plan_type: str
    amount: float
    currency: str
    status: str
    is_paid: bool
    created_at: datetime
    paid_at: datetime | None = None

    model_config = {"from_attributes": True}
