from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_
from typing import Optional
from datetime import datetime, timedelta
import math

from app.database import get_db
from app.models.user import User
from app.models.activity import Activity, ActivityType, ActivityStatus
from app.schemas.activity import (
    ActivityCreate,
    ActivityUpdate,
    ActivityResponse,
    ActivityListResponse,
    ActivityStatsResponse,
)
from app.utils.security import get_current_user


router = APIRouter(prefix="/api/v1/activities", tags=["Activities"])


@router.post("/", response_model=ActivityResponse, status_code=201)
async def create_activity(
    request: ActivityCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Yeni aktivlik yarat (görüş, zəng, baxış)
    """
    # Create activity
    activity = Activity(
        agent_id=current_user.id,
        activity_type=ActivityType(request.activity_type),
        title=request.title,
        description=request.description,
        client_id=request.client_id,
        property_id=request.property_id,
        scheduled_at=request.scheduled_at,
        location=request.location,
    )

    # Calculate reminder time
    if request.scheduled_at and request.reminder_minutes:
        activity.reminder_at = request.scheduled_at - timedelta(
            minutes=request.reminder_minutes
        )

    db.add(activity)
    await db.commit()
    await db.refresh(activity)

    return activity


@router.get("/", response_model=ActivityListResponse)
async def list_activities(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    activity_type: Optional[str] = None,
    status: Optional[str] = None,
    client_id: Optional[str] = None,
    property_id: Optional[str] = None,
    date_from: Optional[datetime] = None,
    date_to: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Aktivlikləri siyahıla (filterlər ilə)
    """
    # Base query
    query = select(Activity).where(Activity.agent_id == current_user.id)

    # Filters
    if activity_type:
        query = query.where(Activity.activity_type == ActivityType(activity_type))

    if status:
        query = query.where(Activity.status == ActivityStatus(status))

    if client_id:
        query = query.where(Activity.client_id == client_id)

    if property_id:
        query = query.where(Activity.property_id == property_id)

    if date_from:
        query = query.where(Activity.scheduled_at >= date_from)

    if date_to:
        query = query.where(Activity.scheduled_at <= date_to)

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Pagination
    offset = (page - 1) * limit
    query = query.order_by(Activity.scheduled_at.desc()).offset(offset).limit(limit)

    result = await db.execute(query)
    activities = result.scalars().all()

    return ActivityListResponse(
        activities=activities,
        total=total,
        page=page,
        total_pages=math.ceil(total / limit) if total > 0 else 0,
    )


@router.get("/upcoming", response_model=ActivityListResponse)
async def get_upcoming_activities(
    limit: int = Query(10, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Gələcək aktivliklər (növbəti görüşlər)
    """
    now = datetime.utcnow()

    query = (
        select(Activity)
        .where(
            and_(
                Activity.agent_id == current_user.id,
                Activity.status == ActivityStatus.scheduled,
                Activity.scheduled_at >= now,
            )
        )
        .order_by(Activity.scheduled_at.asc())
        .limit(limit)
    )

    result = await db.execute(query)
    activities = result.scalars().all()

    return ActivityListResponse(
        activities=activities,
        total=len(activities),
        page=1,
        total_pages=1,
    )


@router.get("/today", response_model=ActivityListResponse)
async def get_today_activities(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Bu günün aktivlikləri
    """
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)

    query = (
        select(Activity)
        .where(
            and_(
                Activity.agent_id == current_user.id,
                Activity.scheduled_at >= today_start,
                Activity.scheduled_at < today_end,
            )
        )
        .order_by(Activity.scheduled_at.asc())
    )

    result = await db.execute(query)
    activities = result.scalars().all()

    return ActivityListResponse(
        activities=activities,
        total=len(activities),
        page=1,
        total_pages=1,
    )


@router.get("/stats/summary", response_model=ActivityStatsResponse)
async def get_activities_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Aktivlik statistikaları
    """
    # Total activities
    total_query = select(func.count()).where(Activity.agent_id == current_user.id)
    total_result = await db.execute(total_query)
    total_activities = total_result.scalar()

    # By type
    type_query = (
        select(Activity.activity_type, func.count())
        .where(Activity.agent_id == current_user.id)
        .group_by(Activity.activity_type)
    )
    type_result = await db.execute(type_query)
    by_type = {str(t): count for t, count in type_result.all()}

    # By status
    status_query = (
        select(Activity.status, func.count())
        .where(Activity.agent_id == current_user.id)
        .group_by(Activity.status)
    )
    status_result = await db.execute(status_query)
    by_status = {str(s): count for s, count in status_result.all()}

    # Time-based stats
    now = datetime.utcnow()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = today_start - timedelta(days=today_start.weekday())
    month_start = today_start.replace(day=1)

    # Today
    today_query = select(func.count()).where(
        and_(
            Activity.agent_id == current_user.id,
            Activity.scheduled_at >= today_start,
            Activity.scheduled_at < today_start + timedelta(days=1),
        )
    )
    today_result = await db.execute(today_query)
    today = today_result.scalar()

    # This week
    week_query = select(func.count()).where(
        and_(
            Activity.agent_id == current_user.id,
            Activity.scheduled_at >= week_start,
        )
    )
    week_result = await db.execute(week_query)
    this_week = week_result.scalar()

    # This month
    month_query = select(func.count()).where(
        and_(
            Activity.agent_id == current_user.id,
            Activity.scheduled_at >= month_start,
        )
    )
    month_result = await db.execute(month_query)
    this_month = month_result.scalar()

    # Upcoming (future scheduled)
    upcoming_query = select(func.count()).where(
        and_(
            Activity.agent_id == current_user.id,
            Activity.status == ActivityStatus.scheduled,
            Activity.scheduled_at >= now,
        )
    )
    upcoming_result = await db.execute(upcoming_query)
    upcoming = upcoming_result.scalar()

    # Overdue (missed scheduled)
    overdue_query = select(func.count()).where(
        and_(
            Activity.agent_id == current_user.id,
            Activity.status == ActivityStatus.scheduled,
            Activity.scheduled_at < now,
        )
    )
    overdue_result = await db.execute(overdue_query)
    overdue = overdue_result.scalar()

    return ActivityStatsResponse(
        total_activities=total_activities,
        by_type=by_type,
        by_status=by_status,
        today=today,
        this_week=this_week,
        this_month=this_month,
        upcoming=upcoming,
        overdue=overdue,
    )


@router.get("/{activity_id}", response_model=ActivityResponse)
async def get_activity(
    activity_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Aktivliyin detallarını gətir
    """
    query = select(Activity).where(
        and_(Activity.id == activity_id, Activity.agent_id == current_user.id)
    )

    result = await db.execute(query)
    activity = result.scalar_one_or_none()

    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    return activity


@router.put("/{activity_id}", response_model=ActivityResponse)
async def update_activity(
    activity_id: str,
    request: ActivityUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Aktivliyi yenilə (status, tarix, məlumat)
    """
    query = select(Activity).where(
        and_(Activity.id == activity_id, Activity.agent_id == current_user.id)
    )

    result = await db.execute(query)
    activity = result.scalar_one_or_none()

    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    # Update fields
    if request.title:
        activity.title = request.title
    if request.description is not None:
        activity.description = request.description
    if request.status:
        activity.status = ActivityStatus(request.status)
        # Auto-set completed_at
        if request.status == "completed" and not activity.completed_at:
            activity.completed_at = datetime.utcnow()
    if request.scheduled_at:
        activity.scheduled_at = request.scheduled_at
    if request.completed_at:
        activity.completed_at = request.completed_at
    if request.location is not None:
        activity.location = request.location

    activity.updated_at = datetime.utcnow()

    await db.commit()
    await db.refresh(activity)

    return activity


@router.delete("/{activity_id}", status_code=204)
async def delete_activity(
    activity_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Aktivliyi sil
    """
    query = select(Activity).where(
        and_(Activity.id == activity_id, Activity.agent_id == current_user.id)
    )

    result = await db.execute(query)
    activity = result.scalar_one_or_none()

    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    await db.delete(activity)
    await db.commit()

    return None
