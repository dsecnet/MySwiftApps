package life.corevia.app.ui.mealplan

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.MealPlan
import life.corevia.app.data.models.MealPlanCreateRequest
import life.corevia.app.data.repository.MealPlanRepository

/**
 * iOS MealPlanManager.swift → Android MealPlanViewModel
 */
class MealPlanViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = MealPlanRepository.getInstance(application)

    private val _plans = MutableStateFlow<List<MealPlan>>(emptyList())
    val plans: StateFlow<List<MealPlan>> = _plans.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    private val _selectedFilter = MutableStateFlow<String?>(null)
    val selectedFilter: StateFlow<String?> = _selectedFilter.asStateFlow()

    val filteredPlans: List<MealPlan>
        get() = _selectedFilter.value?.let { filter ->
            _plans.value.filter { it.planType == filter }
        } ?: _plans.value

    init {
        loadPlans()
    }

    fun loadPlans() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getMealPlans().fold(
                onSuccess = { _plans.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun createPlan(request: MealPlanCreateRequest) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.createMealPlan(request).fold(
                onSuccess = {
                    _successMessage.value = "Qida planı yaradıldı"
                    loadPlans()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun completePlan(planId: String) {
        viewModelScope.launch {
            repository.completeMealPlan(planId).fold(
                onSuccess = {
                    _successMessage.value = "Plan tamamlandı"
                    loadPlans()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun deletePlan(planId: String) {
        viewModelScope.launch {
            repository.deleteMealPlan(planId).fold(
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
