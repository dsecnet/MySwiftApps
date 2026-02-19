package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Marketplace Models ─────────────────────────────────────────────────────
// iOS: MarketplaceManager.swift

data class Product(
    val id: String,
    val name: String,
    val description: String? = null,
    val price: Double,
    val currency: String = "AZN",
    @SerializedName("image_url")   val imageUrl: String? = null,
    val category: String = "supplement",  // "supplement", "equipment", "clothing", "accessory"
    @SerializedName("in_stock")    val inStock: Boolean = true,
    val rating: Double = 0.0,
    @SerializedName("review_count") val reviewCount: Int = 0,
    @SerializedName("created_at")  val createdAt: String? = null
)

data class Order(
    val id: String,
    @SerializedName("product_id")  val productId: String,
    @SerializedName("product_name") val productName: String,
    val quantity: Int = 1,
    @SerializedName("total_price") val totalPrice: Double,
    val status: String = "pending",  // "pending", "confirmed", "shipped", "delivered", "cancelled"
    @SerializedName("created_at")  val createdAt: String? = null
)

data class CreateOrderRequest(
    @SerializedName("product_id") val productId: String,
    val quantity: Int = 1
)
