package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Chat/Messaging Models ──────────────────────────────────────────────────
// iOS: ChatModels.swift → ChatMessageResponse + ChatConversation + MessageLimitResponse

// iOS: ChatMessageResponse — 1-ə-1 field uyğunluq
// Gson non-null Kotlin field-lara null inject edə bilər → default dəyər verilir
data class ChatMessage(
    val id: String = "",
    @SerializedName("sender_id")             val senderId: String = "",
    @SerializedName("receiver_id")           val receiverId: String = "",
    @SerializedName("sender_name")           val senderName: String? = null,
    @SerializedName("sender_profile_image")  val senderProfileImage: String? = null,
    val message: String = "",
    @SerializedName("is_read")               val isRead: Boolean = false,
    @SerializedName("created_at")            val createdAt: String = ""
)

// iOS: ChatConversation — əvvəlki sessiyada user_profile_image/last_message_time düzəldilib
data class Conversation(
    @SerializedName("user_id")             val userId: String = "",
    @SerializedName("user_name")           val userName: String = "",
    @SerializedName("user_profile_image")  val userProfileImage: String? = null,
    @SerializedName("last_message")        val lastMessage: String? = null,
    @SerializedName("last_message_time")   val lastMessageTime: String? = null,
    @SerializedName("unread_count")        val unreadCount: Int = 0
)

// iOS: ChatMessageCreate — receiver_id + message
data class SendMessageRequest(
    @SerializedName("receiver_id") val receiverId: String,
    val message: String
)

// iOS: MessageLimitResponse — daily_limit + used_today + remaining
data class MessageLimitResponse(
    @SerializedName("daily_limit")   val dailyLimit: Int = 0,
    @SerializedName("used_today")    val usedToday: Int = 0,
    @SerializedName("remaining")     val remaining: Int = 0
)
