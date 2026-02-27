package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * iOS User.swift equivalent
 * İstifadəçi profil, statistika, gündəlik irəliləyiş modelleri
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - User Profile
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class UserProfile(
    val id: String = "",
    val email: String = "",
    @SerialName("name") val fullName: String = "İstifadəçi",
    @SerialName("profile_image_url") val profileImage: String? = null,
    @SerialName("user_type") val userType: String = "client",
    @SerialName("is_premium") val isPremium: Boolean = false,

    // Fiziki məlumatlar
    val height: Float? = null,
    val weight: Float? = null,
    val age: Int? = null,
    val gender: String? = null,

    // Hədəflər
    @SerialName("fitness_goal") val fitnessGoal: String? = null,
    @SerialName("daily_calorie_goal") val dailyCalorieGoal: Int = 2000,
    @SerialName("daily_water_goal") val dailyWaterGoal: Int = 8,
    @SerialName("daily_step_goal") val dailyStepGoal: Int = 10000,
    @SerialName("daily_sleep_goal") val dailySleepGoal: Float = 8f,

    // Trainer spesifik
    val specialization: String? = null,
    val experience: Int? = null,
    val rating: Double? = null,
    @SerialName("price_per_session") val pricePerSession: Double? = null,
    val bio: String? = null,
    @SerialName("verification_status") val verificationStatus: String? = null,
    @SerialName("instagram_handle") val instagramHandle: String? = null,

    // Tarixlər
    @SerialName("created_at") val createdAt: String? = null,

    // Client spesifik
    val goal: String? = null,
    @SerialName("trainer_id") val trainerId: String? = null
) {
    /** İstifadəçi tipi — client və ya trainer */
    val isTrainer: Boolean
        get() = userType == "trainer"

    /** İstifadəçi tipi göstərilən ad */
    val userTypeDisplayName: String
        get() = if (isTrainer) "Trener" else "Müştəri"

    /** Profil tamamlanma faizi (0.0 - 1.0) */
    val profileCompletion: Float
        get() {
            var total = 5
            var filled = 0
            if (fullName.isNotBlank() && fullName != "İstifadəçi") filled++
            if (email.isNotBlank()) filled++
            if (height != null) filled++
            if (weight != null) filled++
            if (age != null) filled++
            return if (total > 0) filled.toFloat() / total else 0f
        }

    /** Doğrulama statusu: verified, pending, rejected, unverified */
    val isVerified: Boolean
        get() = verificationStatus?.lowercase() == "verified"

    val verificationDisplayName: String
        get() = when (verificationStatus?.lowercase()) {
            "verified" -> "Doğrulanmış"
            "pending" -> "Gözləmədə"
            "rejected" -> "Rədd edildi"
            else -> "Doğrulanmamış"
        }

    /** İxtisas etiketləri (vergüllə ayrılmış) */
    val specialtyTags: List<String>
        get() = specialization?.split(",")?.map { it.trim() }?.filter { it.isNotBlank() } ?: emptyList()

    /** Qiymet göstərişi */
    val displayPrice: String
        get() = pricePerSession?.let { "%.0f ₼".format(it) } ?: ""

    /** Üzvlük tarixi formatı */
    val memberSinceFormatted: String
        get() {
            val raw = createdAt ?: return ""
            return try {
                // "2024-06-15T10:30:00Z" → "İyun 2024"
                val parts = raw.split("-")
                if (parts.size >= 2) {
                    val year = parts[0]
                    val month = when (parts[1]) {
                        "01" -> "Yanvar"
                        "02" -> "Fevral"
                        "03" -> "Mart"
                        "04" -> "Aprel"
                        "05" -> "May"
                        "06" -> "İyun"
                        "07" -> "İyul"
                        "08" -> "Avqust"
                        "09" -> "Sentyabr"
                        "10" -> "Oktyabr"
                        "11" -> "Noyabr"
                        "12" -> "Dekabr"
                        else -> parts[1]
                    }
                    "$month $year"
                } else raw
            } catch (_: Exception) {
                raw
            }
        }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - User Stats
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class UserStats(
    @SerialName("total_workouts") val totalWorkouts: Int = 0,
    @SerialName("current_streak") val currentStreak: Int = 0,
    @SerialName("total_calories_burned") val totalCaloriesBurned: Float = 0f,
    @SerialName("total_distance") val totalDistance: Float = 0f
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Daily Progress
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class DailyProgress(
    @SerialName("calories_consumed") val caloriesConsumed: Int = 0,
    @SerialName("calories_goal") val caloriesGoal: Int = 2000,
    @SerialName("water_consumed") val waterConsumed: Int = 0,
    @SerialName("water_goal") val waterGoal: Int = 8,
    val steps: Int = 0,
    @SerialName("steps_goal") val stepsGoal: Int = 10000,
    @SerialName("sleep_hours") val sleepHours: Float = 0f,
    @SerialName("sleep_goal") val sleepGoal: Float = 8f
) {
    val calorieProgress: Float get() = if (caloriesGoal > 0) caloriesConsumed.toFloat() / caloriesGoal else 0f
    val waterProgress: Float get() = if (waterGoal > 0) waterConsumed.toFloat() / waterGoal else 0f
    val stepProgress: Float get() = if (stepsGoal > 0) steps.toFloat() / stepsGoal else 0f
    val sleepProgress: Float get() = if (sleepGoal > 0) sleepHours / sleepGoal else 0f
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - User Update Request
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class UserUpdateRequest(
    @SerialName("full_name") val fullName: String? = null,
    val height: Float? = null,
    val weight: Float? = null,
    val age: Int? = null,
    val gender: String? = null,
    @SerialName("fitness_goal") val fitnessGoal: String? = null,
    val goal: String? = null,
    @SerialName("daily_calorie_goal") val dailyCalorieGoal: Int? = null,
    @SerialName("daily_water_goal") val dailyWaterGoal: Int? = null,
    @SerialName("daily_step_goal") val dailyStepGoal: Int? = null,
    @SerialName("daily_sleep_goal") val dailySleepGoal: Float? = null
)
