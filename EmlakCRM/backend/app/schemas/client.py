from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, List
from datetime import datetime


# ============================================================
# MARK: - Request Schemas
# ============================================================

class ClientCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    phone: str = Field(..., min_length=9, max_length=20)
    email: Optional[EmailStr] = None
    whatsapp: Optional[str] = Field(None, max_length=20)

    client_type: str = Field(..., pattern="^(buyer|seller|renter|landlord)$")

    # Preferences
    preferred_property_type: Optional[str] = None
    preferred_city: Optional[str] = None
    preferred_district: Optional[str] = None
    min_price: Optional[float] = Field(None, ge=0)
    max_price: Optional[float] = Field(None, ge=0)
    min_rooms: Optional[int] = Field(None, ge=0, le=20)
    max_rooms: Optional[int] = Field(None, ge=0, le=20)

    # Source
    source: Optional[str] = Field(None, max_length=100)  # bina.az, tap.az, referral, cold_call

    # Tags
    tags: Optional[List[str]] = None

    # Notes
    notes: Optional[str] = None

    @field_validator("phone", "whatsapp")
    @classmethod
    def validate_phone(cls, v):
        if v is None:
            return v
        # Remove spaces and dashes
        phone = v.replace(" ", "").replace("-", "")
        if not phone.startswith("+"):
            phone = "+" + phone
        return phone


class ClientUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    whatsapp: Optional[str] = None

    lead_status: Optional[str] = Field(
        None,
        pattern="^(new|contacted|viewing_scheduled|negotiating|deal_closed|lost|archived)$"
    )

    # Preferences
    preferred_property_type: Optional[str] = None
    preferred_city: Optional[str] = None
    preferred_district: Optional[str] = None
    min_price: Optional[float] = None
    max_price: Optional[float] = None
    min_rooms: Optional[int] = None
    max_rooms: Optional[int] = None

    # Tags
    tags: Optional[List[str]] = None

    # Notes
    notes: Optional[str] = None


# ============================================================
# MARK: - Response Schemas
# ============================================================

class ClientResponse(BaseModel):
    id: str
    agent_id: str

    # Basic Info
    name: str
    phone: str
    email: Optional[str]
    whatsapp: Optional[str]

    # Type & Status
    client_type: str
    lead_status: str

    # Preferences
    preferred_property_type: Optional[str]
    preferred_city: Optional[str]
    preferred_district: Optional[str]
    min_price: Optional[float]
    max_price: Optional[float]
    min_rooms: Optional[int]
    max_rooms: Optional[int]

    # Source
    source: Optional[str]

    # Tags
    tags: Optional[List[str]]

    # Notes
    notes: Optional[str]

    # Stats
    total_viewings: int
    total_offers: int

    # Timestamps
    created_at: datetime
    updated_at: datetime
    last_contacted_at: Optional[datetime]

    class Config:
        from_attributes = True


class ClientListResponse(BaseModel):
    clients: List[ClientResponse]
    total: int
    page: int
    page_size: int
    pages: int


class ClientStatsResponse(BaseModel):
    total: int
    by_type: dict
    by_status: dict
    by_source: dict
    hot_leads: int  # contacted or viewing_scheduled
    converted: int  # deal_closed
    conversion_rate: float
