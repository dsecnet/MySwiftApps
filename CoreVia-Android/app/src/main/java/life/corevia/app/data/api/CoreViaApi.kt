package life.corevia.app.data.api

import life.corevia.app.data.models.*
import okhttp3.MultipartBody
import retrofit2.http.*

/**
 * iOS APIService.swift-in Android ekvivalenti.
 * Bütün endpoint-lər burada Retrofit annotasiyaları ilə təyin edilir.
 * Backend: https://api.corevia.life/
 */
interface CoreViaApi {

    // ═══════════════════════════════════════════════════════════════════════════
    // AUTH
    // ═══════════════════════════════════════════════════════════════════════════

    // Step 1: Login → OTP göndərilir
    @POST("api/v1/auth/login")
    suspend fun login(@Body request: LoginRequest): okhttp3.ResponseBody

    // Step 2: OTP doğrulama + token alınır
    @POST("api/v1/auth/login-verify")
    suspend fun loginVerify(@Body request: LoginVerifyRequest): AuthResponse

    // Register Step 1: OTP göndər (iOS kimi yalnız email)
    @POST("api/v1/auth/register-request")
    suspend fun registerRequest(@Body request: RegisterOtpRequest): okhttp3.ResponseBody

    // Register Step 2: OTP ilə qeydiyyat tamamla (201 qaytarır, AuthResponse yoxdur)
    @POST("api/v1/auth/register")
    suspend fun register(@Body request: RegisterVerifyRequest): okhttp3.ResponseBody

    // Token yenilə — JSON body ilə (header yox!)
    @POST("api/v1/auth/refresh")
    suspend fun refreshToken(@Body request: RefreshTokenRequest): AuthResponse

    // Şifrəni unutdum — OTP göndər
    @POST("api/v1/auth/forgot-password")
    suspend fun forgotPassword(@Body request: ForgotPasswordRequest): okhttp3.ResponseBody

    // OTP doğrulama
    @POST("api/v1/auth/verify-otp")
    suspend fun verifyOtp(@Body request: VerifyOtpRequest): okhttp3.ResponseBody

    // Şifrə sıfırlama
    @POST("api/v1/auth/reset-password")
    suspend fun resetPassword(@Body request: ResetPasswordRequest): okhttp3.ResponseBody

    // Premium status yenilənmiş token al
    @POST("api/v1/auth/refresh-claims")
    suspend fun refreshClaims(): AuthResponse

    // Trainer verifikasiya foto yüklə
    @Multipart
    @POST("api/v1/auth/verify-trainer")
    suspend fun verifyTrainer(@Part file: MultipartBody.Part): okhttp3.ResponseBody

    // ═══════════════════════════════════════════════════════════════════════════
    // USERS
    // ═══════════════════════════════════════════════════════════════════════════

    // iOS: /api/v1/auth/me (NOT /api/v1/users/me!)
    @GET("api/v1/auth/me")
    suspend fun getMe(): UserResponse

    @PUT("api/v1/users/profile")
    suspend fun updateProfile(@Body request: ProfileUpdateRequest): UserResponse

    @GET("api/v1/users/my-students")
    suspend fun getMyStudents(): List<UserResponse>

    @GET("api/v1/users/trainers")
    suspend fun getTrainers(): List<UserResponse>

    @GET("api/v1/users/trainer/{trainerId}")
    suspend fun getTrainer(@Path("trainerId") trainerId: String): UserResponse

    @POST("api/v1/users/assign-trainer/{trainerId}")
    suspend fun assignTrainer(@Path("trainerId") trainerId: String): okhttp3.ResponseBody

    @DELETE("api/v1/users/unassign-trainer")
    suspend fun unassignTrainer(): okhttp3.ResponseBody

    @POST("api/v1/users/assign-student/{studentId}")
    suspend fun assignStudent(@Path("studentId") studentId: String): okhttp3.ResponseBody

    // ═══════════════════════════════════════════════════════════════════════════
    // WORKOUTS
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/workouts/")
    suspend fun getWorkouts(): List<Workout>

    @POST("api/v1/workouts/")
    suspend fun createWorkout(@Body request: WorkoutCreateRequest): Workout

