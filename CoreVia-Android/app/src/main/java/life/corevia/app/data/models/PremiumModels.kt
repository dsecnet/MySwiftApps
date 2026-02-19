package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Premium/Subscription Models ────────────────────────────────────────────
// iOS: PremiumManager.swift

data class PremiumStatus(
    @SerializedName("is_premium")      val isPremium: Boolean = false,
    @SerializedName("plan_id")         val planId: String? = null,
    @SerializedName("plan_name")       val planName: String? = null,
    @SerializedName("expires_at")      val expiresAt: String? = null,
    @SerializedName("is_trial")        val isTrial: Boolean = false,
    @SerializedName("auto_renew")      val autoRenew: Boolean = false
)

data class PremiumPlan(
    val id: String,
    val name: String,
    val price: Double,
    val currency: String = "AZN",
    @SerializedName("duration_months") val durationMonths: Int,
    val description: String? = null,
    val features: List<String> = emptyList()
)

data class SubscribeRequest(
    @SerializedName("plan_id")       val planId: String,
    @SerializedName("receipt_data")  val receiptData: String? = null,
    @SerializedName("purchase_token") val purchaseToken: String? = null
)

data class SubscriptionHistory(
    val id: String,
    @SerializedName("plan_name")  val planName: String,
    val amount: Double,
    val currency: String = "AZN",
    val status: String,              // "active", "cancelled", "expired"
    @SerializedName("started_at") val startedAt: String,
    @SerializedName("expires_at") val expiresAt: String? = null
)
