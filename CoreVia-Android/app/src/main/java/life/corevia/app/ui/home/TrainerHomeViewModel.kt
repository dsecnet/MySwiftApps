package life.corevia.app.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.local.TokenManager
import life.corevia.app.data.model.DashboardStudentSummary
import life.corevia.app.data.repository.AuthRepository
import life.corevia.app.data.repository.TrainerDashboardRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

/**
 * iOS TrainerDashboardManager.swift equivalent
 * Trainer Dashboard — tələbə siyahısı, statistikalar, gəlir
 */

data class TrainerHomeUiState(
    val userName: String = "Trener",
    // Dashboard Stats
    val totalSubscribers: Int = 0,
    val activeStudents: Int = 0,
    val monthlyEarnings: Double = 0.0,
    val currency: String = "AZN",
    val totalTrainingPlans: Int = 0,
    val totalMealPlans: Int = 0,
    // Students
    val students: List<DashboardStudentSummary> = emptyList(),
    // Stats Summary
    val avgWorkoutsPerWeek: Double = 0.0,
    val totalWorkoutsAllStudents: Int = 0,
    val avgStudentWeight: Double = 0.0,
    // UI
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class TrainerHomeViewModel @Inject constructor(
    private val tokenManager: TokenManager,
    private val trainerDashboardRepository: TrainerDashboardRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(TrainerHomeUiState())
    val uiState: StateFlow<TrainerHomeUiState> = _uiState.asStateFlow()

    init {
        _uiState.value = _uiState.value.copy(
            userName = tokenManager.getUserName()
        )
        loadDashboard()
        loadUserProfile()
    }

    private fun loadUserProfile() {
        viewModelScope.launch {
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
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun loadDashboard() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)

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
                        avgStudentWeight = stats.statsSummary.avgStudentWeight,
                        isLoading = false
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}
