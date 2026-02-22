package life.corevia.app.data.repository

import android.content.Context
import android.os.Build
import android.util.Log
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
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
class AuthRepository(private val context: Context) {

    private val api = ApiClient.getInstance(context).api
    private val tokenManager = TokenManager.getInstance(context)

    // ═══════════════════════════════════════════════════════════════════════════
    // LOGIN (2-step)
    // ═══════════════════════════════════════════════════════════════════════════

    suspend fun sendLoginOtp(email: String, password: String, userType: String): Result<Unit> {
        return try {
            val cleanEmail = email.trim().lowercase()
            android.util.Log.d("AUTH", "Login OTP request → email=$cleanEmail userType=$userType")
            api.login(LoginRequest(cleanEmail, password, userType))
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
            // iOS kimi: userType-ı dərhal saxla (app açılanda API gözləmədən istifadə olunur)
            tokenManager.userType = user.userType
            android.util.Log.d("AUTH", "Login verify → SUCCESS user=${user.name} userType=${user.userType}")
            // FCM token-i backend-e qeyd et
            registerFcmToken()
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
        // FCM token-i deaktiv et (logout zamani)
        unregisterFcmToken()
        tokenManager.clearTokens()
        // Clear ApiClient singleton (köhnə token interceptor sıfırlansın)
        ApiClient.clearInstance()
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

    // ─── FCM Token Registration ────────────────────────────────────────────────
    private fun registerFcmToken() {
        try {
            com.google.firebase.messaging.FirebaseMessaging.getInstance().token
                .addOnSuccessListener { token ->
                    Log.d("AUTH", "FCM token alinib: ${token.take(20)}...")
                    @OptIn(DelicateCoroutinesApi::class)
                    GlobalScope.launch(Dispatchers.IO) {
                        try {
                            val notifRepo = NotificationRepository.getInstance(context)
                            val deviceName = "${Build.MANUFACTURER} ${Build.MODEL}"
                            notifRepo.registerDeviceToken(token, deviceName)
                        } catch (e: Exception) {
                            Log.e("AUTH", "FCM token qeyd xetasi: ${e.message}")
                        }
                    }
                }
                .addOnFailureListener { e ->
                    Log.e("AUTH", "FCM token almaq olmadi: ${e.message}")
                }
        } catch (e: Exception) {
            Log.e("AUTH", "Firebase init xetasi (google-services.json olmaya biler): ${e.message}")
        }
    }

    private fun unregisterFcmToken() {
        try {
            com.google.firebase.messaging.FirebaseMessaging.getInstance().token
                .addOnSuccessListener { token ->
                    @OptIn(DelicateCoroutinesApi::class)
                    GlobalScope.launch(Dispatchers.IO) {
                        try {
                            val notifRepo = NotificationRepository.getInstance(context)
                            notifRepo.unregisterDeviceToken(token)
                        } catch (e: Exception) {
                            Log.e("AUTH", "FCM token silme xetasi: ${e.message}")
                        }
                    }
                }
        } catch (e: Exception) {
            Log.e("AUTH", "Firebase token silme xetasi: ${e.message}")
        }
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
