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

    // iOS: POST /api/v1/auth/refresh — JSON body ilə (header yox!)
    // FIXED: iOS-da eyni bug düzəldildi — backend JSON body gözləyir
    @POST("api/v1/auth/refresh")
    suspend fun refreshToken(@Body request: RefreshTokenRequest): AuthResponse

    // ─── User ──────────────────────────────────────────────────────────────────

    // iOS: GET /api/v1/users/me
    @GET("api/v1/users/me")
    suspend fun getMe(): UserResponse

    // iOS: PUT /api/v1/users/profile
    @PUT("api/v1/users/profile")
    suspend fun updateProfile(@Body request: ProfileUpdateRequest): UserResponse

    // iOS: GET /api/v1/users/my-students (Trainer only)
    @GET("api/v1/users/my-students")
    suspend fun getMyStudents(): List<UserResponse>

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

    // ─── Food Entries ─────────────────────────────────────────────────────────
    // FIXED: Endpoint-lər düzəldildi — /api/v1/food/ (meal-plans yox!)

    // iOS: GET /api/v1/food/
    @GET("api/v1/food/")
    suspend fun getFoodEntries(): List<FoodEntry>

    // iOS: POST /api/v1/food/
    @POST("api/v1/food/")
    suspend fun createFoodEntry(@Body request: FoodEntryCreateRequest): FoodEntry

    // iOS: PUT /api/v1/food/{id}
    @PUT("api/v1/food/{id}")
    suspend fun updateFoodEntry(
        @Path("id") id: String,
        @Body request: FoodEntryCreateRequest
    ): FoodEntry

    // iOS: DELETE /api/v1/food/{id}
    @DELETE("api/v1/food/{id}")
    suspend fun deleteFoodEntry(@Path("id") id: String)

    // ─── Training Plans ───────────────────────────────────────────────────────
    // FIXED: Endpoint-lər düzəldildi — /api/v1/plans/training (training-plans yox!)

    // iOS: GET /api/v1/plans/training
    @GET("api/v1/plans/training")
    suspend fun getTrainingPlans(): List<TrainingPlan>

    // iOS: GET /api/v1/plans/training/{id}
    @GET("api/v1/plans/training/{id}")
    suspend fun getTrainingPlan(@Path("id") id: String): TrainingPlan

    // iOS: POST /api/v1/plans/training
    @POST("api/v1/plans/training")
    suspend fun createTrainingPlan(@Body request: TrainingPlanCreateRequest): TrainingPlan

    // iOS: PUT /api/v1/plans/training/{id}/complete
    @PUT("api/v1/plans/training/{id}/complete")
    suspend fun completeTrainingPlan(@Path("id") id: String): TrainingPlan

    // iOS: DELETE /api/v1/plans/training/{id}
    @DELETE("api/v1/plans/training/{id}")
    suspend fun deleteTrainingPlan(@Path("id") id: String)

    // ─── Meal Plans ──────────────────────────────────────────────────────────
    // YENI: /api/v1/plans/meal

    // iOS: GET /api/v1/plans/meal
    @GET("api/v1/plans/meal")
    suspend fun getMealPlans(): List<MealPlan>

    // iOS: GET /api/v1/plans/meal/{id}
    @GET("api/v1/plans/meal/{id}")
    suspend fun getMealPlan(@Path("id") id: String): MealPlan

    // iOS: POST /api/v1/plans/meal
    @POST("api/v1/plans/meal")
    suspend fun createMealPlan(@Body request: MealPlanCreateRequest): MealPlan

    // iOS: PUT /api/v1/plans/meal/{id}/complete
    @PUT("api/v1/plans/meal/{id}/complete")
    suspend fun completeMealPlan(@Path("id") id: String): MealPlan

    // iOS: DELETE /api/v1/plans/meal/{id}
    @DELETE("api/v1/plans/meal/{id}")
    suspend fun deleteMealPlan(@Path("id") id: String)

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
