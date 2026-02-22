package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Premium/Subscription Models ────────────────────────────────────────────
// Backend: /api/v1/premium/

// ─── PremiumStatusResponse ──────────────────────────────────────────────────
// Backend qaytarır: is_premium, plan_type, expires_at, auto_renew, features
data class PremiumStatus(
    @SerializedName("is_premium")      val isPremium: Boolean = false,
    @SerializedName("plan_type")       val planType: String? = null,
    @SerializedName("expires_at")      val expiresAt: String? = null,
    @SerializedName("auto_renew")      val autoRenew: Boolean = false,
    val features: List<String> = emptyList()
) {
    // UI compatibility
    val planName: String? get() = when (planType) {
        "monthly" -> "Aylıq Premium"
        "yearly" -> "İllik Premium"
        else -> planType
    }
}

// ─── Premium Plan (GET /plans response-dan) ─────────────────────────────────
// Backend qaytarır: product_id, name, price, currency, period, features
data class PremiumPlan(
    @SerializedName("product_id") val productId: String,
    val name: String,
    val price: Double,
    val currency: String = "AZN",
    val period: String = "monthly",  // "monthly" / "yearly"
    val features: List<String> = emptyList(),
    @SerializedName("save_percent") val savePercent: Int? = null,
    @SerializedName("is_popular") val isPopular: Boolean = false
)

// ─── Plans list wrapper ──────────────────────────────────────────────────────
// Backend GET /plans qaytarır: { "plans": [...] }
data class PremiumPlansResponse(
    val plans: List<PremiumPlan> = emptyList()
)

// ─── SubscribeRequest ───────────────────────────────────────────────────────
// Backend gözləyir: product_id, transaction_id, original_transaction_id, receipt_data
data class SubscribeRequest(
    @SerializedName("product_id")              val productId: String,
    @SerializedName("transaction_id")          val transactionId: String? = null,
    @SerializedName("original_transaction_id") val originalTransactionId: String? = null,
    @SerializedName("receipt_data")            val receiptData: String? = null
)

// ─── SubscriptionResponse / History ─────────────────────────────────────────
// Backend qaytarır: id, user_id, product_id, transaction_id, plan_type, price,
//                   currency, is_active, auto_renew, started_at, expires_at,
//                   cancelled_at, created_at
data class SubscriptionHistory(
    val id: String,
    @SerializedName("user_id")       val userId: String? = null,
    @SerializedName("product_id")    val productId: String? = null,
    @SerializedName("transaction_id") val transactionId: String? = null,
    @SerializedName("plan_type")     val planType: String? = null,
    val price: Double = 0.0,
    val currency: String = "AZN",
    @SerializedName("is_active")     val isActive: Boolean = false,
    @SerializedName("auto_renew")    val autoRenew: Boolean = false,
    @SerializedName("started_at")    val startedAt: String? = null,
    @SerializedName("expires_at")    val expiresAt: String? = null,
    @SerializedName("cancelled_at")  val cancelledAt: String? = null,
    @SerializedName("created_at")    val createdAt: String? = null
) {
    // UI compatibility
    val planName: String get() = when (planType) {
        "monthly" -> "Aylıq Premium"
        "yearly" -> "İllik Premium"
        else -> planType ?: "Premium"
    }
    val amount: Double get() = price
    val status: String get() = when {
        isActive -> "active"
        cancelledAt != null -> "cancelled"
        else -> "expired"
    }
}
