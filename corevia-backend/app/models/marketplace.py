import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Float, Boolean, DateTime, Text, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base
import enum


class ProductType(str, enum.Enum):
    workout_plan = "workout_plan"
    meal_plan = "meal_plan"
    training_program = "training_program"
    ebook = "ebook"
    video_course = "video_course"


class MarketplaceProduct(Base):
    """Products for sale (workout plans, meal plans, programs)"""
    __tablename__ = "marketplace_products"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    seller_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)

    # Product info
    product_type: Mapped[ProductType] = mapped_column(SAEnum(ProductType), nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)

    # Pricing
    price: Mapped[float] = mapped_column(Float, nullable=False)
    currency: Mapped[str] = mapped_column(String(10), default="AZN")

    # Media
    cover_image_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    preview_video_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

    # Product content (JSON or reference IDs)
    content_data: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON string

    # Stats
    sales_count: Mapped[int] = mapped_column(Integer, default=0)
    rating: Mapped[float | None] = mapped_column(Float, nullable=True)
    reviews_count: Mapped[int] = mapped_column(Integer, default=0)

    # Status
    is_published: Mapped[bool] = mapped_column(Boolean, default=False)
    is_featured: Mapped[bool] = mapped_column(Boolean, default=False)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    seller: Mapped["User"] = relationship("User", foreign_keys=[seller_id])
    purchases: Mapped[list["ProductPurchase"]] = relationship("ProductPurchase", back_populates="product", cascade="all, delete-orphan")
    product_reviews: Mapped[list["ProductReview"]] = relationship("ProductReview", back_populates="product", cascade="all, delete-orphan")


class ProductPurchase(Base):
    """Purchase record"""
    __tablename__ = "product_purchases"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    product_id: Mapped[str] = mapped_column(String, ForeignKey("marketplace_products.id"), nullable=False, index=True)
    buyer_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)

    # Payment info
    amount_paid: Mapped[float] = mapped_column(Float, nullable=False)
    currency: Mapped[str] = mapped_column(String(10), default="AZN")
    transaction_id: Mapped[str | None] = mapped_column(String(200), nullable=True, unique=True)

    # Receipt validation (Apple/Google)
    receipt_data: Mapped[str | None] = mapped_column(Text, nullable=True)

    purchased_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)

    # Relationships
    product: Mapped["MarketplaceProduct"] = relationship("MarketplaceProduct", back_populates="purchases")
    buyer: Mapped["User"] = relationship("User")


class ProductReview(Base):
    """Review for a marketplace product"""
    __tablename__ = "product_reviews"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    product_id: Mapped[str] = mapped_column(String, ForeignKey("marketplace_products.id"), nullable=False, index=True)
    buyer_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False, index=True)

    rating: Mapped[int] = mapped_column(Integer, nullable=False)  # 1-5
    comment: Mapped[str | None] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    product: Mapped["MarketplaceProduct"] = relationship("MarketplaceProduct", back_populates="product_reviews")
    buyer: Mapped["User"] = relationship("User")


# Import to avoid circular imports
from app.models.user import User
