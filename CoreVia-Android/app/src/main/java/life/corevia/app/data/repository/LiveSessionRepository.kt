package life.corevia.app.data.repository

import life.corevia.app.data.model.CreateSessionRequest
import life.corevia.app.data.model.LiveSession
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class LiveSessionRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getLiveSessions(
        status: String? = null
    ): NetworkResult<List<LiveSession>> {
        return try {
            val response = apiService.getLiveSessions(status)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Sessiyalar yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getMyLiveSessions(): NetworkResult<List<LiveSession>> {
        return try {
            val response = apiService.getMyLiveSessions()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Sessiyalar yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getLiveSession(sessionId: String): NetworkResult<LiveSession> {
        return try {
            val response = apiService.getLiveSession(sessionId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: LiveSession())
            } else {
                NetworkResult.Error("Sessiya tapılmadı", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun createLiveSession(request: CreateSessionRequest): NetworkResult<LiveSession> {
        return try {
            val response = apiService.createLiveSession(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: LiveSession())
            } else {
                NetworkResult.Error("Sessiya yaradıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun joinLiveSession(sessionId: String): NetworkResult<LiveSession> {
        return try {
            val response = apiService.joinLiveSession(sessionId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: LiveSession())
            } else {
                NetworkResult.Error("Sessiyaya qoşulmaq mümkün olmadı", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun deleteLiveSession(sessionId: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deleteLiveSession(sessionId)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Sessiya silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
