package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RouteCreateRequest(
    @SerialName("activity_type") val activityType: String,
    @SerialName("start_latitude") val startLatitude: Double,
    @SerialName("start_longitude") val startLongitude: Double,
    @SerialName("end_latitude") val endLatitude: Double? = null,
    @SerialName("end_longitude") val endLongitude: Double? = null,
    @SerialName("coordinates_json") val coordinatesJson: String? = null,
    @SerialName("distance_km") val distanceKm: Double,
    @SerialName("duration_seconds") val durationSeconds: Int,
    @SerialName("calories_burned") val caloriesBurned: Int? = null,
    @SerialName("started_at") val startedAt: String,
    @SerialName("finished_at") val finishedAt: String
)

@Serializable
data class RouteResponse(
    val id: String = "",
    @SerialName("user_id") val userId: String? = null,
    @SerialName("workout_id") val workoutId: String? = null,
    val name: String? = null,
    @SerialName("activity_type") val activityType: String = "running",
    @SerialName("start_latitude") val startLatitude: Double? = null,
    @SerialName("start_longitude") val startLongitude: Double? = null,
    @SerialName("end_latitude") val endLatitude: Double? = null,
    @SerialName("end_longitude") val endLongitude: Double? = null,
    @SerialName("coordinates_json") val coordinatesJson: String? = null,
    @SerialName("distance_km") val distanceKm: Double = 0.0,
    @SerialName("duration_seconds") val durationSeconds: Int = 0,
    @SerialName("avg_pace") val avgPace: Double? = null,
    @SerialName("max_pace") val maxPace: Double? = null,
    @SerialName("avg_speed_kmh") val avgSpeedKmh: Double? = null,
    @SerialName("max_speed_kmh") val maxSpeedKmh: Double? = null,
    @SerialName("elevation_gain") val elevationGain: Double? = null,
    @SerialName("elevation_loss") val elevationLoss: Double? = null,
    @SerialName("calories_burned") val caloriesBurned: Int? = null,
    @SerialName("static_map_url") val staticMapUrl: String? = null,
    @SerialName("is_assigned") val isAssigned: Boolean = false,
    @SerialName("is_completed") val isCompleted: Boolean = false,
    @SerialName("started_at") val startedAt: String? = null,
    @SerialName("finished_at") val finishedAt: String? = null,
    @SerialName("created_at") val createdAt: String? = null
)

@Serializable
data class RouteStatsResponse(
    @SerialName("total_routes") val totalRoutes: Int = 0,
    @SerialName("total_distance_km") val totalDistanceKm: Double = 0.0,
    @SerialName("total_duration_seconds") val totalDurationSeconds: Int = 0,
    @SerialName("total_calories") val totalCalories: Int = 0,
    @SerialName("avg_pace") val avgPace: Double? = null,
    @SerialName("avg_speed_kmh") val avgSpeedKmh: Double? = null,
    @SerialName("longest_route_km") val longestRouteKm: Double? = null,
    @SerialName("activity_breakdown") val activityBreakdown: Map<String, Int>? = null
)
