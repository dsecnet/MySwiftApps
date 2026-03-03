import uuid
import math

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.user import User
from app.models.notification import Notification
from app.schemas.notification import NotificationResponse, NotificationListResponse
from app.schemas.auth import MessageResponse
from app.services.notification_service import notification_service
from app.utils.dependencies import get_current_user, pagination_params

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("", response_model=NotificationListResponse)
async def get_my_notifications(
    current_user: User = Depends(get_current_user),
    pagination: dict = Depends(pagination_params),
    db: AsyncSession = Depends(get_db),
):
    """Get the current user's notifications."""
    query = select(Notification).where(
        Notification.user_id == current_user.id
    )

    # Count total
    count_query = select(func.count()).select_from(
        select(Notification.id)
        .where(Notification.user_id == current_user.id)
        .subquery()
    )
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Count unread
    unread_count = await notification_service.get_unread_count(
        db, current_user.id
    )

    # Sort by newest first
    query = query.order_by(Notification.created_at.desc())

    # Pagination
    query = query.offset(pagination["offset"]).limit(pagination["per_page"])
    result = await db.execute(query)
    notifications = result.scalars().all()

    pages = math.ceil(total / pagination["per_page"]) if total > 0 else 1

    return NotificationListResponse(
        items=[NotificationResponse.model_validate(n) for n in notifications],
        total=total,
        unread_count=unread_count,
        page=pagination["page"],
        per_page=pagination["per_page"],
        pages=pages,
    )


@router.put("/{notification_id}/read", response_model=MessageResponse)
async def mark_notification_as_read(
    notification_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Mark a notification as read."""
    result = await db.execute(
        select(Notification).where(
            Notification.id == notification_id,
            Notification.user_id == current_user.id,
        )
    )
    notification = result.scalar_one_or_none()

    if notification is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found",
        )

    notification.is_read = True
    await db.flush()

    return MessageResponse(message="Notification marked as read")
