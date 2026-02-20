package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.ContentCreateRequest
import life.corevia.app.data.models.ContentResponse

/**
 * iOS ContentManager.swift — Android Repository ekvivalenti.
 */
class ContentRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getMyContent(): Result<List<ContentResponse>> {
        return try {
            Result.success(api.getMyContent())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getTrainerContent(trainerId: String): Result<List<ContentResponse>> {
        return try {
            Result.success(api.getTrainerContent(trainerId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createContent(request: ContentCreateRequest): Result<ContentResponse> {
        return try {
            Result.success(api.createContent(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteContent(contentId: String): Result<Unit> {
        return try {
            api.deleteContent(contentId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: ContentRepository? = null
        fun getInstance(context: Context): ContentRepository =
            instance ?: synchronized(this) {
                instance ?: ContentRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
