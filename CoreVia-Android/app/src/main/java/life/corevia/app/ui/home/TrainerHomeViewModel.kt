package life.corevia.app.ui.home

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.TrainerStatsResponse
import life.corevia.app.data.repository.TrainerRepository

/**
 * iOS: TrainerDashboardManager — Android ViewModel ekvivalenti.
 * GET /api/v1/trainer/stats — dashboard statistikalar + tələbə siyahısı.
 */
class TrainerHomeViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = TrainerRepository.getInstance(application)

    private val _stats = MutableStateFlow<TrainerStatsResponse?>(null)
    val stats: StateFlow<TrainerStatsResponse?> = _stats.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        fetchStats()
    }

    fun fetchStats() {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null
            repository.getTrainerStats().fold(
                onSuccess = { _stats.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }
}
