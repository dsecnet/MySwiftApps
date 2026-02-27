package life.corevia.app.ui.content

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.ContentCreateRequest
import life.corevia.app.data.model.ContentResponse
import life.corevia.app.data.repository.ContentRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class ContentUiState(
    val isLoading: Boolean = false,
    val contents: List<ContentResponse> = emptyList(),
    val error: String? = null,

    // Create form
    val showCreateSheet: Boolean = false,
    val createTitle: String = "",
    val createBody: String = "",
    val createIsPremiumOnly: Boolean = false,
    val isCreating: Boolean = false,

    // Delete
    val isDeleting: Boolean = false,

    // Mode
    val isTrainerMode: Boolean = false
) {
    val isCreateFormValid: Boolean
        get() = createTitle.isNotBlank() && createBody.isNotBlank()
}

@HiltViewModel
class ContentViewModel @Inject constructor(
    private val contentRepository: ContentRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ContentUiState())
    val uiState: StateFlow<ContentUiState> = _uiState.asStateFlow()

    // ─── Load My Content (Trainer mode) ──────────────────────────────

    fun loadMyContent() {
        _uiState.value = _uiState.value.copy(isTrainerMode = true)
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = contentRepository.fetchMyContent()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        contents = result.data,
                        isLoading = false
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

    // ─── Load Trainer Content (Student mode) ─────────────────────────

    fun loadTrainerContent(trainerId: String) {
        _uiState.value = _uiState.value.copy(isTrainerMode = false)
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = contentRepository.fetchTrainerContent(trainerId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        contents = result.data,
                        isLoading = false
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

    // ─── Create Content ──────────────────────────────────────────────

    fun createContent() {
        val state = _uiState.value
        if (!state.isCreateFormValid) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isCreating = true, error = null)
            val request = ContentCreateRequest(
                title = state.createTitle,
                body = state.createBody,
                contentType = "article",
                isPremiumOnly = state.createIsPremiumOnly
            )
            when (contentRepository.createContent(request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isCreating = false,
                        showCreateSheet = false,
                        createTitle = "",
                        createBody = "",
                        createIsPremiumOnly = false
                    )
                    loadMyContent()
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isCreating = false,
                        error = "Məzmun yaradıla bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    // ─── Delete Content ──────────────────────────────────────────────

    fun deleteContent(contentId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isDeleting = true)
            when (contentRepository.deleteContent(contentId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(isDeleting = false)
                    loadMyContent()
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isDeleting = false,
                        error = "Məzmun silinə bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    // ─── Form Updates ────────────────────────────────────────────────

    fun updateCreateTitle(title: String) {
        _uiState.value = _uiState.value.copy(createTitle = title)
    }

    fun updateCreateBody(body: String) {
        _uiState.value = _uiState.value.copy(createBody = body)
    }

    fun togglePremiumOnly() {
        _uiState.value = _uiState.value.copy(
            createIsPremiumOnly = !_uiState.value.createIsPremiumOnly
        )
    }

    fun toggleCreateSheet() {
        _uiState.value = _uiState.value.copy(
            showCreateSheet = !_uiState.value.showCreateSheet,
            createTitle = "",
            createBody = "",
            createIsPremiumOnly = false
        )
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }
}
