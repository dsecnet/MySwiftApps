package life.corevia.app.data.repository

import life.corevia.app.data.model.RouteCreateRequest
import life.corevia.app.data.model.RouteResponse
import life.corevia.app.data.model.RouteStatsResponse
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class RouteRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getRoutes(): NetworkResult<List<RouteResponse>> {
        return try {
            val response = apiService.getRoutes()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Marşrutlar yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getWeeklyStats(): NetworkResult<RouteStatsResponse> {
        return try {
            val response = apiService.getRouteStats(days = 7)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: RouteStatsResponse())
            } else {
                NetworkResult.Error("Statistika yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun saveRoute(request: RouteCreateRequest): NetworkResult<RouteResponse> {
        return try {
            val response = apiService.createRoute(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Marşrut saxlanıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun deleteRoute(id: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deleteRoute(id)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Marşrut silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
