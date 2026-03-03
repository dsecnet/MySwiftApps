import uuid
import math

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models.user import User
from app.models.agent import Agent
from app.models.review import Review
from app.schemas.review import (
    ReviewCreateRequest,
    ReviewResponse,
    ReviewListResponse,
)
from app.services.notification_service import notification_service
from app.utils.dependencies import get_current_user, pagination_params

router = APIRouter(prefix="/agents", tags=["Reviews"])


@router.get("/{agent_id}/reviews", response_model=ReviewListResponse)
async def get_agent_reviews(
    agent_id: uuid.UUID,
    pagination: dict = Depends(pagination_params),
    db: AsyncSession = Depends(get_db),
):
    """Get all reviews for a specific agent."""
    # Verify agent exists
    agent_result = await db.execute(
        select(Agent).where(Agent.id == agent_id)
    )
    agent = agent_result.scalar_one_or_none()
    if agent is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found",
        )

    query = select(Review).options(
        selectinload(Review.user)
    ).where(Review.agent_id == agent_id)

    # Count
    count_query = select(func.count()).select_from(
        select(Review.id).where(Review.agent_id == agent_id).subquery()
    )
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Sort by newest first
    query = query.order_by(Review.created_at.desc())

    # Pagination
    query = query.offset(pagination["offset"]).limit(pagination["per_page"])
    result = await db.execute(query)
    reviews = result.scalars().all()

    pages = math.ceil(total / pagination["per_page"]) if total > 0 else 1

    return ReviewListResponse(
        items=[ReviewResponse.model_validate(r) for r in reviews],
        total=total,
        page=pagination["page"],
        per_page=pagination["per_page"],
        pages=pages,
    )


@router.post(
    "/{agent_id}/reviews",
    response_model=ReviewResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_review(
    agent_id: uuid.UUID,
    request: ReviewCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a review for an agent."""
    # Verify agent exists
    agent_result = await db.execute(
        select(Agent).options(selectinload(Agent.user)).where(Agent.id == agent_id)
    )
    agent = agent_result.scalar_one_or_none()
    if agent is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found",
        )

    # Cannot review yourself
    if agent.user_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot review yourself",
        )

    # Check if user already reviewed this agent
    existing_result = await db.execute(
        select(Review).where(
            Review.agent_id == agent_id,
            Review.user_id == current_user.id,
        )
    )
    if existing_result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You have already reviewed this agent",
        )

    # Create review
    review = Review(
        agent_id=agent_id,
        user_id=current_user.id,
        rating=request.rating,
        comment=request.comment,
    )
    db.add(review)
    await db.flush()

    # Update agent rating and review count
    agent.total_reviews = (agent.total_reviews or 0) + 1

    # Recalculate average rating
    avg_result = await db.execute(
        select(func.avg(Review.rating)).where(Review.agent_id == agent_id)
    )
    avg_rating = avg_result.scalar() or 0.0
    agent.rating = round(float(avg_rating), 2)
    await db.flush()

    # Send notification to agent
    await notification_service.notify_new_review(
        db=db,
        agent_user_id=agent.user_id,
        reviewer_name=current_user.full_name,
        rating=request.rating,
        agent_id=agent_id,
    )

    await db.refresh(review)

    return ReviewResponse.model_validate(review)
