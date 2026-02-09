from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, extract
from datetime import datetime
from pydantic import BaseModel

from app.database import get_db
from app.models.user import User
from app.models.property import Property, PropertyStatus
from app.models.client import Client, LeadStatus
from app.models.activity import Activity, ActivityStatus
from app.models.deal import Deal, DealStatus
from app.utils.security import get_current_user


router = APIRouter(prefix="/api/v1/dashboard", tags=["Dashboard"])


class DashboardStats(BaseModel):
    """Dashboard statistikaları"""
    # Overview
    total_properties: int
    total_clients: int
    total_activities: int
    total_deals: int

    # Properties breakdown
    properties_for_sale: int
    properties_for_rent: int
    properties_sold: int

    # Clients breakdown
    active_clients: int
    hot_leads: int  # contacted + viewing_scheduled
    conversion_rate: float

    # Activities
    upcoming_activities: int
    today_activities: int
    overdue_activities: int

    # Deals & Revenue
    pending_deals: int
    completed_deals: int
    total_revenue: float
    total_commission: float
    this_month_revenue: float
    this_month_commission: float

    # Quick insights
    avg_property_price: float
    avg_deal_value: float
    deal_conversion_rate: float


class RecentActivity(BaseModel):
    """Son aktivliklər"""
    type: str  # "property", "client", "activity", "deal"
    title: str
    description: str
    created_at: datetime


class DashboardResponse(BaseModel):
    """Dashboard response"""
    stats: DashboardStats
    recent_activities: list[RecentActivity]


