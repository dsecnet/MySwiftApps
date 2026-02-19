package life.corevia.app.ui.notifications

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.AppNotification
import life.corevia.app.data.repository.NotificationRepository

/**
 * iOS NotificationManager.swift-in Android ViewModel ekvivalenti.
 *
 * Bildirişlər siyahısı + unread count + mark read + delete.
 */
class NotificationsViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = NotificationRepository.getInstance(application)

    // ─── State ──────────────────────────────────────────────────────────────────
    private val _notifications = MutableStateFlow<List<AppNotification>>(emptyList())
    val notifications: StateFlow<List<AppNotification>> = _notifications.asStateFlow()

    private val _unreadCount = MutableStateFlow(0)
    val unreadCount: StateFlow<Int> = _unreadCount.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    init {
        loadNotifications()
        loadUnreadCount()
    }

    // ─── Actions ────────────────────────────────────────────────────────────────

    fun loadNotifications() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getNotifications().fold(
                onSuccess = { _notifications.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun loadUnreadCount() {
        viewModelScope.launch {
            repository.getUnreadCount().fold(
                onSuccess = { _unreadCount.value = it },
                onFailure = { /* sessiz xəta */ }
            )
        }
    }

    fun markRead(notificationId: String) {
        viewModelScope.launch {
            repository.markRead(listOf(notificationId)).fold(
                onSuccess = {
                    _notifications.value = _notifications.value.map {
                        if (it.id == notificationId) it.copy(isRead = true) else it
                    }
                    loadUnreadCount()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun markAllRead() {
        viewModelScope.launch {
            repository.markAllRead().fold(
                onSuccess = {
                    _notifications.value = _notifications.value.map { it.copy(isRead = true) }
                    _unreadCount.value = 0
                    _successMessage.value = "Bütün bildirişlər oxunmuş kimi işarələndi"
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun deleteNotification(notificationId: String) {
        viewModelScope.launch {
            repository.deleteNotification(notificationId).fold(
                onSuccess = {
                    _notifications.value = _notifications.value.filter { it.id != notificationId }
                    loadUnreadCount()
                    _successMessage.value = "Bildiriş silindi"
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
