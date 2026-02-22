package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Analytics Models ───────────────────────────────────────────────────────
// iOS: AnalyticsManager.swift

data class DailyStats(
    val date: String,
    @SerializedName("workouts_completed")       val workoutsCompleted: Int = 0,
    @SerializedName("total_workout_minutes")    val totalWorkoutMinutes: Int = 0,
    @SerializedName("calories_burned")          val caloriesBurned: Int = 0,
    @SerializedName("distance_km")              val distanceKm: Double = 0.0,
    @SerializedName("calories_consumed")        val caloriesConsumed: Int = 0,
    @SerializedName("protein_g")                val proteinG: Double = 0.0,
    @SerializedName("carbs_g")                  val carbsG: Double = 0.0,
    @SerializedName("fats_g")                   val fatsG: Double = 0.0,
    @SerializedName("weight_kg")                val weightKg: Double? = null,
    @SerializedName("body_fat_percent")         val bodyFatPercent: Double? = null
)

data class WeeklyStats(
    @SerializedName("week_start")                   val weekStart: String = "",
    @SerializedName("week_end")                     val weekEnd: String = "",
    @SerializedName("workouts_completed")            val workoutsCompleted: Int = 0,
    @SerializedName("total_workout_minutes")         val totalWorkoutMinutes: Int = 0,
    @SerializedName("calories_burned")               val caloriesBurned: Int = 0,
    @SerializedName("calories_consumed")             val caloriesConsumed: Int = 0,
    @SerializedName("distance_km")                   val distanceKm: Double = 0.0,
    @SerializedName("avg_daily_calories_burned")     val avgDailyCaloriesBurned: Int = 0,
    @SerializedName("avg_daily_calories_consumed")   val avgDailyCaloriesConsumed: Int = 0,
    @SerializedName("weight_change_kg")              val weightChangeKg: Double? = null,
    @SerializedName("workout_consistency_percent")   val workoutConsistencyPercent: Int = 0
)

data class AnalyticsDashboard(
    @SerializedName("current_week")              val currentWeek: WeeklyStats? = null,
    @SerializedName("weight_trend")              val weightTrend: List<ProgressTrendItem> = emptyList(),
    @SerializedName("workout_trend")             val workoutTrend: List<WorkoutTrendItem> = emptyList(),
    @SerializedName("nutrition_trend")           val nutritionTrend: List<NutritionTrendItem> = emptyList(),
    @SerializedName("total_workouts_30d")        val totalWorkouts30d: Int = 0,
    @SerializedName("total_minutes_30d")         val totalMinutes30d: Int = 0,
    @SerializedName("total_calories_burned_30d") val totalCaloriesBurned30d: Int = 0,
    @SerializedName("avg_daily_calories")        val avgDailyCalories: Int = 0,
    @SerializedName("workout_streak_days")       val workoutStreakDays: Int = 0
)

data class ProgressTrendItem(
    val date: String,
    val value: Double,
    @SerializedName("change_from_previous") val changeFromPrevious: Double? = null
)

data class WorkoutTrendItem(
    val date: String,
    @SerializedName("workouts_count") val workoutsCount: Int = 0,
    val minutes: Int = 0,
    val calories: Int = 0
)

data class NutritionTrendItem(
    val date: String,
    val calories: Int = 0,
    val protein: Double = 0.0,
    val carbs: Double = 0.0,
    val fats: Double = 0.0
)

data class BodyMeasurement(
    val id: String,
    @SerializedName("user_id")          val userId: String? = null,
    @SerializedName("measured_at")      val measuredAt: String? = null,
    @SerializedName("weight_kg")        val weightKg: Double? = null,
    @SerializedName("body_fat_percent") val bodyFatPercent: Double? = null,
    @SerializedName("muscle_mass_kg")   val muscleMassKg: Double? = null,
    @SerializedName("chest_cm")         val chestCm: Double? = null,
    @SerializedName("waist_cm")         val waistCm: Double? = null,
    @SerializedName("hips_cm")          val hipsCm: Double? = null,
    @SerializedName("arms_cm")          val armsCm: Double? = null,
    @SerializedName("legs_cm")          val legsCm: Double? = null,
    val notes: String? = null,
    @SerializedName("created_at")       val createdAt: String? = null
)

data class BodyMeasurementCreateRequest(
    @SerializedName("measured_at")      val measuredAt: String,
    @SerializedName("weight_kg")        val weightKg: Double,
    @SerializedName("body_fat_percent") val bodyFatPercent: Double? = null,
    @SerializedName("muscle_mass_kg")   val muscleMassKg: Double? = null,
    @SerializedName("chest_cm")         val chestCm: Double? = null,
    @SerializedName("waist_cm")         val waistCm: Double? = null,
    @SerializedName("hips_cm")          val hipsCm: Double? = null,
    @SerializedName("arms_cm")          val armsCm: Double? = null,
    @SerializedName("legs_cm")          val legsCm: Double? = null,
    val notes: String? = null
)

// ─── Comparison Models ──────────────────────────────────────────────────────

data class ComparisonPeriod(
    @SerializedName("period_name")      val periodName: String = "",
    val workouts: Int = 0,
    val minutes: Int = 0,
    @SerializedName("calories_burned")  val caloriesBurned: Int = 0,
    @SerializedName("calories_consumed") val caloriesConsumed: Int = 0,
    @SerializedName("weight_change")    val weightChange: Double? = null
)

data class ProgressComparison(
    @SerializedName("current_period")               val currentPeriod: ComparisonPeriod,
    @SerializedName("previous_period")              val previousPeriod: ComparisonPeriod,
    @SerializedName("workouts_change_percent")      val workoutsChangePercent: Double = 0.0,
    @SerializedName("minutes_change_percent")       val minutesChangePercent: Double = 0.0,
    @SerializedName("calories_burned_change_percent") val caloriesBurnedChangePercent: Double = 0.0
)
