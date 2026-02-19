package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.api.TokenManager
import life.corevia.app.data.models.*

/**
 * iOS AuthenticationManager.swift-in Android Repository ekvivalenti.
 *
 * 2-step login axını:
 *  - sendLoginOtp(email, password) → POST /api/v1/auth/login → OTP göndərildi
 *  - verifyLoginOtp(email, otp)    → POST /api/v1/auth/login-verify → token alınır
 *
 * 2-step register axını:
 *  - sendRegisterOtp(name, email, password, userType) → POST /api/v1/auth/register-request → OTP göndərildi
 *  - verifyRegisterOtp(name, email, password, userType, otp) → POST /api/v1/auth/register → token alınır
 *
 * 3-step forgot password:
 *  - sendForgotPasswordOtp(email) → POST /api/v1/auth/forgot-password → OTP göndərildi
 *  - verifyForgotPasswordOtp(email, otp) → POST /api/v1/auth/verify-otp → doğrulandı
 *  - resetPassword(email, otp, newPassword) → POST /api/v1/auth/reset-password → şifrə dəyişdi
 */
class AuthRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api
    private val tokenManager = TokenManager.getInstance(context)

    // ═══════════════════════════════════════════════════════════════════════════
    // LOGIN (2-step)
    // ═══════════════════════════════════════════════════════════════════════════

    suspend fun sendLoginOtp(email: String, password: String): Result<Unit> {
        return try {
            val cleanEmail = email.trim().lowercase()
            android.util.Log.d("AUTH", "Login OTP request → email=$cleanEmail")
            api.login(LoginRequest(cleanEmail, password))
            android.util.Log.d("AUTH", "Login OTP request → SUCCESS")
            Result.success(Unit)
        } catch (e: Exception) {
            android.util.Log.e("AUTH", "Login OTP request → FAIL: ${e.message}", e)
            Result.failure(Exception(ErrorParser.parseMessage(e)))
        }
    }

    suspend fun verifyLoginOtp(email: String, otpCode: String): Result<UserResponse> {
        return try {
            val cleanEmail = email.trim().lowercase()
            val cleanOtp = otpCode.trim()
            android.util.Log.d("AUTH", "Login verify → email=$cleanEmail otp=$cleanOtp")
            val response = api.loginVerify(LoginVerifyRequest(cleanEmail, cleanOtp))
            tokenManager.accessToken = response.accessToken
            tokenManager.refreshToken = response.refreshToken
            val user = api.getMe()
            android.util.Log.d("AUTH", "Login verify → SUCCESS user=${user.name}")
            Result.success(user)
        } catch (e: Exception) {
            android.util.Log.e("AUTH", "Login verify → FAIL: ${e.message}", e)
            Result.failure(Exception(ErrorParser.parseMessage(e)))
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REGISTER (2-step)
    // ═══════════════════════════════════════════════════════════════════════════

    suspend fun sendRegisterOtp(
        name: String, email: String, password: String, userType: String
    ): Result<Unit> {
        return try {
            val cleanEmail = email.trim().lowercase()
            android.util.Log.d("AUTH", "Register OTP request → email=$cleanEmail")
            // iOS kimi: register-request endpointinə yalnız email göndərilir
            api.registerRequest(RegisterOtpRequest(cleanEmail))
            android.util.Log.d("AUTH", "Register OTP request → SUCCESS (OTP göndərildi)")
            Result.success(Unit)
        } catch (e: Exception) {
            android.util.Log.e("AUTH", "Register OTP request → FAIL: ${e.message}", e)
            Result.failure(Exception(ErrorParser.parseMessage(e)))
        }
    }

    suspend fun verifyRegisterOtp(
        name: String, email: String, password: String, userType: String, otpCode: String
    ): Result<Unit> {
        return try {
            val cleanEmail = email.trim().lowercase()
            val cleanOtp = otpCode.trim()
            android.util.Log.d("AUTH", "Register verify → email=$cleanEmail otp=$cleanOtp userType=$userType name=$name")
            // iOS kimi: register endpoint 201 qaytarır, token yoxdur
            api.register(
                RegisterVerifyRequest(name, cleanEmail, password, userType, cleanOtp)
            )
            android.util.Log.d("AUTH", "Register verify → SUCCESS")
            // Uğurlu — istifadəçi login ekranına yönləndirilir
            Result.success(Unit)
        } catch (e: Exception) {
            android.util.Log.e("AUTH", "Register verify → FAIL: ${e.message}", e)
            Result.failure(Exception(ErrorParser.parseMessage(e)))
        }
    }

    // Köhnə register — geriyə uyğunluq (OTP olmadan birbaşa)
    suspend fun register(
        name: String, email: String, password: String, userType: String
    ): Result<UserResponse> {
        return sendRegisterOtp(name, email, password, userType).fold(
            onSuccess = { Result.success(UserResponse("", name, email, userType, null)) },
            onFailure = { Result.failure(it) }
        )
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FORGOT PASSWORD (3-step)
    // ═══════════════════════════════════════════════════════════════════════════

    suspend fun sendForgotPasswordOtp(email: String): Result<Unit> {
        return try {
            val cleanEmail = email.trim().lowercase()
            api.forgotPassword(ForgotPasswordRequest(cleanEmail))
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(Exception(ErrorParser.parseMessage(e)))
        }
    }

    suspend fun verifyForgotPasswordOtp(email: String, otpCode: String): Result<Unit> {
        return try {
            val cleanEmail = email.trim().lowercase()
            val cleanOtp = otpCode.trim()
            api.verifyOtp(VerifyOtpRequest(cleanEmail, cleanOtp))
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(Exception(ErrorParser.parseMessage(e)))
        }
    }

    suspend fun resetPassword(email: String, otpCode: String, newPassword: String): Result<Unit> {
        return try {
            val cleanEmail = email.trim().lowercase()
            val cleanOtp = otpCode.trim()
            api.resetPassword(ResetPasswordRequest(cleanEmail, cleanOtp, newPassword))
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(Exception(ErrorParser.parseMessage(e)))
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // COMMON
    // ═══════════════════════════════════════════════════════════════════════════

    fun isLoggedIn(): Boolean = tokenManager.isLoggedIn

    fun logout() {
        tokenManager.clearTokens()
        // Clear all repository singletons so they reload fresh on next login
        WorkoutRepository.clearInstance()
        FoodRepository.clearInstance()
        TrainingPlanRepository.clearInstance()
        MealPlanRepository.clearInstance()
        UserRepository.clearInstance()
        ChatRepository.clearInstance()
        NotificationRepository.clearInstance()
        AnalyticsRepository.clearInstance()
        SocialRepository.clearInstance()
        PremiumRepository.clearInstance()
        TrainerRepository.clearInstance()
        LiveSessionRepository.clearInstance()
        MarketplaceRepository.clearInstance()
        NewsRepository.clearInstance()
    }

    suspend fun getCurrentUser(): Result<UserResponse> {
        return try {
            Result.success(api.getMe())
        } catch (e: Exception) {
            Result.failure(e)
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
