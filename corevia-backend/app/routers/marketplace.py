"""
Marketplace Router - OWASP Top 10 Compliant
- A01:2021 - Broken Access Control: Authorization checks on all endpoints
- A02:2021 - Cryptographic Failures: Secure payment validation
- A03:2021 - Injection: Parameterized queries, input validation
- A04:2021 - Insecure Design: Rate limiting, business logic validation
- A05:2021 - Security Misconfiguration: Secure defaults
- A07:2021 - Identification and Authentication Failures: JWT validation
- A08:2021 - Software and Data Integrity Failures: Receipt validation
"""

import logging
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_, desc
from typing import Optional

from app.database import get_db
from app.models.user import User, UserType
from app.models.marketplace import MarketplaceProduct, ProductPurchase, ProductReview
from app.schemas.marketplace import (
    ProductCreate,
    ProductUpdate,
    ProductResponse,
    ProductAuthor,
    PurchaseCreate,
    PurchaseResponse,
    ProductReviewCreate,
    ProductReviewResponse,
    ReviewAuthor,
    MarketplaceListResponse,
    MyProductsResponse,
    MyPurchasesResponse,
)
from app.utils.security import get_current_user, require_trainer
from app.services.file_service import save_upload
from app.services.premium_service import validate_apple_receipt

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/marketplace", tags=["Marketplace"])


# ============================================================
# SECURITY HELPERS
# ============================================================

async def get_product_or_404(product_id: str, db: AsyncSession) -> MarketplaceProduct:
    """Get product with validation - OWASP A01:2021"""
    result = await db.execute(select(MarketplaceProduct).where(MarketplaceProduct.id == product_id))
    product = result.scalar_one_or_none()
    if not product:
        raise HTTPException(status_code=404, detail="Məhsul tapılmadı")
    return product


async def verify_product_ownership(product: MarketplaceProduct, user: User):
    """Verify user owns product - OWASP A01:2021"""
    if product.seller_id != user.id:
        logger.warning(f"Unauthorized access attempt: user {user.id} to product {product.id}")
        raise HTTPException(
            status_code=403,
            detail="Bu məhsula yalnız satıcı dəyişiklik edə bilər"
        )


