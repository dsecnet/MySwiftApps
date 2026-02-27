package life.corevia.app.di

import android.content.SharedPreferences
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import life.corevia.app.data.local.TokenManager
import life.corevia.app.data.remote.ApiService
import life.corevia.app.data.local.OnDeviceFoodAnalyzer
import life.corevia.app.data.repository.AICalorieRepository
import life.corevia.app.data.repository.AuthRepository
import life.corevia.app.data.repository.ChatRepository
import life.corevia.app.data.repository.ContentRepository
import life.corevia.app.data.repository.FoodImageRepository
import life.corevia.app.data.repository.FoodRepository
import life.corevia.app.data.repository.MealPlanRepository
import life.corevia.app.data.repository.NewsRepository
import life.corevia.app.data.repository.OnboardingRepository
import life.corevia.app.data.repository.ProfileImageRepository
import life.corevia.app.data.repository.RouteRepository
import life.corevia.app.data.repository.SurveyRepository
import life.corevia.app.data.repository.TrainerDashboardRepository
import life.corevia.app.data.repository.TrainerRepository
import life.corevia.app.data.repository.TrainingPlanRepository
import life.corevia.app.data.repository.WorkoutRepository
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {

    @Provides
    @Singleton
    fun provideAuthRepository(
        apiService: ApiService,
        tokenManager: TokenManager
    ): AuthRepository = AuthRepository(apiService, tokenManager)

    @Provides
    @Singleton
    fun provideRouteRepository(
        apiService: ApiService
    ): RouteRepository = RouteRepository(apiService)

    @Provides
    @Singleton
    fun provideFoodRepository(
        apiService: ApiService
    ): FoodRepository = FoodRepository(apiService)

    @Provides
    @Singleton
    fun provideChatRepository(
        apiService: ApiService
    ): ChatRepository = ChatRepository(apiService)

    @Provides
    @Singleton
    fun provideWorkoutRepository(
        apiService: ApiService
    ): WorkoutRepository = WorkoutRepository(apiService)

    @Provides
    @Singleton
    fun provideSurveyRepository(
        apiService: ApiService
    ): SurveyRepository = SurveyRepository(apiService)

    @Provides
    @Singleton
    fun provideMealPlanRepository(
        apiService: ApiService
    ): MealPlanRepository = MealPlanRepository(apiService)

    @Provides
    @Singleton
    fun provideAICalorieRepository(
        apiService: ApiService,
        okHttpClient: OkHttpClient,
        json: Json,
        onDeviceFoodAnalyzer: OnDeviceFoodAnalyzer
    ): AICalorieRepository = AICalorieRepository(apiService, okHttpClient, json, onDeviceFoodAnalyzer)

    @Provides
    @Singleton
    fun provideProfileImageRepository(
        okHttpClient: OkHttpClient
    ): ProfileImageRepository = ProfileImageRepository(okHttpClient)

    // ── New Repositories ─────────────────────────────────────

    @Provides
    @Singleton
    fun provideContentRepository(
        apiService: ApiService,
        okHttpClient: OkHttpClient
    ): ContentRepository = ContentRepository(apiService, okHttpClient)

    @Provides
    @Singleton
    fun provideFoodImageRepository(
        okHttpClient: OkHttpClient
    ): FoodImageRepository = FoodImageRepository(okHttpClient)

    @Provides
    @Singleton
    fun provideNewsRepository(
        apiService: ApiService
    ): NewsRepository = NewsRepository(apiService)

    @Provides
    @Singleton
    fun provideOnboardingRepository(
        apiService: ApiService,
        sharedPreferences: SharedPreferences
    ): OnboardingRepository = OnboardingRepository(apiService, sharedPreferences)

    // ── Trainer + Training Plan Repositories ─────────────────

    @Provides
    @Singleton
    fun provideTrainerRepository(
        apiService: ApiService
    ): TrainerRepository = TrainerRepository(apiService)

    @Provides
    @Singleton
    fun provideTrainerDashboardRepository(
        apiService: ApiService
    ): TrainerDashboardRepository = TrainerDashboardRepository(apiService)

    @Provides
    @Singleton
    fun provideTrainingPlanRepository(
        apiService: ApiService
    ): TrainingPlanRepository = TrainingPlanRepository(apiService)
}
