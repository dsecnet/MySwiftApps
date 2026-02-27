package life.corevia.app.data.repository

import life.corevia.app.data.model.TrainerDashboardStats
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS TrainerDashboardManager.swift equivalent
 * Trainer Dashboard — real API data ilə statistikalar
 */
@Singleton
class TrainerDashboardRepository @Inject constructor(
    private val apiService: ApiService
) {

    // ─── Fetch Dashboard Stats ───────────────────────────────────────

    suspend fun fetchStats(): NetworkResult<TrainerDashboardStats> {
        return try {
            val response = apiService.getTrainerStats()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: TrainerDashboardStats())
            } else {
                NetworkResult.Error("Statistika yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
