package life.corevia.app.ui.chat

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.ChatMessage
import life.corevia.app.data.repository.ChatRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class ChatDetailUiState(
    val userId: String = "",
    val userName: String = "",
    val messages: List<ChatMessage> = emptyList(),
    val messageText: String = "",
    val isLoading: Boolean = false,
    val isSending: Boolean = false,
    val errorMessage: String? = null,
    val remainingMessages: Int? = null
)

@HiltViewModel
class ChatDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val chatRepository: ChatRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ChatDetailUiState())
    val uiState: StateFlow<ChatDetailUiState> = _uiState.asStateFlow()

    init {
        val id = savedStateHandle.get<String>("userId") ?: ""
        val name = savedStateHandle.get<String>("userName") ?: ""
        _uiState.value = _uiState.value.copy(userId = id, userName = name)
        if (id.isNotEmpty()) {
            loadMessages()
            loadMessageLimit()
        }
    }

    fun loadMessages() {
        val userId = _uiState.value.userId
        if (userId.isEmpty()) return
        _uiState.value = _uiState.value.copy(isLoading = true)

        viewModelScope.launch {
            when (val result = chatRepository.getChatHistory(userId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        messages = result.data ?: emptyList()
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    private fun loadMessageLimit() {
        viewModelScope.launch {
            when (val result = chatRepository.getMessageLimit()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        remainingMessages = result.data?.remaining
                    )
                }
                else -> {}
            }
        }
    }

    fun updateMessageText(text: String) {
        _uiState.value = _uiState.value.copy(messageText = text, errorMessage = null)
    }

    fun sendMessage() {
        val state = _uiState.value
        val text = state.messageText.trim()
        if (text.isEmpty() || state.isSending) return

        _uiState.value = state.copy(isSending = true, errorMessage = null)

        viewModelScope.launch {
            when (val result = chatRepository.sendMessage(state.userId, text)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSending = false,
                        messageText = ""
                    )
                    delay(300)
                    loadMessages()
                    loadMessageLimit()
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isSending = false,
                        errorMessage = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}
