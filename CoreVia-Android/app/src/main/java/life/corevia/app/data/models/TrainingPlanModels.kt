package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Enum ─────────────────────────────────────────────────────────────────────

// iOS: enum PlanType: String, Codable
enum class PlanType(val value: String) {
    WEIGHT_LOSS("weight_loss"),
    WEIGHT_GAIN("weight_gain"),
    STRENGTH_TRAINING("strength_training");

    companion object {
        fun from(value: String) = entries.firstOrNull { it.value == value } ?: WEIGHT_LOSS
    }
}

// ─── Models ───────────────────────────────────────────────────────────────────

// iOS: struct PlanWorkout: Identifiable, Codable
data class PlanWorkout(
    val id: String = "",
    val name: String = "",
    val sets: Int = 0,
    val reps: Int = 0,
    val duration: Int? = null   // optional — bəzi məşqlər vaxt əsaslıdır
)

// iOS: struct TrainingPlan: Identifiable, Codable
// FIXED: isCompleted + completedAt əlavə edildi (iOS-da eyni bug fix edilmişdi)
data class TrainingPlan(
    val id: String = "",
    @SerializedName("trainer_id")           val trainerId: String? = null,
    @SerializedName("assigned_student_id")  val assignedStudentId: String? = null,
    @SerializedName("assigned_student_name") val assignedStudentName: String? = null,
    val title: String = "",
    @SerializedName("plan_type")            val planType: String = "weight_loss",
    val workouts: List<PlanWorkout> = emptyList(),
    val notes: String? = null,
    @SerializedName("is_completed")         val isCompleted: Boolean = false,
    @SerializedName("completed_at")         val completedAt: String? = null,
    @SerializedName("created_at")           val createdAt: String? = null,
    @SerializedName("updated_at")           val updatedAt: String? = null
)
