package life.corevia.app.data.repository

import android.content.SharedPreferences
import life.corevia.app.data.model.OnboardingCompleteRequest
import life.corevia.app.data.model.OnboardingOptionsResponse
import life.corevia.app.data.model.OnboardingStatusResponse
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS OnboardingManager.swift equivalent
 * Onboarding seçimləri, status management
 */
@Singleton
class OnboardingRepository @Inject constructor(
    private val apiService: ApiService,
    private val sharedPreferences: SharedPreferences
) {

    companion object {
        private const val ONBOARDING_COMPLETED_KEY = "onboarding_completed"
    }

    /** Lokal cache-dən oxu (sürətli başlanğıc) */
    var isCompleted: Boolean
        get() = sharedPreferences.getBoolean(ONBOARDING_COMPLETED_KEY, false)
        set(value) {
            sharedPreferences.edit().putBoolean(ONBOARDING_COMPLETED_KEY, value).apply()
        }

    // ─── Fetch Onboarding Options ────────────────────────────────────

    suspend fun fetchOptions(): NetworkResult<OnboardingOptionsResponse> {
        return try {
            val response = apiService.getOnboardingOptions()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: OnboardingOptionsResponse())
            } else {
                NetworkResult.Error("Seçimlər yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Check Onboarding Status ─────────────────────────────────────

    suspend fun checkStatus(): NetworkResult<OnboardingStatusResponse> {
        return try {
            val response = apiService.getOnboardingStatus()
            if (response.isSuccessful) {
                val status = response.body()
                if (status != null) {
                    isCompleted = status.isCompleted
                }
                NetworkResult.Success(status ?: OnboardingStatusResponse())
            } else {
                // Xəta olsa lokal cache-ə etibar et
                NetworkResult.Error("Status yoxlanıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            // Xəta olsa lokal cache-ə etibar et, false-a sıfırlama
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Complete Onboarding ─────────────────────────────────────────

    suspend fun complete(
        goal: String,
        level: String,
        trainerType: String? = null
    ): NetworkResult<OnboardingStatusResponse> {
        return try {
            val request = OnboardingCompleteRequest(
                fitnessGoal = goal,
                fitnessLevel = level,
                preferredTrainerType = trainerType
            )
            val response = apiService.completeOnboarding(request)
            if (response.isSuccessful) {
                isCompleted = true
                NetworkResult.Success(response.body() ?: OnboardingStatusResponse(isCompleted = true))
            } else {
                NetworkResult.Error("Onboarding tamamlana bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Reset on Logout ─────────────────────────────────────────────

    fun resetOnLogout() {
        isCompleted = false
        sharedPreferences.edit().remove(ONBOARDING_COMPLETED_KEY).apply()
    }
}
