package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * iOS MarketplaceModels.swift equivalent
 * Marketplace product, review data models
 */

@Serializable
data class MarketplaceProduct(
    val id: String = "",
    @SerialName("seller_id") val sellerId: String = "",
    val title: String = "",
    val description: String = "",
    @SerialName("product_type") val productType: String = "workout_plan",
    val price: Double = 0.0,
    val currency: String = "AZN",
    @SerialName("image_url") val imageUrl: String? = null,
    @SerialName("is_published") val isPublished: Boolean = true,
    val rating: Double = 0.0,
    @SerialName("reviews_count") val reviewsCount: Int = 0,
    @SerialName("sales_count") val salesCount: Int = 0,
    val seller: ProductSeller = ProductSeller(),
    @SerialName("created_at") val createdAt: String = ""
) {
    val displayPrice: String
        get() = "%.2f %s".format(price, currency)

    val productTypeEnum: MarketplaceProductType
        get() = MarketplaceProductType.fromValue(productType)
}

@Serializable
data class ProductSeller(
    val id: String = "",
    @SerialName("full_name") val fullName: String = "",
    @SerialName("profile_image") val profileImage: String? = null,
    val rating: Double = 0.0
) {
    val initials: String
        get() = fullName.split(" ")
            .take(2)
            .mapNotNull { it.firstOrNull()?.uppercase() }
            .joinToString("")
            .ifBlank { "?" }
}

@Serializable
data class ProductsResponse(
    val products: List<MarketplaceProduct> = emptyList(),
    val total: Int = 0,
    val page: Int = 1,
    @SerialName("has_more") val hasMore: Boolean = false
)

@Serializable
data class ProductReview(
    val id: String = "",
    @SerialName("product_id") val productId: String = "",
    @SerialName("user_id") val userId: String = "",
    val rating: Int = 5,
    val comment: String = "",
    val author: ReviewAuthor = ReviewAuthor(),
    @SerialName("created_at") val createdAt: String = ""
)

@Serializable
data class ReviewAuthor(
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
data class CreateReviewRequest(
    val rating: Int,
    val comment: String
)

@Serializable
data class CreateProductRequest(
    val title: String,
    val description: String,
    @SerialName("product_type") val productType: String,
    val price: Double,
    val currency: String = "AZN"
)

enum class MarketplaceProductType(val value: String, val displayName: String) {
    WORKOUT_PLAN("workout_plan", "Məşq Planı"),
    MEAL_PLAN("meal_plan", "Yemək Planı"),
    TRAINING_PROGRAM("training_program", "Proqram"),
    EBOOK("ebook", "E-kitab"),
    VIDEO_COURSE("video_course", "Video Kurs");

    companion object {
        fun fromValue(value: String): MarketplaceProductType =
            entries.find { it.value == value } ?: WORKOUT_PLAN
    }
}
