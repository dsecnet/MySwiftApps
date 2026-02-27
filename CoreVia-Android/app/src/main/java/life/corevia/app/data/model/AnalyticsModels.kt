package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * iOS AnalyticsModels.swift equivalent
 * Analytics dashboard data models
 */

@Serializable
data class AnalyticsDashboardResponse(
    @SerialName("current_week") val currentWeek: WeeklyStatsResponse = WeeklyStatsResponse(),
    @SerialName("weight_trend") val weightTrend: List<ProgressTrend> = emptyList(),
    @SerialName("workout_trend") val workoutTrend: List<WorkoutTrend> = emptyList(),
    @SerialName("nutrition_trend") val nutritionTrend: List<NutritionTrend> = emptyList(),
    @SerialName("thirty_day_summary") val thirtyDaySummary: ThirtyDaySummary = ThirtyDaySummary()
)

@Serializable
data class WeeklyStatsResponse(
    @SerialName("total_workouts") val totalWorkouts: Int = 0,
    @SerialName("total_minutes") val totalMinutes: Int = 0,
    @SerialName("total_calories") val totalCalories: Int = 0,
    @SerialName("consistency_percent") val consistencyPercent: Double = 0.0,
    @SerialName("avg_duration") val avgDuration: Int = 0
)

@Serializable
data class WorkoutTrend(
    val date: String = "",
    val count: Int = 0,
    val minutes: Int = 0,
    val calories: Int = 0
)

@Serializable
data class NutritionTrend(
    val date: String = "",
    val calories: Int = 0,
    val protein: Double = 0.0,
    val carbs: Double = 0.0,
    val fats: Double = 0.0
)

@Serializable
data class ProgressTrend(
    val date: String = "",
    val weight: Double? = null,
    val value: Double? = null
)

@Serializable
data class ThirtyDaySummary(
    @SerialName("total_workouts") val totalWorkouts: Int = 0,
    @SerialName("total_calories_burned") val totalCaloriesBurned: Int = 0,
    @SerialName("total_food_calories") val totalFoodCalories: Int = 0,
    @SerialName("avg_daily_calories") val avgDailyCalories: Int = 0,
    @SerialName("total_distance") val totalDistance: Double = 0.0,
    @SerialName("avg_sleep") val avgSleep: Double = 0.0
)

@Serializable
data class DailyStatsResponse(
    val date: String = "",
    val workouts: Int = 0,
    val calories: Int = 0,
    val steps: Int = 0,
    val water: Int = 0,
    @SerialName("sleep_hours") val sleepHours: Double = 0.0
)
