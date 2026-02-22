package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Social Models ──────────────────────────────────────────────────────────
// iOS: SocialManager.swift → Post, Comment, Achievement

// ─── Author nested objects (backend qaytarır) ───────────────────────────────

data class PostAuthor(
    val id: String? = null,
    val name: String? = null,
    @SerializedName("profile_image_url") val profileImageUrl: String? = null,
    @SerializedName("user_type") val userType: String? = null
)

data class CommentAuthor(
    val id: String? = null,
    val name: String? = null,
    @SerializedName("profile_image_url") val profileImageUrl: String? = null
)

// ─── Post ───────────────────────────────────────────────────────────────────

data class SocialPost(
    val id: String,
    @SerializedName("user_id")      val userId: String,
    val content: String? = null,
    @SerializedName("image_url")    val imageUrl: String? = null,
    @SerializedName("post_type")    val postType: String = "general",
    @SerializedName("likes_count")  val likeCount: Int = 0,
    @SerializedName("comments_count") val commentCount: Int = 0,
    @SerializedName("is_liked")     val isLiked: Boolean = false,
    @SerializedName("is_public")    val isPublic: Boolean = true,
    @SerializedName("workout_id")   val workoutId: String? = null,
    @SerializedName("food_entry_id") val foodEntryId: String? = null,
    @SerializedName("created_at")   val createdAt: String,
    @SerializedName("updated_at")   val updatedAt: String? = null,
    // Backend nested author object
    val author: PostAuthor? = null
) {
    // Compatibility helpers — backend author obj-dan oxu
    val userName: String? get() = author?.name
    val userImageUrl: String? get() = author?.profileImageUrl
}

// ─── Comment ────────────────────────────────────────────────────────────────

data class SocialComment(
    val id: String,
    @SerializedName("user_id")      val userId: String,
    @SerializedName("post_id")      val postId: String? = null,
    val content: String,
    @SerializedName("created_at")   val createdAt: String,
    // Backend nested author object
    val author: CommentAuthor? = null
) {
    val userName: String? get() = author?.name
    val userImageUrl: String? get() = author?.profileImageUrl
}

// ─── Create Requests ────────────────────────────────────────────────────────

data class CreatePostRequest(
    val content: String,
    @SerializedName("post_type") val postType: String = "general",
    @SerializedName("workout_id") val workoutId: String? = null,
    @SerializedName("food_entry_id") val foodEntryId: String? = null,
    @SerializedName("is_public") val isPublic: Boolean = true
)

data class CreateCommentRequest(
    val content: String
)

// ─── Feed Response Wrapper ──────────────────────────────────────────────────

data class FeedResponse(
    val posts: List<SocialPost> = emptyList(),
    val total: Int = 0,
    val page: Int = 1,
    @SerializedName("page_size") val pageSize: Int = 20,
    @SerializedName("has_more") val hasMore: Boolean = false
)

// ─── Achievement ────────────────────────────────────────────────────────────

data class Achievement(
    val id: String,
    @SerializedName("achievement_type") val achievementType: String? = null,
    val title: String,
    val description: String,
    val icon: String? = null,
    @SerializedName("is_unlocked") val isUnlocked: Boolean = false,
    @SerializedName("earned_at") val earnedAt: String? = null,
    @SerializedName("unlocked_at") val unlockedAt: String? = null,
    val progress: Double = 0.0,
    val target: Int = 1,
    val current: Int = 0
)

// ─── User Profile Summary ───────────────────────────────────────────────────

data class UserProfileSummary(
    val id: String,
    val name: String,
    @SerializedName("profile_image_url") val profileImageUrl: String? = null,
    @SerializedName("user_type")   val userType: String,
    val bio: String? = null,
    @SerializedName("is_following") val isFollowing: Boolean = false,
    @SerializedName("followers_count") val followerCount: Int = 0,
    @SerializedName("following_count") val followingCount: Int = 0,
    @SerializedName("posts_count")  val postCount: Int = 0
)
