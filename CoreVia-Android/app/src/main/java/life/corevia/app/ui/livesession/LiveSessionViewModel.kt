package life.corevia.app.ui.livesession

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

data class LiveSessionListUiState(
    val sessions: List<LiveSession> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val selectedFilter: String = "all"
) {
    val filteredSessions: List<LiveSession>
        get() = if (selectedFilter == "all") sessions
        else sessions.filter { it.status == selectedFilter }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ═══════════════════════════════════════════════════════════════════

@HiltViewModel
class LiveSessionViewModel @Inject constructor(
    private val repository: LiveSessionRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(LiveSessionListUiState())
    val uiState: StateFlow<LiveSessionListUiState> = _uiState.asStateFlow()

    init {
        loadSessions()
    }

    // ─── Load Sessions ───────────────────────────────────────────

    fun loadSessions() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = repository.getLiveSessions()) {
                is NetworkResult.Success -> _uiState.value = _uiState.value.copy(
                    sessions = result.data,
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

    // ─── Set Filter ──────────────────────────────────────────────

    fun setFilter(filter: String) {
        _uiState.value = _uiState.value.copy(selectedFilter = filter)
    }

    // ─── Delete Session ──────────────────────────────────────────

    fun deleteSession(id: String) {
        viewModelScope.launch {
            when (repository.deleteLiveSession(id)) {
                is NetworkResult.Success -> _uiState.value = _uiState.value.copy(
                    sessions = _uiState.value.sessions.filter { it.id != id }
                )
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }
}
