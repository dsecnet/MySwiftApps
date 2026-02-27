package life.corevia.app.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.ChatConversation
import life.corevia.app.data.model.ChatMessage
import life.corevia.app.data.model.MessageLimitResponse
import life.corevia.app.data.repository.ChatRepository
import life.corevia.app.util.NetworkResult
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.inject.Inject

data class ConversationsUiState(
    val isLoading: Boolean = false,
    val conversations: List<ChatConversation> = emptyList(),
    val messageLimit: MessageLimitResponse = MessageLimitResponse(),
    val error: String? = null,
    val selectedConversation: ChatConversation? = null,
    val messages: List<ChatMessage> = emptyList(),
    val isLoadingMessages: Boolean = false,
    val isSending: Boolean = false
)

@HiltViewModel
class ConversationsViewModel @Inject constructor(
    private val chatRepository: ChatRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ConversationsUiState())
    val uiState: StateFlow<ConversationsUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            launch { loadConversations() }
            launch { loadMessageLimit() }
        }
    }

    private suspend fun loadConversations() {
        when (val result = chatRepository.getConversations()) {
            is NetworkResult.Success -> {
                _uiState.value = _uiState.value.copy(conversations = result.data, isLoading = false)
            }
            is NetworkResult.Error -> {
                _uiState.value = _uiState.value.copy(isLoading = false, error = result.message)
            }
            is NetworkResult.Loading -> {}
        }
    }

    private suspend fun loadMessageLimit() {
        when (val result = chatRepository.getMessageLimit()) {
            is NetworkResult.Success -> {
                _uiState.value = _uiState.value.copy(messageLimit = result.data)
            }
            is NetworkResult.Error -> {}
            is NetworkResult.Loading -> {}
        }
    }

    fun openConversation(conversation: ChatConversation) {
        _uiState.value = _uiState.value.copy(
            selectedConversation = conversation,
            isLoadingMessages = true,
            messages = emptyList()
        )
        viewModelScope.launch {
            when (val result = chatRepository.getChatHistory(conversation.usersId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(messages = result.data, isLoadingMessages = false)
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(isLoadingMessages = false)
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun closeConversation() {
        _uiState.value = _uiState.value.copy(selectedConversation = null, messages = emptyList())
    }

    fun sendMessage(message: String) {
        val conversation = _uiState.value.selectedConversation ?: return
        if (message.isBlank()) return

        _uiState.value = _uiState.value.copy(isSending = true)
        viewModelScope.launch {
            when (val result = chatRepository.sendMessage(conversation.usersId, message)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        messages = _uiState.value.messages + result.data,
                        isSending = false
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(isSending = false)
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun formatTime(dateString: String?): String {
        if (dateString == null) return ""
        return try {
            val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            val outputFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
            val date = inputFormat.parse(dateString)
            outputFormat.format(date ?: Date())
        } catch (e: Exception) { "" }
    }
}
