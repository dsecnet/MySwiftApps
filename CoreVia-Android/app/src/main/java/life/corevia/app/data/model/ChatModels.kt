package life.corevia.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ChatConversation(
    val id: String = "",
    @SerialName("user_id") val usersId: String = "",
    @SerialName("user_name") val userName: String = "",
    @SerialName("user_profile_image") val userProfileImage: String? = null,
    @SerialName("user_type") val userType: String = "client",
    @SerialName("last_message") val lastMessage: String? = null,
    @SerialName("last_message_time") val lastMessageTime: String? = null,
    @SerialName("unread_count") val unreadCount: Int = 0,
    @SerialName("is_trainer") val isTrainer: Boolean = false
)

@Serializable
data class ChatMessage(
    val id: String = "",
    @SerialName("sender_id") val senderId: String = "",
    @SerialName("receiver_id") val receiverId: String = "",
    @SerialName("sender_name") val senderName: String = "",
    @SerialName("sender_profile_image") val senderProfileImage: String? = null,
    val message: String = "",
    @SerialName("is_read") val isRead: Boolean = false,
    @SerialName("created_at") val createdAt: String = ""
)

@Serializable
data class ChatMessageCreate(
    @SerialName("receiver_id") val receiverId: String,
    val message: String
)

@Serializable
data class MessageLimitResponse(
    val limit: Int = 50,
    val used: Int = 0,
    val remaining: Int = 50
)
