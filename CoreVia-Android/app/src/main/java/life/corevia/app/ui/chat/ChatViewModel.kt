package life.corevia.app.ui.chat

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.ChatRepository

/**
 * iOS ChatManager.swift-in Android ViewModel ekvivalenti.
 *
 * Conversations siyahısı + mesaj tarixçəsi + mesaj göndər + limit.
 */
class ChatViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = ChatRepository.getInstance(application)

    // ─── Conversations ──────────────────────────────────────────────────────────
    private val _conversations = MutableStateFlow<List<Conversation>>(emptyList())
    val conversations: StateFlow<List<Conversation>> = _conversations.asStateFlow()

    // ─── Messages (aktiv söhbət üçün) ───────────────────────────────────────────
    private val _messages = MutableStateFlow<List<ChatMessage>>(emptyList())
    val messages: StateFlow<List<ChatMessage>> = _messages.asStateFlow()

    // ─── Message Limit ──────────────────────────────────────────────────────────
    private val _messageLimit = MutableStateFlow<MessageLimitResponse?>(null)
    val messageLimit: StateFlow<MessageLimitResponse?> = _messageLimit.asStateFlow()

    // ─── Loading / Error ────────────────────────────────────────────────────────
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    // ─── Aktiv söhbət partneri ──────────────────────────────────────────────────
    private val _activeChatUserId = MutableStateFlow<String?>(null)
    val activeChatUserId: StateFlow<String?> = _activeChatUserId.asStateFlow()

    private val _activeChatUserName = MutableStateFlow("")
    val activeChatUserName: StateFlow<String> = _activeChatUserName.asStateFlow()

    init {
        loadConversations()
    }

    // ─── Actions ────────────────────────────────────────────────────────────────

    fun loadConversations() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getConversations().fold(
                onSuccess = { _conversations.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun openChat(userId: String, userName: String) {
        _activeChatUserId.value = userId
        _activeChatUserName.value = userName
        loadMessages(userId)
        loadMessageLimit()
    }

    fun loadMessages(userId: String) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getChatHistory(userId).fold(
                onSuccess = { _messages.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun sendMessage(content: String) {
        val receiverId = _activeChatUserId.value ?: return
        if (content.isBlank()) return

        viewModelScope.launch {
            repository.sendMessage(SendMessageRequest(receiverId, content)).fold(
                onSuccess = { newMessage ->
                    _messages.value = _messages.value + newMessage
                    // Söhbətlər siyahısını yenilə
                    loadConversations()
                    // Limit yenilə
                    loadMessageLimit()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun loadMessageLimit() {
        viewModelScope.launch {
            repository.getMessageLimit().fold(
                onSuccess = { _messageLimit.value = it },
                onFailure = { /* sessiz xəta */ }
            )
        }
    }

    fun closeChat() {
        _activeChatUserId.value = null
        _activeChatUserName.value = ""
        _messages.value = emptyList()
    }

    fun clearError() { _errorMessage.value = null }
}
