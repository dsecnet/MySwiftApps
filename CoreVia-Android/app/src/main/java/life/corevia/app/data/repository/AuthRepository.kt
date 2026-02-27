package life.corevia.app.data.repository

import life.corevia.app.data.local.TokenManager
import life.corevia.app.data.model.ErrorResponse
import life.corevia.app.data.model.LoginRequest
import life.corevia.app.data.model.LoginVerifyRequest
import life.corevia.app.data.model.RegisterOTPRequest
import life.corevia.app.data.model.RegisterRequest
import life.corevia.app.data.model.UserProfile
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import kotlinx.serialization.json.Json
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
    private val apiService: ApiService,
    private val tokenManager: TokenManager
) {
    suspend fun login(email: String, password: String, userType: String): NetworkResult<String> {
        return try {
            val response = apiService.login(LoginRequest(email, password, userType))
            if (response.isSuccessful) {
                tokenManager.saveUserType(userType)
                NetworkResult.Success(response.body()?.message ?: "OTP göndərildi")
            } else {
                val errorBody = response.errorBody()?.string()
                val errorMsg = try {
                    Json.decodeFromString<ErrorResponse>(errorBody ?: "").detail ?: "Xəta baş verdi"
                } catch (e: Exception) {
                    "Xəta baş verdi"
                }
                NetworkResult.Error(errorMsg, response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun verifyOtp(email: String, otpCode: String): NetworkResult<Boolean> {
        return try {
            val response = apiService.loginVerify(LoginVerifyRequest(email, otpCode))
            if (response.isSuccessful) {
                response.body()?.let { tokenResponse ->
                    tokenManager.saveTokens(tokenResponse.accessToken, tokenResponse.refreshToken)
                }

                // ── Token alındıqdan sonra user profile-ı yüklə ──
                try {
                    val userResponse = apiService.getCurrentUser()
                    if (userResponse.isSuccessful) {
                        userResponse.body()?.let { user ->
                            // Müdafiəvi ad: backend "İstifadəçi" və ya boş qaytarırsa email-dən götür
                            val displayName = if (user.fullName.isNotBlank() && user.fullName != "İstifadəçi") {
                                user.fullName
                            } else {
                                email.substringBefore("@").replaceFirstChar { it.uppercase() }
                            }
                            tokenManager.saveUserInfo(displayName, user.email)
                            tokenManager.saveUserType(user.userType)
                        }
                    } else {
                        tokenManager.saveUserInfo(email.substringBefore("@").replaceFirstChar { it.uppercase() }, email)
                    }
                } catch (_: Exception) {
                    // Profile yüklənə bilməsə belə login uğurludur
                    tokenManager.saveUserInfo(email.substringBefore("@").replaceFirstChar { it.uppercase() }, email)
                }

                NetworkResult.Success(true)
            } else {
                val errorBody = response.errorBody()?.string()
                val errorMsg = try {
                    Json.decodeFromString<ErrorResponse>(errorBody ?: "").detail ?: "OTP səhvdir"
                } catch (e: Exception) {
                    "OTP səhvdir"
                }
                NetworkResult.Error(errorMsg, response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    /** Backend-dən cari user profile-ı yüklə */
    suspend fun fetchCurrentUser(): NetworkResult<UserProfile> {
        return try {
            val response = apiService.getCurrentUser()
            if (response.isSuccessful) {
                val user = response.body()!!
                // Müdafiəvi ad: backend "İstifadəçi" və ya boş qaytarırsa email-dən götür
                val displayName = if (user.fullName.isNotBlank() && user.fullName != "İstifadəçi") {
                    user.fullName
                } else {
                    user.email.substringBefore("@").replaceFirstChar { it.uppercase() }
                }
                tokenManager.saveUserInfo(displayName, user.email)
                tokenManager.saveUserType(user.userType)
                NetworkResult.Success(user.copy(fullName = displayName))
            } else {
                NetworkResult.Error("Profil yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    /** Client üçün OTP göndər (register-request) */
    suspend fun requestRegisterOTP(email: String): NetworkResult<String> {
        return try {
            val response = apiService.registerRequest(RegisterOTPRequest(email))
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()?.message ?: "OTP göndərildi")
            } else {
                val errorBody = response.errorBody()?.string()
                val errorMsg = try {
                    Json.decodeFromString<ErrorResponse>(errorBody ?: "").detail ?: "OTP göndərilə bilmədi"
                } catch (_: Exception) {
                    "OTP göndərilə bilmədi"
                }
                NetworkResult.Error(errorMsg, response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    /** Qeydiyyat (client + OTP, trainer birbaşa) */
    suspend fun register(
        name: String,
        email: String,
        password: String,
        userType: String,
        otpCode: String = "",
        instagram: String? = null,
        specialization: String? = null,
        experienceYears: Int? = null,
        bio: String? = null
    ): NetworkResult<String> {
        return try {
            val request = RegisterRequest(
                name = name,
                email = email,
                password = password,
                userType = userType,
                otpCode = otpCode,
                instagram = instagram,
                specialization = specialization,
                experienceYears = experienceYears,
                bio = bio
            )
            val response = apiService.register(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()?.message ?: "Qeydiyyat uğurlu oldu")
            } else {
                val errorBody = response.errorBody()?.string()
                val errorMsg = try {
                    Json.decodeFromString<ErrorResponse>(errorBody ?: "").detail ?: "Qeydiyyat uğursuz oldu"
                } catch (_: Exception) {
                    "Qeydiyyat uğursuz oldu"
                }
                NetworkResult.Error(errorMsg, response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    fun isLoggedIn(): Boolean = tokenManager.isLoggedIn()

    fun getUserType(): String = tokenManager.getUserType()

    fun logout() {
        tokenManager.clearAll()
    }
}
