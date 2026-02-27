package life.corevia.app.ui.analytics

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.AnalyticsDashboardResponse
import life.corevia.app.data.model.NutritionTrend
import life.corevia.app.data.model.ThirtyDaySummary
import life.corevia.app.data.model.WeeklyStatsResponse
import life.corevia.app.data.model.WorkoutTrend
import life.corevia.app.data.repository.AnalyticsRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class AnalyticsDashboardUiState(
    val isLoading: Boolean = false,
    val error: String? = null,
    val currentWeek: WeeklyStatsResponse = WeeklyStatsResponse(),
    val workoutTrend: List<WorkoutTrend> = emptyList(),
    val nutritionTrend: List<NutritionTrend> = emptyList(),
    val thirtyDaySummary: ThirtyDaySummary = ThirtyDaySummary()
)

@HiltViewModel
class AnalyticsDashboardViewModel @Inject constructor(
    private val analyticsRepository: AnalyticsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AnalyticsDashboardUiState())
    val uiState: StateFlow<AnalyticsDashboardUiState> = _uiState.asStateFlow()

    init {
        loadDashboard()
    }

    fun loadDashboard() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = analyticsRepository.getDashboard()) {
                is NetworkResult.Success -> {
                    val data = result.data
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        currentWeek = data.currentWeek,
                        workoutTrend = data.workoutTrend,
                        nutritionTrend = data.nutritionTrend,
                        thirtyDaySummary = data.thirtyDaySummary
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
}
