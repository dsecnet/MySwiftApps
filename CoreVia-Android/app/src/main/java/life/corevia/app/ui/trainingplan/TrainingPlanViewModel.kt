package life.corevia.app.ui.trainingplan

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.PlanType
import life.corevia.app.data.models.TrainingPlan
import life.corevia.app.data.models.TrainingPlanCreateRequest
import life.corevia.app.data.repository.TrainingPlanRepository

/**
 * iOS TrainingPlanManager.swift → Android TrainingPlanViewModel
 * UPDATED: createPlan, completePlan, deletePlan əlavə edildi
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

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

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
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // iOS: TrainingPlanManager.savePlan(_:)
    fun createPlan(request: TrainingPlanCreateRequest) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.createTrainingPlan(request).fold(
                onSuccess = {
                    _successMessage.value = "Plan yaradıldı"
                    loadPlans()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // iOS: complete plan
    fun completePlan(planId: String) {
        viewModelScope.launch {
            repository.completeTrainingPlan(planId).fold(
                onSuccess = {
                    _successMessage.value = "Plan tamamlandı"
                    loadPlans()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    // iOS: delete plan
    fun deletePlan(planId: String) {
        viewModelScope.launch {
            repository.deleteTrainingPlan(planId).fold(
                onSuccess = {
                    _successMessage.value = "Plan silindi"
                    loadPlans()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun setFilter(planType: String?) { _selectedFilter.value = planType }
    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
