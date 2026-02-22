package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Marketplace Models ─────────────────────────────────────────────────────
// iOS: MarketplaceManager.swift

data class Product(
    val id: String,
    @SerializedName("title")       val name: String,
    val description: String? = null,
    val price: Double,
    val currency: String = "AZN",
    @SerializedName("cover_image_url") val imageUrl: String? = null,
    @SerializedName("product_type") val category: String = "supplement",
    @SerializedName("is_published") val inStock: Boolean = true,
    val rating: Double? = null,
    @SerializedName("reviews_count") val reviewCount: Int? = null,
    @SerializedName("sales_count")  val salesCount: Int = 0,
    @SerializedName("seller_id")    val sellerId: String? = null,
    val seller: ProductSeller? = null,
    @SerializedName("is_purchased") val isPurchased: Boolean = false,
    @SerializedName("created_at")   val createdAt: String? = null
)

data class ProductSeller(
    val id: String,
    val name: String,
    @SerializedName("profile_image_url") val profileImageUrl: String? = null,
    val rating: Double? = null
)

data class MarketplaceListResponse(
    val products: List<Product>,
    val total: Int,
    val page: Int,
    @SerializedName("page_size") val pageSize: Int,
    @SerializedName("has_more") val hasMore: Boolean
)

data class Order(
    val id: String,
    @SerializedName("product_id")  val productId: String,
    @SerializedName("product_name") val productName: String,
    val quantity: Int = 1,
    @SerializedName("total_price") val totalPrice: Double,
    val status: String = "pending",
    @SerializedName("created_at")  val createdAt: String? = null
)

data class CreateOrderRequest(
    @SerializedName("product_id") val productId: String,
    val quantity: Int = 1
)

// ─── Review Models ──────────────────────────────────────────────────────────

data class ProductReview(
    val id: String,
    @SerializedName("product_id") val productId: String,
    @SerializedName("buyer_id")   val buyerId: String,
    val rating: Int,
    val comment: String? = null,
    val author: ReviewAuthor? = null,
    @SerializedName("created_at") val createdAt: String? = null
)

data class ReviewAuthor(
    val id: String,
    val name: String,
    @SerializedName("profile_image_url") val profileImageUrl: String? = null
)

data class CreateProductReviewRequest(
    @SerializedName("product_id") val productId: String,
    val rating: Int,
    val comment: String? = null
)
