package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.api.TokenManager
import life.corevia.app.data.models.*

/**
 * iOS AuthenticationManager.swift-in Android Repository ekvivalenti.
 *
 * 2-step login axını (iOS LoginView.swift loginAction() + verifyOTPAndLogin() ilə eyni):
 *  - sendLoginOtp(email, password) → POST /api/v1/auth/login → 200 OK (OTP göndərildi)
 *  - verifyLoginOtp(email, otp)    → POST /api/v1/auth/login-verify → token alınır
 *
 * Qayda: ViewModel bu class-ı çağırır, Screen ViewModel-i çağırır.
 * Screen heç vaxt birbaşa ApiClient-ə toxunmur.
 *
 * Result<T> qaytarır — uğur da, xəta da structured şəkildə.
 */
class AuthRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api
    private val tokenManager = TokenManager.getInstance(context)

    /**
     * iOS loginAction() ilə eyni — Step 1:
     * POST /api/v1/auth/login → 200 = OTP göndərildi
     * Uğurda Result.success(Unit), xətada Result.failure(exception)
     */
    suspend fun sendLoginOtp(email: String, password: String): Result<Unit> {
        return try {
            api.login(LoginRequest(email, password))
            Result.success(Unit)
        } catch (e: Exception) {
            val message = parseErrorMessage(e) ?: "Email və ya şifrə səhvdir"
            Result.failure(Exception(message))
        }
    }

    /**
     * iOS verifyOTPAndLogin() ilə eyni — Step 2:
     * POST /api/v1/auth/login-verify + {email, otp_code} → token alınır + user məlumatı
     */
    suspend fun verifyLoginOtp(email: String, otpCode: String): Result<UserResponse> {
        return try {
            val response = api.loginVerify(LoginVerifyRequest(email, otpCode))
            tokenManager.accessToken = response.accessToken
            tokenManager.refreshToken = response.refreshToken
            val user = api.getMe()
            Result.success(user)
        } catch (e: Exception) {
            val message = parseErrorMessage(e) ?: "OTP səhvdir və ya vaxtı keçib"
            Result.failure(Exception(message))
        }
    }

    // iOS: AuthenticationManager.register(name:email:password:userType:)
    suspend fun register(
        name: String,
        email: String,
        password: String,
        userType: String           // "client" | "trainer"
    ): Result<UserResponse> {
        return try {
            val response = api.register(
                RegisterRequest(name, email, password, userType)
            )
            tokenManager.accessToken = response.accessToken
            tokenManager.refreshToken = response.refreshToken
            val user = api.getMe()
            Result.success(user)
        } catch (e: Exception) {
            val message = parseErrorMessage(e) ?: "Qeydiyyat uğursuz oldu"
            Result.failure(Exception(message))
        }
    }

    // iOS: KeychainManager.shared.isLoggedIn
    fun isLoggedIn(): Boolean = tokenManager.isLoggedIn

    // iOS: AuthenticationManager.logout()
    fun logout() {
        tokenManager.clearTokens()
    }

    // iOS: UserProfileManager.shared.currentUser
    suspend fun getCurrentUser(): Result<UserResponse> {
        return try {
            Result.success(api.getMe())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // HTTP xəta mesajını parse et (iOS: errorResponse?["detail"])
    private fun parseErrorMessage(e: Exception): String? {
        return when (e) {
            is retrofit2.HttpException -> {
                try {
                    val errorBody = e.response()?.errorBody()?.string()
                    if (!errorBody.isNullOrBlank()) {
                        val json = org.json.JSONObject(errorBody)
                        json.optString("detail").takeIf { it.isNotBlank() }
                    } else null
                } catch (_: Exception) { null }
            }
            else -> e.message
        }
    }

    companion object {
        @Volatile private var instance: AuthRepository? = null
        fun getInstance(context: Context): AuthRepository =
            instance ?: synchronized(this) {
                instance ?: AuthRepository(context.applicationContext).also { instance = it }
            }
    }
}
