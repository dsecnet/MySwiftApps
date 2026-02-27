package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AICalorieResult(
    val foods: List<DetectedFood> = emptyList(),
    @SerialName("total_calories") val totalCalories: Double = 0.0,
    @SerialName("total_protein") val totalProtein: Double = 0.0,
    @SerialName("total_carbs") val totalCarbs: Double = 0.0,
    @SerialName("total_fat") val totalFat: Double = 0.0,
    val confidence: Double = 0.0,
    @SerialName("image_url") val imageUrl: String? = null
)

@Serializable
data class DetectedFood(
    val id: String? = null,
    val name: String = "",
    val calories: Double = 0.0,
    val protein: Double = 0.0,
    val carbs: Double = 0.0,
    val fat: Double = 0.0,
    @SerialName("portion_grams") val portionGrams: Double = 200.0,
    val confidence: Double = 0.0
)

// Backend returns different format - need mapping
@Serializable
data class BackendFoodAnalysisResponse(
    val success: Boolean? = null,
    @SerialName("food_name") val foodName: String? = null,
    val calories: Double? = null,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerialName("portion_size") val portionSize: String? = null,
    val confidence: Double? = null,
    @SerialName("foods_detail") val foodsDetail: List<BackendFoodDetail>? = null
)

@Serializable
data class BackendFoodDetail(
    val name: String? = null,
    val calories: Double? = null,
    val protein: Double? = null,
    val carbs: Double? = null,
    val fats: Double? = null,
    @SerialName("portion_size") val portionSize: String? = null
)
