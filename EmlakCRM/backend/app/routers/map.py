from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from math import radians, cos, sin, asin, sqrt

from app.database import get_db
from app.models.property import Property
from app.models.user import User
from app.utils.security import get_current_user
from app.schemas.property import PropertyResponse
from app.data.baku_metro_stations import (
    get_nearest_metro,
    get_nearby_landmarks,
    BAKU_METRO_STATIONS,
    BAKU_LANDMARKS
)

router = APIRouter(prefix="/map", tags=["Map"])


def calculate_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Haversine formula - 2 GPS nöqtəsi arasında məsafə (km)
    """
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    return 6371 * c


@router.get("/properties/nearby")
def get_properties_nearby(
    latitude: float = Query(..., description="GPS enlik"),
    longitude: float = Query(..., description="GPS uzunluq"),
    radius_km: float = Query(2.0, description="Axtarış radiusu (km)", ge=0.1, le=50),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Verilmiş koordinatlara yaxın property-ləri tapır.

    **Parametrlər:**
    - latitude: GPS enlik (məs: 40.4093)
    - longitude: GPS uzunluq (məs: 49.8671)
    - radius_km: Axtarış radiusu km-lə (default: 2km)
    - limit: Maksimum nəticə sayı

    **Nümunə:**
    ```
    GET /map/properties/nearby?latitude=40.4093&longitude=49.8671&radius_km=3
    ```
    """
    # Latitude və longitude olan property-ləri tap
    properties = db.query(Property).filter(
        Property.latitude.isnot(None),
        Property.longitude.isnot(None)
    ).all()

    nearby_properties = []

    for prop in properties:
        distance_km = calculate_distance_km(
            latitude, longitude,
            prop.latitude, prop.longitude
        )

        if distance_km <= radius_km:
            # Property object-i dict-ə çevir və distance əlavə et
            prop_dict = {
                "id": prop.id,
                "title": prop.title,
                "property_type": prop.property_type,
                "deal_type": prop.deal_type,
                "status": prop.status,
                "price": prop.price,
                "currency": prop.currency,
                "area_sqm": prop.area_sqm,
                "rooms": prop.rooms,
                "city": prop.city,
                "district": prop.district,
                "address": prop.address,
                "latitude": prop.latitude,
                "longitude": prop.longitude,
                "images": prop.images,
                "created_at": prop.created_at,
                "distance_km": round(distance_km, 2),
                "distance_m": int(distance_km * 1000)
            }
            nearby_properties.append(prop_dict)

    # Məsafəyə görə sırala
    nearby_properties.sort(key=lambda x: x['distance_m'])

    return {
        "center": {
            "latitude": latitude,
            "longitude": longitude
        },
        "radius_km": radius_km,
        "total": len(nearby_properties[:limit]),
        "properties": nearby_properties[:limit]
    }


