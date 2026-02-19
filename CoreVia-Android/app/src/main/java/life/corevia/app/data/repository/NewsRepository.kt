package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

class NewsRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getNews(): Result<List<NewsArticle>> {
        return try {
            Result.success(api.getNews())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getArticle(articleId: String): Result<NewsArticle> {
        return try {
            Result.success(api.getNewsArticle(articleId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: NewsRepository? = null
        fun getInstance(context: Context): NewsRepository =
            instance ?: synchronized(this) {
                instance ?: NewsRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
