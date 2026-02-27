package life.corevia.app.data.remote

import life.corevia.app.data.model.AnalyticsDashboardResponse
import life.corevia.app.data.model.CreateCommentRequest
import life.corevia.app.data.model.CreatePostRequest
import life.corevia.app.data.model.CreateReviewRequest
import life.corevia.app.data.model.MarketplaceProduct
import life.corevia.app.data.model.PostComment
import life.corevia.app.data.model.ProductReview
import life.corevia.app.data.model.ProductsResponse
import life.corevia.app.data.model.SocialPost
import life.corevia.app.data.model.FeedResponse
import life.corevia.app.data.model.Workout
import life.corevia.app.data.model.WorkoutCreateRequest
import life.corevia.app.data.model.LiveSession
import life.corevia.app.data.model.CreateSessionRequest
import life.corevia.app.data.model.CreateProductRequest
import life.corevia.app.data.model.ChatConversation
import life.corevia.app.data.model.ChatMessage
import life.corevia.app.data.model.ChatMessageCreate
import life.corevia.app.data.model.ContentCreateRequest
import life.corevia.app.data.model.ContentResponse
import life.corevia.app.data.model.DailyFoodStats
import life.corevia.app.data.model.DailySurveyRequest
import life.corevia.app.data.model.DailySurveyResponse
import life.corevia.app.data.model.FoodCreateRequest
import life.corevia.app.data.model.FoodEntry
import life.corevia.app.data.model.LoginRequest
import life.corevia.app.data.model.LoginVerifyRequest
import life.corevia.app.data.model.RegisterOTPRequest
import life.corevia.app.data.model.RegisterRequest
import life.corevia.app.data.model.MealPlan
import life.corevia.app.data.model.MealPlanCreateRequest
import life.corevia.app.data.model.MessageLimitResponse
import life.corevia.app.data.model.NewsCategoriesResponse
import life.corevia.app.data.model.NewsResponse
import life.corevia.app.data.model.OTPResponse
import life.corevia.app.data.model.OnboardingCompleteRequest
import life.corevia.app.data.model.OnboardingOptionsResponse
import life.corevia.app.data.model.OnboardingStatusResponse
import life.corevia.app.data.model.RouteCreateRequest
import life.corevia.app.data.model.RouteResponse
import life.corevia.app.data.model.RouteStatsResponse
import life.corevia.app.data.model.TodaySurveyStatus
import life.corevia.app.data.model.TokenResponse
import life.corevia.app.data.model.TrainerDashboardStats
import life.corevia.app.data.model.TrainerResponse
import life.corevia.app.data.model.TrainingPlan
import life.corevia.app.data.model.TrainingPlanCreateRequest
import life.corevia.app.data.model.TrainingPlanUpdateRequest
import life.corevia.app.data.model.UserProfile
import life.corevia.app.data.model.UserResponse
import life.corevia.app.data.model.UserUpdateRequest
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.PUT
import retrofit2.http.Path
import retrofit2.http.Query

interface ApiService {

    // ── Auth ─────────────────────────────────────────────────

    @POST("/api/v1/auth/login")
    suspend fun login(@Body request: LoginRequest): Response<OTPResponse>

    @POST("/api/v1/auth/login-verify")
    suspend fun loginVerify(@Body request: LoginVerifyRequest): Response<TokenResponse>

    @POST("/api/v1/auth/register-request")
    suspend fun registerRequest(@Body request: RegisterOTPRequest): Response<OTPResponse>

    @POST("/api/v1/auth/register")
    suspend fun register(@Body request: RegisterRequest): Response<OTPResponse>

    // ── User / Profile ──────────────────────────────────────

    @GET("/api/v1/auth/me")
    suspend fun getCurrentUser(): Response<UserProfile>

    @PUT("/api/v1/users/profile")
    suspend fun updateProfile(@Body request: UserUpdateRequest): Response<UserProfile>

    // ── Routes ───────────────────────────────────────────────

    @GET("/api/v1/routes/")
    suspend fun getRoutes(): Response<List<RouteResponse>>

    @GET("/api/v1/routes/stats")
    suspend fun getRouteStats(@Query("days") days: Int = 7): Response<RouteStatsResponse>

    @POST("/api/v1/routes/")
    suspend fun createRoute(@Body request: RouteCreateRequest): Response<RouteResponse>

    @DELETE("/api/v1/routes/{id}")
    suspend fun deleteRoute(@Path("id") id: String): Response<Unit>

    // ── Workouts ─────────────────────────────────────────────

    @GET("/api/v1/workouts/")
    suspend fun getWorkouts(): Response<List<Workout>>

    @POST("/api/v1/workouts/")
    suspend fun createWorkout(@Body request: WorkoutCreateRequest): Response<Workout>

    @PUT("/api/v1/workouts/{id}")
    suspend fun updateWorkout(@Path("id") id: String, @Body request: WorkoutCreateRequest): Response<Workout>

