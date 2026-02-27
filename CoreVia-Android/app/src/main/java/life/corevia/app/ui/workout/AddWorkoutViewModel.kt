package life.corevia.app.ui.workout

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.WorkoutCreateRequest
import life.corevia.app.data.model.WorkoutType
import life.corevia.app.data.repository.WorkoutRepository
import life.corevia.app.util.NetworkResult
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.inject.Inject

data class AddWorkoutUiState(
    val title: String = "",
    val selectedCategory: WorkoutType = WorkoutType.STRENGTH,
    val duration: Int = 30,
    val caloriesBurned: String = "",
    val notes: String = "",
    val selectedDate: Long = System.currentTimeMillis(),
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val errorMessage: String? = null
) {
    val isFormValid: Boolean
        get() {
            val trimmed = title.trim()
            if (trimmed.isEmpty() || trimmed.length > 200) return false
            if (duration < 1 || duration > 1440) return false
            if (caloriesBurned.isNotEmpty()) {
                val cal = caloriesBurned.toIntOrNull() ?: return false
                if (cal < 0 || cal > 10000) return false
            }
            return true
        }
}

@HiltViewModel
class AddWorkoutViewModel @Inject constructor(
    private val workoutRepository: WorkoutRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AddWorkoutUiState())
    val uiState: StateFlow<AddWorkoutUiState> = _uiState.asStateFlow()

    fun updateTitle(value: String) {
        if (value.length <= 200) {
            _uiState.value = _uiState.value.copy(title = value, errorMessage = null)
        }
    }

    fun updateCategory(category: WorkoutType) {
        _uiState.value = _uiState.value.copy(selectedCategory = category)
    }

    fun increaseDuration() {
        val cur = _uiState.value.duration
        if (cur < 1440) _uiState.value = _uiState.value.copy(duration = cur + 5)
    }

    fun decreaseDuration() {
        val cur = _uiState.value.duration
        if (cur > 5) _uiState.value = _uiState.value.copy(duration = cur - 5)
    }

    fun updateCalories(value: String) {
        val filtered = value.filter { it.isDigit() }
        if (filtered.isEmpty() || (filtered.toIntOrNull() ?: 0) <= 10000) {
            _uiState.value = _uiState.value.copy(caloriesBurned = filtered, errorMessage = null)
        }
    }

    fun updateNotes(value: String) {
        if (value.length <= 1000) {
            _uiState.value = _uiState.value.copy(notes = value, errorMessage = null)
        }
    }

    fun updateDate(millis: Long) {
        _uiState.value = _uiState.value.copy(selectedDate = millis)
    }

    fun saveWorkout() {
        val state = _uiState.value
        if (!state.isFormValid) {
            _uiState.value = state.copy(errorMessage = "Formu duzgun doldurun")
            return
        }
        _uiState.value = state.copy(isLoading = true, errorMessage = null)

        viewModelScope.launch {
            val dateStr = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                .format(Date(state.selectedDate))

            val request = WorkoutCreateRequest(
                title = state.title.trim(),
                category = state.selectedCategory.value,
                duration = state.duration,
                caloriesBurned = state.caloriesBurned.toIntOrNull(),
                notes = state.notes.trim().ifBlank { null },
                date = dateStr
            )

            when (val result = workoutRepository.createWorkout(request)) {
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
