package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Review Models ──────────────────────────────────────────────────────────
// iOS: TrainerReview functionality

data class TrainerReview(
    val id: String,
    @SerializedName("trainer_id")  val trainerId: String,
    @SerializedName("client_id")   val clientId: String,
    @SerializedName("client_name") val clientName: String? = null,
    @SerializedName("client_image_url") val clientImageUrl: String? = null,
    val rating: Int,                // 1-5
    val comment: String? = null,
    @SerializedName("created_at")  val createdAt: String
)

data class CreateReviewRequest(
    val rating: Int,
    val comment: String? = null
)

data class ReviewSummary(
    @SerializedName("average_rating") val averageRating: Double = 0.0,
    @SerializedName("total_reviews")  val totalReviews: Int = 0,
    @SerializedName("rating_distribution") val ratingDistribution: Map<String, Int> = emptyMap()
)