    @DELETE("/api/v1/workouts/{id}")
    suspend fun deleteWorkout(@Path("id") id: String): Response<Unit>

    @retrofit2.http.PATCH("/api/v1/workouts/{id}/toggle")
    suspend fun toggleWorkout(@Path("id") id: String): Response<Workout>

    // ── Food ─────────────────────────────────────────────────

    @GET("/api/v1/food/")
    suspend fun getFoodEntries(): Response<List<FoodEntry>>

    @GET("/api/v1/food/daily")
    suspend fun getDailyFoodStats(): Response<DailyFoodStats>

    @POST("/api/v1/food/")
    suspend fun addFoodEntry(@Body request: FoodCreateRequest): Response<FoodEntry>

    @PUT("/api/v1/food/{id}")
    suspend fun updateFoodEntry(
        @Path("id") id: String,
        @Body request: FoodCreateRequest
    ): Response<FoodEntry>

    @DELETE("/api/v1/food/{id}")
    suspend fun deleteFoodEntry(@Path("id") id: String): Response<Unit>

    // ── Chat ─────────────────────────────────────────────────

    @GET("/api/v1/chat/conversations")
    suspend fun getConversations(): Response<List<ChatConversation>>

    @GET("/api/v1/chat/history/{userId}")
    suspend fun getChatHistory(@Path("userId") userId: String): Response<List<ChatMessage>>

    @POST("/api/v1/chat/send")
    suspend fun sendMessage(@Body request: ChatMessageCreate): Response<ChatMessage>

    @GET("/api/v1/chat/limit")
    suspend fun getMessageLimit(): Response<MessageLimitResponse>

    // ── Meal Plans ─────────────────────────────────────────────

    @GET("/api/v1/plans/meal")
    suspend fun getMealPlans(): Response<List<MealPlan>>

    @GET("/api/v1/plans/meal/{id}")
    suspend fun getMealPlan(@Path("id") id: String): Response<MealPlan>

    @POST("/api/v1/plans/meal")
    suspend fun createMealPlan(@Body request: MealPlanCreateRequest): Response<MealPlan>

    @PUT("/api/v1/plans/meal/{id}")
    suspend fun updateMealPlan(
        @Path("id") id: String,
        @Body request: MealPlanCreateRequest
    ): Response<MealPlan>

    @DELETE("/api/v1/plans/meal/{id}")
    suspend fun deleteMealPlan(@Path("id") id: String): Response<Unit>

    // ── Daily Survey ─────────────────────────────────────────

    @POST("/api/v1/survey/daily")
    suspend fun submitDailySurvey(@Body request: DailySurveyRequest): Response<DailySurveyResponse>

    @GET("/api/v1/survey/daily/today")
    suspend fun getTodaySurveyStatus(): Response<TodaySurveyStatus>

    // ── Content ──────────────────────────────────────────────

    @GET("/api/v1/content/trainer/{trainerId}")
    suspend fun getTrainerContent(@Path("trainerId") trainerId: String): Response<List<ContentResponse>>

    @GET("/api/v1/content/my")
    suspend fun getMyContent(): Response<List<ContentResponse>>

    @POST("/api/v1/content/")
    suspend fun createContent(@Body request: ContentCreateRequest): Response<ContentResponse>

    @DELETE("/api/v1/content/{id}")
    suspend fun deleteContent(@Path("id") id: String): Response<Unit>

    // ── News ─────────────────────────────────────────────────

    @GET("/api/v1/news/")
    suspend fun getNews(
        @Query("category") category: String? = null,
        @Query("limit") limit: Int = 20,
        @Query("offset") offset: Int = 0
    ): Response<NewsResponse>

    @GET("/api/v1/news/categories")
    suspend fun getNewsCategories(): Response<NewsCategoriesResponse>

    // ── Onboarding ───────────────────────────────────────────

    @GET("/api/v1/onboarding/options")
    suspend fun getOnboardingOptions(): Response<OnboardingOptionsResponse>

    @GET("/api/v1/onboarding/status")
    suspend fun getOnboardingStatus(): Response<OnboardingStatusResponse>

    @POST("/api/v1/onboarding/complete")
    suspend fun completeOnboarding(@Body request: OnboardingCompleteRequest): Response<OnboardingStatusResponse>

    // ── Trainers ─────────────────────────────────────────────

    @GET("/api/v1/users/trainers")
    suspend fun getTrainers(): Response<List<TrainerResponse>>

    @GET("/api/v1/users/trainer/{trainerId}")
    suspend fun getTrainer(@Path("trainerId") trainerId: String): Response<TrainerResponse>

    @POST("/api/v1/users/assign-trainer/{trainerId}")
    suspend fun assignTrainer(@Path("trainerId") trainerId: String): Response<UserResponse>

    @DELETE("/api/v1/users/unassign-trainer")
    suspend fun unassignTrainer(): Response<UserResponse>

    @GET("/api/v1/users/my-students")
    suspend fun getMyStudents(): Response<List<UserResponse>>

