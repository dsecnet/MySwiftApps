package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Social Models ──────────────────────────────────────────────────────────
// iOS: SocialManager.swift → Post, Comment, Achievement

data class SocialPost(
    val id: String,
    @SerializedName("user_id")      val userId: String,
    @SerializedName("user_name")    val userName: String? = null,
    @SerializedName("user_image_url") val userImageUrl: String? = null,
    val content: String,
    @SerializedName("image_url")    val imageUrl: String? = null,
    @SerializedName("post_type")    val postType: String = "general",  // "general", "workout", "achievement"
    @SerializedName("like_count")   val likeCount: Int = 0,
    @SerializedName("comment_count") val commentCount: Int = 0,
    @SerializedName("is_liked")     val isLiked: Boolean = false,
    @SerializedName("created_at")   val createdAt: String
)

data class SocialComment(
    val id: String,
    @SerializedName("user_id")      val userId: String,
    @SerializedName("user_name")    val userName: String? = null,
    @SerializedName("user_image_url") val userImageUrl: String? = null,
    val content: String,
    @SerializedName("created_at")   val createdAt: String
)

data class CreatePostRequest(
    val content: String,
    @SerializedName("post_type") val postType: String = "general"
)

data class CreateCommentRequest(
    val content: String
)

data class Achievement(
    val id: String,
    val title: String,
    val description: String,
    val icon: String? = null,
    @SerializedName("is_unlocked") val isUnlocked: Boolean = false,
    @SerializedName("unlocked_at") val unlockedAt: String? = null,
    val progress: Double = 0.0,
    val target: Double = 1.0
)

data class UserProfileSummary(
    val id: String,
    val name: String,
    @SerializedName("profile_image_url") val profileImageUrl: String? = null,
    @SerializedName("user_type")   val userType: String,
    @SerializedName("is_following") val isFollowing: Boolean = false,
    @SerializedName("follower_count") val followerCount: Int = 0,
    @SerializedName("following_count") val followingCount: Int = 0,
    @SerializedName("post_count")  val postCount: Int = 0
)
