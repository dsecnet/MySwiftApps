package life.corevia.app.ui.plans

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.MealPlan
import life.corevia.app.data.model.MealPlanCreateRequest
import life.corevia.app.data.model.MealPlanItemRequest
import life.corevia.app.data.model.PlanType
import life.corevia.app.data.repository.MealPlanRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class MealPlanUiState(
    val isLoading: Boolean = false,
    val mealPlans: List<MealPlan> = emptyList(),
    val selectedFilter: String = "all",
    val error: String? = null
) {
    val filteredPlans: List<MealPlan>
        get() = if (selectedFilter == "all") mealPlans
        else mealPlans.filter { it.planType == selectedFilter }

    val totalPlans: Int get() = mealPlans.size
    val activePlans: Int get() = mealPlans.count { it.isActive }
    val totalMeals: Int get() = mealPlans.sumOf { it.meals.size }
    val avgCalories: Int
        get() = if (mealPlans.isNotEmpty())
            mealPlans.sumOf { it.totalCalories } / mealPlans.size
        else 0
}

data class AddMealPlanUiState(
    val name: String = "",
    val description: String = "",
    val selectedPlanType: PlanType = PlanType.CUSTOM,
    val meals: List<MealPlanItemRequest> = emptyList(),
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val error: String? = null
) {
    val isValid: Boolean get() = name.isNotBlank() && meals.isNotEmpty()
    val totalCalories: Int get() = meals.sumOf { it.calories }
}

@HiltViewModel
class MealPlanViewModel @Inject constructor(
    private val mealPlanRepository: MealPlanRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(MealPlanUiState())
    val uiState: StateFlow<MealPlanUiState> = _uiState.asStateFlow()

    private val _addState = MutableStateFlow(AddMealPlanUiState())
    val addState: StateFlow<AddMealPlanUiState> = _addState.asStateFlow()

    init {
        loadMealPlans()
    }

    fun loadMealPlans() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            when (val result = mealPlanRepository.getMealPlans()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        mealPlans = result.data,
                        isLoading = false
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

    fun setFilter(filter: String) {
        _uiState.value = _uiState.value.copy(selectedFilter = filter)
    }

    fun deleteMealPlan(id: String) {
        viewModelScope.launch {
            when (mealPlanRepository.deleteMealPlan(id)) {
                is NetworkResult.Success -> loadMealPlans()
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }

    // ── Add Meal Plan ──────────────────────────────

    fun updateName(name: String) {
        _addState.value = _addState.value.copy(name = name)
    }

    fun updateDescription(desc: String) {
        _addState.value = _addState.value.copy(description = desc)
    }

    fun updatePlanType(type: PlanType) {
        _addState.value = _addState.value.copy(selectedPlanType = type)
    }

    fun addMealItem(item: MealPlanItemRequest) {
        _addState.value = _addState.value.copy(
            meals = _addState.value.meals + item
        )
    }

    fun removeMealItem(index: Int) {
        val updated = _addState.value.meals.toMutableList()
        if (index in updated.indices) {
            updated.removeAt(index)
            _addState.value = _addState.value.copy(meals = updated)
        }
    }

    fun saveMealPlan() {
        val state = _addState.value
        if (!state.isValid) return

        viewModelScope.launch {
            _addState.value = _addState.value.copy(isLoading = true)
            val request = MealPlanCreateRequest(
                name = state.name,
                description = state.description.ifBlank { null },
                planType = state.selectedPlanType.value,
                meals = state.meals
            )
            when (mealPlanRepository.createMealPlan(request)) {
                is NetworkResult.Success -> {
                    _addState.value = _addState.value.copy(
                        isLoading = false,
                        isSaved = true
                    )
                    loadMealPlans()
                }
                is NetworkResult.Error -> {
                    _addState.value = _addState.value.copy(
                        isLoading = false,
                        error = "Yemək planı saxlanıla bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun resetAddState() {
        _addState.value = AddMealPlanUiState()
    }
}
