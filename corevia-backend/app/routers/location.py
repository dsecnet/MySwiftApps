from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database import get_db
from app.models.user import User
from app.models.route import Route
from app.schemas.route import (
    RouteCreate,
    RouteUpdate,
    RouteAssign,
    RouteResponse,
    RouteStatsResponse,
)
from app.utils.security import get_current_user, get_premium_or_trainer
from app.services.location_service import process_route_data, get_mapbox_directions

router = APIRouter(prefix="/api/v1/routes", tags=["Routes & Location"])


@router.post("/", response_model=RouteResponse, status_code=status.HTTP_201_CREATED)
async def create_route(
    route_data: RouteCreate,
    current_user: User = Depends(get_premium_or_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Yeni marsrut yarat — Premium lazimdir"""
    stats = process_route_data(
        route_data.coordinates_json,
        route_data.activity_type,
        route_data.duration_seconds,
        weight_kg=current_user.weight,
    )

    route = Route(
        user_id=current_user.id,
        workout_id=route_data.workout_id,
        name=route_data.name,
        activity_type=route_data.activity_type,
        start_latitude=route_data.start_latitude,
        start_longitude=route_data.start_longitude,
        end_latitude=route_data.end_latitude,
        end_longitude=route_data.end_longitude,
        polyline=route_data.polyline,
        coordinates_json=route_data.coordinates_json,
        distance_km=route_data.distance_km or stats["distance_km"],
        duration_seconds=route_data.duration_seconds,
        avg_pace=route_data.avg_pace or stats["avg_pace"],
        max_pace=route_data.max_pace or stats["max_pace"],
        avg_speed_kmh=route_data.avg_speed_kmh or stats["avg_speed_kmh"],
        max_speed_kmh=route_data.max_speed_kmh or stats["max_speed_kmh"],
        elevation_gain=route_data.elevation_gain or stats["elevation_gain"],
        elevation_loss=route_data.elevation_loss or stats["elevation_loss"],
        calories_burned=route_data.calories_burned or stats["calories_burned"],
        static_map_url=stats["static_map_url"],
        started_at=route_data.started_at or datetime.utcnow(),
        finished_at=route_data.finished_at,
        is_completed=route_data.finished_at is not None,
    )
    db.add(route)
    await db.flush()
    return route


@router.get("/", response_model=list[RouteResponse])
async def get_routes(
    current_user: User = Depends(get_premium_or_trainer),
    db: AsyncSession = Depends(get_db),
    activity_type: str | None = None,
    is_completed: bool | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
    limit: int = Query(default=50, le=100),
    offset: int = Query(default=0, ge=0),
):
    """İstifadəçinin marsrutlarini gətir (filter + pagination)"""
    query = select(Route).where(Route.user_id == current_user.id)

    if activity_type:
        query = query.where(Route.activity_type == activity_type)
    if is_completed is not None:
        query = query.where(Route.is_completed == is_completed)
    if date_from:
        query = query.where(Route.started_at >= date_from)
    if date_to:
        query = query.where(Route.started_at <= date_to)

    query = query.order_by(Route.started_at.desc()).offset(offset).limit(limit)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/stats", response_model=RouteStatsResponse)
async def get_route_stats(
    current_user: User = Depends(get_premium_or_trainer),
    db: AsyncSession = Depends(get_db),
    days: int = Query(default=30, le=365),
):
    """Marsrut statistikası (son N gün)"""
    since = datetime.utcnow() - timedelta(days=days)

    result = await db.execute(
        select(
            func.count(Route.id),
            func.coalesce(func.sum(Route.distance_km), 0.0),
            func.coalesce(func.sum(Route.duration_seconds), 0),
            func.coalesce(func.sum(Route.calories_burned), 0),
            func.max(Route.distance_km),
        ).where(
            Route.user_id == current_user.id,
            Route.started_at >= since,
            Route.is_completed == True,
        )
    )
    row = result.one()

    total_routes = row[0]
    total_distance = float(row[1])
    total_duration = int(row[2])
    total_calories = int(row[3])
    longest = float(row[4]) if row[4] else 0.0

    breakdown_result = await db.execute(
        select(Route.activity_type, func.count(Route.id))
        .where(
            Route.user_id == current_user.id,
            Route.started_at >= since,
            Route.is_completed == True,
        )
        .group_by(Route.activity_type)
    )
    breakdown = {row[0]: row[1] for row in breakdown_result.all()}

    avg_pace = None
    avg_speed = None
    if total_distance > 0 and total_duration > 0:
        avg_pace = round((total_duration / 60) / total_distance, 2)
        avg_speed = round(total_distance / (total_duration / 3600), 2)

    return RouteStatsResponse(
        total_routes=total_routes,
        total_distance_km=round(total_distance, 2),
        total_duration_seconds=total_duration,
        total_calories=total_calories,
        avg_pace=avg_pace,
        avg_speed_kmh=avg_speed,
        longest_route_km=round(longest, 2),
        activity_breakdown=breakdown,
    )


@router.get("/assigned", response_model=list[RouteResponse])
async def get_assigned_routes(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Student-in trainer tərəfindən təyin olunmuş marsrutlarini gətir"""
    result = await db.execute(
        select(Route)
        .where(Route.user_id == current_user.id, Route.is_assigned == True)
        .order_by(Route.created_at.desc())
    )
    return result.scalars().all()


@router.get("/{route_id}", response_model=RouteResponse)
async def get_route(
    route_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Tək marsrutu gətir"""
    result = await db.execute(
        select(Route).where(Route.id == route_id, Route.user_id == current_user.id)
    )
    route = result.scalar_one_or_none()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Marsrut tapilmadi")
    return route


@router.put("/{route_id}", response_model=RouteResponse)
async def update_route(
    route_id: str,
    route_data: RouteUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Marsrutu yenilə (finish zamanı end koordinatlarini, stats-i gondermek ucun)"""
    result = await db.execute(
        select(Route).where(Route.id == route_id, Route.user_id == current_user.id)
    )
    route = result.scalar_one_or_none()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Marsrut tapilmadi")

    update_data = route_data.model_dump(exclude_unset=True)

    if "coordinates_json" in update_data and update_data["coordinates_json"]:
        duration = update_data.get("duration_seconds", route.duration_seconds)
        stats = process_route_data(
            update_data["coordinates_json"],
            route.activity_type,
            duration,
            weight_kg=current_user.weight,
        )
        for key, value in stats.items():
            if key not in update_data or update_data[key] is None:
                update_data[key] = value

    for field, value in update_data.items():
        setattr(route, field, value)

    return route


@router.delete("/{route_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_route(
    route_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Marsrutu sil"""
    result = await db.execute(
        select(Route).where(Route.id == route_id, Route.user_id == current_user.id)
    )
    route = result.scalar_one_or_none()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Marsrut tapilmadi")
    await db.delete(route)


# === Trainer assignment endpoints ===

@router.post("/assign", response_model=RouteResponse, status_code=status.HTTP_201_CREATED)
async def assign_route_to_student(
    assign_data: RouteAssign,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer öz student-inə marsrut təyin etsin"""
    if current_user.user_type != "trainer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer marsrut teyin ede biler",
        )

    from app.models.user import User as UserModel
    student_result = await db.execute(
        select(UserModel).where(UserModel.id == assign_data.student_id)
    )
    student = student_result.scalar_one_or_none()

    if not student:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student tapilmadi")
    if student.trainer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Bu student sizin student-iniz deyil",
        )

    route = Route(
        user_id=assign_data.student_id,
        name=assign_data.name,
        activity_type=assign_data.activity_type,
        start_latitude=assign_data.start_latitude,
        start_longitude=assign_data.start_longitude,
        end_latitude=assign_data.end_latitude,
        end_longitude=assign_data.end_longitude,
        polyline=assign_data.polyline,
        distance_km=assign_data.distance_km,
        duration_seconds=0,
        is_assigned=True,
        assigned_by_id=current_user.id,
        assignment_notes=assign_data.assignment_notes,
    )
    db.add(route)
    await db.flush()
    return route


@router.get("/trainer/assigned", response_model=list[RouteResponse])
async def get_trainer_assigned_routes(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer-in təyin etdiyi bütün marsrutlar"""
    if current_user.user_type != "trainer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer ucundur",
        )

    result = await db.execute(
        select(Route)
        .where(Route.assigned_by_id == current_user.id)
        .order_by(Route.created_at.desc())
    )
    return result.scalars().all()


@router.get("/directions/preview")
async def get_directions_preview(
    start_lat: float = Query(...),
    start_lng: float = Query(...),
    end_lat: float = Query(...),
    end_lng: float = Query(...),
    profile: str = Query(default="walking"),
    current_user: User = Depends(get_current_user),
):
    """Mapbox Directions API ile 2 nöqtə arasında marsrut preview al"""
    VALID_PROFILES = {"walking", "cycling", "driving", "driving-traffic"}
    if profile not in VALID_PROFILES:
        raise HTTPException(status_code=400, detail="Invalid profile")

    result = await get_mapbox_directions(
        start=(start_lat, start_lng),
        end=(end_lat, end_lng),
        profile=profile,
    )

    if not result:
        return {
            "available": False,
            "message": "Mapbox xidmeti hal-hazirda mövcud deyil. Marsrut preview Mapbox API key tələb edir.",
        }

    return {
        "available": True,
        "distance_km": result["distance_km"],
        "duration_seconds": result["duration_seconds"],
        "geometry": result["geometry"],
    }
