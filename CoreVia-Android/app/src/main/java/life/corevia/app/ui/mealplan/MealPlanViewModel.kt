package life.corevia.app.ui.mealplan

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

    // Selected plan for editing
    private val _selectedPlan = MutableStateFlow<MealPlan?>(null)
    val selectedPlan: StateFlow<MealPlan?> = _selectedPlan.asStateFlow()

    val filteredPlans: List<MealPlan>
        get() = _selectedFilter.value?.let { filter ->
            _plans.value.filter { it.planType == filter }
        } ?: _plans.value

    init {
        loadPlans()
    }

    fun loadPlans() {
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            repository.getMealPlans().fold(
                onSuccess = { withContext(Dispatchers.Main) { _plans.value = it } },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun createPlan(request: MealPlanCreateRequest) {
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            repository.createMealPlan(request).fold(
                onSuccess = {
                    withContext(Dispatchers.Main) { _successMessage.value = "Qida planı yaradıldı" }
                    repository.getMealPlans().fold(
                        onSuccess = { plans -> withContext(Dispatchers.Main) { _plans.value = plans } },
                        onFailure = { /* ignore refresh error */ }
                    )
                },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun completePlan(planId: String) {
        viewModelScope.launch(Dispatchers.IO) {
            repository.completeMealPlan(planId).fold(
                onSuccess = {
                    withContext(Dispatchers.Main) { _successMessage.value = "Plan tamamlandı" }
                    repository.getMealPlans().fold(
                        onSuccess = { plans -> withContext(Dispatchers.Main) { _plans.value = plans } },
                        onFailure = { /* ignore */ }
                    )
                },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
        }
    }

    fun deletePlan(planId: String) {
        viewModelScope.launch(Dispatchers.IO) {
            repository.deleteMealPlan(planId).fold(
                onSuccess = {
                    withContext(Dispatchers.Main) { _successMessage.value = "Plan silindi" }
                    repository.getMealPlans().fold(
                        onSuccess = { plans -> withContext(Dispatchers.Main) { _plans.value = plans } },
                        onFailure = { /* ignore */ }
                    )
                },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
        }
    }

    fun updatePlan(planId: String, request: MealPlanCreateRequest) {
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            repository.updateMealPlan(planId, request).fold(
                onSuccess = {
                    withContext(Dispatchers.Main) { _successMessage.value = "Qida planı yeniləndi" }
                    repository.getMealPlans().fold(
                        onSuccess = { plans -> withContext(Dispatchers.Main) { _plans.value = plans } },
                        onFailure = { /* ignore refresh error */ }
                    )
                },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun selectPlan(plan: MealPlan) { _selectedPlan.value = plan }
    fun clearSelectedPlan() { _selectedPlan.value = null }
    fun setFilter(planType: String?) { _selectedFilter.value = planType }
    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
