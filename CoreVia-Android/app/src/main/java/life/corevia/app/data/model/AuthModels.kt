package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// MARK: - Request Models

@Serializable
data class LoginRequest(
    val email: String,
    val password: String,
    @SerialName("user_type") val userType: String // "client" or "trainer"
)

@Serializable
data class LoginVerifyRequest(
    val email: String,
    @SerialName("otp_code") val otpCode: String
)

// MARK: - Response Models

@Serializable
data class TokenResponse(
    @SerialName("access_token") val accessToken: String,
    @SerialName("refresh_token") val refreshToken: String
)

@Serializable
data class OTPResponse(
    val message: String
)

@Serializable
data class ErrorResponse(
    val detail: String? = null
)

// MARK: - Register Models

@Serializable
data class RegisterOTPRequest(
    val email: String
)

@Serializable
data class RegisterRequest(
    val name: String,
    val email: String,
    val password: String,
    @SerialName("user_type") val userType: String,
    @SerialName("otp_code") val otpCode: String = "",
    val instagram: String? = null,
    val specialization: String? = null,
    @SerialName("experience_years") val experienceYears: Int? = null,
    val bio: String? = null
)

// MARK: - User Type

enum class UserType(val value: String) {
    CLIENT("client"),
    TRAINER("trainer")
}
