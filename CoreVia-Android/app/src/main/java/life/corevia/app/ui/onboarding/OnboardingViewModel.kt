package life.corevia.app.ui.onboarding

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.OnboardingOption
import life.corevia.app.data.repository.OnboardingRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class OnboardingUiState(
    val currentStep: Int = 0, // 0=Goal, 1=FitnessLevel, 2=BodyInfo, 3=TrainerType
    val totalSteps: Int = 4,
    // Options from backend
    val goalOptions: List<OnboardingOption> = emptyList(),
    val fitnessLevelOptions: List<OnboardingOption> = emptyList(),
    val trainerTypeOptions: List<OnboardingOption> = emptyList(),
    // User selections
    val selectedGoal: String = "",
    val selectedFitnessLevel: String = "",
    val selectedTrainerType: String = "",
    // Body info
    val age: String = "",
    val weight: String = "",
    val height: String = "",
    // State
    val isLoading: Boolean = false,
    val isCompleted: Boolean = false,
    val errorMessage: String? = null
) {
    val progress: Float get() = (currentStep + 1).toFloat() / totalSteps

    val bmi: Double?
        get() {
            val w = weight.toDoubleOrNull() ?: return null
            val h = (height.toDoubleOrNull() ?: return null) / 100.0
            if (h <= 0) return null
            return w / (h * h)
        }

    val bmiCategory: String
        get() = when {
            bmi == null -> ""
            bmi!! < 18.5 -> "Arıq"
            bmi!! < 25.0 -> "Normal"
            bmi!! < 30.0 -> "Artıq çəki"
            else -> "Piylənmə"
        }

    val canProceed: Boolean
        get() = when (currentStep) {
            0 -> selectedGoal.isNotEmpty()
            1 -> selectedFitnessLevel.isNotEmpty()
            2 -> age.isNotEmpty() && weight.isNotEmpty() && height.isNotEmpty()
            3 -> selectedTrainerType.isNotEmpty()
            else -> false
        }
}

@HiltViewModel
class OnboardingViewModel @Inject constructor(
    private val onboardingRepository: OnboardingRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(OnboardingUiState())
    val uiState: StateFlow<OnboardingUiState> = _uiState.asStateFlow()

    init {
        loadOptions()
    }

    private fun loadOptions() {
        _uiState.value = _uiState.value.copy(isLoading = true)
        viewModelScope.launch {
            when (val result = onboardingRepository.fetchOptions()) {
                is NetworkResult.Success -> {
                    result.data?.let { options ->
                        _uiState.value = _uiState.value.copy(
                            isLoading = false,
                            goalOptions = options.goals,
                            fitnessLevelOptions = options.fitnessLevels,
                            trainerTypeOptions = options.trainerTypes
                        )
                    }
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

    fun selectGoal(value: String) {
        _uiState.value = _uiState.value.copy(selectedGoal = value)
    }

    fun selectFitnessLevel(value: String) {
        _uiState.value = _uiState.value.copy(selectedFitnessLevel = value)
    }

    fun selectTrainerType(value: String) {
        _uiState.value = _uiState.value.copy(selectedTrainerType = value)
    }

    fun updateAge(value: String) {
        _uiState.value = _uiState.value.copy(age = value.filter { it.isDigit() })
    }

    fun updateWeight(value: String) {
        _uiState.value = _uiState.value.copy(weight = value.filter { it.isDigit() || it == '.' })
    }

    fun updateHeight(value: String) {
        _uiState.value = _uiState.value.copy(height = value.filter { it.isDigit() || it == '.' })
    }

    fun nextStep() {
        val state = _uiState.value
        if (state.currentStep < state.totalSteps - 1) {
            _uiState.value = state.copy(currentStep = state.currentStep + 1)
        } else {
            completeOnboarding()
        }
    }

    fun previousStep() {
        val state = _uiState.value
        if (state.currentStep > 0) {
            _uiState.value = state.copy(currentStep = state.currentStep - 1)
        }
    }

    private fun completeOnboarding() {
        val state = _uiState.value
        _uiState.value = state.copy(isLoading = true, errorMessage = null)

        viewModelScope.launch {
            when (val result = onboardingRepository.complete(
                goal = state.selectedGoal,
                level = state.selectedFitnessLevel,
                trainerType = state.selectedTrainerType
            )) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(isLoading = false, isCompleted = true)
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = result.message)
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}
