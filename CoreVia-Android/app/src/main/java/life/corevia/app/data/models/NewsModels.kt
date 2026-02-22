package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── News Models ────────────────────────────────────────────────────────────
// iOS: NewsManager.swift

data class NewsArticle(
    val id: String,
    val title: String,
    val summary: String? = null,
    val content: String? = null,
    val category: String = "fitness",
    val source: String? = null,
    @SerializedName("reading_time")     val readingTime: Int? = null,  // minutes
    @SerializedName("image_description") val imageDescription: String? = null,
    @SerializedName("published_at")     val publishedAt: String? = null,
    @SerializedName("image_url")        val imageUrl: String? = null,
    @SerializedName("is_bookmarked")    val isBookmarked: Boolean = false
)

data class NewsListResponse(
    val articles: List<NewsArticle>,
    val total: Int,
    @SerializedName("cache_status") val cacheStatus: String = "cached"
)

// ─── Bookmark Models ────────────────────────────────────────────────────────

data class NewsBookmark(
    val id: String,
    @SerializedName("article_id")    val articleId: String,
    @SerializedName("article_title") val articleTitle: String? = null,
    @SerializedName("created_at")    val createdAt: String? = null
)

data class BookmarkRequest(
    @SerializedName("article_id")    val articleId: String,
    @SerializedName("article_title") val articleTitle: String? = null
)
