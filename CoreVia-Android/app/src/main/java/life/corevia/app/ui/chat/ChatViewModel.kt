package life.corevia.app.ui.chat

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
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
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            try {
                repository.getConversations().fold(
                    onSuccess = { withContext(Dispatchers.Main) { _conversations.value = it } },
                    onFailure = { e ->
                        val msg = if (e is Exception) ErrorParser.parseMessage(e) else e.message ?: "Xəta"
                        withContext(Dispatchers.Main) { _errorMessage.value = msg }
                    }
                )
            } catch (e: Exception) {
                withContext(Dispatchers.Main) { _errorMessage.value = e.message ?: "Xəta baş verdi" }
            }
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun openChat(userId: String, userName: String) {
        _activeChatUserId.value = userId
        _activeChatUserName.value = userName
        loadMessages(userId)
        loadMessageLimit()
    }

    fun loadMessages(userId: String) {
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            try {
                repository.getChatHistory(userId).fold(
                    onSuccess = { withContext(Dispatchers.Main) { _messages.value = it } },
                    onFailure = { e ->
                        val msg = if (e is Exception) ErrorParser.parseMessage(e) else e.message ?: "Xəta"
                        withContext(Dispatchers.Main) { _errorMessage.value = msg }
                    }
                )
            } catch (e: Exception) {
                withContext(Dispatchers.Main) { _errorMessage.value = e.message ?: "Xəta baş verdi" }
            }
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun sendMessage(message: String) {
        val receiverId = _activeChatUserId.value ?: return
        if (message.isBlank()) return

        viewModelScope.launch(Dispatchers.IO) {
            try {
                repository.sendMessage(SendMessageRequest(receiverId, message)).fold(
                    onSuccess = { newMessage ->
                        withContext(Dispatchers.Main) {
                            _messages.value = _messages.value + newMessage
                        }
                        // Söhbətlər siyahısını yenilə
                        repository.getConversations().fold(
                            onSuccess = { withContext(Dispatchers.Main) { _conversations.value = it } },
                            onFailure = { /* ignore */ }
                        )
                        // Limit yenilə
                        repository.getMessageLimit().fold(
                            onSuccess = { withContext(Dispatchers.Main) { _messageLimit.value = it } },
                            onFailure = { /* ignore */ }
                        )
                    },
                    onFailure = { e ->
                        val msg = if (e is Exception) ErrorParser.parseMessage(e) else e.message ?: "Xəta"
                        withContext(Dispatchers.Main) { _errorMessage.value = msg }
                    }
                )
            } catch (e: Exception) {
                withContext(Dispatchers.Main) { _errorMessage.value = e.message ?: "Xəta baş verdi" }
            }
        }
    }

    fun loadMessageLimit() {
        viewModelScope.launch(Dispatchers.IO) {
            repository.getMessageLimit().fold(
                onSuccess = { withContext(Dispatchers.Main) { _messageLimit.value = it } },
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
