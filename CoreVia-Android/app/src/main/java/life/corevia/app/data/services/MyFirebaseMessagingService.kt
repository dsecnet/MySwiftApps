package life.corevia.app.data.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import life.corevia.app.MainActivity
import life.corevia.app.data.api.TokenManager
import life.corevia.app.data.repository.NotificationRepository

/**
 * iOS: AppDelegate + UNUserNotificationCenter-in Android ekvivalenti.
 *
 * 1. FCM token yenilenende backend-e gonderir
 * 2. Push notification gelende local notification gosterir
 * 3. Notification tap olunanda muvafiq ekrana yonlendirir
 */
class MyFirebaseMessagingService : FirebaseMessagingService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    companion object {
        private const val TAG = "FCM"
        const val CHANNEL_ID = "corevia_notifications"
        const val CHANNEL_NAME = "CoreVia Bildirisleri"
    }

    // ─── Token yenilenende ──────────────────────────────────────────────────────
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "Yeni FCM token: $token")
        registerTokenWithBackend(token)
    }

    // ─── Push notification gelende ──────────────────────────────────────────────
    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        Log.d(TAG, "Push notification alindi: ${message.data}")

        val title = message.notification?.title ?: message.data["title"] ?: "CoreVia"
        val body = message.notification?.body ?: message.data["body"] ?: ""
        val type = message.data["type"] ?: "system"

        showLocalNotification(title, body, type, message.data)
    }

    // ─── Backend-e token qeyd et ────────────────────────────────────────────────
    private fun registerTokenWithBackend(token: String) {
        val tokenManager = TokenManager.getInstance(applicationContext)
        if (!tokenManager.isLoggedIn) {
            Log.d(TAG, "Istifadeci daxil olmayib, token qeyd edilmeyecek")
            return
        }

        serviceScope.launch {
            try {
                val repository = NotificationRepository.getInstance(applicationContext)
                val deviceName = "${Build.MANUFACTURER} ${Build.MODEL}"
                repository.registerDeviceToken(token, deviceName).fold(
                    onSuccess = { Log.d(TAG, "FCM token ugurla qeyd olundu") },
                    onFailure = { Log.e(TAG, "FCM token qeyd etme xetasi: ${it.message}") }
                )
            } catch (e: Exception) {
                Log.e(TAG, "FCM token qeyd etme xetasi: ${e.message}", e)
            }
        }
    }

    // ─── Lokal bildiris goster ──────────────────────────────────────────────────
    private fun showLocalNotification(
        title: String,
        body: String,
        type: String,
        data: Map<String, String>
    ) {
        createNotificationChannel()

        // Tap olunanda acilacaq intent
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_type", type)
            data.forEach { (key, value) -> putExtra(key, value) }
        }

        val pendingIntent = PendingIntent.getActivity(
            this, System.currentTimeMillis().toInt(),
            intent, PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )

        // Bildiris icon-unu type-a gore sec
        val icon = when {
            type.contains("workout") -> android.R.drawable.ic_menu_compass
            type.contains("meal") || type.contains("food") -> android.R.drawable.ic_menu_gallery
            type.contains("chat") || type.contains("message") -> android.R.drawable.ic_dialog_email
            type.contains("trainer") -> android.R.drawable.ic_menu_myplaces
            type.contains("premium") -> android.R.drawable.btn_star_big_on
            else -> android.R.drawable.ic_popup_reminder
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(icon)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }

    // ─── Notification kanali yarat (Android 8+) ─────────────────────────────────
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "CoreVia fitness app bildirislerini"
                enableLights(true)
                enableVibration(true)
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
