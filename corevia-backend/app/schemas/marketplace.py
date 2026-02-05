from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import Optional
from decimal import Decimal


# ============================================================
# Product Schemas (Input Validation - OWASP A03:2021)
# ============================================================

class ProductCreate(BaseModel):
    """Create marketplace product - strict validation"""
    product_type: str = Field(..., min_length=1, max_length=50)
    title: str = Field(..., min_length=3, max_length=200)
    description: str = Field(..., min_length=10, max_length=5000)
    price: float = Field(..., gt=0, le=10000)  # Max 10,000 AZN
    currency: str = Field(default="AZN", min_length=3, max_length=3)
    is_published: bool = False

    @field_validator('product_type')
    @classmethod
    def validate_product_type(cls, v: str) -> str:
        """Whitelist validation - OWASP A03:2021"""
        allowed_types = ["workout_plan", "meal_plan", "training_program", "ebook", "video_course"]
        if v not in allowed_types:
            raise ValueError(f"Invalid product_type. Allowed: {allowed_types}")
        return v

    @field_validator('currency')
    @classmethod
    def validate_currency(cls, v: str) -> str:
        """Whitelist validation"""
        allowed_currencies = ["AZN", "USD", "EUR", "TRY"]
        if v.upper() not in allowed_currencies:
            raise ValueError(f"Invalid currency. Allowed: {allowed_currencies}")
        return v.upper()

    @field_validator('title', 'description')
    @classmethod
    def sanitize_text(cls, v: str) -> str:
        """Prevent XSS - OWASP A03:2021"""
        # Remove potential XSS characters
        dangerous_chars = ['<', '>', '"', "'", '&', ';']
        for char in dangerous_chars:
            if char in v:
                raise ValueError(f"Invalid character detected: {char}")
        return v.strip()


class ProductUpdate(BaseModel):
    """Update product - optional fields"""
    title: Optional[str] = Field(None, min_length=3, max_length=200)
    description: Optional[str] = Field(None, min_length=10, max_length=5000)
    price: Optional[float] = Field(None, gt=0, le=10000)
    is_published: Optional[bool] = None

    @field_validator('title', 'description')
    @classmethod
    def sanitize_text(cls, v: Optional[str]) -> Optional[str]:
        """Prevent XSS"""
        if v is None:
            return v
        dangerous_chars = ['<', '>', '"', "'", '&', ';']
        for char in dangerous_chars:
            if char in v:
                raise ValueError(f"Invalid character detected: {char}")
        return v.strip()


class ProductAuthor(BaseModel):
    """Product seller info - safe exposure"""
    id: str
    name: str
    profile_image_url: Optional[str] = None
    rating: Optional[float] = None

    class Config:
        from_attributes = True


class ProductResponse(BaseModel):
    """Product response - no sensitive data"""
    id: str
    seller_id: str
    product_type: str
    title: str
    description: str
    price: float
    currency: str
    cover_image_url: Optional[str]
    preview_video_url: Optional[str]
    sales_count: int
    rating: Optional[float]
    reviews_count: int
    is_published: bool
    created_at: datetime
    updated_at: datetime

    # Extra fields
    seller: Optional[ProductAuthor] = None
    is_purchased: Optional[bool] = False  # Current user purchased this

    class Config:
        from_attributes = True


# ============================================================
# Purchase Schemas (Payment Security - OWASP A07:2021)
# ============================================================

class PurchaseCreate(BaseModel):
    """Purchase product - secure payment validation"""
    product_id: str = Field(..., min_length=36, max_length=36)  # UUID length

    # Payment proof (Apple/Google receipt)
    receipt_data: Optional[str] = Field(None, max_length=100000)  # Base64 receipt
    transaction_id: Optional[str] = Field(None, min_length=10, max_length=200)

    @field_validator('product_id')
    @classmethod
    def validate_uuid(cls, v: str) -> str:
        """Validate UUID format - prevent injection"""
        import uuid
        try:
            uuid.UUID(v)
            return v
        except ValueError:
            raise ValueError("Invalid product_id format")


class PurchaseResponse(BaseModel):
    """Purchase response - no sensitive payment data exposed"""
    id: str
    product_id: str
    buyer_id: str
    amount_paid: float
    currency: str
    purchased_at: datetime

    # Product info (for confirmation)
    product_title: Optional[str] = None

    class Config:
        from_attributes = True


# ============================================================
# Review Schemas (Input Validation)
# ============================================================

class ProductReviewCreate(BaseModel):
    """Create product review"""
    product_id: str = Field(..., min_length=36, max_length=36)
    rating: int = Field(..., ge=1, le=5)  # 1-5 stars only
    comment: Optional[str] = Field(None, max_length=1000)

    @field_validator('product_id')
    @classmethod
    def validate_uuid(cls, v: str) -> str:
        """Validate UUID format"""
        import uuid
        try:
            uuid.UUID(v)
            return v
        except ValueError:
            raise ValueError("Invalid product_id format")

    @field_validator('comment')
    @classmethod
    def sanitize_comment(cls, v: Optional[str]) -> Optional[str]:
        """Prevent XSS"""
        if v is None:
            return v
        dangerous_chars = ['<', '>', '"', "'", '&', ';']
        for char in dangerous_chars:
            if char in v:
                raise ValueError(f"Invalid character detected: {char}")
        return v.strip()


class ReviewAuthor(BaseModel):
    """Review author info"""
    id: str
    name: str
    profile_image_url: Optional[str] = None

    class Config:
        from_attributes = True


class ProductReviewResponse(BaseModel):
    """Product review response"""
    id: str
    product_id: str
    buyer_id: str
    rating: int
    comment: Optional[str]
    created_at: datetime
    author: Optional[ReviewAuthor] = None

    class Config:
        from_attributes = True


# ============================================================
# Marketplace List Responses
# ============================================================

class MarketplaceListResponse(BaseModel):
    """Paginated marketplace list"""
    products: list[ProductResponse]
    total: int
    page: int
    page_size: int
    has_more: bool


class MyProductsResponse(BaseModel):
    """Seller's products"""
    products: list[ProductResponse]
    total_sales: int
    total_revenue: float


class MyPurchasesResponse(BaseModel):
    """Buyer's purchases"""
    purchases: list[PurchaseResponse]
    total_spent: float
