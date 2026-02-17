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
    val id: String,
    val name: String,
    val sets: Int,
    val reps: Int,
    val duration: Int?   // optional — bəzi məşqlər vaxt əsaslıdır
)

// iOS: struct TrainingPlan: Identifiable, Codable
data class TrainingPlan(
    val id: String,
    @SerializedName("trainer_id")           val trainerId: String?,
    @SerializedName("assigned_student_id")  val assignedStudentId: String?,
    val title: String,
    @SerializedName("plan_type")            val planType: String,   // "weight_loss" | "weight_gain" | "strength_training"
    val workouts: List<PlanWorkout>,
    val assignedStudentName: String?,
    @SerializedName("created_at")           val createdAt: String?,
    @SerializedName("updated_at")           val updatedAt: String?,
    val notes: String?
)