@router.get("/", response_model=DashboardResponse)
async def get_dashboard(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Agent üçün ümumi dashboard (bütün statistikalar)
    """
    # Properties stats
    total_properties_query = select(func.count()).where(
        Property.agent_id == current_user.id
    )
    total_properties_result = await db.execute(total_properties_query)
    total_properties = total_properties_result.scalar()

    # Properties for sale
    sale_query = select(func.count()).where(
        and_(Property.agent_id == current_user.id, Property.deal_type == "sale")
    )
    sale_result = await db.execute(sale_query)
    properties_for_sale = sale_result.scalar()

    # Properties for rent
    rent_query = select(func.count()).where(
        and_(Property.agent_id == current_user.id, Property.deal_type == "rent")
    )
    rent_result = await db.execute(rent_query)
    properties_for_rent = rent_result.scalar()

    # Properties sold
    sold_query = select(func.count()).where(
        and_(
            Property.agent_id == current_user.id,
            Property.status == PropertyStatus.sold,
        )
    )
    sold_result = await db.execute(sold_query)
    properties_sold = sold_result.scalar()

    # Average property price
    avg_price_query = select(func.avg(Property.price)).where(
        Property.agent_id == current_user.id
    )
    avg_price_result = await db.execute(avg_price_query)
    avg_property_price = avg_price_result.scalar() or 0.0

    # Clients stats
    total_clients_query = select(func.count()).where(
        Client.agent_id == current_user.id
    )
    total_clients_result = await db.execute(total_clients_query)
    total_clients = total_clients_result.scalar()

    # Active clients (not lost or archived)
    active_clients_query = select(func.count()).where(
        and_(
            Client.agent_id == current_user.id,
            Client.lead_status.not_in([LeadStatus.lost, LeadStatus.archived]),
        )
    )
    active_clients_result = await db.execute(active_clients_query)
    active_clients = active_clients_result.scalar()

    # Hot leads (contacted + viewing_scheduled)
    hot_leads_query = select(func.count()).where(
        and_(
            Client.agent_id == current_user.id,
            Client.lead_status.in_([LeadStatus.contacted, LeadStatus.viewing_scheduled]),
        )
    )
    hot_leads_result = await db.execute(hot_leads_query)
    hot_leads = hot_leads_result.scalar()

    # Client conversion rate
    converted_query = select(func.count()).where(
        and_(
            Client.agent_id == current_user.id,
            Client.lead_status == LeadStatus.deal_closed,
        )
    )
    converted_result = await db.execute(converted_query)
    converted = converted_result.scalar()
    conversion_rate = (converted / total_clients * 100) if total_clients > 0 else 0.0

    # Activities stats
    total_activities_query = select(func.count()).where(
        Activity.agent_id == current_user.id
    )
    total_activities_result = await db.execute(total_activities_query)
    total_activities = total_activities_result.scalar()

    # Upcoming activities
    now = datetime.utcnow()
    upcoming_query = select(func.count()).where(
        and_(
            Activity.agent_id == current_user.id,
            Activity.status == ActivityStatus.scheduled,
            Activity.scheduled_at >= now,
        )
    )
    upcoming_result = await db.execute(upcoming_query)
    upcoming_activities = upcoming_result.scalar()

    # Today activities
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)
    today_query = select(func.count()).where(
        and_(
            Activity.agent_id == current_user.id,
            Activity.scheduled_at >= today_start,
            Activity.scheduled_at < today_end,
        )
    )
    today_result = await db.execute(today_query)
    today_activities = today_result.scalar()

    # Overdue activities
    overdue_query = select(func.count()).where(
        and_(
            Activity.agent_id == current_user.id,
            Activity.status == ActivityStatus.scheduled,
            Activity.scheduled_at < now,
        )
    )
    overdue_result = await db.execute(overdue_query)
    overdue_activities = overdue_result.scalar()

    # Deals stats
    total_deals_query = select(func.count()).where(Deal.agent_id == current_user.id)
    total_deals_result = await db.execute(total_deals_query)
    total_deals = total_deals_result.scalar()

    # Pending deals
    pending_deals_query = select(func.count()).where(
        and_(Deal.agent_id == current_user.id, Deal.status == DealStatus.pending)
    )
    pending_deals_result = await db.execute(pending_deals_query)
    pending_deals = pending_deals_result.scalar()

    # Completed deals
    completed_deals_query = select(func.count()).where(
        and_(Deal.agent_id == current_user.id, Deal.status == DealStatus.completed)
    )
    completed_deals_result = await db.execute(completed_deals_query)
    completed_deals = completed_deals_result.scalar()

    # Revenue & commission
    revenue_query = select(
        func.sum(Deal.agreed_price), func.sum(Deal.commission_amount)
    ).where(and_(Deal.agent_id == current_user.id, Deal.status == DealStatus.completed))
    revenue_result = await db.execute(revenue_query)
    total_revenue, total_commission = revenue_result.one()
    total_revenue = total_revenue or 0.0
    total_commission = total_commission or 0.0

    # This month revenue
    month_query = select(
        func.sum(Deal.agreed_price), func.sum(Deal.commission_amount)
    ).where(
        and_(
            Deal.agent_id == current_user.id,
            Deal.status == DealStatus.completed,
            extract("year", Deal.closed_at) == now.year,
            extract("month", Deal.closed_at) == now.month,
        )
    )
    month_result = await db.execute(month_query)
    this_month_revenue, this_month_commission = month_result.one()
    this_month_revenue = this_month_revenue or 0.0
    this_month_commission = this_month_commission or 0.0

    # Average deal value
    avg_deal_query = select(func.avg(Deal.agreed_price)).where(
        and_(Deal.agent_id == current_user.id, Deal.status == DealStatus.completed)
    )
    avg_deal_result = await db.execute(avg_deal_query)
    avg_deal_value = avg_deal_result.scalar() or 0.0

    # Deal conversion rate
    deal_conversion_rate = (
        (completed_deals / total_deals * 100) if total_deals > 0 else 0.0
    )

    # Recent activities (last 10)
    recent_activities = []

    # Recent properties
    recent_props_query = (
        select(Property.title, Property.created_at)
        .where(Property.agent_id == current_user.id)
        .order_by(Property.created_at.desc())
        .limit(3)
    )
    recent_props_result = await db.execute(recent_props_query)
    for title, created_at in recent_props_result.all():
        recent_activities.append(
            RecentActivity(
                type="property",
                title="Yeni əmlak",
                description=title,
                created_at=created_at,
            )
        )

    # Recent clients
    recent_clients_query = (
        select(Client.name, Client.created_at)
        .where(Client.agent_id == current_user.id)
        .order_by(Client.created_at.desc())
        .limit(3)
    )
    recent_clients_result = await db.execute(recent_clients_query)
    for name, created_at in recent_clients_result.all():
        recent_activities.append(
            RecentActivity(
                type="client",
                title="Yeni müştəri",
                description=name,
                created_at=created_at,
            )
        )

    # Recent deals
    recent_deals_query = (
        select(Deal.agreed_price, Deal.created_at)
        .where(Deal.agent_id == current_user.id)
        .order_by(Deal.created_at.desc())
        .limit(2)
    )
    recent_deals_result = await db.execute(recent_deals_query)
    for price, created_at in recent_deals_result.all():
        recent_activities.append(
            RecentActivity(
                type="deal",
                title="Yeni deal",
                description=f"{price:,.0f} AZN",
                created_at=created_at,
            )
        )

    # Sort by created_at descending
    recent_activities.sort(key=lambda x: x.created_at, reverse=True)
    recent_activities = recent_activities[:10]

    # Build stats
    stats = DashboardStats(
        total_properties=total_properties,
        total_clients=total_clients,
        total_activities=total_activities,
        total_deals=total_deals,
        properties_for_sale=properties_for_sale,
        properties_for_rent=properties_for_rent,
        properties_sold=properties_sold,
        active_clients=active_clients,
        hot_leads=hot_leads,
        conversion_rate=conversion_rate,
        upcoming_activities=upcoming_activities,
        today_activities=today_activities,
        overdue_activities=overdue_activities,
        pending_deals=pending_deals,
        completed_deals=completed_deals,
        total_revenue=total_revenue,
        total_commission=total_commission,
        this_month_revenue=this_month_revenue,
        this_month_commission=this_month_commission,
        avg_property_price=avg_property_price,
        avg_deal_value=avg_deal_value,
        deal_conversion_rate=deal_conversion_rate,
    )

    return DashboardResponse(stats=stats, recent_activities=recent_activities)


# Import timedelta
from datetime import timedelta
