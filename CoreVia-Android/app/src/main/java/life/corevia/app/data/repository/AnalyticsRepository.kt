package life.corevia.app.data.repository

import life.corevia.app.data.model.AnalyticsDashboardResponse
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AnalyticsRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getDashboard(): NetworkResult<AnalyticsDashboardResponse> {
        return try {
            val response = apiService.getAnalyticsDashboard()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: AnalyticsDashboardResponse())
            } else {
                NetworkResult.Error("Dashboard yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
