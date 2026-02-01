import json
import math
import httpx
from app.config import get_settings

settings = get_settings()

_has_mapbox_token = bool(settings.mapbox_access_token) and not settings.mapbox_access_token.startswith("your-")


def calculate_distance(coords: list[list[float]]) -> float:
    """Haversine formula ile koordinat siyahisinin umumi mesafesini hesabla (km)"""
    if len(coords) < 2:
        return 0.0

    total = 0.0
    R = 6371.0  # Yerin radiusu (km)

    for i in range(len(coords) - 1):
        lat1, lon1 = math.radians(coords[i][0]), math.radians(coords[i][1])
        lat2, lon2 = math.radians(coords[i + 1][0]), math.radians(coords[i + 1][1])

        dlat = lat2 - lat1
        dlon = lon2 - lon1

        a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        total += R * c

    return round(total, 3)


def calculate_pace(distance_km: float, duration_seconds: int) -> float | None:
    """Tempi hesabla (min/km)"""
    if distance_km <= 0 or duration_seconds <= 0:
        return None
    return round((duration_seconds / 60) / distance_km, 2)


def calculate_speed(distance_km: float, duration_seconds: int) -> float | None:
    """Suret hesabla (km/saat)"""
    if distance_km <= 0 or duration_seconds <= 0:
        return None
    hours = duration_seconds / 3600
    return round(distance_km / hours, 2)


def calculate_elevation(coords: list[list[float]]) -> tuple[float, float]:
    """Yukselis ve enis hesabla (metres). coords: [[lat, lng, alt, ...], ...]"""
    gain = 0.0
    loss = 0.0

    for i in range(1, len(coords)):
        if len(coords[i]) >= 3 and len(coords[i - 1]) >= 3:
            alt_curr = coords[i][2]
            alt_prev = coords[i - 1][2]
            if alt_curr is not None and alt_prev is not None:
                diff = alt_curr - alt_prev
                if diff > 0:
                    gain += diff
                else:
                    loss += abs(diff)

    return round(gain, 1), round(loss, 1)


def estimate_calories(activity_type: str, distance_km: float, duration_seconds: int, weight_kg: float | None = None) -> int:
    """Texmini kalori hesabla (MET formula)"""
    weight = weight_kg or 70.0  # default 70 kg
    hours = duration_seconds / 3600

    # MET deyerleri (Metabolic Equivalent of Task)
    met_values = {
        "running": 9.8,     # ~6 min/km pace
        "cycling": 7.5,     # moderate effort
        "walking": 3.8,     # brisk walking
    }
    met = met_values.get(activity_type, 5.0)

    calories = met * weight * hours
    return round(calories)


def generate_static_map_url(
    coordinates: list[list[float]],
    width: int = 600,
    height: int = 400,
) -> str | None:
    """Mapbox Static Images API ile marşrut xəritəsi URL-i yarat"""
    if not _has_mapbox_token or not coordinates or len(coordinates) < 2:
        return None

    # Polyline yarat - Mapbox GeoJSON overlay istifade edek
    # Coordinates-i longitude,latitude formatina cevir (Mapbox tersinedir)
    geojson_coords = [[c[1], c[0]] for c in coordinates]

    # Sadeleşdirmek ucun hər 5-ci nöqteni götür (URL uzunluq limiti)
    if len(geojson_coords) > 100:
        step = len(geojson_coords) // 100
        geojson_coords = geojson_coords[::step]
        # Son nöqteni əlavə et
        if geojson_coords[-1] != [coordinates[-1][1], coordinates[-1][0]]:
            geojson_coords.append([coordinates[-1][1], coordinates[-1][0]])

    geojson = {
        "type": "Feature",
        "geometry": {
            "type": "LineString",
            "coordinates": geojson_coords,
        },
        "properties": {
            "stroke": "#3B82F6",
            "stroke-width": 4,
            "stroke-opacity": 0.85,
        },
    }

    import urllib.parse
    geojson_str = urllib.parse.quote(json.dumps(geojson))

    url = (
        f"https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/"
        f"geojson({geojson_str})/auto/{width}x{height}@2x"
        f"?access_token={settings.mapbox_access_token}&padding=40"
    )

    return url


async def get_mapbox_directions(
    start: tuple[float, float],
    end: tuple[float, float],
    profile: str = "walking",
) -> dict | None:
    """Mapbox Directions API ile iki nöqtə arasında marsrut al"""
    if not _has_mapbox_token:
        return None

    # Mapbox: longitude,latitude sırasıdır
    url = (
        f"https://api.mapbox.com/directions/v5/mapbox/{profile}/"
        f"{start[1]},{start[0]};{end[1]},{end[0]}"
        f"?geometries=geojson&overview=full&access_token={settings.mapbox_access_token}"
    )

    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        if response.status_code == 200:
            data = response.json()
            if data.get("routes"):
                route = data["routes"][0]
                return {
                    "distance_km": round(route["distance"] / 1000, 3),
                    "duration_seconds": round(route["duration"]),
                    "geometry": route["geometry"],
                }
    return None


def process_route_data(coordinates_json: str | None, activity_type: str, duration_seconds: int, weight_kg: float | None = None) -> dict:
    """Koordinat datalarini emal edib statistikalar hesabla"""
    result = {
        "distance_km": 0.0,
        "avg_pace": None,
        "max_pace": None,
        "avg_speed_kmh": None,
        "max_speed_kmh": None,
        "elevation_gain": None,
        "elevation_loss": None,
        "calories_burned": None,
        "static_map_url": None,
    }

    if not coordinates_json:
        return result

    try:
        coords = json.loads(coordinates_json)
    except (json.JSONDecodeError, TypeError):
        return result

    if not coords or len(coords) < 2:
        return result

    # Mesafe hesabla
    distance = calculate_distance(coords)
    result["distance_km"] = distance

    # Pace ve speed
    result["avg_pace"] = calculate_pace(distance, duration_seconds)
    result["avg_speed_kmh"] = calculate_speed(distance, duration_seconds)

    # Elevation
    gain, loss = calculate_elevation(coords)
    if gain > 0 or loss > 0:
        result["elevation_gain"] = gain
        result["elevation_loss"] = loss

    # Kalori
    result["calories_burned"] = estimate_calories(activity_type, distance, duration_seconds, weight_kg)

    # Static map
    result["static_map_url"] = generate_static_map_url(coords)

    return result
