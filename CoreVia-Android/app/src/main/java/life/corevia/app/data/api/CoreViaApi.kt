package life.corevia.app.data.api

import life.corevia.app.data.models.*
import okhttp3.MultipartBody
import retrofit2.http.*

/**
 * iOS APIService.swift-in Android ekvivalenti.
 * Bütün endpoint-lər burada Retrofit annotasiyaları ilə təyin edilir.
 *
 * iOS-da: APIService.shared.request(endpoint:method:body:)
 * Android-da: ApiClient.api.login(request) — suspend fun
 */
interface CoreViaApi {

    // ─── Auth ──────────────────────────────────────────────────────────────────

    // iOS: POST /api/v1/auth/login → Step 1: OTP göndərilir (200 = OK)
    @POST("api/v1/auth/login")
    suspend fun login(@Body request: LoginRequest): okhttp3.ResponseBody

    // iOS: POST /api/v1/auth/login-verify → Step 2: OTP doğrulama + token alınır
    @POST("api/v1/auth/login-verify")
    suspend fun loginVerify(@Body request: LoginVerifyRequest): AuthResponse

    // iOS: POST /api/v1/auth/register
    @POST("api/v1/auth/register")
    suspend fun register(@Body request: RegisterRequest): AuthResponse

    // iOS: POST /api/v1/auth/refresh  (Authorization: Bearer <refresh_token>)
    @POST("api/v1/auth/refresh")
    suspend fun refreshToken(@Header("Authorization") bearerRefresh: String): AuthResponse

    // ─── User ──────────────────────────────────────────────────────────────────

    // iOS: GET /api/v1/users/me
    @GET("api/v1/users/me")
    suspend fun getMe(): UserResponse

    // ─── Workouts ─────────────────────────────────────────────────────────────

    // iOS: GET /api/v1/workouts/
    @GET("api/v1/workouts/")
    suspend fun getWorkouts(): List<Workout>

    // iOS: POST /api/v1/workouts/
    @POST("api/v1/workouts/")
    suspend fun createWorkout(@Body request: WorkoutCreateRequest): Workout

    // iOS: PUT /api/v1/workouts/{id}
    @PUT("api/v1/workouts/{id}")
    suspend fun updateWorkout(
        @Path("id") id: String,
        @Body request: WorkoutUpdateRequest
    ): Workout

    // iOS: DELETE /api/v1/workouts/{id}
    @DELETE("api/v1/workouts/{id}")
    suspend fun deleteWorkout(@Path("id") id: String)

    // ─── Food / Meal ───────────────────────────────────────────────────────────

    // iOS: GET /api/v1/meal-plans/
    @GET("api/v1/meal-plans/")
    suspend fun getFoodEntries(): List<FoodEntry>

    // iOS: POST /api/v1/meal-plans/
    @POST("api/v1/meal-plans/")
    suspend fun createFoodEntry(@Body request: FoodEntryCreateRequest): FoodEntry

    // iOS: DELETE /api/v1/meal-plans/{id}
    @DELETE("api/v1/meal-plans/{id}")
    suspend fun deleteFoodEntry(@Path("id") id: String)

    // ─── Training Plans ───────────────────────────────────────────────────────

    // iOS: GET /api/v1/training-plans/
    @GET("api/v1/training-plans/")
    suspend fun getTrainingPlans(): List<TrainingPlan>

    // iOS: POST /api/v1/training-plans/
    @POST("api/v1/training-plans/")
    suspend fun createTrainingPlan(@Body request: TrainingPlan): TrainingPlan

    // ─── Image Upload (Multipart) ─────────────────────────────────────────────

    // iOS: uploadImage(endpoint:imageData:) — Multipart POST
    @Multipart
    @POST("api/v1/users/me/profile-image")
    suspend fun uploadProfileImage(@Part file: MultipartBody.Part): UserResponse

    // iOS: uploadImageWithFields — Məşq analizı üçün multipart
    @Multipart
    @POST("api/v1/food/analyze-image")
    suspend fun analyzeFoodImage(@Part file: MultipartBody.Part): FoodEntry
}
