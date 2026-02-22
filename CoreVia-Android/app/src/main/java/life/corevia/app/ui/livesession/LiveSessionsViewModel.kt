package life.corevia.app.ui.livesession

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.LiveSessionRepository

class LiveSessionsViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = LiveSessionRepository.getInstance(application)

    private val _sessions = MutableStateFlow<List<LiveSession>>(emptyList())
    val sessions: StateFlow<List<LiveSession>> = _sessions.asStateFlow()

    private val _selectedSession = MutableStateFlow<LiveSession?>(null)
    val selectedSession: StateFlow<LiveSession?> = _selectedSession.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    init { loadSessions() }

    fun loadSessions() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getSessions().fold(
                onSuccess = { _sessions.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun selectSession(session: LiveSession) { _selectedSession.value = session }

    fun joinSession(sessionId: String) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.joinSession(sessionId).fold(
                onSuccess = {
                    _selectedSession.value = it
                    _successMessage.value = "Sessiyaya qoşuldunuz!"
                    loadSessions()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun leaveSession(sessionId: String) {
        viewModelScope.launch {
            repository.leaveSession(sessionId).fold(
                onSuccess = {
                    _successMessage.value = "Sessiyadan ayrıldınız"
                    loadSessions()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    private val _selectedFilter = MutableStateFlow<String?>(null)
    val selectedFilter: StateFlow<String?> = _selectedFilter.asStateFlow()

    fun selectFilter(filter: String?) { _selectedFilter.value = filter }

    val filteredSessions: List<LiveSession>
        get() {
            val filter = _selectedFilter.value
            return if (filter != null) {
                _sessions.value.filter { it.status == filter }
            } else {
                _sessions.value
            }
        }

    val upcomingSessions: List<LiveSession>
        get() = _sessions.value.filter { it.status == "scheduled" }

    val liveSessions: List<LiveSession>
        get() = _sessions.value.filter { it.status == "live" }

    val endedSessions: List<LiveSession>
        get() = _sessions.value.filter { it.status in listOf("completed", "ended") }

    fun clearSelectedSession() { _selectedSession.value = null }
    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
