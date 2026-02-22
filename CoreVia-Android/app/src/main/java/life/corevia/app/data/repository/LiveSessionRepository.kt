package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

class LiveSessionRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getSessions(): Result<List<LiveSession>> {
        return try {
            val response = api.getLiveSessions()
            Result.success(response.sessions)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getSession(sessionId: String): Result<LiveSession> {
        return try {
            Result.success(api.getLiveSession(sessionId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createSession(request: CreateLiveSessionRequest): Result<LiveSession> {
        return try {
            Result.success(api.createLiveSession(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun joinSession(sessionId: String): Result<LiveSession> {
        return try {
            Result.success(api.joinLiveSession(sessionId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun leaveSession(sessionId: String): Result<LiveSession> {
        return try {
            Result.success(api.leaveLiveSession(sessionId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: LiveSessionRepository? = null
        fun getInstance(context: Context): LiveSessionRepository =
            instance ?: synchronized(this) {
                instance ?: LiveSessionRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
