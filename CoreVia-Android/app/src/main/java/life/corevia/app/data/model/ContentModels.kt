package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * iOS ContentModels.swift equivalent
 * Content response, create request modelleri
 */

// MARK: - Content Response
@Serializable
data class ContentResponse(
    val id: String = "",
    @SerialName("trainer_id") val trainerId: String = "",
    @SerialName("trainer_name") val trainerName: String = "",
    @SerialName("trainer_profile_image") val trainerProfileImage: String? = null,
    val title: String = "",
    val body: String? = null,
    @SerialName("content_type") val contentType: String = "",
    @SerialName("image_url") val imageUrl: String? = null,
    @SerialName("is_premium_only") val isPremiumOnly: Boolean = false,
    @SerialName("created_at") val createdAt: String = ""
)

// MARK: - Content Create Request
@Serializable
data class ContentCreateRequest(
    val title: String,
    val body: String? = null,
    @SerialName("content_type") val contentType: String,
    @SerialName("is_premium_only") val isPremiumOnly: Boolean = false
)
