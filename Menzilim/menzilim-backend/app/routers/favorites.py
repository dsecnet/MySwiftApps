import uuid
import math

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models.user import User
from app.models.listing import Listing
from app.models.favorite import Favorite
from app.schemas.listing import ListingResponse, ListingListResponse
from app.schemas.auth import MessageResponse
from app.services.notification_service import notification_service
from app.utils.dependencies import get_current_user, pagination_params

router = APIRouter(prefix="/favorites", tags=["Favorites"])


@router.get("", response_model=ListingListResponse)
async def get_my_favorites(
    current_user: User = Depends(get_current_user),
    pagination: dict = Depends(pagination_params),
    db: AsyncSession = Depends(get_db),
):
    """Get the current user's favorite listings."""
    query = (
        select(Listing)
        .join(Favorite, Favorite.listing_id == Listing.id)
        .where(Favorite.user_id == current_user.id)
    )

    # Count total
    count_query = select(func.count()).select_from(
        select(Favorite.id).where(Favorite.user_id == current_user.id).subquery()
    )
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Sort by favorited date (newest first)
    query = query.order_by(Favorite.created_at.desc())

    # Pagination
    query = query.offset(pagination["offset"]).limit(pagination["per_page"])
    result = await db.execute(query)
    listings = result.scalars().all()

    # Mark all as favorited
    listing_responses = []
    for listing in listings:
        resp = ListingResponse.model_validate(listing)
        resp.is_favorited = True
        listing_responses.append(resp)

    pages = math.ceil(total / pagination["per_page"]) if total > 0 else 1

    return ListingListResponse(
        items=listing_responses,
        total=total,
        page=pagination["page"],
        per_page=pagination["per_page"],
        pages=pages,
    )


@router.post("/{listing_id}", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
async def add_to_favorites(
    listing_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Add a listing to the current user's favorites."""
    # Verify listing exists
    listing_result = await db.execute(
        select(Listing).where(Listing.id == listing_id)
    )
    listing = listing_result.scalar_one_or_none()
    if listing is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found",
        )

    # Check if already favorited
    existing = await db.execute(
        select(Favorite).where(
            Favorite.user_id == current_user.id,
            Favorite.listing_id == listing_id,
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Listing already in favorites",
        )

    favorite = Favorite(
        user_id=current_user.id,
        listing_id=listing_id,
    )
    db.add(favorite)
    await db.flush()

    # Notify listing owner (if not favoriting own listing)
    if listing.user_id != current_user.id:
        await notification_service.notify_new_favorite(
            db=db,
            listing_owner_id=listing.user_id,
            listing_title=listing.title,
            listing_id=listing_id,
        )

    return MessageResponse(message="Listing added to favorites")


@router.delete("/{listing_id}", response_model=MessageResponse)
async def remove_from_favorites(
    listing_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Remove a listing from the current user's favorites."""
    result = await db.execute(
        select(Favorite).where(
            Favorite.user_id == current_user.id,
            Favorite.listing_id == listing_id,
        )
    )
    favorite = result.scalar_one_or_none()

    if favorite is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not in favorites",
        )

    await db.delete(favorite)
    await db.flush()

    return MessageResponse(message="Listing removed from favorites")
