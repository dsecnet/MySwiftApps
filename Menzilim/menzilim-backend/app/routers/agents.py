import uuid
import math

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models.user import User, UserRole
from app.models.agent import Agent
from app.models.listing import Listing, ListingStatus
from app.schemas.agent import AgentResponse, AgentUpdateRequest, AgentListResponse
from app.schemas.listing import ListingResponse, ListingListResponse
from app.utils.dependencies import get_current_user, pagination_params

router = APIRouter(prefix="/agents", tags=["Agents"])


@router.get("", response_model=AgentListResponse)
async def list_agents(
    sort_by: str = Query("rating", enum=["rating", "level", "total_sales", "total_reviews"]),
    sort_order: str = Query("desc", enum=["asc", "desc"]),
    is_premium: bool | None = None,
    pagination: dict = Depends(pagination_params),
    db: AsyncSession = Depends(get_db),
):
    """List all agents with sorting and pagination."""
    query = select(Agent).options(selectinload(Agent.user))

    if is_premium is not None:
        query = query.where(Agent.is_premium == is_premium)

    # Count total
    count_query = select(func.count()).select_from(
        select(Agent.id).where(
            Agent.is_premium == is_premium if is_premium is not None else True
        ).subquery()
    ) if is_premium is not None else select(func.count(Agent.id))

    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Sorting
    sort_column = getattr(Agent, sort_by, Agent.rating)
    if sort_order == "desc":
        query = query.order_by(sort_column.desc())
    else:
        query = query.order_by(sort_column.asc())

    # Pagination
    query = query.offset(pagination["offset"]).limit(pagination["per_page"])
    result = await db.execute(query)
    agents = result.scalars().all()

    pages = math.ceil(total / pagination["per_page"]) if total > 0 else 1

    return AgentListResponse(
        items=[AgentResponse.model_validate(a) for a in agents],
        total=total,
        page=pagination["page"],
        per_page=pagination["per_page"],
        pages=pages,
    )


@router.get("/{agent_id}", response_model=AgentResponse)
async def get_agent(
    agent_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get an agent's profile by ID."""
    result = await db.execute(
        select(Agent)
        .options(selectinload(Agent.user))
        .where(Agent.id == agent_id)
    )
    agent = result.scalar_one_or_none()

    if agent is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found",
        )

    return AgentResponse.model_validate(agent)


@router.get("/{agent_id}/listings", response_model=ListingListResponse)
async def get_agent_listings(
    agent_id: uuid.UUID,
    status_filter: ListingStatus | None = Query(None, alias="status"),
    pagination: dict = Depends(pagination_params),
    db: AsyncSession = Depends(get_db),
):
    """Get all listings for a specific agent."""
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

    query = select(Listing).where(Listing.agent_id == agent_id)
    if status_filter:
        query = query.where(Listing.status == status_filter)

    # Count
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Sort by created_at desc
    query = query.order_by(
        Listing.is_boosted.desc(),
        Listing.created_at.desc(),
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


@router.put("/me", response_model=AgentResponse)
async def update_agent_profile(
    request: AgentUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update the current user's agent profile."""
    if current_user.role not in (UserRole.AGENT, UserRole.ADMIN):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only agents can update agent profiles",
        )

    result = await db.execute(
        select(Agent)
        .options(selectinload(Agent.user))
        .where(Agent.user_id == current_user.id)
    )
    agent = result.scalar_one_or_none()

    if agent is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent profile not found",
        )

    update_data = request.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields to update",
        )

    for field, value in update_data.items():
        setattr(agent, field, value)

    await db.flush()
    await db.refresh(agent)

    return AgentResponse.model_validate(agent)
