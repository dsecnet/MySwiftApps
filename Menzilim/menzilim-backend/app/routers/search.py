import math

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, func, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.listing import Listing, ListingStatus, ListingType, PropertyType
from app.schemas.listing import ListingResponse, ListingListResponse
from app.utils.dependencies import pagination_params

router = APIRouter(prefix="/listings", tags=["Search"])


@router.get("/search", response_model=ListingListResponse)
async def search_listings(
    q: str = Query(..., min_length=2, max_length=200, description="Search query"),
    listing_type: ListingType | None = None,
    property_type: PropertyType | None = None,
    min_price: float | None = None,
    max_price: float | None = None,
    rooms: int | None = None,
    city: str | None = None,
    min_area: float | None = None,
    max_area: float | None = None,
    sort_by: str = Query("created_at", enum=["created_at", "price", "views_count"]),
    sort_order: str = Query("desc", enum=["asc", "desc"]),
    pagination: dict = Depends(pagination_params),
    db: AsyncSession = Depends(get_db),
):
    """
    Advanced search for listings with text query.
    Searches across title, description, city, district, and address fields.
    """
    search_term = f"%{q}%"

    query = select(Listing).where(
        Listing.status == ListingStatus.ACTIVE,
        or_(
            Listing.title.ilike(search_term),
            Listing.description.ilike(search_term),
            Listing.city.ilike(search_term),
            Listing.district.ilike(search_term),
            Listing.address.ilike(search_term),
        ),
    )

    # Apply filters
    if listing_type:
        query = query.where(Listing.listing_type == listing_type)
    if property_type:
        query = query.where(Listing.property_type == property_type)
    if min_price is not None:
        query = query.where(Listing.price >= min_price)
    if max_price is not None:
        query = query.where(Listing.price <= max_price)
    if rooms is not None:
        query = query.where(Listing.rooms == rooms)
    if city:
        query = query.where(Listing.city.ilike(f"%{city}%"))
    if min_area is not None:
        query = query.where(Listing.area_sqm >= min_area)
    if max_area is not None:
        query = query.where(Listing.area_sqm <= max_area)

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Sorting
    sort_column = getattr(Listing, sort_by, Listing.created_at)
    if sort_order == "desc":
        query = query.order_by(
            Listing.is_boosted.desc(),
            sort_column.desc(),
        )
    else:
        query = query.order_by(
            Listing.is_boosted.desc(),
            sort_column.asc(),
        )

    # Pagination
    query = query.offset(pagination["offset"]).limit(pagination["per_page"])
    result = await db.execute(query)
    listings = result.scalars().all()

    pages = math.ceil(total / pagination["per_page"]) if total > 0 else 1

    return ListingListResponse(
        items=[ListingResponse.model_validate(l) for l in listings],
        total=total,
        page=pagination["page"],
        per_page=pagination["per_page"],
        pages=pages,
    )
