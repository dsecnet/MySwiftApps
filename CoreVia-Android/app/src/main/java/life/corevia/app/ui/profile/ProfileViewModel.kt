package life.corevia.app.ui.profile

import timber.log.Timber
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.local.TokenManager
import life.corevia.app.data.model.DashboardStudentSummary
import life.corevia.app.data.model.UserProfile
import life.corevia.app.data.model.UserStats
import life.corevia.app.data.repository.AuthRepository
import life.corevia.app.data.repository.FoodRepository
import life.corevia.app.data.repository.TrainerDashboardRepository
import life.corevia.app.data.repository.WorkoutRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class ProfileUiState(
    val userProfile: UserProfile = UserProfile(
        fullName = "İstifadəçi",
        email = "",
        isPremium = false
    ),
    val userStats: UserStats = UserStats(
        totalWorkouts = 0,
        currentStreak = 0,
        totalCaloriesBurned = 0f
    ),
    // Today highlights (client) — real backend data
    val todayWorkouts: Int = 0,
    val todayCalories: Int = 0,
    val todayMeals: Int = 0,
    // Weekly progress (client) — real backend data
    val weekWorkouts: Int = 0,
    val weekWorkoutGoal: Int = 5,
    val weekCalories: Int = 0,
    val weekCalorieGoal: Int = 2000,

    // ── Trainer Dashboard Data ──
    val totalSubscribers: Int = 0,
    val activeStudents: Int = 0,
    val monthlyEarnings: Double = 0.0,
    val currency: String = "AZN",
    val totalTrainingPlans: Int = 0,
    val totalMealPlans: Int = 0,
    val students: List<DashboardStudentSummary> = emptyList(),
    // Stats summary
    val avgWorkoutsPerWeek: Double = 0.0,
    val totalWorkoutsAllStudents: Int = 0,
    val avgStudentWeight: Double = 0.0,

    // Profile completion
    val profileCompletion: Float = 0f,
    val isLoading: Boolean = false
)

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val tokenManager: TokenManager,
    private val authRepository: AuthRepository,
    private val trainerDashboardRepository: TrainerDashboardRepository,
    private val workoutRepository: WorkoutRepository,
    private val foodRepository: FoodRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init {
        loadLocalProfile()
        fetchProfileFromApi()
    }

    /** Əvvəlcə lokal cache-dən oxu (sürətli göstərmə) */
    private fun loadLocalProfile() {
        val name = tokenManager.getUserName()
        val email = tokenManager.getUserEmail()

        Timber.d("loadLocalProfile: name='$name', email='$email'")

        _uiState.value = _uiState.value.copy(
            userProfile = _uiState.value.userProfile.copy(
                fullName = name,
                email = email,
                userType = tokenManager.getUserType()
            ),
            profileCompletion = calculateCompletion(name, email, _uiState.value.userProfile)
        )
    }

    /** Backend-dən real profile data yüklə */
    private fun fetchProfileFromApi() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)

            when (val result = authRepository.fetchCurrentUser()) {
                is NetworkResult.Success -> {
                    val user = result.data
                    Timber.d("API User: name='${user.fullName}', email='${user.email}', type='${user.userType}'")

                    // Adı müdafiəvi şəkildə yoxla — boşdursa email-dən götür
                    val displayName = if (user.fullName.isNotBlank() && user.fullName != "İstifadəçi") {
                        user.fullName
                    } else {
                        user.email.substringBefore("@").replaceFirstChar { it.uppercase() }
                    }

                    // TokenManager-ı yenilə ki bütün ekranlar yeni adı görsün
                    tokenManager.saveUserInfo(displayName, user.email)
                    tokenManager.saveUserType(user.userType)

                    val updatedUser = user.copy(fullName = displayName)

                    _uiState.value = _uiState.value.copy(
                        userProfile = updatedUser,
                        profileCompletion = updatedUser.profileCompletion,
                        isLoading = false
                    )

                    // Trainer isə dashboard stats da yüklə
                    if (user.isTrainer) {
                        fetchTrainerStats()
                    } else {
                        // Client isə workout + food data yüklə
                        fetchClientStats()
                    }
                }
                is NetworkResult.Error -> {
                    Timber.e("fetchCurrentUser error: ${result.message}")
                    _uiState.value = _uiState.value.copy(isLoading = false)
                    // Trainer isə yenə də stats yükləməyə çalış
                    if (tokenManager.getUserType() == "trainer") {
                        fetchTrainerStats()
                    } else {
                        fetchClientStats()
                    }
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    /** Client workout + food statistikaları yüklə */
    private fun fetchClientStats() {
        viewModelScope.launch {
            // Workout data
            when (val result = workoutRepository.getWorkouts()) {
                is NetworkResult.Success -> {
                    val workouts = result.data
                    _uiState.value = _uiState.value.copy(
                        todayWorkouts = workouts.size,
                        weekWorkouts = workouts.size,
                        userStats = _uiState.value.userStats.copy(
                            totalWorkouts = workouts.size,
                            totalCaloriesBurned = workouts.sumOf { it.caloriesBurned }.toFloat()
                        )
                    )
                }
                is NetworkResult.Error -> {
                    Timber.e("getWorkouts error: ${result.message}")
                }
                is NetworkResult.Loading -> {}
            }

            // Food data
            when (val result = foodRepository.getDailyStats()) {
                is NetworkResult.Success -> {
                    val stats = result.data
                    _uiState.value = _uiState.value.copy(
                        todayCalories = stats.totalCalories,
                        todayMeals = stats.entries.size,
                        weekCalories = stats.totalCalories,
                        weekCalorieGoal = stats.calorieGoal
                    )
                }
                is NetworkResult.Error -> {
                    Timber.e("getDailyStats error: ${result.message}")
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    /** Trainer dashboard statistikaları yüklə */
    private fun fetchTrainerStats() {
        viewModelScope.launch {
            when (val result = trainerDashboardRepository.fetchStats()) {
                is NetworkResult.Success -> {
                    val stats = result.data
                    _uiState.value = _uiState.value.copy(
                        totalSubscribers = stats.totalSubscribers,
                        activeStudents = stats.activeStudents,
                        monthlyEarnings = stats.monthlyEarnings,
                        currency = stats.currency,
                        totalTrainingPlans = stats.totalTrainingPlans,
                        totalMealPlans = stats.totalMealPlans,
                        students = stats.students,
                        avgWorkoutsPerWeek = stats.statsSummary.avgStudentWorkoutsPerWeek,
                        totalWorkoutsAllStudents = stats.statsSummary.totalWorkoutsAllStudents,
                        avgStudentWeight = stats.statsSummary.avgStudentWeight
                    )
                }
                is NetworkResult.Error -> {
                    Timber.e("fetchTrainerStats error: ${result.message}")
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    /** Profili yenidən yüklə (pull-to-refresh üçün) */
    fun refreshProfile() {
        fetchProfileFromApi()
    }

    private fun calculateCompletion(name: String, email: String, profile: UserProfile): Float {
        val fields = listOf(
            name.isNotBlank() && name != "İstifadəçi",
            email.isNotBlank(),
            profile.age != null && profile.age > 0,
            profile.weight != null && profile.weight > 0,
            profile.height != null && profile.height > 0
        )
        val filled = fields.count { it }
        return filled.toFloat() / fields.size.toFloat()
    }

    fun logout() {
        tokenManager.clearAll()
    }
}
