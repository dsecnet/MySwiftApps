package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

enum class PlanType(val value: String, val displayName: String) {
    WEIGHT_LOSS("weight_loss", "Arıqlama"),
    WEIGHT_GAIN("weight_gain", "Kilo alma"),
    MUSCLE_BUILDING("muscle_building", "Əzələ kütləsi"),
    MAINTENANCE("maintenance", "Saxlama"),
    CUSTOM("custom", "Xüsusi");

    companion object {
        fun fromValue(value: String): PlanType =
            entries.find { it.value == value } ?: CUSTOM
    }
}

@Serializable
data class MealPlanItem(
    val id: String = "",
    val name: String = "",
    val calories: Int = 0,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerialName("meal_type") val mealType: String = "breakfast",
    @SerialName("day_of_week") val dayOfWeek: Int? = null
)

@Serializable
data class MealPlan(
    val id: String = "",
    val name: String = "",
    val description: String? = null,
    @SerialName("plan_type") val planType: String = "custom",
    @SerialName("trainer_id") val trainerId: String? = null,
    @SerialName("student_id") val studentId: String? = null,
    @SerialName("student_name") val studentName: String? = null,
    val meals: List<MealPlanItem> = emptyList(),
    @SerialName("total_calories") val totalCalories: Int = 0,
    @SerialName("is_active") val isActive: Boolean = true,
    @SerialName("created_at") val createdAt: String? = null,
    @SerialName("updated_at") val updatedAt: String? = null
)

@Serializable
data class MealPlanCreateRequest(
    val name: String,
    val description: String? = null,
    @SerialName("plan_type") val planType: String = "custom",
    @SerialName("student_id") val studentId: String? = null,
    val meals: List<MealPlanItemRequest> = emptyList()
)

@Serializable
data class MealPlanItemRequest(
    val name: String,
    val calories: Int,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerialName("meal_type") val mealType: String = "breakfast",
    @SerialName("day_of_week") val dayOfWeek: Int? = null
)
