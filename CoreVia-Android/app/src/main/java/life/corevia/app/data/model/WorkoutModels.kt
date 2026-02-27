package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * iOS Workout.swift + WorkoutManager.swift model equivalent
 * Məşq data modeli, kateqoriya, statistika helper-ləri
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - Workout
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class Workout(
    val id: String = "",
    val title: String = "",
    val notes: String? = null,
    val duration: Int = 0, // dəqiqə
    @SerialName("calories_burned") val caloriesBurned: Int = 0,
    val category: String = "strength",
    @SerialName("is_completed") val isCompleted: Boolean = false,
    @SerialName("created_at") val createdAt: String? = null,
    @SerialName("user_id") val userId: String? = null,
    val date: String? = null
) {
    /** WorkoutType enum */
    val categoryEnum: WorkoutType
        get() = WorkoutType.fromValue(category)

    /** Bugünkü məşq? */
    val isToday: Boolean
        get() {
            val dateStr = date ?: createdAt ?: return false
            return try {
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val parsed = isoFormat.parse(dateStr) ?: return false
                val calendar = Calendar.getInstance()
                val today = calendar.get(Calendar.DAY_OF_YEAR)
                val todayYear = calendar.get(Calendar.YEAR)
                calendar.time = parsed
                calendar.get(Calendar.DAY_OF_YEAR) == today && calendar.get(Calendar.YEAR) == todayYear
            } catch (_: Exception) {
                false
            }
        }

    /** Bu həftəki məşq? */
    val isThisWeek: Boolean
        get() {
            val dateStr = date ?: createdAt ?: return false
            return try {
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val parsed = isoFormat.parse(dateStr) ?: return false
                val calendar = Calendar.getInstance()
                val thisWeek = calendar.get(Calendar.WEEK_OF_YEAR)
                val thisYear = calendar.get(Calendar.YEAR)
                calendar.time = parsed
                calendar.get(Calendar.WEEK_OF_YEAR) == thisWeek && calendar.get(Calendar.YEAR) == thisYear
            } catch (_: Exception) {
                false
            }
        }

    /** Tarix formatı — "dd MMM yyyy" */
    val formattedDate: String
        get() {
            val dateStr = date ?: createdAt ?: return ""
            return try {
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val parsed = isoFormat.parse(dateStr) ?: return ""
                val dateFormat = SimpleDateFormat("dd MMM yyyy", Locale.getDefault())
                dateFormat.format(parsed)
            } catch (_: Exception) {
                ""
            }
        }

    /** Qısa tarix — "Bugün", "Dünən", "dd MMM yyyy" */
    val relativeDate: String
        get() {
            val dateStr = date ?: createdAt ?: return ""
            return try {
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val parsed = isoFormat.parse(dateStr) ?: return ""
                val calendar = Calendar.getInstance()
                val parsedCal = Calendar.getInstance().apply { time = parsed }

                when {
                    calendar.get(Calendar.DAY_OF_YEAR) == parsedCal.get(Calendar.DAY_OF_YEAR) &&
                            calendar.get(Calendar.YEAR) == parsedCal.get(Calendar.YEAR) -> "Bugün"
                    else -> {
                        calendar.add(Calendar.DAY_OF_YEAR, -1)
                        if (calendar.get(Calendar.DAY_OF_YEAR) == parsedCal.get(Calendar.DAY_OF_YEAR) &&
                            calendar.get(Calendar.YEAR) == parsedCal.get(Calendar.YEAR)
                        ) "Dünən" else formattedDate
                    }
                }
            } catch (_: Exception) {
                ""
            }
        }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Workout Create Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class WorkoutCreateRequest(
    val title: String,
    val category: String,
    val duration: Int,
    @SerialName("calories_burned") val caloriesBurned: Int? = null,
    val notes: String? = null,
    val date: String? = null
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Workout Update Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class WorkoutUpdateRequest(
    val title: String? = null,
    val category: String? = null,
    val duration: Int? = null,
    @SerialName("calories_burned") val caloriesBurned: Int? = null,
    val notes: String? = null,
    @SerialName("is_completed") val isCompleted: Boolean? = null
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Workout Summary
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class WorkoutSummary(
    @SerialName("total_workouts") val totalWorkouts: Int = 0,
    @SerialName("total_duration") val totalDuration: Int = 0,
    @SerialName("total_calories") val totalCalories: Int = 0,
    @SerialName("this_week") val thisWeek: Int = 0
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Workout Category (iOS WorkoutCategory equivalent)
// ═══════════════════════════════════════════════════════════════════
enum class WorkoutType(val value: String, val displayName: String) {
    STRENGTH("strength", "Güc"),
    CARDIO("cardio", "Kardio"),
    FLEXIBILITY("flexibility", "Elastiklik"),
    HIIT("hiit", "HIIT"),
    YOGA("yoga", "Yoga"),
    ENDURANCE("endurance", "Dözümlülük");

    companion object {
        fun fromValue(value: String): WorkoutType =
            entries.find { it.value == value } ?: STRENGTH
    }
}

enum class MuscleGroup(val value: String, val displayName: String) {
    CHEST("chest", "Sinə"),
    BACK("back", "Arxa"),
    SHOULDERS("shoulders", "Çiyinlər"),
    ARMS("arms", "Qollar"),
    LEGS("legs", "Ayaqlar"),
    CORE("core", "Kör"),
    FULL_BODY("full_body", "Bütün bədən")
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - List Extensions (iOS WorkoutManager statistics equivalent)
// ═══════════════════════════════════════════════════════════════════

/** Bugünkü məşqlər */
fun List<Workout>.todayWorkouts(): List<Workout> =
    filter { it.isToday }

/** Bu həftəki məşqlər */
fun List<Workout>.weekWorkouts(): List<Workout> =
    filter { it.isThisWeek }

/** Tamamlanmış məşqlər */
fun List<Workout>.completedWorkouts(): List<Workout> =
    filter { it.isCompleted }

/** Gözləyən məşqlər */
fun List<Workout>.pendingWorkouts(): List<Workout> =
    filter { !it.isCompleted }

/** Bugünkü toplam dəqiqə */
fun List<Workout>.todayTotalMinutes(): Int =
    todayWorkouts().sumOf { it.duration }

/** Bugünkü toplam kalori */
fun List<Workout>.todayTotalCalories(): Int =
    todayWorkouts().sumOf { it.caloriesBurned }

/** Həftəlik məşq sayı */
fun List<Workout>.weekWorkoutCount(): Int =
    weekWorkouts().size

/** Bugünkü irəliləyiş (0.0 - 1.0) */
fun List<Workout>.todayProgress(): Double {
    val today = todayWorkouts()
    if (today.isEmpty()) return 0.0
    val completed = today.count { it.isCompleted }
    return completed.toDouble() / today.size
}
