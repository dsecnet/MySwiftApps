package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Request Models ───────────────────────────────────────────────────────────

// iOS: struct LoginRequest: Encodable
data class LoginRequest(
    val email: String,
    val password: String
)

// iOS: struct RegisterRequest: Encodable
data class RegisterRequest(
    val name: String,
    val email: String,
    val password: String,
    @SerializedName("user_type") val userType: String  // "client" | "trainer"
)

// ─── Response Models ──────────────────────────────────────────────────────────

// iOS: struct AuthResponse (access + refresh tokens)
data class AuthResponse(
    @SerializedName("access_token")  val accessToken: String,
    @SerializedName("refresh_token") val refreshToken: String,
    @SerializedName("token_type")    val tokenType: String = "Bearer"
)

// iOS: struct UserResponse: Codable
data class UserResponse(
    val id: String,
    val name: String,
    val email: String,
    @SerializedName("user_type")            val userType: String,           // "client" | "trainer"
    @SerializedName("profile_image_url")    val profileImageUrl: String?,
    @SerializedName("is_active")            val isActive: Boolean,
    @SerializedName("is_premium")           val isPremium: Boolean,
    @SerializedName("created_at")           val createdAt: String,

    // Client fields
    val age: Int?,
    val weight: Double?,
    val height: Double?,
    val goal: String?,
    @SerializedName("trainer_id")           val trainerId: String?,

    // Trainer fields
    val specialization: String?,
    val experience: Int?,
    val rating: Double?,
    @SerializedName("price_per_session")    val pricePerSession: Double?,
    val bio: String?,
    @SerializedName("verification_status")  val verificationStatus: String?,
    @SerializedName("instagram_handle")     val instagramHandle: String?,
    @SerializedName("verification_photo_url") val verificationPhotoUrl: String?,
    @SerializedName("verification_score")   val verificationScore: Double?
)
