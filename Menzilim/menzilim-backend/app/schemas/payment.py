import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.payment import PaymentStatus


class VerifyReceiptRequest(BaseModel):
    receipt_data: str = Field(..., description="Base64 encoded Apple receipt")
    transaction_id: str | None = None
    product_id: str | None = None


class PaymentResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    type: str
    amount: Decimal
    currency: str
    apple_transaction_id: str | None = None
    status: PaymentStatus
    created_at: datetime

    model_config = {"from_attributes": True}


class PaymentListResponse(BaseModel):
    items: list[PaymentResponse]
    total: int
    page: int
    per_page: int
    pages: int
