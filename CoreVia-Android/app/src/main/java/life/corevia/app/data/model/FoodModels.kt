package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * iOS FoodManager.swift model equivalent
 * MealType enum + FoodEntry + request modelleri
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - Meal Type
// ═══════════════════════════════════════════════════════════════════
enum class MealType(val value: String, val displayName: String) {
    BREAKFAST("breakfast", "Səhər yeməyi"),
    LUNCH("lunch", "Nahar"),
    DINNER("dinner", "Şam yeməyi"),
    SNACK("snack", "Qəlyanaltı");

    companion object {
        fun fromValue(value: String): MealType =
            entries.find { it.value == value } ?: BREAKFAST
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Food Entry
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class FoodEntry(
    val id: String = "",
    @SerialName("user_id") val userId: String? = null,
    val name: String = "",
    val calories: Int = 0,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerialName("meal_type") val mealType: String = "breakfast",
    val date: String? = null,
    val notes: String? = null,
    @SerialName("has_image") val hasImage: Boolean = false,
    @SerialName("image_url") val imageUrl: String? = null,
    @SerialName("ai_analyzed") val aiAnalyzed: Boolean? = null,
    @SerialName("ai_confidence") val aiConfidence: Double? = null
) {
    /** Formatted time — "HH:mm" */
    val formattedTime: String
        get() {
            if (date.isNullOrBlank()) return ""
            return try {
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val parsed = isoFormat.parse(date) ?: return ""
                val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
                timeFormat.format(parsed)
            } catch (_: Exception) {
                ""
            }
        }

    /** Check if entry is from today */
    val isToday: Boolean
        get() {
            if (date.isNullOrBlank()) return false
            return try {
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val parsed = isoFormat.parse(date) ?: return false
                val calendar = Calendar.getInstance()
                val today = calendar.get(Calendar.DAY_OF_YEAR)
                val todayYear = calendar.get(Calendar.YEAR)
                calendar.time = parsed
                calendar.get(Calendar.DAY_OF_YEAR) == today && calendar.get(Calendar.YEAR) == todayYear
            } catch (_: Exception) {
                false
            }
        }

    /** Get MealType enum */
    val mealTypeEnum: MealType
        get() = MealType.fromValue(mealType)
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Food Create Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class FoodCreateRequest(
    val name: String,
    val calories: Int,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerialName("meal_type") val mealType: String,
    val notes: String? = null
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Food Update Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class FoodUpdateRequest(
    val name: String? = null,
    val calories: Int? = null,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerialName("meal_type") val mealType: String? = null,
    val notes: String? = null
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Daily Food Stats
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class DailyFoodStats(
    @SerialName("total_calories") val totalCalories: Int = 0,
    @SerialName("total_protein") val totalProtein: Double = 0.0,
    @SerialName("total_carbs") val totalCarbs: Double = 0.0,
    @SerialName("total_fats") val totalFats: Double = 0.0,
    @SerialName("calorie_goal") val calorieGoal: Int = 2000,
    @SerialName("water_glasses") val waterGlasses: Int = 0,
    val entries: List<FoodEntry> = emptyList()
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - List Extensions (iOS FoodManager statistics equivalent)
// ═══════════════════════════════════════════════════════════════════

/** Filter entries to today only */
fun List<FoodEntry>.todayEntries(): List<FoodEntry> =
    filter { it.isToday }

/** Filter today entries by meal type */
fun List<FoodEntry>.entriesForMealType(type: MealType): List<FoodEntry> =
    todayEntries().filter { it.mealTypeEnum == type }

/** Today's total calories */
fun List<FoodEntry>.todayTotalCalories(): Int =
    todayEntries().sumOf { it.calories }

/** Today's total protein */
fun List<FoodEntry>.todayTotalProtein(): Double =
    todayEntries().mapNotNull { it.protein }.sum()

/** Today's total carbs */
fun List<FoodEntry>.todayTotalCarbs(): Double =
    todayEntries().mapNotNull { it.carbs }.sum()

/** Today's total fats */
fun List<FoodEntry>.todayTotalFats(): Double =
    todayEntries().mapNotNull { it.fats }.sum()

/** Today's calorie progress (0.0 - 1.0+) */
fun List<FoodEntry>.todayProgress(dailyGoal: Int = 2000): Double =
    if (dailyGoal > 0) todayTotalCalories().toDouble() / dailyGoal else 0.0

/** Remaining calories for today */
fun List<FoodEntry>.remainingCalories(dailyGoal: Int = 2000): Int =
    maxOf(0, dailyGoal - todayTotalCalories())

/** Calories for a specific meal type today */
fun List<FoodEntry>.caloriesForMealType(type: MealType): Int =
    entriesForMealType(type).sumOf { it.calories }
