package life.corevia.app.ui.food

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.DailyFoodStats
import life.corevia.app.data.model.FoodCreateRequest
import life.corevia.app.data.model.FoodEntry
import life.corevia.app.data.model.MealType
import life.corevia.app.data.repository.FoodRepository
import life.corevia.app.util.NetworkResult
import life.corevia.app.util.toUserFriendlyError
import javax.inject.Inject

data class FoodUiState(
    val isLoading: Boolean = false,
    val dailyStats: DailyFoodStats = DailyFoodStats(),
    val entries: List<FoodEntry> = emptyList(),
    val waterGlasses: Int = 0,
    val calorieGoal: Int = 2000,
    val error: String? = null,
    val showAddSheet: Boolean = false,
    val showEditGoal: Boolean = false
) {
    val todayCalories: Int get() = dailyStats.totalCalories
    val todayProtein: Double get() = dailyStats.totalProtein
    val todayCarbs: Double get() = dailyStats.totalCarbs
    val todayFats: Double get() = dailyStats.totalFats
    val calorieProgress: Float get() {
        if (calorieGoal <= 0) return 0f
        return (todayCalories.toFloat() / calorieGoal).coerceIn(0f, 1.5f)
    }
    val remainingCalories: Int get() = calorieGoal - todayCalories

    fun entriesForMeal(mealType: MealType): List<FoodEntry> =
        entries.filter { it.mealType == mealType.value }
}

@HiltViewModel
class FoodViewModel @Inject constructor(
    private val foodRepository: FoodRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(FoodUiState())
    val uiState: StateFlow<FoodUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            launch { loadDailyStats() }
            launch { loadEntries() }
        }
    }

    private suspend fun loadDailyStats() {
        when (val result = foodRepository.getDailyStats()) {
            is NetworkResult.Success -> {
                _uiState.value = _uiState.value.copy(
                    dailyStats = result.data,
                    calorieGoal = result.data.calorieGoal,
                    waterGlasses = result.data.waterGlasses,
                    isLoading = false
                )
            }
            is NetworkResult.Error -> {
                _uiState.value = _uiState.value.copy(isLoading = false, error = result.message.toUserFriendlyError())
            }
            is NetworkResult.Loading -> {}
        }
    }

    private suspend fun loadEntries() {
        when (val result = foodRepository.getFoodEntries()) {
            is NetworkResult.Success -> {
                _uiState.value = _uiState.value.copy(entries = result.data, isLoading = false)
            }
            is NetworkResult.Error -> {
                _uiState.value = _uiState.value.copy(isLoading = false)
            }
            is NetworkResult.Loading -> {}
        }
    }

    fun addFood(name: String, calories: Int, protein: Double?, carbs: Double?, fats: Double?, mealType: MealType, notes: String?) {
        viewModelScope.launch {
            val request = FoodCreateRequest(
                name = name,
                calories = calories,
                protein = protein,
                carbs = carbs,
                fats = fats,
                mealType = mealType.value,
                notes = notes
            )
            when (foodRepository.addEntry(request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(showAddSheet = false)
                    loadData()
                }
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun deleteEntry(id: String) {
        viewModelScope.launch {
            when (foodRepository.deleteEntry(id)) {
                is NetworkResult.Success -> loadData()
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun addWater() {
        if (_uiState.value.waterGlasses < 8) {
            _uiState.value = _uiState.value.copy(waterGlasses = _uiState.value.waterGlasses + 1)
        }
    }

    fun removeWater() {
        if (_uiState.value.waterGlasses > 0) {
            _uiState.value = _uiState.value.copy(waterGlasses = _uiState.value.waterGlasses - 1)
        }
    }

    fun toggleAddSheet() {
        _uiState.value = _uiState.value.copy(showAddSheet = !_uiState.value.showAddSheet)
    }

    fun toggleEditGoal() {
        _uiState.value = _uiState.value.copy(showEditGoal = !_uiState.value.showEditGoal)
    }

    fun updateCalorieGoal(goal: Int) {
        _uiState.value = _uiState.value.copy(calorieGoal = goal, showEditGoal = false)
    }
}
