package life.corevia.app.ui.food

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.FoodCreateRequest
import life.corevia.app.data.model.MealType
import life.corevia.app.data.repository.FoodRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class AddFoodUiState(
    val foodName: String = "",
    val calories: String = "",
    val protein: String = "",
    val carbs: String = "",
    val fats: String = "",
    val selectedMealType: MealType = MealType.BREAKFAST,
    val notes: String = "",
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val errorMessage: String? = null
) {
    val isFormValid: Boolean
        get() = foodName.trim().isNotEmpty() &&
                calories.isNotEmpty() &&
                (calories.toIntOrNull() ?: 0) > 0
}

@HiltViewModel
class AddFoodViewModel @Inject constructor(
    private val foodRepository: FoodRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AddFoodUiState())
    val uiState: StateFlow<AddFoodUiState> = _uiState.asStateFlow()

    fun updateFoodName(value: String) {
        if (value.length <= 200) {
            _uiState.value = _uiState.value.copy(foodName = value, errorMessage = null)
        }
    }

    fun updateCalories(value: String) {
        val filtered = value.filter { it.isDigit() }
        if (filtered.isEmpty() || (filtered.toIntOrNull() ?: 0) <= 10000) {
            _uiState.value = _uiState.value.copy(calories = filtered, errorMessage = null)
        }
    }

    fun updateProtein(value: String) {
        val filtered = value.filter { it.isDigit() || it == '.' }
        _uiState.value = _uiState.value.copy(protein = filtered)
    }

    fun updateCarbs(value: String) {
        val filtered = value.filter { it.isDigit() || it == '.' }
        _uiState.value = _uiState.value.copy(carbs = filtered)
    }

    fun updateFats(value: String) {
        val filtered = value.filter { it.isDigit() || it == '.' }
        _uiState.value = _uiState.value.copy(fats = filtered)
    }

    fun updateMealType(type: MealType) {
        _uiState.value = _uiState.value.copy(selectedMealType = type)
    }

    fun updateNotes(value: String) {
        if (value.length <= 500) {
            _uiState.value = _uiState.value.copy(notes = value)
        }
    }

    fun saveFoodEntry() {
        val state = _uiState.value
        if (!state.isFormValid) {
            _uiState.value = state.copy(errorMessage = "Ad ve kalori daxil edin")
            return
        }
        _uiState.value = state.copy(isLoading = true, errorMessage = null)

        viewModelScope.launch {
            val request = FoodCreateRequest(
                name = state.foodName.trim(),
                calories = state.calories.toIntOrNull() ?: 0,
                protein = state.protein.toDoubleOrNull(),
                carbs = state.carbs.toDoubleOrNull(),
                fats = state.fats.toDoubleOrNull(),
                mealType = state.selectedMealType.value,
                notes = state.notes.trim().ifBlank { null }
            )

            when (val result = foodRepository.addEntry(request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(isLoading = false, isSaved = true)
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = result.message)
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}
