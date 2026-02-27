package life.corevia.app.ui.livesession

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.LiveSession
import life.corevia.app.data.repository.LiveSessionRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

// ═══════════════════════════════════════════════════════════════════
// MARK: - UI State
// ═══════════════════════════════════════════════════════════════════

data class LiveSessionDetailUiState(
    val session: LiveSession? = null,
    val isLoading: Boolean = false,
    val isJoining: Boolean = false,
    val error: String? = null
)

// ═══════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ═══════════════════════════════════════════════════════════════════

@HiltViewModel
class LiveSessionDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val repository: LiveSessionRepository
) : ViewModel() {

    private val sessionId: String = savedStateHandle.get<String>("sessionId") ?: ""

    private val _uiState = MutableStateFlow(LiveSessionDetailUiState())
    val uiState: StateFlow<LiveSessionDetailUiState> = _uiState.asStateFlow()

    init {
        loadSession()
    }

    // ─── Load Session ────────────────────────────────────────────

    fun loadSession() {
        if (sessionId.isBlank()) {
            _uiState.value = _uiState.value.copy(error = "Sessiya ID tapılmadı")
            return
        }

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = repository.getLiveSession(sessionId)) {
                is NetworkResult.Success -> _uiState.value = _uiState.value.copy(
                    session = result.data,
                    isLoading = false
                )
                is NetworkResult.Error -> _uiState.value = _uiState.value.copy(
                    error = result.message,
                    isLoading = false
                )
                is NetworkResult.Loading -> {}
            }
        }
    }

    // ─── Join Session ────────────────────────────────────────────

    fun joinSession(onSuccess: () -> Unit = {}) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isJoining = true)
            when (val result = repository.joinLiveSession(sessionId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        session = result.data,
                        isJoining = false
                    )
                    onSuccess()
                }
                is NetworkResult.Error -> _uiState.value = _uiState.value.copy(
                    error = result.message,
                    isJoining = false
                )
                is NetworkResult.Loading -> {}
            }
        }
    }
}
