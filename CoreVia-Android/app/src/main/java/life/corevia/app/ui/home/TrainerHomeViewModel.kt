package life.corevia.app.ui.home

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
        _isLoading.value = true
        _errorMessage.value = null
        viewModelScope.launch(Dispatchers.IO) {
            repository.getTrainerStats().fold(
                onSuccess = { withContext(Dispatchers.Main) { _stats.value = it } },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }
}
