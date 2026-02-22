package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

class NewsRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getNews(): Result<List<NewsArticle>> {
        return try {
            val response = api.getNews()
            Result.success(response.articles)
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

    suspend fun bookmarkArticle(articleId: String, title: String?): Result<NewsBookmark> {
        return try {
            Result.success(api.bookmarkArticle(BookmarkRequest(articleId, title)))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun removeBookmark(articleId: String): Result<Unit> {
        return try {
            api.removeBookmark(articleId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getBookmarks(): Result<List<NewsBookmark>> {
        return try {
            Result.success(api.getBookmarks())
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
