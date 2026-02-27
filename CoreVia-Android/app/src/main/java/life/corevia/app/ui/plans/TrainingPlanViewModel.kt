package life.corevia.app.ui.plans

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.PlanWorkout
import life.corevia.app.data.model.PlanWorkoutCreateRequest
import life.corevia.app.data.model.TrainingPlan
import life.corevia.app.data.model.TrainingPlanCreateRequest
import life.corevia.app.data.model.TrainingPlanType
import life.corevia.app.data.repository.TrainerRepository
import life.corevia.app.data.repository.TrainingPlanRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

// ── List Screen State ──
data class TrainingPlanListState(
    val plans: List<TrainingPlan> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val selectedFilter: String = "all" // "all", "weight_loss", "weight_gain", "strength_training"
) {
    val filteredPlans: List<TrainingPlan>
        get() = if (selectedFilter == "all") plans
        else plans.filter { it.planType == selectedFilter }

    val totalPlans: Int get() = plans.size
    val completedPlans: Int get() = plans.count { it.isCompleted == true }
}

// ── Add Screen State ──
data class AddTrainingPlanState(
    val title: String = "",
    val selectedPlanType: TrainingPlanType = TrainingPlanType.STRENGTH_TRAINING,
    val assignedStudentId: String? = null,
    val workouts: List<PlanWorkout> = emptyList(),
    val notes: String = "",
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val errorMessage: String? = null,
    // Inline exercise form
    val exerciseName: String = "",
    val exerciseSets: Int = 3,
    val exerciseReps: Int = 10,
    val exerciseDuration: Int = 0,
    // Students list
    val students: List<Pair<String, String>> = emptyList() // id, name
) {
    val isFormValid: Boolean
        get() = title.trim().isNotEmpty() && workouts.isNotEmpty()
}

@HiltViewModel
class TrainingPlanViewModel @Inject constructor(
    private val trainingPlanRepository: TrainingPlanRepository,
    private val trainerRepository: TrainerRepository
) : ViewModel() {

    // ── List state ──
    private val _listState = MutableStateFlow(TrainingPlanListState())
    val listState: StateFlow<TrainingPlanListState> = _listState.asStateFlow()

    // ── Add/Create state ──
    private val _addState = MutableStateFlow(AddTrainingPlanState())
    val addState: StateFlow<AddTrainingPlanState> = _addState.asStateFlow()

    init {
        loadPlans()
    }

    // ═══════ LIST ACTIONS ═══════

    fun loadPlans() {
        _listState.value = _listState.value.copy(isLoading = true)
        viewModelScope.launch {
            when (val result = trainingPlanRepository.getTrainingPlans()) {
                is NetworkResult.Success -> {
                    _listState.value = _listState.value.copy(
                        isLoading = false,
                        plans = result.data ?: emptyList()
                    )
                }
                is NetworkResult.Error -> {
                    _listState.value = _listState.value.copy(
                        isLoading = false,
                        errorMessage = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun setFilter(filter: String) {
        _listState.value = _listState.value.copy(selectedFilter = filter)
    }

    fun deletePlan(id: String) {
        viewModelScope.launch {
            when (trainingPlanRepository.deleteTrainingPlan(id)) {
                is NetworkResult.Success -> loadPlans()
                else -> {}
            }
        }
    }

    fun completePlan(id: String) {
        viewModelScope.launch {
            when (trainingPlanRepository.completeTrainingPlan(id)) {
                is NetworkResult.Success -> loadPlans()
                else -> {}
            }
        }
    }

    // ═══════ ADD ACTIONS ═══════

    fun loadStudents() {
        viewModelScope.launch {
            when (val result = trainerRepository.fetchMyStudents()) {
                is NetworkResult.Success -> {
                    val list = result.data?.map { Pair(it.id, it.fullName) } ?: emptyList()
                    _addState.value = _addState.value.copy(students = list)
                }
                else -> {}
            }
        }
    }

    fun updateTitle(value: String) {
        _addState.value = _addState.value.copy(title = value, errorMessage = null)
    }

    fun updatePlanType(type: TrainingPlanType) {
        _addState.value = _addState.value.copy(selectedPlanType = type)
    }

    fun updateAssignedStudent(id: String?) {
        _addState.value = _addState.value.copy(assignedStudentId = id)
    }

    fun updateNotes(value: String) {
        if (value.length <= 500) {
            _addState.value = _addState.value.copy(notes = value)
        }
    }

    // Exercise inline form
    fun updateExerciseName(value: String) {
        _addState.value = _addState.value.copy(exerciseName = value)
    }

    fun updateExerciseSets(value: Int) {
        _addState.value = _addState.value.copy(exerciseSets = value.coerceIn(1, 20))
    }

    fun updateExerciseReps(value: Int) {
        _addState.value = _addState.value.copy(exerciseReps = value.coerceIn(1, 100))
    }

    fun updateExerciseDuration(value: Int) {
        _addState.value = _addState.value.copy(exerciseDuration = value.coerceIn(0, 120))
    }

    fun addExercise() {
        val state = _addState.value
        if (state.exerciseName.trim().isEmpty()) return

        val exercise = PlanWorkout(
            name = state.exerciseName.trim(),
            sets = state.exerciseSets,
            reps = state.exerciseReps,
            duration = if (state.exerciseDuration > 0) state.exerciseDuration else null
        )
        _addState.value = state.copy(
            workouts = state.workouts + exercise,
            exerciseName = "",
            exerciseSets = 3,
            exerciseReps = 10,
            exerciseDuration = 0
        )
    }

    fun removeExercise(index: Int) {
        val state = _addState.value
        _addState.value = state.copy(workouts = state.workouts.toMutableList().apply { removeAt(index) })
    }

    fun savePlan() {
        val state = _addState.value
        if (!state.isFormValid) {
            _addState.value = state.copy(errorMessage = "Başlıq və ən azı 1 məşq əlavə edin")
            return
        }
        _addState.value = state.copy(isLoading = true, errorMessage = null)

        viewModelScope.launch {
            val request = TrainingPlanCreateRequest(
                title = state.title.trim(),
                planType = state.selectedPlanType.value,
                assignedStudentId = state.assignedStudentId,
                workouts = state.workouts.map { w ->
                    PlanWorkoutCreateRequest(
                        name = w.name,
                        sets = w.sets,
                        reps = w.reps,
                        duration = w.duration
                    )
                },
                notes = state.notes.trim().ifBlank { null }
            )

            when (val result = trainingPlanRepository.createTrainingPlan(request)) {
                is NetworkResult.Success -> {
                    _addState.value = _addState.value.copy(isLoading = false, isSaved = true)
                    loadPlans()
                }
                is NetworkResult.Error -> {
                    _addState.value = _addState.value.copy(isLoading = false, errorMessage = result.message)
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun resetAddState() {
        _addState.value = AddTrainingPlanState()
    }
}
