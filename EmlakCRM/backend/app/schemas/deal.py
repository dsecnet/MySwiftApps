from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class DealCreate(BaseModel):
    """Deal yaratmaq üçün schema"""
    property_id: str = Field(..., min_length=1)
    client_id: str = Field(..., min_length=1)

    agreed_price: float = Field(..., gt=0, description="Razılaşdırılmış qiymət")
    currency: str = Field(default="AZN", pattern="^(AZN|USD|EUR)$")
    commission_percentage: Optional[float] = Field(None, ge=0, le=100, description="Komissiya faizi")
    deposit_amount: Optional[float] = Field(None, ge=0, description="Depozit məbləği")

    notes: Optional[str] = Field(None, max_length=2000)


class DealUpdate(BaseModel):
    """Deal update schema"""
    status: Optional[str] = Field(None, pattern="^(pending|in_progress|completed|cancelled)$")

    agreed_price: Optional[float] = Field(None, gt=0)
    commission_percentage: Optional[float] = Field(None, ge=0, le=100)
    deposit_amount: Optional[float] = Field(None, ge=0)

    contract_signed_at: Optional[datetime] = None
    contract_document_url: Optional[str] = Field(None, max_length=500)

    notes: Optional[str] = Field(None, max_length=2000)


class DealResponse(BaseModel):
    """Deal response schema"""
    id: str
    agent_id: str
    property_id: str
    client_id: str

    status: str

    agreed_price: float
    currency: str
    commission_percentage: Optional[float]
    commission_amount: Optional[float]
    deposit_amount: Optional[float]

    contract_signed_at: Optional[datetime]
    contract_document_url: Optional[str]

    notes: Optional[str]

    created_at: datetime
    updated_at: datetime
    closed_at: Optional[datetime]

    class Config:
        from_attributes = True


class DealWithDetails(DealResponse):
    """Deal with property and client details"""
    property_title: Optional[str] = None
    property_address: Optional[str] = None
    client_name: Optional[str] = None
    client_phone: Optional[str] = None


class DealListResponse(BaseModel):
    """Deal list with pagination"""
    deals: list[DealResponse]
    total: int
    page: int
    total_pages: int


class DealStatsResponse(BaseModel):
    """Deal statistics"""
    total_deals: int
    by_status: dict  # {"pending": 5, "completed": 10, ...}

    total_revenue: float  # Total agreed prices for completed deals
    total_commission: float  # Total commission earned
    average_deal_value: float

    this_month_deals: int
    this_month_revenue: float
    this_month_commission: float

    pending_deals_value: float  # Total value of pending deals
    conversion_rate: float  # Completed / Total * 100