    @PUT("api/v1/workouts/{id}")
    suspend fun updateWorkout(@Path("id") id: String, @Body request: WorkoutUpdateRequest): Workout

    @DELETE("api/v1/workouts/{id}")
    suspend fun deleteWorkout(@Path("id") id: String)

    @GET("api/v1/workouts/today")
    suspend fun getTodayWorkouts(): List<Workout>

    @GET("api/v1/workouts/stats")
    suspend fun getWorkoutStats(): WorkoutStatsResponse

    @PATCH("api/v1/workouts/{id}/toggle")
    suspend fun toggleWorkout(@Path("id") id: String): Workout

    // ═══════════════════════════════════════════════════════════════════════════
    // FOOD ENTRIES
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/food/")
    suspend fun getFoodEntries(): List<FoodEntry>

    @POST("api/v1/food/")
    suspend fun createFoodEntry(@Body request: FoodEntryCreateRequest): FoodEntry

    @PUT("api/v1/food/{id}")
    suspend fun updateFoodEntry(@Path("id") id: String, @Body request: FoodEntryCreateRequest): FoodEntry

    @DELETE("api/v1/food/{id}")
    suspend fun deleteFoodEntry(@Path("id") id: String)

    @GET("api/v1/food/today")
    suspend fun getTodayFoodEntries(): List<FoodEntry>

    @GET("api/v1/food/daily-summary")
    suspend fun getDailySummary(): DailyNutritionSummary

    @Multipart
    @POST("api/v1/food/analyze")
    suspend fun analyzeFoodImage(@Part file: MultipartBody.Part): FoodAnalysisResult

    // ═══════════════════════════════════════════════════════════════════════════
    // TRAINING PLANS
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/plans/training")
    suspend fun getTrainingPlans(): List<TrainingPlan>

    @GET("api/v1/plans/training/{id}")
    suspend fun getTrainingPlan(@Path("id") id: String): TrainingPlan

    @POST("api/v1/plans/training")
    suspend fun createTrainingPlan(@Body request: TrainingPlanCreateRequest): TrainingPlan

    @PUT("api/v1/plans/training/{id}/complete")
    suspend fun completeTrainingPlan(@Path("id") id: String): TrainingPlan

    @DELETE("api/v1/plans/training/{id}")
    suspend fun deleteTrainingPlan(@Path("id") id: String)

    // ═══════════════════════════════════════════════════════════════════════════
    // MEAL PLANS
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/plans/meal")
    suspend fun getMealPlans(): List<MealPlan>

    @GET("api/v1/plans/meal/{id}")
    suspend fun getMealPlan(@Path("id") id: String): MealPlan

    @POST("api/v1/plans/meal")
    suspend fun createMealPlan(@Body request: MealPlanCreateRequest): MealPlan

    @PUT("api/v1/plans/meal/{id}/complete")
    suspend fun completeMealPlan(@Path("id") id: String): MealPlan

    @DELETE("api/v1/plans/meal/{id}")
    suspend fun deleteMealPlan(@Path("id") id: String)

    // ═══════════════════════════════════════════════════════════════════════════
    // CHAT
    // ═══════════════════════════════════════════════════════════════════════════

    @POST("api/v1/chat/send")
    suspend fun sendMessage(@Body request: SendMessageRequest): ChatMessage

    @GET("api/v1/chat/history/{userId}")
    suspend fun getChatHistory(@Path("userId") userId: String): List<ChatMessage>

    @GET("api/v1/chat/conversations")
    suspend fun getConversations(): List<Conversation>

    @GET("api/v1/chat/limit")
    suspend fun getMessageLimit(): MessageLimitResponse

    // ═══════════════════════════════════════════════════════════════════════════
    // NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/notifications/")
    suspend fun getNotifications(): List<AppNotification>

    @GET("api/v1/notifications/unread-count")
    suspend fun getUnreadCount(): UnreadCountResponse

    @POST("api/v1/notifications/mark-read")
    suspend fun markNotificationsRead(@Body request: MarkReadRequest): okhttp3.ResponseBody

    @POST("api/v1/notifications/mark-all-read")
    suspend fun markAllNotificationsRead(): okhttp3.ResponseBody

