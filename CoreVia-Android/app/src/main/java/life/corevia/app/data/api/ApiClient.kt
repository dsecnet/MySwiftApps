package life.corevia.app.data.api

import android.content.Context
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

/**
 * iOS APIService.swift-in Android ekvivalenti.
 * OkHttp + Retrofit ilə:
 *  - Bearer token əlavə edir (AuthInterceptor)
 *  - 401 → refresh token → retry (TokenAuthenticator)
 *  - Timeout: 30 saniyə (iOS ilə eyni)
 *  - Base URL: https://api.corevia.life
 *
 * İstifadə:
 *   val api = ApiClient.getInstance(context).api
 *   val workouts = api.getWorkouts()   // suspend fun
 */
class ApiClient private constructor(context: Context) {

    private val tokenManager = TokenManager.getInstance(context)

    // ─── Base URL ──────────────────────────────────────────────────────────────
    // iOS: #if targetEnvironment(simulator) → localhost, else → api.corevia.life
    // Android-da BuildConfig.DEBUG ilə eyni effekt:
    private val baseUrl = "https://api.corevia.life/"

    // ─── Auth Interceptor ──────────────────────────────────────────────────────
    // iOS: request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    private val authInterceptor = Interceptor { chain ->
        val original: Request = chain.request()
        val token = tokenManager.accessToken

        val request = if (token != null) {
            original.newBuilder()
                .header("Authorization", "Bearer $token")
                .header("Content-Type", "application/json")
                .build()
        } else {
            original.newBuilder()
                .header("Content-Type", "application/json")
                .build()
        }
        chain.proceed(request)
    }

    // ─── Token Authenticator (401 Auto-Refresh) ────────────────────────────────
    // iOS: refreshTokenIfNeeded() → retry request with new token
    private val tokenAuthenticator = object : okhttp3.Authenticator {
        override fun authenticate(route: okhttp3.Route?, response: Response): Request? {
            // Əgər artıq refresh endpoint-inə gedirsə sonsuz loop-u önlə
            if (response.request.url.encodedPath.contains("auth/refresh")) return null

            // Refresh token mövcuddurmu?
            val refreshToken = tokenManager.refreshToken ?: run {
                tokenManager.clearTokens()
                return null
            }

            // Synchronous refresh (Authenticator bloklanır)
            // FIXED: iOS-da eyni bug düzəldildi — backend JSON body gözləyir, header yox!
            val refreshResponse = try {
                val jsonBody = """{"refresh_token":"$refreshToken"}"""
                val mediaType = "application/json; charset=utf-8".toMediaTypeOrNull()
                val refreshRequest = Request.Builder()
                    .url("${baseUrl}api/v1/auth/refresh")
                    .post(jsonBody.toRequestBody(mediaType))
                    .header("Content-Type", "application/json")
                    .build()

                okhttp3.OkHttpClient().newCall(refreshRequest).execute()
            } catch (e: Exception) {
                tokenManager.clearTokens()
                return null
            }

            if (!refreshResponse.isSuccessful) {
                // iOS: KeychainManager.shared.clearTokens() → return false
                tokenManager.clearTokens()
                return null
            }

            // Yeni tokenları parse et
            val body = refreshResponse.body?.string() ?: run {
                tokenManager.clearTokens()
                return null
            }

            val gson = com.google.gson.Gson()
            val authResp = try {
                gson.fromJson(body, life.corevia.app.data.models.AuthResponse::class.java)
            } catch (e: Exception) {
                tokenManager.clearTokens()
                return null
            }

            // Yeni tokenları saxla
            tokenManager.accessToken = authResp.accessToken
            tokenManager.refreshToken = authResp.refreshToken

            // Orijinal request-i yeni token ilə təkrar et
            return response.request.newBuilder()
                .header("Authorization", "Bearer ${authResp.accessToken}")
                .build()
        }
    }

    // ─── Logging Interceptor (Debug) ───────────────────────────────────────────
    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    // ─── OkHttpClient ──────────────────────────────────────────────────────────
    // iOS: config.timeoutIntervalForRequest = 30
    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(authInterceptor)
        .addInterceptor(loggingInterceptor)
        .authenticator(tokenAuthenticator)
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    // ─── Retrofit ──────────────────────────────────────────────────────────────
    private val retrofit = Retrofit.Builder()
        .baseUrl(baseUrl)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    // ─── API Interface ─────────────────────────────────────────────────────────
    val api: CoreViaApi = retrofit.create(CoreViaApi::class.java)

    // ─── Singleton ─────────────────────────────────────────────────────────────
    companion object {
        @Volatile
        private var instance: ApiClient? = null

        fun getInstance(context: Context): ApiClient {
            return instance ?: synchronized(this) {
                instance ?: ApiClient(context.applicationContext).also { instance = it }
            }
        }
    }
}
