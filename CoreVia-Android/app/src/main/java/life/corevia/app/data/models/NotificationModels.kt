package life.corevia.app.data.models

import com.google.gson.annotations.SerializedName

// ─── Notification Models ────────────────────────────────────────────────────
// iOS: NotificationManager.swift

data class AppNotification(
    val id: String = "",
    @SerializedName("user_id")            val userId: String = "",
    val title: String = "",
    @SerializedName("body")               val message: String = "",
    @SerializedName("notification_type")  val type: String = "",   // "workout_reminder", "meal_reminder", "trainer_message", etc.
    val data: String? = null,
    @SerializedName("is_read")            val isRead: Boolean = false,
    @SerializedName("is_sent")            val isSent: Boolean = false,
    @SerializedName("created_at")         val createdAt: String = ""
)

data class UnreadCountResponse(
    @SerializedName("unread_count") val unreadCount: Int
)

data class DeviceTokenRequest(
    @SerializedName("fcm_token") val fcmToken: String,
    @SerializedName("device_name") val deviceName: String? = null,
    val platform: String = "android"
)

data class MarkReadRequest(
    @SerializedName("notification_ids") val notificationIds: List<String>
)

data class SendNotificationRequest(
    @SerializedName("student_id") val studentId: String,
    val title: String,
    val body: String
)
