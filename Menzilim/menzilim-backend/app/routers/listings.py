import uuid
import math
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.user import User, UserRole
from app.models.listing import (
    Listing,
    ListingType,
    PropertyType,
    ListingStatus,
    BoostType,
)
from app.models.agent import Agent
from app.models.favorite import Favorite
from app.schemas.listing import (
    ListingCreateRequest,
    ListingUpdateRequest,
    ListingResponse,
    ListingListResponse,
    ListingMapResponse,
    BoostRequest,
)
from app.schemas.auth import MessageResponse
from app.utils.dependencies import get_current_user, pagination_params

router = APIRouter(prefix="/listings", tags=["Listings"])


@router.get("", response_model=ListingListResponse)
async def list_listings(
    listing_type: ListingType | None = None,
    property_type: PropertyType | None = None,
    min_price: float | None = None,
    max_price: float | None = None,
    rooms: int | None = None,
    city: str | None = None,
    district: str | None = None,
    sort_by: str = Query("created_at", enum=["created_at", "price", "views_count"]),
    sort_order: str = Query("desc", enum=["asc", "desc"]),
    pagination: dict = Depends(pagination_params),
    db: AsyncSession = Depends(get_db),
):
    """List listings with filters, sorting, and pagination."""
    query = select(Listing).where(Listing.status == ListingStatus.ACTIVE)

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
    if district:
        query = query.where(Listing.district.ilike(f"%{district}%"))

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Sorting: boosted listings first, then by chosen field
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


@router.post("", response_model=ListingResponse, status_code=status.HTTP_201_CREATED)
async def create_listing(
    request: ListingCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new listing."""
    # Check if user has an agent profile
    agent_id = None
    if current_user.role == UserRole.AGENT:
        agent_result = await db.execute(
            select(Agent).where(Agent.user_id == current_user.id)
        )
        agent = agent_result.scalar_one_or_none()
        if agent:
            agent_id = agent.id

    listing = Listing(
        user_id=current_user.id,
        agent_id=agent_id,
        status=ListingStatus.ACTIVE,
        **request.model_dump(),
    )
    db.add(listing)
    await db.flush()
    await db.refresh(listing)

    # Update agent total_listings count
    if agent_id:
        agent_result = await db.execute(
            select(Agent).where(Agent.id == agent_id)
        )
        agent = agent_result.scalar_one_or_none()
        if agent:
            agent.total_listings = (agent.total_listings or 0) + 1
            await db.flush()

    return ListingResponse.model_validate(listing)


@router.get("/{listing_id}", response_model=ListingResponse)
async def get_listing(
    listing_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get a listing by ID. Increments the view count."""
    result = await db.execute(
        select(Listing).where(Listing.id == listing_id)
    )
    listing = result.scalar_one_or_none()

    if listing is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found",
        )

    # Increment views
    listing.views_count = (listing.views_count or 0) + 1
    await db.flush()

    return ListingResponse.model_validate(listing)


@router.put("/{listing_id}", response_model=ListingResponse)
async def update_listing(
    listing_id: uuid.UUID,
    request: ListingUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update a listing. Only the owner or admin can update."""
    result = await db.execute(
        select(Listing).where(Listing.id == listing_id)
    )
    listing = result.scalar_one_or_none()

    if listing is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found",
        )

    # Authorization check
    if listing.user_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this listing",
        )

    update_data = request.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields to update",
        )

    for field, value in update_data.items():
        setattr(listing, field, value)

    await db.flush()
    await db.refresh(listing)

    return ListingResponse.model_validate(listing)


@router.delete("/{listing_id}", response_model=MessageResponse)
async def delete_listing(
    listing_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a listing. Only the owner or admin can delete."""
    result = await db.execute(
        select(Listing).where(Listing.id == listing_id)
    )
    listing = result.scalar_one_or_none()

    if listing is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found",
        )

    if listing.user_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to delete this listing",
        )

    await db.delete(listing)
    await db.flush()

    return MessageResponse(message="Listing deleted successfully")


@router.get("/map/bounds", response_model=list[ListingMapResponse])
async def get_listings_on_map(
    min_lat: float = Query(..., ge=-90, le=90),
    max_lat: float = Query(..., ge=-90, le=90),
    min_lng: float = Query(..., ge=-180, le=180),
    max_lng: float = Query(..., ge=-180, le=180),
    listing_type: ListingType | None = None,
    property_type: PropertyType | None = None,
    db: AsyncSession = Depends(get_db),
):
    """Get active listings within map bounds for map display."""
    query = select(Listing).where(
        and_(
            Listing.status == ListingStatus.ACTIVE,
            Listing.latitude.isnot(None),
            Listing.longitude.isnot(None),
            Listing.latitude >= min_lat,
            Listing.latitude <= max_lat,
            Listing.longitude >= min_lng,
            Listing.longitude <= max_lng,
        )
    )

    if listing_type:
        query = query.where(Listing.listing_type == listing_type)
    if property_type:
        query = query.where(Listing.property_type == property_type)

    query = query.limit(500)  # Cap results for map performance

    result = await db.execute(query)
    listings = result.scalars().all()

    return [ListingMapResponse.model_validate(l) for l in listings]


@router.post("/{listing_id}/boost", response_model=ListingResponse)
async def boost_listing(
    listing_id: uuid.UUID,
    request: BoostRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Boost a listing for increased visibility."""
    result = await db.execute(
        select(Listing).where(Listing.id == listing_id)
    )
    listing = result.scalar_one_or_none()

    if listing is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found",
        )

    if listing.user_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to boost this listing",
        )

    if listing.status != ListingStatus.ACTIVE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only active listings can be boosted",
        )

    listing.is_boosted = True
    listing.boost_type = request.boost_type
    listing.boost_expires_at = datetime.now(timezone.utc) + timedelta(
        days=request.duration_days
    )

    await db.flush()
    await db.refresh(listing)

    return ListingResponse.model_validate(listing)