@router.get("/properties/by-metro")
def get_properties_by_metro(
    metro_name: str = Query(..., description="Metro stansiyası adı"),
    radius_km: float = Query(1.5, description="Metroya məsafə (km)", ge=0.1, le=10),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Müəyyən metro stansiyasına yaxın property-ləri tapır.

    **Nümunə:**
    ```
    GET /map/properties/by-metro?metro_name=28 May&radius_km=1.5
    ```
    """
    # Metro stansiyasını tap
    metro_station = None
    for station in BAKU_METRO_STATIONS:
        if station["name"].lower() == metro_name.lower() or \
           station["name_en"].lower() == metro_name.lower():
            metro_station = station
            break

    if not metro_station:
        raise HTTPException(
            status_code=404,
            detail=f"Metro stansiyası tapılmadı: {metro_name}"
        )

    # Bu metronun yaxınlığındakı property-ləri tap
    properties = db.query(Property).filter(
        Property.latitude.isnot(None),
        Property.longitude.isnot(None)
    ).all()

    nearby_properties = []

    for prop in properties:
        distance_km = calculate_distance_km(
            metro_station["latitude"], metro_station["longitude"],
            prop.latitude, prop.longitude
        )

        if distance_km <= radius_km:
            prop_dict = {
                "id": prop.id,
                "title": prop.title,
                "property_type": prop.property_type,
                "deal_type": prop.deal_type,
                "price": prop.price,
                "area_sqm": prop.area_sqm,
                "rooms": prop.rooms,
                "district": prop.district,
                "address": prop.address,
                "latitude": prop.latitude,
                "longitude": prop.longitude,
                "images": prop.images,
                "distance_to_metro_km": round(distance_km, 2),
                "distance_to_metro_m": int(distance_km * 1000)
            }
            nearby_properties.append(prop_dict)

    nearby_properties.sort(key=lambda x: x['distance_to_metro_m'])

    return {
        "metro": {
            "name": metro_station["name"],
            "name_en": metro_station["name_en"],
            "line": metro_station["line"],
            "line_name": metro_station["line_name"],
            "coordinates": {
                "latitude": metro_station["latitude"],
                "longitude": metro_station["longitude"]
            }
        },
        "radius_km": radius_km,
        "total": len(nearby_properties[:limit]),
        "properties": nearby_properties[:limit]
    }


@router.get("/metro/stations")
def get_metro_stations(
    current_user: User = Depends(get_current_user)
):
    """
    Bakı metro stansiyalarının siyahısı.

    **Response:**
    ```json
    {
        "total": 25,
        "stations": [
            {
                "name": "28 May",
                "line": "M1",
                "latitude": 40.4455,
                "longitude": 49.8920
            }
        ]
    }
    ```
    """
    return {
        "total": len(BAKU_METRO_STATIONS),
        "stations": BAKU_METRO_STATIONS
    }


@router.get("/landmarks")
def get_landmarks(
    latitude: Optional[float] = Query(None, description="GPS enlik (məsafə hesablamaq üçün)"),
    longitude: Optional[float] = Query(None, description="GPS uzunluq"),
    current_user: User = Depends(get_current_user)
):
    """
    Bakı məşhur məkanlarının siyahısı.

    Əgər latitude/longitude verilsə, məsafələr də hesablanır.
    """
    if latitude and longitude:
        # Məsafələrlə birlikdə
        landmarks_with_distance = []
        for landmark in BAKU_LANDMARKS:
            distance_km = calculate_distance_km(
                latitude, longitude,
                landmark["latitude"], landmark["longitude"]
            )
            landmarks_with_distance.append({
                **landmark,
                "distance_km": round(distance_km, 2),
                "distance_m": int(distance_km * 1000)
            })

        landmarks_with_distance.sort(key=lambda x: x['distance_m'])
        return {
            "total": len(landmarks_with_distance),
            "center": {"latitude": latitude, "longitude": longitude},
            "landmarks": landmarks_with_distance
        }
    else:
        # Sadəcə siyahı
        return {
            "total": len(BAKU_LANDMARKS),
            "landmarks": BAKU_LANDMARKS
        }


@router.post("/property/{property_id}/enrich")
async def enrich_property_location(
    property_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Property-nin location məlumatlarını zənginləşdirir:
    - Ən yaxın metro
    - Yaxınlıqdakı məşhur məkanlar

    **Automatic enrichment** - GPS koordinatları əsasında.
    """
    property_obj = db.query(Property).filter(
        Property.id == property_id,
        Property.agent_id == current_user.id
    ).first()

    if not property_obj:
        raise HTTPException(status_code=404, detail="Property tapılmadı")

    if not property_obj.latitude or not property_obj.longitude:
        raise HTTPException(
            status_code=400,
            detail="Property-də GPS koordinatları yoxdur"
        )

    # Ən yaxın metro
    nearest_metro = get_nearest_metro(
        property_obj.latitude,
        property_obj.longitude
    )

    if nearest_metro:
        property_obj.nearest_metro = nearest_metro["station"]
        property_obj.metro_distance_m = nearest_metro["distance_m"]

    # Yaxınlıqdakı məkanlar
    nearby = get_nearby_landmarks(
        property_obj.latitude,
        property_obj.longitude,
        radius_km=2.0
    )

    if nearby:
        property_obj.nearby_landmarks = nearby[:5]  # İlk 5-i saxla

    db.commit()
    db.refresh(property_obj)

    return {
        "success": True,
        "property_id": property_id,
        "enriched_data": {
            "nearest_metro": nearest_metro,
            "nearby_landmarks": nearby[:5]
        }
    }


@router.get("/search/radius")
def radius_search(
    latitude: float = Query(...),
    longitude: float = Query(...),
    radius_km: float = Query(3.0, ge=0.1, le=50),
    property_type: Optional[str] = Query(None),
    deal_type: Optional[str] = Query(None),
    min_price: Optional[float] = Query(None),
    max_price: Optional[float] = Query(None),
    min_rooms: Optional[int] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Radius search + filters.

    **Nümunə:**
    ```
    GET /map/search/radius?latitude=40.4093&longitude=49.8671&radius_km=2&property_type=apartment&min_rooms=2
    ```
    """
    # Base query
    query = db.query(Property).filter(
        Property.latitude.isnot(None),
        Property.longitude.isnot(None)
    )

    # Filters
    if property_type:
        query = query.filter(Property.property_type == property_type)

    if deal_type:
        query = query.filter(Property.deal_type == deal_type)

    if min_price:
        query = query.filter(Property.price >= min_price)

    if max_price:
        query = query.filter(Property.price <= max_price)

    if min_rooms:
        query = query.filter(Property.rooms >= min_rooms)

    properties = query.all()

    # Distance hesabla və filter et
    results = []
    for prop in properties:
        distance_km = calculate_distance_km(
            latitude, longitude,
            prop.latitude, prop.longitude
        )

        if distance_km <= radius_km:
            results.append({
                "id": prop.id,
                "title": prop.title,
                "property_type": prop.property_type,
                "deal_type": prop.deal_type,
                "price": prop.price,
                "area_sqm": prop.area_sqm,
                "rooms": prop.rooms,
                "district": prop.district,
                "address": prop.address,
                "latitude": prop.latitude,
                "longitude": prop.longitude,
                "nearest_metro": prop.nearest_metro,
                "metro_distance_m": prop.metro_distance_m,
                "images": prop.images,
                "distance_km": round(distance_km, 2),
                "distance_m": int(distance_km * 1000)
            })

    # Məsafəyə görə sırala
    results.sort(key=lambda x: x['distance_m'])

    return {
        "search_center": {"latitude": latitude, "longitude": longitude},
        "radius_km": radius_km,
        "filters": {
            "property_type": property_type,
            "deal_type": deal_type,
            "min_price": min_price,
            "max_price": max_price,
            "min_rooms": min_rooms
        },
        "total": len(results[:limit]),
        "properties": results[:limit]
    }
