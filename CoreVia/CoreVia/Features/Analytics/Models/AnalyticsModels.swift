import Foundation

// MARK: - Daily Stats

struct DailyStatsResponse: Codable, Identifiable {
    var id: String { date.description }
    let date: Date
    let workoutsCompleted: Int
    let totalWorkoutMinutes: Int
    let caloriesBurned: Int
    let distanceKm: Double
    let caloriesConsumed: Int
    let proteinG: Double
    let carbsG: Double
    let fatsG: Double
    let weightKg: Double?
    let bodyFatPercent: Double?

    enum CodingKeys: String, CodingKey {
        case date
        case workoutsCompleted = "workouts_completed"
        case totalWorkoutMinutes = "total_workout_minutes"
        case caloriesBurned = "calories_burned"
        case distanceKm = "distance_km"
        case caloriesConsumed = "calories_consumed"
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatsG = "fats_g"
        case weightKg = "weight_kg"
        case bodyFatPercent = "body_fat_percent"
    }
}

// MARK: - Weekly Stats

struct WeeklyStatsResponse: Codable {
    let weekStart: Date
    let weekEnd: Date
    let workoutsCompleted: Int
    let totalWorkoutMinutes: Int
    let caloriesBurned: Int
    let caloriesConsumed: Int
    let distanceKm: Double
    let avgDailyCaloriesBurned: Int
    let avgDailyCaloriesConsumed: Int
    let weightChangeKg: Double?
    let workoutConsistencyPercent: Int

    enum CodingKeys: String, CodingKey {
        case weekStart = "week_start"
        case weekEnd = "week_end"
        case workoutsCompleted = "workouts_completed"
        case totalWorkoutMinutes = "total_workout_minutes"
        case caloriesBurned = "calories_burned"
        case caloriesConsumed = "calories_consumed"
        case distanceKm = "distance_km"
        case avgDailyCaloriesBurned = "avg_daily_calories_burned"
        case avgDailyCaloriesConsumed = "avg_daily_calories_consumed"
        case weightChangeKg = "weight_change_kg"
        case workoutConsistencyPercent = "workout_consistency_percent"
    }
}

// MARK: - Body Measurement

struct BodyMeasurementCreate: Codable {
    let measuredAt: Date
    let weightKg: Double
    let bodyFatPercent: Double?
    let muscleMassKg: Double?
    let chestCm: Double?
    let waistCm: Double?
    let hipsCm: Double?
    let armsCm: Double?
    let legsCm: Double?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case measuredAt = "measured_at"
        case weightKg = "weight_kg"
        case bodyFatPercent = "body_fat_percent"
        case muscleMassKg = "muscle_mass_kg"
        case chestCm = "chest_cm"
        case waistCm = "waist_cm"
        case hipsCm = "hips_cm"
        case armsCm = "arms_cm"
        case legsCm = "legs_cm"
        case notes
    }
}

struct BodyMeasurementResponse: Codable, Identifiable {
    let id: String
    let userId: String
    let measuredAt: Date
    let weightKg: Double
    let bodyFatPercent: Double?
    let muscleMassKg: Double?
    let chestCm: Double?
    let waistCm: Double?
    let hipsCm: Double?
    let armsCm: Double?
    let legsCm: Double?
    let notes: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case measuredAt = "measured_at"
        case weightKg = "weight_kg"
        case bodyFatPercent = "body_fat_percent"
        case muscleMassKg = "muscle_mass_kg"
        case chestCm = "chest_cm"
        case waistCm = "waist_cm"
        case hipsCm = "hips_cm"
        case armsCm = "arms_cm"
        case legsCm = "legs_cm"
        case notes
        case createdAt = "created_at"
    }
}

// MARK: - Analytics Dashboard

struct ProgressTrend: Codable, Identifiable {
    var id: String { date.description }
    let date: Date
    let value: Double
    let changeFromPrevious: Double?

    enum CodingKeys: String, CodingKey {
        case date, value
        case changeFromPrevious = "change_from_previous"
    }
}

struct WorkoutTrend: Codable, Identifiable {
    var id: String { date.description }
    let date: Date
    let workoutsCount: Int
    let minutes: Int
    let calories: Int

    enum CodingKeys: String, CodingKey {
        case date
        case workoutsCount = "workouts_count"
        case minutes, calories
    }
}

struct NutritionTrend: Codable, Identifiable {
    var id: String { date.description }
    let date: Date
    let calories: Int
    let protein: Double
    let carbs: Double
    let fats: Double
}

struct AnalyticsDashboardResponse: Codable {
    let currentWeek: WeeklyStatsResponse
    let weightTrend: [ProgressTrend]
    let workoutTrend: [WorkoutTrend]
    let nutritionTrend: [NutritionTrend]
    let totalWorkouts30d: Int
    let totalMinutes30d: Int
    let totalCaloriesBurned30d: Int
    let avgDailyCalories: Int
    let workoutStreakDays: Int

    enum CodingKeys: String, CodingKey {
        case currentWeek = "current_week"
        case weightTrend = "weight_trend"
        case workoutTrend = "workout_trend"
        case nutritionTrend = "nutrition_trend"
        case totalWorkouts30d = "total_workouts_30d"
        case totalMinutes30d = "total_minutes_30d"
        case totalCaloriesBurned30d = "total_calories_burned_30d"
        case avgDailyCalories = "avg_daily_calories"
        case workoutStreakDays = "workout_streak_days"
    }
}

// MARK: - Progress Comparison

struct ComparisonPeriod: Codable {
    let periodName: String
    let workouts: Int
    let minutes: Int
    let caloriesBurned: Int
    let caloriesConsumed: Int
    let weightChange: Double?

    enum CodingKeys: String, CodingKey {
        case periodName = "period_name"
        case workouts, minutes
        case caloriesBurned = "calories_burned"
        case caloriesConsumed = "calories_consumed"
        case weightChange = "weight_change"
    }
}

struct ProgressComparisonResponse: Codable {
    let currentPeriod: ComparisonPeriod
    let previousPeriod: ComparisonPeriod
    let workoutsChangePercent: Double
    let minutesChangePercent: Double
    let caloriesBurnedChangePercent: Double

    enum CodingKeys: String, CodingKey {
        case currentPeriod = "current_period"
        case previousPeriod = "previous_period"
        case workoutsChangePercent = "workouts_change_percent"
        case minutesChangePercent = "minutes_change_percent"
        case caloriesBurnedChangePercent = "calories_burned_change_percent"
    }
}