    // ── Trainer Dashboard ────────────────────────────────────

    @GET("/api/v1/trainer/stats")
    suspend fun getTrainerStats(): Response<TrainerDashboardStats>

    // ── Training Plans ───────────────────────────────────────

    @GET("/api/v1/plans/training")
    suspend fun getTrainingPlans(): Response<List<TrainingPlan>>

    @GET("/api/v1/plans/training/{id}")
    suspend fun getTrainingPlan(@Path("id") id: String): Response<TrainingPlan>

    @POST("/api/v1/plans/training")
    suspend fun createTrainingPlan(@Body request: TrainingPlanCreateRequest): Response<TrainingPlan>

    @PUT("/api/v1/plans/training/{id}")
    suspend fun updateTrainingPlan(
        @Path("id") id: String,
        @Body request: TrainingPlanUpdateRequest
    ): Response<TrainingPlan>

    @DELETE("/api/v1/plans/training/{id}")
    suspend fun deleteTrainingPlan(@Path("id") id: String): Response<Unit>

    @PUT("/api/v1/plans/training/{id}/complete")
    suspend fun completeTrainingPlan(@Path("id") id: String): Response<TrainingPlan>

    // ── Analytics ───────────────────────────────────────────

    @GET("/api/v1/analytics/dashboard")
    suspend fun getAnalyticsDashboard(): Response<AnalyticsDashboardResponse>

    // ── Social Feed ─────────────────────────────────────────

    @GET("/api/v1/social/feed")
    suspend fun getSocialFeed(
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 20
    ): Response<FeedResponse>

    @POST("/api/v1/social/posts")
    suspend fun createPost(@Body request: CreatePostRequest): Response<SocialPost>

    @POST("/api/v1/social/posts/{id}/like")
    suspend fun togglePostLike(@Path("id") postId: String): Response<SocialPost>

    @DELETE("/api/v1/social/posts/{id}")
    suspend fun deletePost(@Path("id") postId: String): Response<Unit>

    @GET("/api/v1/social/posts/{id}/comments")
    suspend fun getPostComments(@Path("id") postId: String): Response<List<PostComment>>

    @POST("/api/v1/social/posts/{id}/comments")
    suspend fun addPostComment(
        @Path("id") postId: String,
        @Body request: CreateCommentRequest
    ): Response<PostComment>

    @DELETE("/api/v1/social/posts/{postId}/comments/{commentId}")
    suspend fun deletePostComment(
        @Path("postId") postId: String,
        @Path("commentId") commentId: String
    ): Response<Unit>

    // ── Marketplace ─────────────────────────────────────────

    @GET("/api/v1/marketplace/products")
    suspend fun getMarketplaceProducts(
        @Query("product_type") productType: String? = null,
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 20
    ): Response<ProductsResponse>

    @GET("/api/v1/marketplace/products/{id}")
    suspend fun getMarketplaceProduct(@Path("id") productId: String): Response<MarketplaceProduct>

    @GET("/api/v1/marketplace/products/{id}/reviews")
    suspend fun getProductReviews(@Path("id") productId: String): Response<List<ProductReview>>

    @POST("/api/v1/marketplace/products/{id}/reviews")
    suspend fun createProductReview(
        @Path("id") productId: String,
        @Body request: CreateReviewRequest
    ): Response<ProductReview>

    // ── Live Sessions ──────────────────────────────────────────

    @GET("/api/v1/live-sessions")
    suspend fun getLiveSessions(@Query("status") status: String? = null): Response<List<LiveSession>>

    @GET("/api/v1/live-sessions/{id}")
    suspend fun getLiveSession(@Path("id") id: String): Response<LiveSession>

    @POST("/api/v1/live-sessions")
    suspend fun createLiveSession(@Body request: CreateSessionRequest): Response<LiveSession>

    @DELETE("/api/v1/live-sessions/{id}")
    suspend fun deleteLiveSession(@Path("id") id: String): Response<Unit>

    @POST("/api/v1/live-sessions/{id}/join")
    suspend fun joinLiveSession(@Path("id") id: String): Response<LiveSession>

    @GET("/api/v1/live-sessions/my")
    suspend fun getMyLiveSessions(): Response<List<LiveSession>>

    // ── Premium ────────────────────────────────────────────────

    @POST("/api/v1/premium/activate")
    suspend fun activatePremium(): Response<Unit>

    // ── Marketplace (Trainer) ───────────────────────────────

    @POST("/api/v1/marketplace/products")
    suspend fun createMarketplaceProduct(@Body request: CreateProductRequest): Response<MarketplaceProduct>

    @GET("/api/v1/marketplace/my-products")
    suspend fun getMyMarketplaceProducts(): Response<List<MarketplaceProduct>>

    @DELETE("/api/v1/marketplace/products/{id}")
    suspend fun deleteMarketplaceProduct(@Path("id") productId: String): Response<Unit>
}