    @DELETE("api/v1/notifications/{id}")
    suspend fun deleteNotification(@Path("id") id: String)

    @POST("api/v1/notifications/device-token")
    suspend fun registerDeviceToken(@Body request: DeviceTokenRequest): okhttp3.ResponseBody

    @HTTP(method = "DELETE", path = "api/v1/notifications/device-token", hasBody = true)
    suspend fun unregisterDeviceToken(@Body request: DeviceTokenRequest): okhttp3.ResponseBody

    @POST("api/v1/notifications/send")
    suspend fun sendNotification(@Body request: SendNotificationRequest): okhttp3.ResponseBody

    // ═══════════════════════════════════════════════════════════════════════════
    // ANALYTICS
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/analytics/daily/{date}")
    suspend fun getDailyAnalytics(@Path("date") date: String): DailyStats

    @GET("api/v1/analytics/weekly")
    suspend fun getWeeklyAnalytics(): WeeklyStats

    @GET("api/v1/analytics/dashboard")
    suspend fun getAnalyticsDashboard(): AnalyticsDashboard

    @POST("api/v1/analytics/measurements")
    suspend fun createMeasurement(@Body request: BodyMeasurementCreateRequest): BodyMeasurement

    @GET("api/v1/analytics/measurements")
    suspend fun getMeasurements(): List<BodyMeasurement>

    @DELETE("api/v1/analytics/measurements/{id}")
    suspend fun deleteMeasurement(@Path("id") id: String)

    // ═══════════════════════════════════════════════════════════════════════════
    // SOCIAL
    // ═══════════════════════════════════════════════════════════════════════════

    @POST("api/v1/social/posts")
    suspend fun createPost(@Body request: CreatePostRequest): SocialPost

    @GET("api/v1/social/feed")
    suspend fun getSocialFeed(): List<SocialPost>

    @GET("api/v1/social/posts/{postId}")
    suspend fun getPost(@Path("postId") postId: String): SocialPost

    @DELETE("api/v1/social/posts/{postId}")
    suspend fun deletePost(@Path("postId") postId: String)

    @POST("api/v1/social/posts/{postId}/like")
    suspend fun likePost(@Path("postId") postId: String): okhttp3.ResponseBody

    @DELETE("api/v1/social/posts/{postId}/like")
    suspend fun unlikePost(@Path("postId") postId: String)

    @POST("api/v1/social/posts/{postId}/comments")
    suspend fun createComment(@Path("postId") postId: String, @Body request: CreateCommentRequest): SocialComment

    @GET("api/v1/social/posts/{postId}/comments")
    suspend fun getComments(@Path("postId") postId: String): List<SocialComment>

    @DELETE("api/v1/social/comments/{commentId}")
    suspend fun deleteComment(@Path("commentId") commentId: String)

    @POST("api/v1/social/follow/{userId}")
    suspend fun followUser(@Path("userId") userId: String): okhttp3.ResponseBody

    @DELETE("api/v1/social/follow/{userId}")
    suspend fun unfollowUser(@Path("userId") userId: String)

    @GET("api/v1/social/profile/{userId}")
    suspend fun getUserProfile(@Path("userId") userId: String): UserProfileSummary

    @GET("api/v1/social/achievements")
    suspend fun getAchievements(): List<Achievement>

    @Multipart
    @POST("api/v1/social/posts/{postId}/image")
    suspend fun uploadPostImage(@Path("postId") postId: String, @Part file: MultipartBody.Part): SocialPost

    // ═══════════════════════════════════════════════════════════════════════════
    // PREMIUM
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/premium/status")
    suspend fun getPremiumStatus(): PremiumStatus

    @GET("api/v1/premium/plans")
    suspend fun getPremiumPlans(): List<PremiumPlan>

    @POST("api/v1/premium/subscribe")
    suspend fun subscribe(@Body request: SubscribeRequest): okhttp3.ResponseBody

    @POST("api/v1/premium/activate")
    suspend fun activatePremium(): okhttp3.ResponseBody

    @POST("api/v1/premium/cancel")
    suspend fun cancelSubscription(): okhttp3.ResponseBody

