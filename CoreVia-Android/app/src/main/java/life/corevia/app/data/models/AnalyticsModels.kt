package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Analytics Models ───────────────────────────────────────────────────────
// iOS: AnalyticsManager.swift

data class DailyStats(
    val date: String,
    @SerializedName("total_workouts")       val totalWorkouts: Int = 0,
    @SerializedName("total_duration")       val totalDuration: Int = 0,
    @SerializedName("total_calories_burned") val totalCaloriesBurned: Int = 0,
    @SerializedName("total_food_entries")   val totalFoodEntries: Int = 0,
    @SerializedName("total_calories_consumed") val totalCaloriesConsumed: Int = 0,
    @SerializedName("total_protein")        val totalProtein: Double = 0.0,
    @SerializedName("total_carbs")          val totalCarbs: Double = 0.0,
    @SerializedName("total_fats")           val totalFats: Double = 0.0
)

data class WeeklyStats(
    @SerializedName("start_date")           val startDate: String,
    @SerializedName("end_date")             val endDate: String,
    @SerializedName("daily_stats")          val dailyStats: List<DailyStats> = emptyList(),
    @SerializedName("total_workouts")       val totalWorkouts: Int = 0,
    @SerializedName("total_duration")       val totalDuration: Int = 0,
    @SerializedName("total_calories_burned") val totalCaloriesBurned: Int = 0,
    @SerializedName("avg_daily_calories")   val avgDailyCalories: Double = 0.0
)

data class BodyMeasurement(
    val id: String,
    @SerializedName("user_id")    val userId: String? = null,
    val weight: Double? = null,
    val height: Double? = null,
    @SerializedName("body_fat")   val bodyFat: Double? = null,
    @SerializedName("muscle_mass") val muscleMass: Double? = null,
    val chest: Double? = null,
    val waist: Double? = null,
    val hips: Double? = null,
    val arms: Double? = null,
    val notes: String? = null,
    @SerializedName("measured_at") val measuredAt: String? = null,
    @SerializedName("created_at") val createdAt: String? = null
)

data class BodyMeasurementCreateRequest(
    val weight: Double? = null,
    val height: Double? = null,
    @SerializedName("body_fat")   val bodyFat: Double? = null,
    @SerializedName("muscle_mass") val muscleMass: Double? = null,
    val chest: Double? = null,
    val waist: Double? = null,
    val hips: Double? = null,
    val arms: Double? = null,
    val notes: String? = null
)

data class AnalyticsDashboard(
    @SerializedName("today")       val today: DailyStats? = null,
    @SerializedName("this_week")   val thisWeek: WeeklyStats? = null,
    @SerializedName("streak_days") val streakDays: Int = 0,
    @SerializedName("total_workouts_all_time") val totalWorkoutsAllTime: Int = 0
)
