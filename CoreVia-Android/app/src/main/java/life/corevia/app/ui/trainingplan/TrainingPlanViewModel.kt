package life.corevia.app.ui.trainingplan

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.models.PlanType
import life.corevia.app.data.models.TrainingPlan
import life.corevia.app.data.repository.TrainingPlanRepository

/**
 * iOS TrainingPlanManager.swift → Android TrainingPlanViewModel
 */
class TrainingPlanViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = TrainingPlanRepository.getInstance(application)

    // iOS: @Published var plans: [TrainingPlan] = []
    private val _plans = MutableStateFlow<List<TrainingPlan>>(emptyList())
    val plans: StateFlow<List<TrainingPlan>> = _plans.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    // iOS: var selectedFilter: PlanType?
    private val _selectedFilter = MutableStateFlow<String?>(null)
    val selectedFilter: StateFlow<String?> = _selectedFilter.asStateFlow()

    // iOS: var filteredPlans: [TrainingPlan] { computed }
    val filteredPlans: List<TrainingPlan>
        get() = _selectedFilter.value?.let { filter ->
            _plans.value.filter { it.planType == filter }
        } ?: _plans.value

    init {
        loadPlans()
    }

    fun loadPlans() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getTrainingPlans().fold(
                onSuccess = { _plans.value = it },
                onFailure = { _errorMessage.value = it.message }
            )
            _isLoading.value = false
        }
    }

    fun setFilter(planType: String?) { _selectedFilter.value = planType }
    fun clearError() { _errorMessage.value = null }
}