    @POST("api/v1/premium/restore")
    suspend fun restoreSubscription(): okhttp3.ResponseBody

    @GET("api/v1/premium/history")
    suspend fun getSubscriptionHistory(): List<SubscriptionHistory>

    // ═══════════════════════════════════════════════════════════════════════════
    // REVIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    @POST("api/v1/trainer/{trainerId}/reviews")
    suspend fun createReview(@Path("trainerId") trainerId: String, @Body request: CreateReviewRequest): TrainerReview

    @GET("api/v1/trainer/{trainerId}/reviews")
    suspend fun getTrainerReviews(@Path("trainerId") trainerId: String): List<TrainerReview>

    @GET("api/v1/trainer/{trainerId}/reviews/summary")
    suspend fun getReviewSummary(@Path("trainerId") trainerId: String): ReviewSummary

    @DELETE("api/v1/trainer/{trainerId}/reviews")
    suspend fun deleteReview(@Path("trainerId") trainerId: String)

    // ═══════════════════════════════════════════════════════════════════════════
    // TRAINER STATS
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/trainer/stats")
    suspend fun getTrainerStats(): TrainerStatsResponse

    // ═══════════════════════════════════════════════════════════════════════════
    // CONTENT (iOS: TrainerContentView + ContentManager)
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/content/my")
    suspend fun getMyContent(): List<ContentResponse>

    @GET("api/v1/content/trainer/{trainerId}")
    suspend fun getTrainerContent(@Path("trainerId") trainerId: String): List<ContentResponse>

    @POST("api/v1/content/")
    suspend fun createContent(@Body request: ContentCreateRequest): ContentResponse

    @DELETE("api/v1/content/{contentId}")
    suspend fun deleteContent(@Path("contentId") contentId: String)

    // ═══════════════════════════════════════════════════════════════════════════
    // FILE UPLOADS
    // ═══════════════════════════════════════════════════════════════════════════

    @Multipart
    @POST("api/v1/uploads/profile-image")
    suspend fun uploadProfileImage(@Part file: MultipartBody.Part): UserResponse

    @DELETE("api/v1/uploads/profile-image")
    suspend fun deleteProfileImage(): okhttp3.ResponseBody

    @Multipart
    @POST("api/v1/uploads/food-image/{entryId}")
    suspend fun uploadFoodImage(@Path("entryId") entryId: String, @Part file: MultipartBody.Part): FoodEntry

    @Multipart
    @POST("api/v1/uploads/certificate")
    suspend fun uploadCertificate(@Part file: MultipartBody.Part): okhttp3.ResponseBody

    // ═══════════════════════════════════════════════════════════════════════════
    // LIVE SESSIONS
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/live-sessions")
    suspend fun getLiveSessions(): List<LiveSession>

    @GET("api/v1/live-sessions/{sessionId}")
    suspend fun getLiveSession(@Path("sessionId") sessionId: String): LiveSession

    @POST("api/v1/live-sessions")
    suspend fun createLiveSession(@Body request: CreateLiveSessionRequest): LiveSession

    @POST("api/v1/live-sessions/{sessionId}/join")
    suspend fun joinLiveSession(@Path("sessionId") sessionId: String): LiveSession

    @POST("api/v1/live-sessions/{sessionId}/leave")
    suspend fun leaveLiveSession(@Path("sessionId") sessionId: String): LiveSession

    // ═══════════════════════════════════════════════════════════════════════════
    // MARKETPLACE
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/marketplace/products")
    suspend fun getProducts(): List<Product>

    @GET("api/v1/marketplace/products/{productId}")
    suspend fun getProduct(@Path("productId") productId: String): Product

    @POST("api/v1/marketplace/orders")
    suspend fun createOrder(@Body request: CreateOrderRequest): Order

    @GET("api/v1/marketplace/orders")
    suspend fun getOrders(): List<Order>

    // ═══════════════════════════════════════════════════════════════════════════
    // NEWS
    // ═══════════════════════════════════════════════════════════════════════════

    @GET("api/v1/news")
    suspend fun getNews(): List<NewsArticle>

    @GET("api/v1/news/{articleId}")
    suspend fun getNewsArticle(@Path("articleId") articleId: String): NewsArticle
}
