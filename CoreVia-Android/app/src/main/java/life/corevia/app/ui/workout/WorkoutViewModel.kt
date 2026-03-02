package life.corevia.app.ui.workout

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.Workout
import life.corevia.app.data.model.WorkoutCreateRequest
import life.corevia.app.data.repository.WorkoutRepository
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import life.corevia.app.ui.theme.*
import life.corevia.app.util.NetworkResult
import life.corevia.app.util.toUserFriendlyError
import timber.log.Timber
import javax.inject.Inject

data class WorkoutUiState(
    val isLoading: Boolean = false,
    val workouts: List<Workout> = emptyList(),
    val showAddWorkout: Boolean = false,
    val error: String? = null
) {
    val todayWorkouts: List<Workout> get() = workouts.filter { !it.isCompleted }
    val completedWorkouts: List<Workout> get() = workouts.filter { it.isCompleted }

    val weekWorkoutCount: Int get() = workouts.size
    val weekCompletedCount: Int get() = completedWorkouts.size
    val weekTotalMinutes: Int get() = workouts.sumOf { it.duration }
    val weekTotalCalories: Int get() = workouts.sumOf { it.caloriesBurned }

    val todayProgress: Float get() {
        if (workouts.isEmpty()) return 0f
        return (completedWorkouts.size.toFloat() / workouts.size).coerceIn(0f, 1f)
    }
    val todayTotalMinutes: Int get() = workouts.sumOf { it.duration }
    val todayTotalCalories: Int get() = workouts.sumOf { it.caloriesBurned }
}

fun workoutCategoryIcon(type: String): ImageVector = when (type) {
    "strength" -> Icons.Filled.FitnessCenter
    "cardio" -> Icons.Filled.DirectionsRun
    "flexibility" -> Icons.Filled.SelfImprovement
    "hiit" -> Icons.Filled.FlashOn
    "yoga" -> Icons.Filled.Spa
    else -> Icons.Filled.FitnessCenter
}

fun workoutCategoryColor(type: String): Color = when (type) {
    "strength" -> CoreViaPrimary
    "cardio" -> Color(0xFFFF9800)
    "flexibility" -> Color(0xFF9C27B0)
    "hiit" -> Color(0xFFE91E63)
    "yoga" -> CoreViaSuccess
    else -> CoreViaPrimary
}

fun workoutCategoryName(type: String): String = when (type) {
    "strength" -> "Güc"
    "cardio" -> "Kardio"
    "flexibility" -> "Elastiklik"
    "hiit" -> "HIIT"
    "yoga" -> "Yoga"
    else -> type
}

@HiltViewModel
class WorkoutViewModel @Inject constructor(
    private val workoutRepository: WorkoutRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(WorkoutUiState())
    val uiState: StateFlow<WorkoutUiState> = _uiState.asStateFlow()

    init {
        loadWorkouts()
    }

    fun loadWorkouts() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = workoutRepository.getWorkouts()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(workouts = result.data, isLoading = false)
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(isLoading = false, error = result.message.toUserFriendlyError())
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun toggleCompletion(workout: Workout) {
        viewModelScope.launch {
            when (workoutRepository.toggleWorkout(workout.id)) {
                is NetworkResult.Success -> loadWorkouts()
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun addWorkout(title: String, category: String, duration: Int, calories: Int, notes: String?) {
        viewModelScope.launch {
            val dateStr = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
            val request = WorkoutCreateRequest(
                title = title,
                category = category,
                duration = duration,
                caloriesBurned = if (calories > 0) calories else null,
                notes = notes,
                date = dateStr
            )
            when (val result = workoutRepository.createWorkout(request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(showAddWorkout = false)
                    loadWorkouts()
                }
                is NetworkResult.Error -> {
                    Timber.e("Create failed: ${result.message} code=${result.code}")
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun deleteWorkout(id: String) {
        viewModelScope.launch {
            when (workoutRepository.deleteWorkout(id)) {
                is NetworkResult.Success -> loadWorkouts()
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun toggleAddSheet() {
        _uiState.value = _uiState.value.copy(showAddWorkout = !_uiState.value.showAddWorkout)
    }
}