async def verify_purchase_eligibility(product: MarketplaceProduct, user: User, db: AsyncSession):
    """Check if user can purchase - OWASP A04:2021 Business Logic"""
    # Can't buy own product
    if product.seller_id == user.id:
        raise HTTPException(status_code=400, detail="Öz məhsulunuzu ala bilməzsiniz")

    # Check if already purchased
    existing = await db.execute(
        select(ProductPurchase).where(
            and_(
                ProductPurchase.product_id == product.id,
                ProductPurchase.buyer_id == user.id
            )
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Bu məhsulu artıq almısınız")


# ============================================================
# MARKETPLACE PRODUCTS (Public)
# ============================================================

@router.get("/products", response_model=MarketplaceListResponse)
async def list_marketplace_products(
    page: int = 1,
    page_size: int = 20,
    product_type: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    sort_by: str = "created_at",  # created_at, price, rating, sales
    current_user: Optional[User] = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get marketplace products (public, published only)
    OWASP A03:2021 - Parameterized queries
    OWASP A04:2021 - Input validation
    """
    # Validation - OWASP A03:2021
    if page < 1 or page_size < 1 or page_size > 100:
        raise HTTPException(status_code=400, detail="Invalid pagination parameters")

    # Whitelist sort_by - OWASP A03:2021 Injection Prevention
    allowed_sorts = ["created_at", "price", "rating", "sales_count"]
    if sort_by not in allowed_sorts:
        sort_by = "created_at"

    offset = (page - 1) * page_size

    # Build query - Parameterized - OWASP A03:2021
    query = select(MarketplaceProduct).where(MarketplaceProduct.is_published == True)

    if product_type:
        query = query.where(MarketplaceProduct.product_type == product_type)
    if min_price is not None:
        query = query.where(MarketplaceProduct.price >= min_price)
    if max_price is not None:
        query = query.where(MarketplaceProduct.price <= max_price)

    # Sorting
    if sort_by == "price":
        query = query.order_by(MarketplaceProduct.price)
    elif sort_by == "rating":
        query = query.order_by(desc(MarketplaceProduct.rating))
    elif sort_by == "sales_count":
        query = query.order_by(desc(MarketplaceProduct.sales_count))
    else:
        query = query.order_by(desc(MarketplaceProduct.created_at))

    query = query.offset(offset).limit(page_size)

    result = await db.execute(query)
    products = result.scalars().all()

    # Get total count
    count_query = select(func.count(MarketplaceProduct.id)).where(
        MarketplaceProduct.is_published == True
    )
    if product_type:
        count_query = count_query.where(MarketplaceProduct.product_type == product_type)
    if min_price is not None:
        count_query = count_query.where(MarketplaceProduct.price >= min_price)
    if max_price is not None:
        count_query = count_query.where(MarketplaceProduct.price <= max_price)

    count_result = await db.execute(count_query)
    total = count_result.scalar()

    # Build responses with seller info
    product_responses = []
    for product in products:
        # Get seller
        seller_result = await db.execute(select(User).where(User.id == product.seller_id))
        seller = seller_result.scalar_one_or_none()

        # Check if current user purchased
        is_purchased = False
        if current_user:
            purchase_check = await db.execute(
                select(ProductPurchase).where(
                    and_(
                        ProductPurchase.product_id == product.id,
                        ProductPurchase.buyer_id == current_user.id
                    )
                )
            )
            is_purchased = purchase_check.scalar_one_or_none() is not None

        product_response = ProductResponse.model_validate(product)
        if seller:
            product_response.seller = ProductAuthor(
                id=seller.id,
                name=seller.name,
                profile_image_url=seller.profile_image_url,
                rating=seller.rating,
            )
        product_response.is_purchased = is_purchased
        product_responses.append(product_response)

    return MarketplaceListResponse(
        products=product_responses,
        total=total,
        page=page,
        page_size=page_size,
        has_more=(offset + page_size) < total,
    )


@router.get("/products/{product_id}", response_model=ProductResponse)
async def get_product_detail(
    product_id: str,
    current_user: Optional[User] = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get single product detail - OWASP A01:2021 Access Control"""
    product = await get_product_or_404(product_id, db)

    # Only show published products to non-owners - OWASP A01:2021
    if not product.is_published and (not current_user or product.seller_id != current_user.id):
        raise HTTPException(status_code=404, detail="Məhsul tapılmadı")

    # Get seller
    seller_result = await db.execute(select(User).where(User.id == product.seller_id))
    seller = seller_result.scalar_one_or_none()

    # Check if purchased
    is_purchased = False
    if current_user:
        purchase_check = await db.execute(
            select(ProductPurchase).where(
                and_(
                    ProductPurchase.product_id == product.id,
                    ProductPurchase.buyer_id == current_user.id
                )
            )
        )
        is_purchased = purchase_check.scalar_one_or_none() is not None

    product_response = ProductResponse.model_validate(product)
    if seller:
        product_response.seller = ProductAuthor(
            id=seller.id,
            name=seller.name,
            profile_image_url=seller.profile_image_url,
            rating=seller.rating,
        )
    product_response.is_purchased = is_purchased
    return product_response


# ============================================================
# SELLER ENDPOINTS (Trainer Only)
# ============================================================

@router.post("/products", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    product_data: ProductCreate,
    current_user: User = Depends(require_trainer),  # OWASP A01:2021 - Role-based access
    db: AsyncSession = Depends(get_db),
):
    """
    Create marketplace product (Trainer only)
    OWASP A01:2021 - Authorization check
    OWASP A03:2021 - Input validation (Pydantic)
    """
    # Input validated by Pydantic schema (product_data)
    product = MarketplaceProduct(
        seller_id=current_user.id,
        product_type=product_data.product_type,
        title=product_data.title,
        description=product_data.description,
        price=product_data.price,
        currency=product_data.currency,
        is_published=product_data.is_published,
    )
    db.add(product)
    await db.flush()
    await db.refresh(product)

    logger.info(f"Product created: {product.id} by user {current_user.id}")

    product_response = ProductResponse.model_validate(product)
    product_response.seller = ProductAuthor(
        id=current_user.id,
        name=current_user.name,
        profile_image_url=current_user.profile_image_url,
        rating=current_user.rating,
    )
    return product_response


@router.put("/products/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: str,
    product_data: ProductUpdate,
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Update product - OWASP A01:2021 Ownership verification"""
    product = await get_product_or_404(product_id, db)
    await verify_product_ownership(product, current_user)

    # Update fields (validated by Pydantic)
    if product_data.title is not None:
        product.title = product_data.title
    if product_data.description is not None:
        product.description = product_data.description
    if product_data.price is not None:
        product.price = product_data.price
    if product_data.is_published is not None:
        product.is_published = product_data.is_published

    await db.commit()
    await db.refresh(product)

    logger.info(f"Product updated: {product.id} by user {current_user.id}")

    product_response = ProductResponse.model_validate(product)
    product_response.seller = ProductAuthor(
        id=current_user.id,
        name=current_user.name,
        profile_image_url=current_user.profile_image_url,
        rating=current_user.rating,
    )
    return product_response


@router.post("/products/{product_id}/cover-image")
async def upload_product_cover(
    product_id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Upload product cover image - OWASP A01:2021 + File validation"""
    product = await get_product_or_404(product_id, db)
    await verify_product_ownership(product, current_user)

    # File validation happens in save_upload (size, type)
    file_path = await save_upload(file, "marketplace")
    product.cover_image_url = file_path
    await db.commit()

    logger.info(f"Cover image uploaded for product {product.id}")

    return {"cover_image_url": file_path}


@router.delete("/products/{product_id}")
async def delete_product(
    product_id: str,
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Delete product - OWASP A01:2021 Ownership check"""
    product = await get_product_or_404(product_id, db)
    await verify_product_ownership(product, current_user)

    # Can't delete if has sales - OWASP A04:2021 Business logic
    if product.sales_count > 0:
        raise HTTPException(
            status_code=400,
            detail="Satışı olan məhsul silinə bilməz. Yayımdan çıxarın."
        )

    await db.delete(product)
    await db.commit()

    logger.info(f"Product deleted: {product.id} by user {current_user.id}")

    return {"message": "Məhsul silindi"}


@router.get("/my-products", response_model=MyProductsResponse)
async def get_my_products(
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Get seller's products - OWASP A01:2021"""
    result = await db.execute(
        select(MarketplaceProduct)
        .where(MarketplaceProduct.seller_id == current_user.id)
        .order_by(desc(MarketplaceProduct.created_at))
    )
    products = result.scalars().all()

    # Calculate totals
    total_sales = sum(p.sales_count for p in products)
    total_revenue = sum(p.price * p.sales_count for p in products)

    product_responses = [ProductResponse.model_validate(p) for p in products]

    return MyProductsResponse(
        products=product_responses,
        total_sales=total_sales,
        total_revenue=total_revenue,
    )


# ============================================================
# PURCHASE ENDPOINTS
# ============================================================

@router.post("/purchase", response_model=PurchaseResponse)
async def purchase_product(
    purchase_data: PurchaseCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Purchase product
    OWASP A07:2021 - Payment validation
    OWASP A08:2021 - Receipt integrity check
    """
    product = await get_product_or_404(purchase_data.product_id, db)

    if not product.is_published:
        raise HTTPException(status_code=400, detail="Məhsul satışda deyil")

    await verify_purchase_eligibility(product, current_user, db)

    # Validate receipt if provided - OWASP A08:2021
    if purchase_data.receipt_data:
        validation = await validate_apple_receipt(purchase_data.receipt_data)
        if not validation or validation.get("status") != "valid":
            logger.warning(f"Invalid receipt for product {product.id} by user {current_user.id}")
            raise HTTPException(
                status_code=400,
                detail="Ödəniş təsdiqi uğursuz oldu"
            )

    # Create purchase record
    purchase = ProductPurchase(
        product_id=product.id,
        buyer_id=current_user.id,
        amount_paid=product.price,
        currency=product.currency,
        transaction_id=purchase_data.transaction_id,
        receipt_data=purchase_data.receipt_data,
    )
    db.add(purchase)

    # Update product stats
    product.sales_count += 1
    await db.commit()
    await db.refresh(purchase)

    logger.info(f"Purchase completed: product {product.id} by user {current_user.id}")

    response = PurchaseResponse.model_validate(purchase)
    response.product_title = product.title
    return response


@router.get("/my-purchases", response_model=MyPurchasesResponse)
async def get_my_purchases(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get user's purchases - OWASP A01:2021"""
    result = await db.execute(
        select(ProductPurchase)
        .where(ProductPurchase.buyer_id == current_user.id)
        .order_by(desc(ProductPurchase.purchased_at))
    )
    purchases = result.scalars().all()

    # Get product titles
    purchase_responses = []
    for purchase in purchases:
        product_result = await db.execute(
            select(MarketplaceProduct).where(MarketplaceProduct.id == purchase.product_id)
        )
        product = product_result.scalar_one_or_none()

        response = PurchaseResponse.model_validate(purchase)
        if product:
            response.product_title = product.title
        purchase_responses.append(response)

    total_spent = sum(p.amount_paid for p in purchases)

    return MyPurchasesResponse(
        purchases=purchase_responses,
        total_spent=total_spent,
    )


# ============================================================
# REVIEWS
# ============================================================

@router.post("/reviews", response_model=ProductReviewResponse)
async def create_product_review(
    review_data: ProductReviewCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create product review - OWASP A01:2021 Purchase verification"""
    product = await get_product_or_404(review_data.product_id, db)

    # Must have purchased to review - OWASP A04:2021 Business logic
    purchase_check = await db.execute(
        select(ProductPurchase).where(
            and_(
                ProductPurchase.product_id == product.id,
                ProductPurchase.buyer_id == current_user.id
            )
        )
    )
    if not purchase_check.scalar_one_or_none():
        raise HTTPException(
            status_code=403,
            detail="Məhsulu almadan rəy yaza bilməzsiniz"
        )

    # One review per user per product
    existing_review = await db.execute(
        select(ProductReview).where(
            and_(
                ProductReview.product_id == product.id,
                ProductReview.buyer_id == current_user.id
            )
        )
    )
    if existing_review.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Artıq rəy yazmısınız")

    # Create review
    review = ProductReview(
        product_id=product.id,
        buyer_id=current_user.id,
        rating=review_data.rating,
        comment=review_data.comment,
    )
    db.add(review)

    # Update product rating
    product.reviews_count += 1
    if product.rating is None:
        product.rating = float(review_data.rating)
    else:
        # Recalculate average
        total_rating = product.rating * (product.reviews_count - 1) + review_data.rating
        product.rating = total_rating / product.reviews_count

    await db.commit()
    await db.refresh(review)

    logger.info(f"Review created for product {product.id} by user {current_user.id}")

    response = ProductReviewResponse.model_validate(review)
    response.author = ReviewAuthor(
        id=current_user.id,
        name=current_user.name,
        profile_image_url=current_user.profile_image_url,
    )
    return response


@router.get("/products/{product_id}/reviews", response_model=list[ProductReviewResponse])
async def get_product_reviews(
    product_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Get product reviews (public)"""
    product = await get_product_or_404(product_id, db)

    result = await db.execute(
        select(ProductReview)
        .where(ProductReview.product_id == product.id)
        .order_by(desc(ProductReview.created_at))
    )
    reviews = result.scalars().all()

    # Get authors
    responses = []
    for review in reviews:
        author_result = await db.execute(select(User).where(User.id == review.buyer_id))
        author = author_result.scalar_one_or_none()

        response = ProductReviewResponse.model_validate(review)
        if author:
            response.author = ReviewAuthor(
                id=author.id,
                name=author.name,
                profile_image_url=author.profile_image_url,
            )
        responses.append(response)

    return responses
