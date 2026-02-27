package life.corevia.app.data.repository

import life.corevia.app.data.model.NewsCategoriesResponse
import life.corevia.app.data.model.NewsResponse
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS NewsService.swift equivalent
 * Xəbər məqalələri — backend API ilə
 */
@Singleton
class NewsRepository @Inject constructor(
    private val apiService: ApiService
) {

    // ─── Fetch News Articles ─────────────────────────────────────────

    suspend fun fetchNews(
        category: String? = null,
        limit: Int = 20,
        offset: Int = 0
    ): NetworkResult<NewsResponse> {
        return try {
            val response = apiService.getNews(category, limit, offset)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: NewsResponse())
            } else {
                NetworkResult.Error("Xəbərlər yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Fetch News Categories ───────────────────────────────────────

    suspend fun fetchCategories(): NetworkResult<NewsCategoriesResponse> {
        return try {
            val response = apiService.getNewsCategories()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: NewsCategoriesResponse())
            } else {
                NetworkResult.Error("Kateqoriyalar yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
