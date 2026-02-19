package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Trainer Models ──────────────────────────────────────────────────────────
// iOS: TrainerService.swift + ProfileView references

// iOS: ProfileUpdateRequest
data class ProfileUpdateRequest(
    val name: String? = null,
    val age: Int? = null,
    val weight: Double? = null,
    val height: Double? = null,
    val goal: String? = null,
    // Trainer fields
    val specialization: String? = null,
    val experience: Int? = null,
    val bio: String? = null,
    @SerializedName("price_per_session") val pricePerSession: Double? = null,
    @SerializedName("instagram_handle")  val instagramHandle: String? = null
)

// iOS: TrainingPlanCreateRequest
data class TrainingPlanCreateRequest(
    val title: String,
    @SerializedName("plan_type")           val planType: String,
    val notes: String? = null,
    @SerializedName("assigned_student_id") val assignedStudentId: String? = null,
    val workouts: List<PlanWorkoutCreateRequest> = emptyList()
)

// iOS: PlanWorkoutCreate
data class PlanWorkoutCreateRequest(
    val name: String,
    val sets: Int,
    val reps: Int,
    val duration: Int? = null
)

// Refresh token request — iOS ilə eyni bug fix: JSON body göndər, header yox
data class RefreshTokenRequest(
    @SerializedName("refresh_token") val refreshToken: String
)

// ─── Trainer Stats Response ─────────────────────────────────────────────────
// Köhnə model — uyğunluq üçün saxlanılır
data class TrainerStatsResponse(
    @SerializedName("total_students")       val totalStudents: Int = 0,
    @SerializedName("active_students")      val activeStudents: Int = 0,
    @SerializedName("total_training_plans") val totalTrainingPlans: Int = 0,
    @SerializedName("total_meal_plans")     val totalMealPlans: Int = 0,
    @SerializedName("completed_plans")      val completedPlans: Int = 0,
    @SerializedName("average_rating")       val averageRating: Double = 0.0,
    @SerializedName("total_reviews")        val totalReviews: Int = 0,
    @SerializedName("monthly_earnings")     val monthlyEarnings: Double = 0.0,
    // iOS TrainerDashboardStats əlavə sahələr
    @SerializedName("total_subscribers")    val totalSubscribers: Int = 0,
    val currency: String = "₼",
    val students: List<DashboardStudentSummary> = emptyList(),
    @SerializedName("stats_summary")        val statsSummary: DashboardStatsSummary? = null
)

// ─── iOS: DashboardStudentSummary ──────────────────────────────────────────
data class DashboardStudentSummary(
    val id: String = "",
    val name: String = "",
    val email: String = "",
    val weight: Double? = null,
    val height: Double? = null,
    val goal: String? = null,
    val age: Int? = null,
    @SerializedName("profile_image_url") val profileImageUrl: String? = null,
    @SerializedName("training_plans_count") val trainingPlansCount: Int = 0,
    @SerializedName("meal_plans_count")     val mealPlansCount: Int = 0,
    @SerializedName("total_workouts")       val totalWorkouts: Int = 0,
    @SerializedName("this_week_workouts")   val thisWeekWorkouts: Int = 0,
    @SerializedName("total_calories_logged") val totalCaloriesLogged: Int = 0
) {
    /** iOS: student.initials — adın baş hərfləri */
    val initials: String
        get() {
            val parts = name.split(" ")
            return if (parts.size >= 2) {
                "${parts[0].first()}${parts[1].first()}".uppercase()
            } else {
                name.take(2).uppercase()
            }
        }

    /** iOS: student.avatarColor — hash əsaslı palitradan rəng */
    val avatarColorIndex: Int
        get() = (name.hashCode().let { if (it < 0) -it else it }) % 8
}

// ─── iOS: DashboardStatsSummary ────────────────────────────────────────────
data class DashboardStatsSummary(
    @SerializedName("avg_student_workouts_per_week") val avgStudentWorkoutsPerWeek: Double = 0.0,
    @SerializedName("total_workouts_all_students")   val totalWorkoutsAllStudents: Int = 0,
    @SerializedName("avg_student_weight")            val avgStudentWeight: Double = 0.0
)
