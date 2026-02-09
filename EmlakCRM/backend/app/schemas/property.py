from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


# ============================================================
# MARK: - Request Schemas
# ============================================================

class PropertyCreate(BaseModel):
    title: str = Field(..., min_length=5, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    property_type: str = Field(..., pattern="^(apartment|house|land|commercial|office)$")
    deal_type: str = Field(..., pattern="^(sale|rent)$")

    # Location
    city: str = Field(default="Bakı", max_length=100)
    district: Optional[str] = Field(None, max_length=100)
    address: Optional[str] = Field(None, max_length=500)
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    # Details
    price: float = Field(..., gt=0)
    currency: str = Field(default="AZN", pattern="^(AZN|USD|EUR)$")
    area_sqm: Optional[float] = Field(None, gt=0)
    rooms: Optional[int] = Field(None, ge=0, le=20)
    bathrooms: Optional[int] = Field(None, ge=0, le=10)
    floor: Optional[int] = Field(None, ge=0, le=100)
    total_floors: Optional[int] = Field(None, ge=0, le=100)

    # Features
    features: Optional[List[str]] = None

    # Owner
    owner_name: Optional[str] = Field(None, max_length=100)
    owner_phone: Optional[str] = Field(None, max_length=20)

    # External
    bina_az_url: Optional[str] = None
    tap_az_url: Optional[str] = None

    # Notes
    internal_notes: Optional[str] = None


class PropertyUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=5, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    status: Optional[str] = Field(None, pattern="^(available|reserved|sold|rented|archived)$")

    # Location
    city: Optional[str] = None
    district: Optional[str] = None
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    # Details
    price: Optional[float] = Field(None, gt=0)
    area_sqm: Optional[float] = Field(None, gt=0)
    rooms: Optional[int] = Field(None, ge=0, le=20)
    bathrooms: Optional[int] = Field(None, ge=0, le=10)
    floor: Optional[int] = None
    total_floors: Optional[int] = None

    # Features
    features: Optional[List[str]] = None

    # Owner
    owner_name: Optional[str] = None
    owner_phone: Optional[str] = None

    # External
    bina_az_url: Optional[str] = None
    tap_az_url: Optional[str] = None

    # Notes
    internal_notes: Optional[str] = None

    # Marketing
    featured: Optional[bool] = None


# ============================================================
# MARK: - Response Schemas
# ============================================================

class PropertyResponse(BaseModel):
    id: str
    agent_id: str

    # Basic Info
    title: str
    description: Optional[str]
    property_type: str
    deal_type: str
    status: str

    # Location
    city: str
    district: Optional[str]
    address: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]

    # Details
    price: float
    currency: str
    area_sqm: Optional[float]
    rooms: Optional[int]
    bathrooms: Optional[int]
    floor: Optional[int]
    total_floors: Optional[int]

    # Features
    features: Optional[List[str]]

    # Media
    images: Optional[List[str]]
    video_url: Optional[str]

    # Owner
    owner_name: Optional[str]
    owner_phone: Optional[str]

    # Marketing
    featured: bool
    views_count: int
    favorites_count: int

    # External
    bina_az_url: Optional[str]
    tap_az_url: Optional[str]

    # Timestamps
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PropertyListResponse(BaseModel):
    properties: List[PropertyResponse]
    total: int
    page: int
    page_size: int
    pages: int
