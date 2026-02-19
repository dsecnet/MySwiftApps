package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Request Models ───────────────────────────────────────────────────────────

// iOS: struct LoginRequest: Encodable
data class LoginRequest(
    val email: String,
    val password: String
)

// iOS: struct LoginVerifyRequest: Encodable — Step 2 OTP doğrulama
data class LoginVerifyRequest(
    val email: String,
    @SerializedName("otp_code") val otpCode: String
)

// iOS: struct RegisterRequest: Encodable — Step 1: OTP göndər (yalnız email)
data class RegisterOtpRequest(
    val email: String
)

// Köhnə RegisterRequest — geriyə uyğunluq
data class RegisterRequest(
    val name: String,
    val email: String,
    val password: String,
    @SerializedName("user_type") val userType: String  // "client" | "trainer"
)

// Step 2: OTP doğrulama ilə qeydiyyat tamamla
data class RegisterVerifyRequest(
    val name: String,
    val email: String,
    val password: String,
    @SerializedName("user_type") val userType: String,
    @SerializedName("otp_code") val otpCode: String
)

// Şifrəni unutdum — OTP göndər
data class ForgotPasswordRequest(
    val email: String
)

// OTP doğrulama (ümumi)
data class VerifyOtpRequest(
    val email: String,
    @SerializedName("otp_code") val otpCode: String
)

// Şifrə sıfırlama — yeni şifrə ilə
data class ResetPasswordRequest(
    val email: String,
    @SerializedName("otp_code")     val otpCode: String,
    @SerializedName("new_password") val newPassword: String
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
    @SerializedName("is_active")            val isActive: Boolean = true,
    @SerializedName("is_premium")           val isPremium: Boolean = false,
    @SerializedName("created_at")           val createdAt: String? = null,

    // Client fields
    val age: Int? = null,
    val weight: Double? = null,
    val height: Double? = null,
    val goal: String? = null,
    @SerializedName("trainer_id")           val trainerId: String? = null,

    // Trainer fields
    val specialization: String? = null,
    val experience: Int? = null,
    val rating: Double? = null,
    @SerializedName("price_per_session")    val pricePerSession: Double? = null,
    val bio: String? = null,
    @SerializedName("verification_status")  val verificationStatus: String? = null,
    @SerializedName("instagram_handle")     val instagramHandle: String? = null,
    @SerializedName("verification_photo_url") val verificationPhotoUrl: String? = null,
    @SerializedName("verification_score")   val verificationScore: Double? = null
)
