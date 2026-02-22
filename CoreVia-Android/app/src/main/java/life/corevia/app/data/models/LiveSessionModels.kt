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
    @SerializedName("session_type")  val sessionType: String = "group",
    val status: String = "scheduled",
    @SerializedName("max_participants") val maxParticipants: Int = 20,
    @SerializedName("current_participants") val currentParticipants: Int = 0,
    @SerializedName("registered_count") val registeredCount: Int? = 0,
    @SerializedName("active_count") val activeCount: Int? = 0,
    @SerializedName("difficulty_level") val difficultyLevel: String? = null,
    @SerializedName("scheduled_start") val scheduledStart: String? = null,
    @SerializedName("scheduled_at") val scheduledAt: String? = null,
    @SerializedName("scheduled_end") val scheduledEnd: String? = null,
    @SerializedName("duration_minutes") val durationMinutes: Int = 60,
    @SerializedName("is_joined")     val isJoined: Boolean = false,
    @SerializedName("is_public")     val isPublic: Boolean = true,
    @SerializedName("is_paid")       val isPaid: Boolean = false,
    val price: Double? = null,
    val currency: String? = "USD",
    val trainer: Map<String, Any?>? = null,
    @SerializedName("created_at")    val createdAt: String? = null
) {
    // Helper — join/leave endpointlər scheduled_at, list endpoint scheduled_start qaytarır
    val scheduledTime: String? get() = scheduledStart ?: scheduledAt
}

data class CreateLiveSessionRequest(
    val title: String,
    val description: String? = null,
    @SerializedName("session_type") val sessionType: String = "group",
    @SerializedName("max_participants") val maxParticipants: Int = 20,
    @SerializedName("difficulty_level") val difficultyLevel: String = "beginner",
    @SerializedName("duration_minutes") val durationMinutes: Int = 60,
    @SerializedName("scheduled_start") val scheduledStart: String,
    @SerializedName("is_public") val isPublic: Boolean = true,
    @SerializedName("is_paid") val isPaid: Boolean = false,
    val price: Double? = null,
    val currency: String = "USD",
    @SerializedName("workout_plan") val workoutPlan: List<WorkoutExerciseRequest> = emptyList()
)

data class WorkoutExerciseRequest(
    val name: String,
    val type: String = "strength",
    val reps: Int? = null,
    val sets: Int? = null,
    @SerializedName("duration_seconds") val durationSeconds: Int? = null,
    @SerializedName("rest_seconds") val restSeconds: Int = 60
)

// ─── Session List Response Wrapper ──────────────────────────────────────────

data class SessionListResponse(
    val sessions: List<LiveSession> = emptyList(),
    val total: Int = 0,
    val page: Int = 1,
    @SerializedName("page_size") val pageSize: Int = 20,
    @SerializedName("has_more") val hasMore: Boolean = false
)
