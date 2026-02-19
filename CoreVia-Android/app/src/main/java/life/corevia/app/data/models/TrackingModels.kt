package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── GPS Tracking Models ────────────────────────────────────────────────────
// iOS: LocationManager.swift

data class TrackingSession(
    val id: String? = null,
    @SerializedName("activity_type") val activityType: String = "running",  // "running", "walking", "cycling"
    @SerializedName("start_time")    val startTime: String? = null,
    @SerializedName("end_time")      val endTime: String? = null,
    val duration: Int = 0,  // seconds
    val distance: Double = 0.0,  // meters
    @SerializedName("avg_speed")     val avgSpeed: Double = 0.0,  // m/s
    @SerializedName("max_speed")     val maxSpeed: Double = 0.0,
    @SerializedName("calories_burned") val caloriesBurned: Int = 0,
    val route: List<TrackingPoint> = emptyList()
)

data class TrackingPoint(
    val latitude: Double,
    val longitude: Double,
    val altitude: Double? = null,
    val speed: Double? = null,
    val timestamp: String? = null
)
