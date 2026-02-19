package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── News Models ────────────────────────────────────────────────────────────
// iOS: NewsManager.swift

data class NewsArticle(
    val id: String,
    val title: String,
    val summary: String? = null,
    val content: String? = null,
    @SerializedName("image_url")   val imageUrl: String? = null,
    val category: String = "fitness",  // "fitness", "nutrition", "health", "lifestyle"
    val author: String? = null,
    @SerializedName("read_time")   val readTime: Int? = null,  // minutes
    @SerializedName("is_featured") val isFeatured: Boolean = false,
    @SerializedName("created_at")  val createdAt: String? = null
)
