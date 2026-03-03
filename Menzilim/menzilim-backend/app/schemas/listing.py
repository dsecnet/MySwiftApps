import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.listing import (
    ListingType,
    PropertyType,
    Currency,
    Renovation,
    ListingStatus,
    BoostType,
)


class ListingCreateRequest(BaseModel):
    title: str = Field(..., min_length=5, max_length=500)
    description: str | None = Field(None, max_length=5000)
    listing_type: ListingType
    property_type: PropertyType
    price: Decimal = Field(..., gt=0, decimal_places=2)
    currency: Currency = Currency.AZN
    city: str = Field(..., min_length=2, max_length=100)
    district: str | None = Field(None, max_length=100)
    address: str | None = Field(None, max_length=500)
    latitude: float | None = Field(None, ge=-90, le=90)
    longitude: float | None = Field(None, ge=-180, le=180)
    rooms: int | None = Field(None, ge=0, le=50)
    area_sqm: float | None = Field(None, gt=0)
    floor: int | None = Field(None, ge=-5, le=200)
    total_floors: int | None = Field(None, ge=1, le=200)
    renovation: Renovation | None = None
    images: list[str] = Field(default_factory=list, max_length=20)
    video_url: str | None = Field(None, max_length=500)


class ListingUpdateRequest(BaseModel):
    title: str | None = Field(None, min_length=5, max_length=500)
    description: str | None = Field(None, max_length=5000)
    listing_type: ListingType | None = None
    property_type: PropertyType | None = None
    price: Decimal | None = Field(None, gt=0, decimal_places=2)
    currency: Currency | None = None
    city: str | None = Field(None, min_length=2, max_length=100)
    district: str | None = Field(None, max_length=100)
    address: str | None = Field(None, max_length=500)
    latitude: float | None = Field(None, ge=-90, le=90)
    longitude: float | None = Field(None, ge=-180, le=180)
    rooms: int | None = Field(None, ge=0, le=50)
    area_sqm: float | None = Field(None, gt=0)
    floor: int | None = Field(None, ge=-5, le=200)
    total_floors: int | None = Field(None, ge=1, le=200)
    renovation: Renovation | None = None
    images: list[str] | None = Field(None, max_length=20)
    video_url: str | None = Field(None, max_length=500)
    status: ListingStatus | None = None


class ListingResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    agent_id: uuid.UUID | None = None
    title: str
    description: str | None = None
    listing_type: ListingType
    property_type: PropertyType
    price: Decimal
    currency: Currency
    city: str
    district: str | None = None
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    rooms: int | None = None
    area_sqm: float | None = None
    floor: int | None = None
    total_floors: int | None = None
    renovation: Renovation | None = None
    images: list[str] = []
    video_url: str | None = None
    status: ListingStatus
    views_count: int = 0
    is_boosted: bool = False
    boost_type: BoostType | None = None
    boost_expires_at: datetime | None = None
    created_at: datetime
    updated_at: datetime
    is_favorited: bool = False

    model_config = {"from_attributes": True}


class ListingListResponse(BaseModel):
    items: list[ListingResponse]
    total: int
    page: int
    per_page: int
    pages: int


class ListingMapResponse(BaseModel):
    id: uuid.UUID
    title: str
    price: Decimal
    currency: Currency
    latitude: float
    longitude: float
    listing_type: ListingType
    property_type: PropertyType
    rooms: int | None = None
    area_sqm: float | None = None
    images: list[str] = []

    model_config = {"from_attributes": True}


class BoostRequest(BaseModel):
    boost_type: BoostType
    duration_days: int = Field(..., ge=1, le=90)
