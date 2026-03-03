import math

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.user import User
from app.models.complaint import Complaint
from app.schemas.complaint import (
    ComplaintCreateRequest,
    ComplaintResponse,
    ComplaintListResponse,
)
from app.utils.dependencies import get_current_user, pagination_params

router = APIRouter(prefix="/complaints", tags=["Complaints"])


@router.post("", response_model=ComplaintResponse, status_code=status.HTTP_201_CREATED)
async def create_complaint(
    request: ComplaintCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new complaint."""
    complaint = Complaint(
        reporter_id=current_user.id,
        target_type=request.target_type,
        target_id=request.target_id,
        complaint_type=request.complaint_type,
        description=request.description,
        screenshots=request.screenshots,
    )
    db.add(complaint)
    await db.flush()
    await db.refresh(complaint)

    return ComplaintResponse.model_validate(complaint)


@router.get("/my", response_model=ComplaintListResponse)
async def get_my_complaints(
    current_user: User = Depends(get_current_user),
    pagination: dict = Depends(pagination_params),
    db: AsyncSession = Depends(get_db),
):
    """Get the current user's complaints."""
    query = select(Complaint).where(Complaint.reporter_id == current_user.id)

    # Count
    count_query = select(func.count()).select_from(
        select(Complaint.id)
        .where(Complaint.reporter_id == current_user.id)
        .subquery()
    )
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Sort by newest first
    query = query.order_by(Complaint.created_at.desc())

    # Pagination
    query = query.offset(pagination["offset"]).limit(pagination["per_page"])
    result = await db.execute(query)
    complaints = result.scalars().all()

    pages = math.ceil(total / pagination["per_page"]) if total > 0 else 1

    return ComplaintListResponse(
        items=[ComplaintResponse.model_validate(c) for c in complaints],
        total=total,
        page=pagination["page"],
        per_page=pagination["per_page"],
        pages=pages,
    )
