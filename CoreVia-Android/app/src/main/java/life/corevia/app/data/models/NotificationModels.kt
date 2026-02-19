package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Notification Models ────────────────────────────────────────────────────
// iOS: NotificationManager.swift

data class AppNotification(
    val id: String,
    @SerializedName("user_id")    val userId: String,
    val title: String,
    val message: String,
    val type: String,                // "workout_reminder", "plan_assigned", "chat_message", etc.
    @SerializedName("is_read")    val isRead: Boolean = false,
    @SerializedName("related_id") val relatedId: String? = null,
    @SerializedName("created_at") val createdAt: String
)

data class UnreadCountResponse(
    @SerializedName("unread_count") val unreadCount: Int
)

data class DeviceTokenRequest(
    @SerializedName("device_token") val deviceToken: String,
    val platform: String = "android"
)

data class MarkReadRequest(
    @SerializedName("notification_ids") val notificationIds: List<String>
)

data class SendNotificationRequest(
    @SerializedName("student_id") val studentId: String,
    val title: String,
    val message: String
)
