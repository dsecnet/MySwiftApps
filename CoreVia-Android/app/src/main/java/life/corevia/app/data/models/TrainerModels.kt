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
