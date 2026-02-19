package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Live Session Models ────────────────────────────────────────────────────
// iOS: LiveSessionManager.swift

data class LiveSession(
    val id: String,
    @SerializedName("trainer_id")    val trainerId: String,
    @SerializedName("trainer_name")  val trainerName: String? = null,
    val title: String,
    val description: String? = null,
    @SerializedName("session_type")  val sessionType: String = "group",  // "group", "personal"
    val status: String = "scheduled",  // "scheduled", "live", "ended"
    @SerializedName("max_participants") val maxParticipants: Int = 20,
    @SerializedName("current_participants") val currentParticipants: Int = 0,
    @SerializedName("scheduled_at")  val scheduledAt: String,
    @SerializedName("duration_minutes") val durationMinutes: Int = 60,
    @SerializedName("created_at")    val createdAt: String? = null
)

data class CreateLiveSessionRequest(
    val title: String,
    val description: String? = null,
    @SerializedName("session_type") val sessionType: String = "group",
    @SerializedName("max_participants") val maxParticipants: Int = 20,
    @SerializedName("scheduled_at") val scheduledAt: String,
    @SerializedName("duration_minutes") val durationMinutes: Int = 60
)
