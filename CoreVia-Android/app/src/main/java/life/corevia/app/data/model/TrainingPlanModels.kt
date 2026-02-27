package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * iOS TrainingPlanManager.swift model equivalent
 * İdman planı modeli — TrainingPlanType, PlanWorkout, TrainingPlan
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - Training Plan Type
// ═══════════════════════════════════════════════════════════════════
enum class TrainingPlanType(val value: String, val displayName: String) {
    WEIGHT_LOSS("weight_loss", "Arıqlama"),
    WEIGHT_GAIN("weight_gain", "Kilo alma"),
    STRENGTH_TRAINING("strength_training", "Güc məşqi");

    companion object {
        fun fromValue(value: String): TrainingPlanType =
            entries.find { it.value == value } ?: WEIGHT_LOSS
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Plan Workout (Plan daxilindəki məşq)
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class PlanWorkout(
    val id: String = "",
    val name: String = "",
    val sets: Int = 3,
    val reps: Int = 12,
    val duration: Int? = null
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Training Plan
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class TrainingPlan(
    val id: String = "",
    @SerialName("trainer_id") val trainerId: String? = null,
    @SerialName("assigned_student_id") val assignedStudentId: String? = null,
    val title: String = "",
    @SerialName("plan_type") val planType: String = "weight_loss",
    val workouts: List<PlanWorkout> = emptyList(),
    @SerialName("is_completed") val isCompleted: Boolean = false,
    @SerialName("completed_at") val completedAt: String? = null,
    @SerialName("created_at") val createdAt: String? = null,
    @SerialName("updated_at") val updatedAt: String? = null,
    val notes: String? = null
) {
    /** TrainingPlanType enum */
    val planTypeEnum: TrainingPlanType
        get() = TrainingPlanType.fromValue(planType)

    /** Formatted date — "dd MMM yyyy" */
    val formattedDate: String
        get() {
            if (createdAt.isNullOrBlank()) return ""
            return try {
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val parsed = isoFormat.parse(createdAt) ?: return ""
                val dateFormat = SimpleDateFormat("dd MMM yyyy", Locale.getDefault())
                dateFormat.format(parsed)
            } catch (_: Exception) {
                ""
            }
        }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Training Plan Create Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class TrainingPlanCreateRequest(
    val title: String,
    @SerialName("plan_type") val planType: String,
    val notes: String? = null,
    @SerialName("assigned_student_id") val assignedStudentId: String? = null,
    val workouts: List<PlanWorkoutCreateRequest> = emptyList()
)

@Serializable
data class PlanWorkoutCreateRequest(
    val name: String,
    val sets: Int = 3,
    val reps: Int = 12,
    val duration: Int? = null
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Training Plan Update Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class TrainingPlanUpdateRequest(
    val title: String? = null,
    @SerialName("plan_type") val planType: String? = null,
    val notes: String? = null,
    @SerialName("assigned_student_id") val assignedStudentId: String? = null
)
