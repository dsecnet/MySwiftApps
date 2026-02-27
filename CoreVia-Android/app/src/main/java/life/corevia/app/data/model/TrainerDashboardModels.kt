package life.corevia.app.data.model

import androidx.compose.ui.graphics.Color
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import life.corevia.app.ui.theme.*
import kotlin.math.abs

/**
 * iOS TrainerDashboardManager.swift model equivalent
 * Trainer Dashboard statistikalar
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - Trainer Dashboard Stats
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class TrainerDashboardStats(
    @SerialName("total_subscribers") val totalSubscribers: Int = 0,
    @SerialName("active_students") val activeStudents: Int = 0,
    @SerialName("monthly_earnings") val monthlyEarnings: Double = 0.0,
    val currency: String = "AZN",
    @SerialName("total_training_plans") val totalTrainingPlans: Int = 0,
    @SerialName("total_meal_plans") val totalMealPlans: Int = 0,
    val students: List<DashboardStudentSummary> = emptyList(),
    @SerialName("stats_summary") val statsSummary: DashboardStatsSummary = DashboardStatsSummary()
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - Dashboard Student Summary
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class DashboardStudentSummary(
    val id: String = "",
    val name: String = "",
    val email: String = "",
    val weight: Double? = null,
    val height: Double? = null,
    val goal: String? = null,
    val age: Int? = null,
    @SerialName("profile_image_url") val profileImageUrl: String? = null,
    @SerialName("training_plans_count") val trainingPlansCount: Int = 0,
    @SerialName("meal_plans_count") val mealPlansCount: Int = 0,
    @SerialName("total_workouts") val totalWorkouts: Int = 0,
    @SerialName("this_week_workouts") val thisWeekWorkouts: Int = 0,
    @SerialName("total_calories_logged") val totalCaloriesLogged: Int = 0
) {
    /** Name-dən baş hərflər */
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

// ═══════════════════════════════════════════════════════════════════
// MARK: - Dashboard Stats Summary
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class DashboardStatsSummary(
    @SerialName("avg_student_workouts_per_week") val avgStudentWorkoutsPerWeek: Double = 0.0,
    @SerialName("total_workouts_all_students") val totalWorkoutsAllStudents: Int = 0,
    @SerialName("avg_student_weight") val avgStudentWeight: Double = 0.0
)
