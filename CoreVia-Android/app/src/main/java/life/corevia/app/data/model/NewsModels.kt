package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * iOS NewsModels.swift equivalent
 * Xəbər məqalə, kateqoriya modelleri
 */

// ═══════════════════════════════════════════════════════════════════
// MARK: - News Article
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class NewsArticle(
    val id: String = "",
    val title: String = "",
    val summary: String = "",
    val category: String = "",
    val source: String = "",
    @SerialName("reading_time") val readingTime: Int = 0,
    @SerialName("image_description") val imageDescription: String = "",
    @SerialName("published_at") val publishedAt: String = ""
) {
    /** Category icon name (Material Icons mapping) */
    val categoryIconName: String
        get() = when (category.lowercase()) {
            "workout" -> "fitness_center"
            "nutrition" -> "restaurant"
            "research" -> "science"
            "tips" -> "lightbulb"
            "lifestyle" -> "favorite"
            else -> "newspaper"
        }

    /** Category color name */
    val categoryColorName: String
        get() = when (category.lowercase()) {
            "workout" -> "blue"
            "nutrition" -> "green"
            "research" -> "purple"
            "tips" -> "orange"
            "lifestyle" -> "pink"
            else -> "gray"
        }

    /** Parse ISO 8601 date */
    val publishedDate: Date?
        get() {
            return try {
                val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                format.timeZone = TimeZone.getTimeZone("UTC")
                format.parse(publishedAt)
            } catch (_: Exception) {
                try {
                    val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault())
                    format.timeZone = TimeZone.getTimeZone("UTC")
                    format.parse(publishedAt)
                } catch (_: Exception) {
                    null
                }
            }
        }

    /** Time ago string — "2 gün əvvəl", "3 saat əvvəl", "İndi" */
    val timeAgo: String
        get() {
            val date = publishedDate ?: return ""
            val now = Date()
            val diffMillis = now.time - date.time

            val diffHours = diffMillis / (1000 * 60 * 60)
            val diffDays = diffHours / 24

            return when {
                diffDays > 0 -> "$diffDays gün əvvəl"
                diffHours > 0 -> "$diffHours saat əvvəl"
                else -> "İndi"
            }
        }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - News Response
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class NewsResponse(
    val articles: List<NewsArticle> = emptyList(),
    val total: Int = 0,
    @SerialName("cache_status") val cacheStatus: String = ""
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - News Category
// ═══════════════════════════════════════════════════════════════════
@Serializable
data class NewsCategory(
    val id: String = "",
    val name: String = "",
    val icon: String = ""
)

@Serializable
data class NewsCategoriesResponse(
    val categories: List<NewsCategory> = emptyList()
)
