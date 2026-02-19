package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Chat/Messaging Models ──────────────────────────────────────────────────
// iOS: ChatManager.swift → ChatMessage + Conversation

data class ChatMessage(
    val id: String,
    @SerializedName("sender_id")   val senderId: String,
    @SerializedName("receiver_id") val receiverId: String,
    val content: String,
    @SerializedName("is_read")     val isRead: Boolean = false,
    @SerializedName("created_at")  val createdAt: String
)

data class Conversation(
    @SerializedName("user_id")        val userId: String,
    @SerializedName("user_name")      val userName: String,
    @SerializedName("user_image_url") val userImageUrl: String? = null,
    @SerializedName("last_message")   val lastMessage: String? = null,
    @SerializedName("last_message_at") val lastMessageAt: String? = null,
    @SerializedName("unread_count")   val unreadCount: Int = 0
)

data class SendMessageRequest(
    @SerializedName("receiver_id") val receiverId: String,
    val content: String
)

data class MessageLimitResponse(
    @SerializedName("daily_limit")     val dailyLimit: Int,
    @SerializedName("messages_sent")   val messagesSent: Int,
    @SerializedName("remaining")       val remaining: Int
)
