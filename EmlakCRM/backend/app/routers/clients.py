from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, or_
from typing import Optional
from datetime import datetime
import math

from app.database import get_db
from app.models.user import User
from app.models.client import Client, LeadStatus
from app.schemas.client import (
    ClientCreate,
    ClientUpdate,
    ClientResponse,
    ClientListResponse,
    ClientStatsResponse,
)
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/clients", tags=["Clients"])


@router.post("/", response_model=ClientResponse, status_code=status.HTTP_201_CREATED)
async def create_client(
    request: ClientCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Yeni müştəri yarat

    - Agent öz müştərisini yaradır
    - Default lead_status: new
    """
    # Check subscription limits
    if current_user.subscription_plan == "free":
        result = await db.execute(
            select(func.count(Client.id)).where(Client.agent_id == current_user.id)
        )
        client_count = result.scalar()

        if client_count >= 50:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Pulsuz planda maksimum 50 müştəri yarada bilərsiniz. Premium-a keçin.",
            )
    elif current_user.subscription_plan == "basic":
        result = await db.execute(
            select(func.count(Client.id)).where(Client.agent_id == current_user.id)
        )
        client_count = result.scalar()

        if client_count >= 500:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Basic planda maksimum 500 müştəri yarada bilərsiniz. Premium-a keçin.",
            )

    # Check if phone already exists for this agent
    result = await db.execute(
        select(Client).where(
            Client.agent_id == current_user.id,
            Client.phone == request.phone,
        )
    )
    existing_client = result.scalar_one_or_none()

    if existing_client:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bu telefon nömrəsi ilə müştəri artıq mövcuddur: {existing_client.name}",
        )

    # Create client
    new_client = Client(
        agent_id=current_user.id,
        name=request.name,
        phone=request.phone,
        email=request.email,
        whatsapp=request.whatsapp,
        client_type=request.client_type,
        preferred_property_type=request.preferred_property_type,
        preferred_city=request.preferred_city,
        preferred_district=request.preferred_district,
        min_price=request.min_price,
        max_price=request.max_price,
        min_rooms=request.min_rooms,
        max_rooms=request.max_rooms,
        source=request.source,
        tags=request.tags,
        notes=request.notes,
    )

    db.add(new_client)

    # Update user stats
    current_user.total_clients += 1

    await db.commit()
    await db.refresh(new_client)

    return new_client


@router.get("/", response_model=ClientListResponse)
async def list_clients(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    client_type: Optional[str] = None,
    lead_status: Optional[str] = None,
    source: Optional[str] = None,
    search: Optional[str] = None,
    tags: Optional[str] = Query(None, description="Comma-separated tags"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Müştəri siyahısı (agent öz müştərilərini görür)

    Filters:
    - client_type (buyer, seller, renter, landlord)
    - lead_status (new, contacted, viewing_scheduled, negotiating, deal_closed, lost)
    - source (bina.az, tap.az, referral, cold_call)
    - search (name, phone, email)
    - tags (hot_lead, urgent, vip)
    """
    query = select(Client).where(Client.agent_id == current_user.id)

    # Apply filters
    if client_type:
        query = query.where(Client.client_type == client_type)
    if lead_status:
        query = query.where(Client.lead_status == lead_status)
    if source:
        query = query.where(Client.source == source)
    if search:
        query = query.where(
            or_(
                Client.name.ilike(f"%{search}%"),
                Client.phone.ilike(f"%{search}%"),
                Client.email.ilike(f"%{search}%") if Client.email else False,
            )
        )
    if tags:
        tag_list = [t.strip() for t in tags.split(",")]
        # PostgreSQL JSON contains operator
        for tag in tag_list:
            query = query.where(Client.tags.contains([tag]))

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    result = await db.execute(count_query)
    total = result.scalar()

    # Pagination
    offset = (page - 1) * page_size
    query = query.order_by(Client.created_at.desc()).offset(offset).limit(page_size)

    result = await db.execute(query)
    clients = result.scalars().all()

    pages = math.ceil(total / page_size) if total > 0 else 1

    return ClientListResponse(
        clients=clients,
        total=total,
        page=page,
        page_size=page_size,
        pages=pages,
    )


@router.get("/{client_id}", response_model=ClientResponse)
async def get_client(
    client_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Müştəri detalları
    """
    result = await db.execute(
        select(Client).where(
            Client.id == client_id,
            Client.agent_id == current_user.id,
        )
    )
    client = result.scalar_one_or_none()

    if not client:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Müştəri tapılmadı.",
        )

    return client


@router.put("/{client_id}", response_model=ClientResponse)
async def update_client(
    client_id: str,
    request: ClientUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Müştəri məlumatlarını yenilə
    """
    result = await db.execute(
        select(Client).where(
            Client.id == client_id,
            Client.agent_id == current_user.id,
        )
    )
    client = result.scalar_one_or_none()

    if not client:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Müştəri tapılmadı.",
        )

    # Update fields
    update_data = request.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(client, field, value)

    # Update last_contacted_at if status changed to contacted or beyond
    if request.lead_status in ["contacted", "viewing_scheduled", "negotiating", "deal_closed"]:
        if client.last_contacted_at is None or request.lead_status != client.lead_status:
            client.last_contacted_at = datetime.utcnow()

    await db.commit()
    await db.refresh(client)

    return client


@router.delete("/{client_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_client(
    client_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Müştəri sil
    """
    result = await db.execute(
        select(Client).where(
            Client.id == client_id,
            Client.agent_id == current_user.id,
        )
    )
    client = result.scalar_one_or_none()

    if not client:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Müştəri tapılmadı.",
        )

    await db.delete(client)

    # Update user stats
    current_user.total_clients = max(0, current_user.total_clients - 1)

    await db.commit()

    return None


@router.get("/stats/summary", response_model=ClientStatsResponse)
async def get_clients_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Müştəri statistikası
    """
    # Total clients
    result = await db.execute(
        select(func.count(Client.id)).where(Client.agent_id == current_user.id)
    )
    total = result.scalar()

    # By type
    result = await db.execute(
        select(Client.client_type, func.count(Client.id))
        .where(Client.agent_id == current_user.id)
        .group_by(Client.client_type)
    )
    by_type = {row[0]: row[1] for row in result.all()}

    # By status
    result = await db.execute(
        select(Client.lead_status, func.count(Client.id))
        .where(Client.agent_id == current_user.id)
        .group_by(Client.lead_status)
    )
    by_status = {row[0]: row[1] for row in result.all()}

    # By source
    result = await db.execute(
        select(Client.source, func.count(Client.id))
        .where(Client.agent_id == current_user.id)
        .group_by(Client.source)
    )
    by_source = {row[0] if row[0] else "unknown": row[1] for row in result.all()}

    # Hot leads (contacted or viewing_scheduled)
    result = await db.execute(
        select(func.count(Client.id))
        .where(
            Client.agent_id == current_user.id,
            Client.lead_status.in_(["contacted", "viewing_scheduled"])
        )
    )
    hot_leads = result.scalar()

    # Converted (deal_closed)
    result = await db.execute(
        select(func.count(Client.id))
        .where(
            Client.agent_id == current_user.id,
            Client.lead_status == "deal_closed"
        )
    )
    converted = result.scalar()

    # Conversion rate
    conversion_rate = (converted / total * 100) if total > 0 else 0.0

    return ClientStatsResponse(
        total=total,
        by_type=by_type,
        by_status=by_status,
        by_source=by_source,
        hot_leads=hot_leads,
        converted=converted,
        conversion_rate=round(conversion_rate, 2),
    )
