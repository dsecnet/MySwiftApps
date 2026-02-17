package life.corevia.app.ui.workout

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.WorkoutRepository
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

/**
 * iOS WorkoutManager.swift (@MainActor ObservableObject) →
 * Android WorkoutViewModel (AndroidViewModel + StateFlow)
 *
 * Screen bu ViewModel-dən oxuyur.
 * ViewModel WorkoutRepository-ni çağırır.
 * Screen heç vaxt Repository-yə toxunmur.
 */
class WorkoutViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = WorkoutRepository.getInstance(application)

    // ─── State ────────────────────────────────────────────────────────────────
    // iOS: @Published var workouts: [Workout] = []
    private val _workouts = MutableStateFlow<List<Workout>>(emptyList())
    val workouts: StateFlow<List<Workout>> = _workouts.asStateFlow()

    // iOS: @Published var isLoading = false
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    // iOS: @Published var errorMessage: String?
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    // iOS: @Published var showAddWorkout = false
    private val _showAddWorkout = MutableStateFlow(false)
    val showAddWorkout: StateFlow<Boolean> = _showAddWorkout.asStateFlow()

    // ─── Computed Properties ──────────────────────────────────────────────────

    // iOS: var todayWorkouts: [Workout]
    val todayWorkouts: List<Workout>
        get() {
            val today = LocalDate.now().toString()   // "2026-02-17"
            return _workouts.value.filter { it.date.startsWith(today) }
        }

    // iOS: calculateWeeklyMinutes() — HomeView + WorkoutView istifadə edir
    val weeklyMinutes: Int
        get() {
            val weekAgo = LocalDate.now().minusDays(7)
            return _workouts.value
                .filter {
                    try {
                        val date = LocalDate.parse(it.date.take(10))
                        date.isAfter(weekAgo)
                    } catch (e: Exception) { false }
                }
                .sumOf { it.duration }
        }

    // iOS: calculateWeeklyCaloriesBurned()
    val weeklyCaloriesBurned: Int
        get() {
            val weekAgo = LocalDate.now().minusDays(7)
            return _workouts.value
                .filter {
                    try {
                        val date = LocalDate.parse(it.date.take(10))
                        date.isAfter(weekAgo)
                    } catch (e: Exception) { false }
                }
                .sumOf { it.caloriesBurned ?: 0 }
        }

    // iOS: weekWorkoutCount
    val weekWorkoutCount: Int
        get() {
            val weekAgo = LocalDate.now().minusDays(7)
            return _workouts.value.count {
                try {
                    val date = LocalDate.parse(it.date.take(10))
                    date.isAfter(weekAgo)
                } catch (e: Exception) { false }
            }
        }

    // ─── Actions ──────────────────────────────────────────────────────────────

    init {
        loadWorkouts()
    }

    // iOS: func loadWorkouts() async
    fun loadWorkouts() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getWorkouts().fold(
                onSuccess = { _workouts.value = it },
                onFailure = { _errorMessage.value = it.message }
            )
            _isLoading.value = false
        }
    }

    // iOS: func addWorkout(_ workout: Workout)
    fun addWorkout(
        title: String,
        category: String,
        duration: Int,
        caloriesBurned: Int?,
        notes: String?
    ) {
        viewModelScope.launch {
            _isLoading.value = true
            val request = WorkoutCreateRequest(
                title = title,
                category = category,
                duration = duration,
                caloriesBurned = caloriesBurned,
                notes = notes,
                date = LocalDateTime.now().format(
                    DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.000000")
                )
            )
            repository.createWorkout(request).fold(
                onSuccess = {
                    _workouts.value = _workouts.value + it
                    _showAddWorkout.value = false
                },
                onFailure = { _errorMessage.value = it.message }
            )
            _isLoading.value = false
        }
    }

    // iOS: func toggleComplete(_ workout: Workout)
    fun toggleComplete(workout: Workout) {
        viewModelScope.launch {
            val request = WorkoutUpdateRequest(
                title = null,
                category = null,
                duration = null,
                caloriesBurned = null,
                notes = null,
                isCompleted = !workout.isCompleted
            )
            repository.updateWorkout(workout.id, request).fold(
                onSuccess = { updated ->
                    _workouts.value = _workouts.value.map {
                        if (it.id == updated.id) updated else it
                    }
                },
                onFailure = { _errorMessage.value = it.message }
            )
        }
    }

    // iOS: func deleteWorkout(_ workout: Workout)
    fun deleteWorkout(workoutId: String) {
        viewModelScope.launch {
            repository.deleteWorkout(workoutId).fold(
                onSuccess = {
                    _workouts.value = _workouts.value.filter { it.id != workoutId }
                },
                onFailure = { _errorMessage.value = it.message }
            )
        }
    }

    fun setShowAddWorkout(show: Boolean) { _showAddWorkout.value = show }
    fun clearError() { _errorMessage.value = null }
}
