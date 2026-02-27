package life.corevia.app.ui.social

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.PostComment
import life.corevia.app.data.repository.SocialRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class CommentsUiState(
    val isLoading: Boolean = false,
    val comments: List<PostComment> = emptyList(),
    val newComment: String = "",
    val isSending: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class CommentsViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val socialRepository: SocialRepository
) : ViewModel() {

    private val postId: String = savedStateHandle.get<String>("postId") ?: ""

    private val _uiState = MutableStateFlow(CommentsUiState())
    val uiState: StateFlow<CommentsUiState> = _uiState.asStateFlow()

    init {
        loadComments()
    }

    fun loadComments() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            when (val result = socialRepository.getComments(postId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        comments = result.data
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun updateNewComment(value: String) {
        _uiState.value = _uiState.value.copy(newComment = value)
    }

    fun sendComment() {
        val content = _uiState.value.newComment.trim()
        if (content.isBlank()) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSending = true)
            when (socialRepository.addComment(postId, content)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSending = false,
                        newComment = ""
                    )
                    loadComments()
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isSending = false,
                        error = "Şərh göndərilə bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun deleteComment(commentId: String) {
        viewModelScope.launch {
            when (socialRepository.deleteComment(postId, commentId)) {
                is NetworkResult.Success -> loadComments()
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }
}
