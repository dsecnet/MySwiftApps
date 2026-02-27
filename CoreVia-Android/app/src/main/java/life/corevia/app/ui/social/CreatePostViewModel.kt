package life.corevia.app.ui.social

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.CreatePostRequest
import life.corevia.app.data.model.PostType
import life.corevia.app.data.repository.SocialRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class CreatePostUiState(
    val content: String = "",
    val selectedType: PostType = PostType.GENERAL,
    val isPublic: Boolean = true,
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val errorMessage: String? = null
) {
    val isFormValid: Boolean get() = content.isNotBlank()
}

@HiltViewModel
class CreatePostViewModel @Inject constructor(
    private val socialRepository: SocialRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CreatePostUiState())
    val uiState: StateFlow<CreatePostUiState> = _uiState.asStateFlow()

    fun updateContent(value: String) {
        _uiState.value = _uiState.value.copy(content = value)
    }

    fun updateType(type: PostType) {
        _uiState.value = _uiState.value.copy(selectedType = type)
    }

    fun togglePublic() {
        _uiState.value = _uiState.value.copy(isPublic = !_uiState.value.isPublic)
    }

    fun createPost() {
        val state = _uiState.value
        if (!state.isFormValid) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            val request = CreatePostRequest(
                content = state.content,
                postType = state.selectedType.value,
                isPublic = state.isPublic
            )
            when (socialRepository.createPost(request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(isLoading = false, isSaved = true)
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = "Post yaradıla bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}
