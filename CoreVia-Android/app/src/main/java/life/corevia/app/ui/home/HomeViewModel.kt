package life.corevia.app.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.local.TokenManager
import life.corevia.app.data.model.Workout
import life.corevia.app.data.repository.AuthRepository
import life.corevia.app.data.repository.WorkoutRepository
import life.corevia.app.util.NetworkResult
import life.corevia.app.util.toUserFriendlyError
import javax.inject.Inject

data class TodayWorkout(
    val id: String = "",
    val title: String = "",
    val category: String = "cardio",
    val duration: Int = 0,
    val isCompleted: Boolean = false
)

data class WeekStats(
    val workoutCount: Int = 0,
    val completedCount: Int = 0,
    val totalMinutes: Int = 0
)

data class AIRecommendation(
    val title: String = "",
    val description: String = "",
    val icon: String = "sparkles",
    val category: String = "",
    val type: String = "workout"
)

data class HomeUiState(
    val userName: String = "İstifadəçi",
    // Stats
    val todayTotalMinutes: Int = 0,
    val todayTotalCalories: Int = 0,
    // Daily Goal
    val todayProgress: Float = 0f,
    val todayCompletedCount: Int = 0,
    val todayTotalCount: Int = 0,
    // Today Workouts
    val todayWorkouts: List<TodayWorkout> = emptyList(),
    // AI Recommendation
    val aiRecommendation: AIRecommendation = AIRecommendation(
        title = "Gündəlik məşqlərinizə başlayın! 💪",
        description = "Hər gün hərəkət etmək sağlamlığınızı yaxşılaşdırır.",
        icon = "sparkles",
        category = "Tövsiyə",
        type = "motivation"
    ),
    val isLoadingAI: Boolean = false,
    // Weekly Stats
    val weekStats: WeekStats = WeekStats(),
    val isLoading: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val tokenManager: TokenManager,
    private val workoutRepository: WorkoutRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        _uiState.value = _uiState.value.copy(
            userName = tokenManager.getUserName()
        )
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            loadWorkouts()
            loadUserProfile()
        }
    }

    private suspend fun loadUserProfile() {
        when (val result = authRepository.fetchCurrentUser()) {
            is NetworkResult.Success -> {
                val user = result.data
                // Müdafiəvi ad: boşdursa email-dən götür
                val displayName = if (user.fullName.isNotBlank() && user.fullName != "İstifadəçi") {
                    user.fullName
                } else {
                    user.email.substringBefore("@").replaceFirstChar { it.uppercase() }
                }
                tokenManager.saveUserInfo(displayName, user.email)
                _uiState.value = _uiState.value.copy(userName = displayName)
            }
            is NetworkResult.Error -> {} // Local cache istifadə olunur
            is NetworkResult.Loading -> {}
        }
    }

    private suspend fun loadWorkouts() {
        when (val result = workoutRepository.getWorkouts()) {
            is NetworkResult.Success -> {
                val workouts = result.data
                val completed = workouts.filter { it.isCompleted }
                val totalMinutes = workouts.sumOf { it.duration }
                val totalCalories = workouts.sumOf { it.caloriesBurned }

                val todayWorkouts = workouts.map { w ->
                    TodayWorkout(
                        id = w.id,
                        title = w.title,
                        category = w.category,
                        duration = w.duration,
                        isCompleted = w.isCompleted
                    )
                }

                val progress = if (workouts.isNotEmpty()) {
                    completed.size.toFloat() / workouts.size
                } else 0f

                val aiRec = if (progress >= 1f && workouts.isNotEmpty()) {
                    AIRecommendation(
                        title = "Əla iş! Hədəfə çatdın! 🎉",
                        description = "Bu gün bütün məşqləri tamamladın. Sabah da belə davam et!",
                        icon = "trophy",
                        category = "Motivasiya",
                        type = "motivation"
                    )
                } else if (workouts.isNotEmpty()) {
                    AIRecommendation(
                        title = "Davam et! 💪",
                        description = "${workouts.size - completed.size} məşq hələ tamamlanmayıb. Sən bacarırsan!",
                        icon = "sparkles",
                        category = "Tövsiyə",
                        type = "motivation"
                    )
                } else {
                    AIRecommendation(
                        title = "Gündəlik məşqlərinizə başlayın! 💪",
                        description = "Məşq əlavə edib gününüzü aktiv başlayın.",
                        icon = "sparkles",
                        category = "Tövsiyə",
                        type = "motivation"
                    )
                }

                _uiState.value = _uiState.value.copy(
                    todayWorkouts = todayWorkouts,
                    todayTotalMinutes = totalMinutes,
                    todayTotalCalories = totalCalories,
                    todayProgress = progress,
                    todayCompletedCount = completed.size,
                    todayTotalCount = workouts.size,
                    weekStats = WeekStats(
                        workoutCount = workouts.size,
                        completedCount = completed.size,
                        totalMinutes = totalMinutes
                    ),
                    aiRecommendation = aiRec,
                    isLoading = false
                )
            }
            is NetworkResult.Error -> {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = result.message.toUserFriendlyError()
                )
            }
            is NetworkResult.Loading -> {}
        }
    }

}
