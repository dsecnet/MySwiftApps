package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

/**
 * iOS NotificationManager.swift-in Android Repository ekvivalenti.
 */
class NotificationRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getNotifications(): Result<List<AppNotification>> {
        return try {
            Result.success(api.getNotifications())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getUnreadCount(): Result<Int> {
        return try {
            Result.success(api.getUnreadCount().unreadCount)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun markRead(notificationIds: List<String>): Result<Unit> {
        return try {
            api.markNotificationsRead(MarkReadRequest(notificationIds))
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun markAllRead(): Result<Unit> {
        return try {
            api.markAllNotificationsRead()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteNotification(id: String): Result<Unit> {
        return try {
            api.deleteNotification(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun registerDeviceToken(token: String, deviceName: String? = null): Result<Unit> {
        return try {
            api.registerDeviceToken(DeviceTokenRequest(fcmToken = token, deviceName = deviceName))
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun unregisterDeviceToken(token: String): Result<Unit> {
        return try {
            api.unregisterDeviceToken(DeviceTokenRequest(fcmToken = token))
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun sendNotification(request: SendNotificationRequest): Result<Unit> {
        return try {
            api.sendNotification(request)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: NotificationRepository? = null
        fun getInstance(context: Context): NotificationRepository =
            instance ?: synchronized(this) {
                instance ?: NotificationRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
