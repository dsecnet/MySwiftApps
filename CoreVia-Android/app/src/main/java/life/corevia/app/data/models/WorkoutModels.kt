package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Enum ─────────────────────────────────────────────────────────────────────

// iOS: enum WorkoutCategory: String, Codable
enum class WorkoutCategory(val value: String) {
    STRENGTH("strength"),
    CARDIO("cardio"),
    FLEXIBILITY("flexibility"),
    ENDURANCE("endurance");

    companion object {
        fun from(value: String) = entries.firstOrNull { it.value == value } ?: CARDIO
    }
}

// ─── Workout Model ────────────────────────────────────────────────────────────

// iOS: struct Workout: Identifiable, Codable
data class Workout(
    val id: String,
    @SerializedName("user_id")        val userId: String?,
    val title: String,
    val category: String,             // "strength" | "cardio" | "flexibility" | "endurance"
    val duration: Int,                // dəqiqə (minutes)
    @SerializedName("calories_burned") val caloriesBurned: Int?,
    val notes: String?,
    val date: String,                 // ISO 8601: "2026-02-17T10:00:00.000000"
    @SerializedName("is_completed")   val isCompleted: Boolean = false
)

// ─── Request Models ───────────────────────────────────────────────────────────

// iOS: WorkoutCreateRequest (WorkoutManager.swift-dəki private struct)
data class WorkoutCreateRequest(
    val title: String,
    val category: String,
    val duration: Int,
    @SerializedName("calories_burned") val caloriesBurned: Int?,
    val notes: String?,
    val date: String?
)

// iOS: WorkoutUpdateRequest
data class WorkoutUpdateRequest(
    val title: String?,
    val category: String?,
    val duration: Int?,
    @SerializedName("calories_burned") val caloriesBurned: Int?,
    val notes: String?,
    @SerializedName("is_completed")   val isCompleted: Boolean?
)
