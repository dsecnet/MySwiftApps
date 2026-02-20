package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

/**
 * iOS ContentModels.swift — Android ekvivalenti.
 * Backend: /api/v1/content/
 */

// ─── Content Response ───────────────────────────────────────────────────────
data class ContentResponse(
    val id: String,
    @SerializedName("trainer_id")            val trainerId: String,
    @SerializedName("trainer_name")          val trainerName: String = "",
    @SerializedName("trainer_profile_image") val trainerProfileImage: String? = null,
    val title: String,
    val body: String? = null,
    @SerializedName("content_type")          val contentType: String = "text",
    @SerializedName("image_url")             val imageUrl: String? = null,
    @SerializedName("is_premium_only")       val isPremiumOnly: Boolean = false,
    @SerializedName("created_at")            val createdAt: String? = null
)

// ─── Content Create Request ─────────────────────────────────────────────────
data class ContentCreateRequest(
    val title: String,
    val body: String? = null,
    @SerializedName("content_type")    val contentType: String = "text",
    @SerializedName("is_premium_only") val isPremiumOnly: Boolean = true
)
