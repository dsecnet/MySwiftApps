from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, extract
from typing import Optional
from datetime import datetime
import math

from app.database import get_db
from app.models.user import User
from app.models.deal import Deal, DealStatus
from app.models.property import Property
from app.models.client import Client
from app.schemas.deal import (
    DealCreate,
    DealUpdate,
    DealResponse,
    DealWithDetails,
    DealListResponse,
    DealStatsResponse,
)
from app.utils.security import get_current_user


router = APIRouter(prefix="/api/v1/deals", tags=["Deals"])


@router.post("/", response_model=DealResponse, status_code=201)
async def create_deal(
    request: DealCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Yeni deal yarat (satış/kirayə müqaviləsi)
    """
    # Verify property exists and belongs to agent
    property_query = select(Property).where(
        and_(Property.id == request.property_id, Property.agent_id == current_user.id)
    )
    property_result = await db.execute(property_query)
    property_obj = property_result.scalar_one_or_none()

    if not property_obj:
        raise HTTPException(
            status_code=404, detail="Əmlak tapılmadı və ya sizə aid deyil"
        )

    # Verify client exists and belongs to agent
    client_query = select(Client).where(
        and_(Client.id == request.client_id, Client.agent_id == current_user.id)
    )
    client_result = await db.execute(client_query)
    client_obj = client_result.scalar_one_or_none()

    if not client_obj:
        raise HTTPException(
            status_code=404, detail="Müştəri tapılmadı və ya sizə aid deyil"
        )

    # Calculate commission amount
    commission_amount = None
    if request.commission_percentage:
        commission_amount = (request.agreed_price * request.commission_percentage) / 100

    # Create deal
    deal = Deal(
        agent_id=current_user.id,
        property_id=request.property_id,
        client_id=request.client_id,
        agreed_price=request.agreed_price,
        currency=request.currency,
        commission_percentage=request.commission_percentage,
        commission_amount=commission_amount,
        deposit_amount=request.deposit_amount,
        notes=request.notes,
    )

    db.add(deal)
    await db.commit()
    await db.refresh(deal)

    return deal


@router.get("/", response_model=DealListResponse)
async def list_deals(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    property_id: Optional[str] = None,
    client_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Deal-ləri siyahıla (filterlər ilə)
    """
    # Base query
    query = select(Deal).where(Deal.agent_id == current_user.id)

    # Filters
    if status:
        query = query.where(Deal.status == DealStatus(status))

    if property_id:
        query = query.where(Deal.property_id == property_id)

    if client_id:
        query = query.where(Deal.client_id == client_id)

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Pagination
    offset = (page - 1) * limit
    query = query.order_by(Deal.created_at.desc()).offset(offset).limit(limit)

    result = await db.execute(query)
    deals = result.scalars().all()

    return DealListResponse(
        deals=deals,
        total=total,
        page=page,
        total_pages=math.ceil(total / limit) if total > 0 else 0,
    )


@router.get("/with-details", response_model=list[DealWithDetails])
async def list_deals_with_details(
    limit: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Deal-ləri əmlak və müştəri məlumatları ilə siyahıla
    """
    query = (
        select(Deal, Property.title, Property.address, Client.name, Client.phone)
        .join(Property, Deal.property_id == Property.id)
        .join(Client, Deal.client_id == Client.id)
        .where(Deal.agent_id == current_user.id)
    )

    if status:
        query = query.where(Deal.status == DealStatus(status))

    query = query.order_by(Deal.created_at.desc()).limit(limit)

    result = await db.execute(query)
    rows = result.all()

    deals_with_details = []
    for deal, prop_title, prop_address, client_name, client_phone in rows:
        deal_dict = {
            **deal.__dict__,
            "property_title": prop_title,
            "property_address": prop_address,
            "client_name": client_name,
            "client_phone": client_phone,
        }
        deals_with_details.append(DealWithDetails(**deal_dict))

    return deals_with_details


@router.get("/stats/summary", response_model=DealStatsResponse)
async def get_deals_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Deal statistikaları (revenue, komissiya, conversion)
    """
    # Total deals
    total_query = select(func.count()).where(Deal.agent_id == current_user.id)
    total_result = await db.execute(total_query)
    total_deals = total_result.scalar()

    # By status
    status_query = (
        select(Deal.status, func.count())
        .where(Deal.agent_id == current_user.id)
        .group_by(Deal.status)
    )
    status_result = await db.execute(status_query)
    by_status = {str(s): count for s, count in status_result.all()}

    # Completed deals stats
    completed_query = select(
        func.sum(Deal.agreed_price), func.sum(Deal.commission_amount)
    ).where(
        and_(Deal.agent_id == current_user.id, Deal.status == DealStatus.completed)
    )
    completed_result = await db.execute(completed_query)
    total_revenue, total_commission = completed_result.one()
    total_revenue = total_revenue or 0.0
    total_commission = total_commission or 0.0

    # Average deal value
    avg_query = select(func.avg(Deal.agreed_price)).where(
        and_(Deal.agent_id == current_user.id, Deal.status == DealStatus.completed)
    )
    avg_result = await db.execute(avg_query)
    average_deal_value = avg_result.scalar() or 0.0

    # This month stats
    now = datetime.utcnow()
    month_query = select(
        func.count(), func.sum(Deal.agreed_price), func.sum(Deal.commission_amount)
    ).where(
        and_(
            Deal.agent_id == current_user.id,
            Deal.status == DealStatus.completed,
            extract("year", Deal.closed_at) == now.year,
            extract("month", Deal.closed_at) == now.month,
        )
    )
    month_result = await db.execute(month_query)
    this_month_deals, this_month_revenue, this_month_commission = month_result.one()
    this_month_deals = this_month_deals or 0
    this_month_revenue = this_month_revenue or 0.0
    this_month_commission = this_month_commission or 0.0

    # Pending deals value
    pending_query = select(func.sum(Deal.agreed_price)).where(
        and_(Deal.agent_id == current_user.id, Deal.status == DealStatus.pending)
    )
    pending_result = await db.execute(pending_query)
    pending_deals_value = pending_result.scalar() or 0.0

    # Conversion rate
    completed_count = by_status.get(str(DealStatus.completed), 0)
    conversion_rate = (
        (completed_count / total_deals * 100) if total_deals > 0 else 0.0
    )

    return DealStatsResponse(
        total_deals=total_deals,
        by_status=by_status,
        total_revenue=total_revenue,
        total_commission=total_commission,
        average_deal_value=average_deal_value,
        this_month_deals=this_month_deals,
        this_month_revenue=this_month_revenue,
        this_month_commission=this_month_commission,
        pending_deals_value=pending_deals_value,
        conversion_rate=conversion_rate,
    )


@router.get("/{deal_id}", response_model=DealResponse)
async def get_deal(
    deal_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Deal detallarını gətir
    """
    query = select(Deal).where(
        and_(Deal.id == deal_id, Deal.agent_id == current_user.id)
    )

    result = await db.execute(query)
    deal = result.scalar_one_or_none()

    if not deal:
        raise HTTPException(status_code=404, detail="Deal tapılmadı")

    return deal


@router.put("/{deal_id}", response_model=DealResponse)
async def update_deal(
    deal_id: str,
    request: DealUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Deal-i yenilə (status, qiymət, komissiya)
    """
    query = select(Deal).where(
        and_(Deal.id == deal_id, Deal.agent_id == current_user.id)
    )

    result = await db.execute(query)
    deal = result.scalar_one_or_none()

    if not deal:
        raise HTTPException(status_code=404, detail="Deal tapılmadı")

    # Update fields
    if request.status:
        deal.status = DealStatus(request.status)
        # Auto-set closed_at when completed
        if request.status == "completed" and not deal.closed_at:
            deal.closed_at = datetime.utcnow()

    if request.agreed_price:
        deal.agreed_price = request.agreed_price
        # Recalculate commission if percentage exists
        if deal.commission_percentage:
            deal.commission_amount = (
                deal.agreed_price * deal.commission_percentage
            ) / 100

    if request.commission_percentage is not None:
        deal.commission_percentage = request.commission_percentage
        deal.commission_amount = (deal.agreed_price * request.commission_percentage) / 100

    if request.deposit_amount is not None:
        deal.deposit_amount = request.deposit_amount

    if request.contract_signed_at:
        deal.contract_signed_at = request.contract_signed_at

    if request.contract_document_url:
        deal.contract_document_url = request.contract_document_url

    if request.notes is not None:
        deal.notes = request.notes

    deal.updated_at = datetime.utcnow()

    await db.commit()
    await db.refresh(deal)

    return deal


@router.delete("/{deal_id}", status_code=204)
async def delete_deal(
    deal_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Deal-i sil
    """
    query = select(Deal).where(
        and_(Deal.id == deal_id, Deal.agent_id == current_user.id)
    )

    result = await db.execute(query)
    deal = result.scalar_one_or_none()

    if not deal:
        raise HTTPException(status_code=404, detail="Deal tapılmadı")

    await db.delete(deal)
    await db.commit()

    return None
