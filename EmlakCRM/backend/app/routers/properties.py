from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, or_
from typing import Optional
import math

from app.database import get_db
from app.models.user import User
from app.models.property import Property, PropertyStatus
from app.schemas.property import (
    PropertyCreate,
    PropertyUpdate,
    PropertyResponse,
    PropertyListResponse,
)
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/properties", tags=["Properties"])


@router.post("/", response_model=PropertyResponse, status_code=status.HTTP_201_CREATED)
async def create_property(
    request: PropertyCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Yeni əmlak yarat

    - Agent öz əmlakını yaradır
    - Default status: available
    """
    # Check subscription limits
    if current_user.subscription_plan == "free":
        result = await db.execute(
            select(func.count(Property.id)).where(Property.agent_id == current_user.id)
        )
        property_count = result.scalar()

        if property_count >= 10:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Pulsuz planda maksimum 10 əmlak yarada bilərsiniz. Premium-a keçin.",
            )
    elif current_user.subscription_plan == "basic":
        result = await db.execute(
            select(func.count(Property.id)).where(Property.agent_id == current_user.id)
        )
        property_count = result.scalar()

        if property_count >= 100:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Basic planda maksimum 100 əmlak yarada bilərsiniz. Premium-a keçin.",
            )

    # Create property
    new_property = Property(
        agent_id=current_user.id,
        title=request.title,
        description=request.description,
        property_type=request.property_type,
        deal_type=request.deal_type,
        city=request.city,
        district=request.district,
        address=request.address,
        latitude=request.latitude,
        longitude=request.longitude,
        price=request.price,
        currency=request.currency,
        area_sqm=request.area_sqm,
        rooms=request.rooms,
        bathrooms=request.bathrooms,
        floor=request.floor,
        total_floors=request.total_floors,
        features=request.features,
        owner_name=request.owner_name,
        owner_phone=request.owner_phone,
        bina_az_url=request.bina_az_url,
        tap_az_url=request.tap_az_url,
        internal_notes=request.internal_notes,
    )

    db.add(new_property)

    # Update user stats
    current_user.total_properties += 1

    await db.commit()
    await db.refresh(new_property)

    return new_property


@router.get("/", response_model=PropertyListResponse)
async def list_properties(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    city: Optional[str] = None,
    district: Optional[str] = None,
    property_type: Optional[str] = None,
    deal_type: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    min_rooms: Optional[int] = None,
    max_rooms: Optional[int] = None,
    status: Optional[str] = None,
    search: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Əmlak siyahısı (agent öz əmlakları görür)

    Filters:
    - city, district, property_type, deal_type
    - min_price, max_price
    - min_rooms, max_rooms
    - status
    - search (title, description)
    """
    query = select(Property).where(Property.agent_id == current_user.id)

    # Apply filters
    if city:
        query = query.where(Property.city == city)
    if district:
        query = query.where(Property.district == district)
    if property_type:
        query = query.where(Property.property_type == property_type)
    if deal_type:
        query = query.where(Property.deal_type == deal_type)
    if min_price:
        query = query.where(Property.price >= min_price)
    if max_price:
        query = query.where(Property.price <= max_price)
    if min_rooms:
        query = query.where(Property.rooms >= min_rooms)
    if max_rooms:
        query = query.where(Property.rooms <= max_rooms)
    if status:
        query = query.where(Property.status == status)
    if search:
        query = query.where(
            or_(
                Property.title.ilike(f"%{search}%"),
                Property.description.ilike(f"%{search}%"),
            )
        )

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    result = await db.execute(count_query)
    total = result.scalar()

    # Pagination
    offset = (page - 1) * page_size
    query = query.order_by(Property.created_at.desc()).offset(offset).limit(page_size)

    result = await db.execute(query)
    properties = result.scalars().all()

    pages = math.ceil(total / page_size) if total > 0 else 1

    return PropertyListResponse(
        properties=properties,
        total=total,
        page=page,
        page_size=page_size,
        pages=pages,
    )


@router.get("/{property_id}", response_model=PropertyResponse)
async def get_property(
    property_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Əmlak detalları
    """
    result = await db.execute(
        select(Property).where(
            Property.id == property_id,
            Property.agent_id == current_user.id,
        )
    )
    property_obj = result.scalar_one_or_none()

    if not property_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Əmlak tapılmadı.",
        )

    # Increment views
    property_obj.views_count += 1
    await db.commit()

    return property_obj


@router.put("/{property_id}", response_model=PropertyResponse)
async def update_property(
    property_id: str,
    request: PropertyUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Əmlak yenilə
    """
    result = await db.execute(
        select(Property).where(
            Property.id == property_id,
            Property.agent_id == current_user.id,
        )
    )
    property_obj = result.scalar_one_or_none()

    if not property_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Əmlak tapılmadı.",
        )

    # Update fields
    update_data = request.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(property_obj, field, value)

    await db.commit()
    await db.refresh(property_obj)

    return property_obj


@router.delete("/{property_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_property(
    property_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Əmlak sil
    """
    result = await db.execute(
        select(Property).where(
            Property.id == property_id,
            Property.agent_id == current_user.id,
        )
    )
    property_obj = result.scalar_one_or_none()

    if not property_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Əmlak tapılmadı.",
        )

    await db.delete(property_obj)

    # Update user stats
    current_user.total_properties = max(0, current_user.total_properties - 1)

    await db.commit()

    return None


@router.get("/stats/summary")
async def get_properties_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Əmlak statistikası
    """
    # Total properties
    result = await db.execute(
        select(func.count(Property.id)).where(Property.agent_id == current_user.id)
    )
    total = result.scalar()

    # By status
    result = await db.execute(
        select(Property.status, func.count(Property.id))
        .where(Property.agent_id == current_user.id)
        .group_by(Property.status)
    )
    by_status = {row[0]: row[1] for row in result.all()}

    # By type
    result = await db.execute(
        select(Property.property_type, func.count(Property.id))
        .where(Property.agent_id == current_user.id)
        .group_by(Property.property_type)
    )
    by_type = {row[0]: row[1] for row in result.all()}

    # By city
    result = await db.execute(
        select(Property.city, func.count(Property.id))
        .where(Property.agent_id == current_user.id)
        .group_by(Property.city)
    )
    by_city = {row[0]: row[1] for row in result.all()}

    return {
        "total": total,
        "by_status": by_status,
        "by_type": by_type,
        "by_city": by_city,
    }
