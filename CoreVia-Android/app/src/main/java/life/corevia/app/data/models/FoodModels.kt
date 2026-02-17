package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Enum ─────────────────────────────────────────────────────────────────────

// iOS: enum MealType: String, Codable
enum class MealType(val value: String) {
    BREAKFAST("breakfast"),
    LUNCH("lunch"),
    DINNER("dinner"),
    SNACK("snack");

    companion object {
        fun from(value: String) = entries.firstOrNull { it.value == value } ?: LUNCH
    }
}

// ─── Models ───────────────────────────────────────────────────────────────────

// iOS: struct FoodEntry: Identifiable, Codable
data class FoodEntry(
    val id: String,
    @SerializedName("user_id")       val userId: String?,
    val name: String,
    val calories: Int,
    val protein: Double?,
    val carbs: Double?,
    val fats: Double?,
    @SerializedName("meal_type")     val mealType: String,    // "breakfast" | "lunch" | "dinner" | "snack"
    val date: String,                // ISO 8601
    val notes: String?,
    @SerializedName("has_image")     val hasImage: Boolean = false,
    @SerializedName("image_url")     val imageUrl: String?,
    @SerializedName("ai_analyzed")   val aiAnalyzed: Boolean?,
    @SerializedName("ai_confidence") val aiConfidence: Double?
)

// ─── Request Model ────────────────────────────────────────────────────────────

data class FoodEntryCreateRequest(
    val name: String,
    val calories: Int,
    val protein: Double?,
    val carbs: Double?,
    val fats: Double?,
    @SerializedName("meal_type") val mealType: String,
    val date: String?,
    val notes: String?
)
