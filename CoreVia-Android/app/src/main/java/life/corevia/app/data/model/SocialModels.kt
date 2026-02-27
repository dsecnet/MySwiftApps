package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * iOS SocialModels.swift equivalent
 * Social feed, posts, comments data models
 */

@Serializable
data class SocialPost(
    val id: String = "",
    @SerialName("user_id") val userId: String = "",
    val content: String = "",
    @SerialName("post_type") val postType: String = "general",
    @SerialName("image_url") val imageUrl: String? = null,
    @SerialName("image_caption") val imageCaption: String? = null,
    @SerialName("is_public") val isPublic: Boolean = true,
    @SerialName("likes_count") val likesCount: Int = 0,
    @SerialName("comments_count") val commentsCount: Int = 0,
    @SerialName("is_liked") val isLiked: Boolean = false,
    val author: PostAuthor = PostAuthor(),
    @SerialName("created_at") val createdAt: String = ""
) {
    val timeAgo: String
        get() {
            return try {
                val isoFormat = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.getDefault())
                val parsed = isoFormat.parse(createdAt) ?: return ""
                val diff = System.currentTimeMillis() - parsed.time
                val minutes = diff / 60000
                val hours = minutes / 60
                val days = hours / 24
                when {
                    minutes < 1 -> "İndicə"
                    minutes < 60 -> "${minutes} dəq əvvəl"
                    hours < 24 -> "${hours} saat əvvəl"
                    days < 7 -> "${days} gün əvvəl"
                    else -> {
                        val df = java.text.SimpleDateFormat("dd MMM", java.util.Locale.getDefault())
                        df.format(parsed)
                    }
                }
            } catch (_: Exception) { "" }
        }
}

@Serializable
data class PostAuthor(
    val id: String = "",
    @SerialName("full_name") val fullName: String = "",
    @SerialName("profile_image") val profileImage: String? = null,
    @SerialName("user_type") val userType: String = "client"
) {
    val initials: String
        get() = fullName.split(" ")
            .take(2)
            .mapNotNull { it.firstOrNull()?.uppercase() }
            .joinToString("")
            .ifBlank { "?" }
}

@Serializable
data class FeedResponse(
    val posts: List<SocialPost> = emptyList(),
    val total: Int = 0,
    val page: Int = 1,
    @SerialName("has_more") val hasMore: Boolean = false
)

@Serializable
data class CreatePostRequest(
    val content: String,
    @SerialName("post_type") val postType: String = "general",
    @SerialName("image_url") val imageUrl: String? = null,
    @SerialName("image_caption") val imageCaption: String? = null,
    @SerialName("is_public") val isPublic: Boolean = true
)

@Serializable
data class PostComment(
    val id: String = "",
    @SerialName("post_id") val postId: String = "",
    @SerialName("user_id") val userId: String = "",
    val content: String = "",
    val author: CommentAuthor = CommentAuthor(),
    @SerialName("created_at") val createdAt: String = ""
) {
    val timeAgo: String
        get() {
            return try {
                val isoFormat = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.getDefault())
                val parsed = isoFormat.parse(createdAt) ?: return ""
                val diff = System.currentTimeMillis() - parsed.time
                val minutes = diff / 60000
                val hours = minutes / 60
                val days = hours / 24
                when {
                    minutes < 1 -> "İndicə"
                    minutes < 60 -> "${minutes} dəq əvvəl"
                    hours < 24 -> "${hours} saat əvvəl"
                    else -> "${days} gün əvvəl"
                }
            } catch (_: Exception) { "" }
        }
}

@Serializable
data class CommentAuthor(
    val id: String = "",
    @SerialName("full_name") val fullName: String = "",
    @SerialName("profile_image") val profileImage: String? = null
) {
    val initials: String
        get() = fullName.split(" ")
            .take(2)
            .mapNotNull { it.firstOrNull()?.uppercase() }
            .joinToString("")
            .ifBlank { "?" }
}

@Serializable
data class CreateCommentRequest(
    val content: String
)

enum class PostType(val value: String, val displayName: String) {
    GENERAL("general", "Ümumi"),
    WORKOUT("workout", "Məşq"),
    MEAL("meal", "Yemək"),
    PROGRESS("progress", "İrəliləyiş"),
    ACHIEVEMENT("achievement", "Nailiyyət");

    companion object {
        fun fromValue(value: String): PostType =
            entries.find { it.value == value } ?: GENERAL
    }
}
