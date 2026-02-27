package life.corevia.app.data.repository

import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Premium status və aktivasiya — Backend API ilə
 */
@Singleton
class PremiumRepository @Inject constructor(
    private val apiService: ApiService
) {

    // ─── Get Premium Status ──────────────────────────────────────────

    suspend fun getPremiumStatus(): NetworkResult<Boolean> {
        return try {
            val response = apiService.getCurrentUser()
            if (response.isSuccessful) {
                val isPremium = response.body()?.isPremium ?: false
                NetworkResult.Success(isPremium)
            } else {
                NetworkResult.Error("Premium status yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Activate Premium ────────────────────────────────────────────

    suspend fun activatePremium(): NetworkResult<Unit> {
        return try {
            val response = apiService.activatePremium()
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Premium aktivasiya uğursuz oldu", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
