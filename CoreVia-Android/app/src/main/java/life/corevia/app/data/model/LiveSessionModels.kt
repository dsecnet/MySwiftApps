package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.text.SimpleDateFormat
import java.util.Locale

/**
 * iOS LiveSessionModels.swift equivalent
 * Canlı sessiya data modeli, status, çətinlik, request/response
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - Live Session Status
// ═══════════════════════════════════════════════════════════════════
enum class LiveSessionStatus(val value: String, val displayName: String) {
    UPCOMING("upcoming", "Gözləyən"),
    LIVE("live", "Canlı"),
    COMPLETED("completed", "Tamamlanmış"),
    CANCELLED("cancelled", "Ləğv edilmiş");

    companion object {
        fun fromValue(value: String): LiveSessionStatus =
            entries.find { it.value == value } ?: UPCOMING
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Live Session Difficulty
// ═══════════════════════════════════════════════════════════════════
enum class LiveSessionDifficulty(val value: String, val displayName: String) {
    BEGINNER("beginner", "Başlanğıc"),
    INTERMEDIATE("intermediate", "Orta"),
    ADVANCED("advanced", "Qabaqcıl");

    companion object {
        fun fromValue(value: String): LiveSessionDifficulty =
            entries.find { it.value == value } ?: BEGINNER
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Live Session
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class LiveSession(
    val id: String = "",
    val title: String = "",
    val description: String = "",
    @SerialName("trainer_id") val trainerId: String = "",
    @SerialName("trainer_name") val trainerName: String = "",
    @SerialName("session_type") val sessionType: String = "strength",
    val status: String = "upcoming",
    @SerialName("max_participants") val maxParticipants: Int = 0,
    @SerialName("current_participants") val currentParticipants: Int = 0,
    @SerialName("scheduled_at") val scheduledAt: String = "",
    val duration: Int = 0,               // dəqiqə
    val price: Double = 0.0,
    val currency: String = "AZN",
    val difficulty: String = "beginner",
    @SerialName("is_public") val isPublic: Boolean = true,
    @SerialName("created_at") val createdAt: String = ""
) {
    /** Status enum */
    val statusEnum: LiveSessionStatus
        get() = LiveSessionStatus.fromValue(status)

    /** Difficulty display name */
    val difficultyDisplayName: String
        get() = LiveSessionDifficulty.fromValue(difficulty).displayName

    /** Formatted price — "10.00 AZN" */
    val displayPrice: String
        get() = "%.2f %s".format(price, currency)

    /** Tarix formatı — "dd MMM yyyy, HH:mm" */
    val formattedDate: String
        get() {
            if (scheduledAt.isBlank()) return ""
            return try {
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val parsed = isoFormat.parse(scheduledAt) ?: return ""
                val dateFormat = SimpleDateFormat("dd MMM yyyy, HH:mm", Locale.getDefault())
                dateFormat.format(parsed)
            } catch (_: Exception) {
                ""
            }
        }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Session List Response
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class SessionListResponse(
    val sessions: List<LiveSession> = emptyList(),
    @SerialName("total_count") val totalCount: Int = 0,
    @SerialName("has_more") val hasMore: Boolean = false
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Create Session Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class CreateSessionRequest(
    val title: String,
    val description: String,
    @SerialName("session_type") val sessionType: String,
    @SerialName("max_participants") val maxParticipants: Int,
    @SerialName("scheduled_at") val scheduledAt: String,
    val duration: Int,
    val price: Double,
    val currency: String = "AZN",
    val difficulty: String = "beginner",
    @SerialName("is_public") val isPublic: Boolean = true
)
