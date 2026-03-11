import uuid
import enum
from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    String,
    Boolean,
    Integer,
    Float,
    Text,
    DateTime,
    ForeignKey,
    Numeric,
    Enum as SAEnum,
    func,
)
from sqlalchemy.dialects.postgresql import UUID, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class ListingType(str, enum.Enum):
    SALE = "sale"
    RENT = "rent"
    DAILY_RENT = "daily_rent"


class PropertyType(str, enum.Enum):
    OLD_BUILDING = "old_building"
    NEW_BUILDING = "new_building"
    HOUSE = "house"
    OFFICE = "office"
    GARAGE = "garage"
    LAND = "land"
    COMMERCIAL = "commercial"


class Currency(str, enum.Enum):
    AZN = "AZN"
    USD = "USD"
    EUR = "EUR"


class Renovation(str, enum.Enum):
    NONE = "none"
    MEDIUM = "medium"
    GOOD = "good"
    EXCELLENT = "excellent"


class ListingStatus(str, enum.Enum):
    ACTIVE = "active"
    PENDING = "pending"
    SOLD = "sold"
    RENTED = "rented"
    ARCHIVED = "archived"


class BoostType(str, enum.Enum):
    VIP = "vip"
    PREMIUM = "premium"
    STANDARD = "standard"


class Listing(Base):
    __tablename__ = "listings"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    agent_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("agents.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    title: Mapped[str] = mapped_column(String(500), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    listing_type: Mapped[ListingType] = mapped_column(
        SAEnum(ListingType, name="listing_type", create_constraint=True),
        nullable=False,
        index=True,
    )
    property_type: Mapped[PropertyType] = mapped_column(
        SAEnum(PropertyType, name="property_type", create_constraint=True),
        nullable=False,
        index=True,
    )
    price: Mapped[Decimal] = mapped_column(
        Numeric(precision=14, scale=2), nullable=False
    )
    currency: Mapped[Currency] = mapped_column(
        SAEnum(Currency, name="currency_type", create_constraint=True),
        default=Currency.AZN,
    )
    city: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    district: Mapped[str | None] = mapped_column(String(100), nullable=True)
    address: Mapped[str | None] = mapped_column(String(500), nullable=True)
    latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    rooms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    area_sqm: Mapped[float | None] = mapped_column(Float, nullable=True)
    floor: Mapped[int | None] = mapped_column(Integer, nullable=True)
    total_floors: Mapped[int | None] = mapped_column(Integer, nullable=True)
    renovation: Mapped[Renovation | None] = mapped_column(
        SAEnum(Renovation, name="renovation_type", create_constraint=True),
        nullable=True,
    )
    images: Mapped[list] = mapped_column(JSON, default=list)
    video_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    status: Mapped[ListingStatus] = mapped_column(
        SAEnum(ListingStatus, name="listing_status", create_constraint=True),
        default=ListingStatus.PENDING,
        index=True,
    )
    views_count: Mapped[int] = mapped_column(Integer, default=0)
    is_boosted: Mapped[bool] = mapped_column(Boolean, default=False)
    boost_type: Mapped[BoostType | None] = mapped_column(
        SAEnum(BoostType, name="boost_type", create_constraint=True),
        nullable=True,
    )
    boost_expires_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="listings")
    agent: Mapped["Agent | None"] = relationship("Agent", back_populates="listings")
    favorites: Mapped[list["Favorite"]] = relationship(
        "Favorite", back_populates="listing", lazy="selectin"
    )

    def __repr__(self) -> str:
        return f"<Listing {self.title} ({self.listing_type.value})>"
