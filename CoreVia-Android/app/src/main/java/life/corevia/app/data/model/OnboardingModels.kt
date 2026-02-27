package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * iOS OnboardingModels.swift equivalent
 * Onboarding seçimləri, status modelleri
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - Onboarding Option
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class OnboardingOption(
    val id: String = "",
    @SerialName("name_az") val nameAz: String = "",
    @SerialName("name_en") val nameEn: String = "",
    @SerialName("name_ru") val nameRu: String = "",
    val icon: String = "circle"
) {
    /** Get localized name by language code */
    fun localizedName(language: String = "az"): String {
        return when (language) {
            "en" -> nameEn.ifBlank { id }
            "ru" -> nameRu.ifBlank { id }
            else -> nameAz.ifBlank { id }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Onboarding Options Response
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class OnboardingOptionsResponse(
    val goals: List<OnboardingOption> = emptyList(),
    @SerialName("fitness_levels") val fitnessLevels: List<OnboardingOption> = emptyList(),
    @SerialName("trainer_types") val trainerTypes: List<OnboardingOption> = emptyList()
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Onboarding Complete Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class OnboardingCompleteRequest(
    @SerialName("fitness_goal") val fitnessGoal: String,
    @SerialName("fitness_level") val fitnessLevel: String,
    @SerialName("preferred_trainer_type") val preferredTrainerType: String? = null
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Onboarding Status Response
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class OnboardingStatusResponse(
    val id: String = "",
    @SerialName("user_id") val userId: String = "",
    @SerialName("fitness_goal") val fitnessGoal: String? = null,
    @SerialName("fitness_level") val fitnessLevel: String? = null,
    @SerialName("preferred_trainer_type") val preferredTrainerType: String? = null,
    @SerialName("is_completed") val isCompleted: Boolean = false
)
