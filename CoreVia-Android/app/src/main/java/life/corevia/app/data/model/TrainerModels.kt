package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import life.corevia.app.ui.theme.*
import androidx.compose.ui.graphics.Color
import kotlin.math.abs

/**
 * iOS TrainerModels.swift equivalent
 * Trainer response, kateqoriya, UserResponse modelleri
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - Trainer Response
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class TrainerResponse(
    val id: String = "",
    val name: String = "",
    @SerialName("profile_image_url") val profileImageUrl: String? = null,
    val specialization: String? = null,
    val experience: Int? = null,
    val rating: Double? = null,
    @SerialName("price_per_session") val pricePerSession: Double? = null,
    val bio: String? = null,
    @SerialName("verification_status") val verificationStatus: String = "",
    @SerialName("instagram_handle") val instagramHandle: String? = null
) {
    /** Auto-detect category from specialization */
    val category: TrainerCategory
        get() {
            val spec = specialization?.lowercase() ?: return TrainerCategory.FITNESS
            return when {
                spec.contains("yoga") -> TrainerCategory.YOGA
                spec.contains("cardio") || spec.contains("kardio") -> TrainerCategory.CARDIO
                spec.contains("nutrition") || spec.contains("qidalanma") -> TrainerCategory.NUTRITION
                spec.contains("strength") || spec.contains("guc") || spec.contains("güc") -> TrainerCategory.STRENGTH
                else -> TrainerCategory.FITNESS
            }
        }

    /** Get specialty tags from specialization text */
    val specialtyTags: List<TrainerCategory>
        get() {
            val tags = mutableListOf(category)
            val spec = specialization?.lowercase() ?: return tags
            TrainerCategory.entries.forEach { cat ->
                if (cat != category && spec.contains(cat.value.lowercase())) {
                    tags.add(cat)
                }
            }
            return tags
        }

    /** Full name alias */
    val fullName: String get() = name

    /** Detected category alias */
    val detectedCategory: TrainerCategory get() = category

    /** Initials from name */
    val initials: String
        get() {
            val parts = name.split(" ")
            return if (parts.size >= 2) {
                "${parts[0].take(1)}${parts[1].take(1)}".uppercase()
            } else {
                name.take(2).uppercase()
            }
        }

    /** Is verified trainer */
    val isVerified: Boolean
        get() = verificationStatus.lowercase() == "verified"

    /** Experience years alias */
    val experienceYears: Int? get() = experience

    val displayRating: String
        get() = rating?.let { "%.1f".format(it) } ?: "--"

    val displayPrice: String
        get() = pricePerSession?.let { "%.0f ₼".format(it) } ?: "--"

    val displayExperience: String
        get() = experience?.let { "$it il" } ?: "--"
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Trainer Category
// ═══════════════════════════════════════════════════════════════════
enum class TrainerCategory(val value: String, val displayName: String) {
    FITNESS("Fitness", "Fitness"),
    STRENGTH("Guc", "Güc"),
    CARDIO("Kardio", "Kardio"),
    YOGA("Yoga", "Yoga"),
    NUTRITION("Qidalanma", "Qidalanma");

    val color: Color
        get() = when (this) {
            FITNESS -> CatFitness
            STRENGTH -> CatStrength
            CARDIO -> CatCardio
            YOGA -> CatYoga
            NUTRITION -> CatNutrition
        }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - User Response (Assign/Unassign API)
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class UserResponse(
    val id: String = "",
    val name: String = "",
    val email: String = "",
    @SerialName("profile_image_url") val profileImageUrl: String? = null,
    @SerialName("user_type") val userType: String = "client",
    @SerialName("trainer_id") val trainerId: String? = null,
    @SerialName("is_premium") val isPremium: Boolean = false,
    val weight: Double? = null,
    val height: Double? = null,
    val age: Int? = null,
    val goal: String? = null
) {
    /** Full name alias */
    val fullName: String get() = name

    /** Name-dən baş hərflər (avatar üçün) */
    val initials: String
        get() {
            val parts = name.split(" ")
            return if (parts.size >= 2) {
                "${parts[0].take(1)}${parts[1].take(1)}".uppercase()
            } else {
                name.take(2).uppercase()
            }
        }

    /** Avatar rəngi — name hash ilə */
    val avatarColor: Color
        get() {
            val index = abs(name.hashCode()) % AvatarPalette.size
            return AvatarPalette[index]
        }
}
