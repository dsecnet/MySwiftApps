package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── MealPlan Models ─────────────────────────────────────────────────────────
// iOS: MealPlanManager.swift → MealPlan + MealPlanItem

// iOS: struct MealPlanItem: Identifiable, Codable
data class MealPlanItem(
    val id: String,
    val name: String,
    val calories: Int,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerializedName("meal_type") val mealType: String   // "breakfast" | "lunch" | "dinner" | "snack"
)

// iOS: struct MealPlan: Identifiable, Codable
data class MealPlan(
    val id: String,
    @SerializedName("trainer_id")           val trainerId: String? = null,
    @SerializedName("assigned_student_id")  val assignedStudentId: String? = null,
    val title: String,
    @SerializedName("plan_type")            val planType: String,           // "weight_loss" | "weight_gain" | "strength_training"
    @SerializedName("daily_calorie_target") val dailyCalorieTarget: Int = 2000,
    val items: List<MealPlanItem> = emptyList(),
    val notes: String? = null,
    @SerializedName("is_completed")         val isCompleted: Boolean = false,
    @SerializedName("completed_at")         val completedAt: String? = null,
    @SerializedName("created_at")           val createdAt: String? = null,
    @SerializedName("updated_at")           val updatedAt: String? = null
)

// ─── Request Models ──────────────────────────────────────────────────────────

// iOS: struct MealPlanItemCreate
data class MealPlanItemCreateRequest(
    val name: String,
    val calories: Int,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerializedName("meal_type") val mealType: String
)

// iOS: struct MealPlanCreate
data class MealPlanCreateRequest(
    val title: String,
    @SerializedName("plan_type")            val planType: String,
    @SerializedName("daily_calorie_target") val dailyCalorieTarget: Int = 2000,
    val notes: String? = null,
    @SerializedName("assigned_student_id")  val assignedStudentId: String? = null,
    val items: List<MealPlanItemCreateRequest> = emptyList()
)

// iOS: struct MealPlanUpdate
data class MealPlanUpdateRequest(
    val title: String? = null,
    @SerializedName("plan_type")            val planType: String? = null,
    @SerializedName("daily_calorie_target") val dailyCalorieTarget: Int? = null,
    val notes: String? = null,
    @SerializedName("assigned_student_id")  val assignedStudentId: String? = null
)
