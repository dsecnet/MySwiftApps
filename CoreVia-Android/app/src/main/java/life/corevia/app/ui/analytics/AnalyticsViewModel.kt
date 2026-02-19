package life.corevia.app.ui.analytics

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.AnalyticsRepository

/**
 * iOS AnalyticsManager.swift-in Android ViewModel ekvivalenti.
 *
 * Dashboard + weekly stats + body measurements CRUD.
 */
class AnalyticsViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = AnalyticsRepository.getInstance(application)

    // ─── State ──────────────────────────────────────────────────────────────────
    private val _dashboard = MutableStateFlow<AnalyticsDashboard?>(null)
    val dashboard: StateFlow<AnalyticsDashboard?> = _dashboard.asStateFlow()

    private val _weeklyStats = MutableStateFlow<WeeklyStats?>(null)
    val weeklyStats: StateFlow<WeeklyStats?> = _weeklyStats.asStateFlow()

    private val _measurements = MutableStateFlow<List<BodyMeasurement>>(emptyList())
    val measurements: StateFlow<List<BodyMeasurement>> = _measurements.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    // ─── Add Measurement Sheet ──────────────────────────────────────────────────
    private val _showAddMeasurement = MutableStateFlow(false)
    val showAddMeasurement: StateFlow<Boolean> = _showAddMeasurement.asStateFlow()

    init {
        loadDashboard()
        loadMeasurements()
    }

    // ─── Actions ────────────────────────────────────────────────────────────────

    fun loadDashboard() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getDashboard().fold(
                onSuccess = { _dashboard.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            // Həftəlik stats da yüklə
            repository.getWeeklyStats().fold(
                onSuccess = { _weeklyStats.value = it },
                onFailure = { /* dashboard-da göstərəcəyik */ }
            )
            _isLoading.value = false
        }
    }

    fun loadMeasurements() {
        viewModelScope.launch {
            repository.getMeasurements().fold(
                onSuccess = { _measurements.value = it },
                onFailure = { /* sessiz xəta */ }
            )
        }
    }

    fun createMeasurement(request: BodyMeasurementCreateRequest) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.createMeasurement(request).fold(
                onSuccess = { newMeasurement ->
                    _measurements.value = listOf(newMeasurement) + _measurements.value
                    _showAddMeasurement.value = false
                    _successMessage.value = "Ölçü əlavə edildi"
                    // Dashboard yenilə
                    loadDashboard()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun deleteMeasurement(measurementId: String) {
        viewModelScope.launch {
            repository.deleteMeasurement(measurementId).fold(
                onSuccess = {
                    _measurements.value = _measurements.value.filter { it.id != measurementId }
                    _successMessage.value = "Ölçü silindi"
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun setShowAddMeasurement(show: Boolean) { _showAddMeasurement.value = show }
    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
