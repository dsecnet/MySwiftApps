package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class DailySurveyRequest(
    @SerialName("energy_level") val energyLevel: Int,       // 1-5
    @SerialName("sleep_hours") val sleepHours: Double,      // 0-24
    @SerialName("sleep_quality") val sleepQuality: Int,     // 1-5
    @SerialName("stress_level") val stressLevel: Int,       // 1-5
    @SerialName("muscle_soreness") val muscleSoreness: Int, // 1-5
    val mood: Int,                                           // 1-5
    @SerialName("water_glasses") val waterGlasses: Int,     // 0-30
    val notes: String? = null
)

@Serializable
data class DailySurveyResponse(
    val id: String = "",
    val date: String = "",
    @SerialName("energy_level") val energyLevel: Int = 3,
    @SerialName("sleep_hours") val sleepHours: Double = 7.0,
    @SerialName("sleep_quality") val sleepQuality: Int = 3,
    @SerialName("stress_level") val stressLevel: Int = 3,
    @SerialName("muscle_soreness") val muscleSoreness: Int = 3,
    val mood: Int = 3,
    @SerialName("water_glasses") val waterGlasses: Int = 8,
    val notes: String? = null,
    @SerialName("created_at") val createdAt: String? = null
)

@Serializable
data class TodaySurveyStatus(
    @SerialName("is_completed") val isCompleted: Boolean = false,
    val survey: DailySurveyResponse? = null
)
