package life.corevia.app.ui.onboarding

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.api.TokenManager

data class OnboardingData(
    val gender: String? = null,
    val age: Int = 25,
    val weight: Int = 70,
    val height: Int = 170,
    val fitnessGoal: String? = null,
    val fitnessLevel: String = "beginner",
    // Trainer-specific fields
    val specialization: String? = null,
    val experience: Int = 1,
    val bio: String = ""
)

sealed class OnboardingUiState {
    object Idle : OnboardingUiState()
    object Loading : OnboardingUiState()
    object Success : OnboardingUiState()
    data class Error(val message: String) : OnboardingUiState()
}

class OnboardingViewModel(application: Application) : AndroidViewModel(application) {
    val isTrainer: Boolean = TokenManager.getInstance(application).isTrainer

    private val _data = MutableStateFlow(OnboardingData())
    val data: StateFlow<OnboardingData> = _data

    private val _uiState = MutableStateFlow<OnboardingUiState>(OnboardingUiState.Idle)
    val uiState: StateFlow<OnboardingUiState> = _uiState

    private val _currentStep = MutableStateFlow(0)
    val currentStep: StateFlow<Int> = _currentStep

    // Client: Welcome, Gender, Age, Weight/Height, Goal
    // Trainer: Welcome, Gender, Specialization, Experience/Bio, Confirmation
    val totalSteps = 5

    fun setGender(gender: String) {
        _data.value = _data.value.copy(gender = gender)
    }

    fun setAge(age: Int) {
        _data.value = _data.value.copy(age = age)
    }

    fun setWeight(weight: Int) {
        _data.value = _data.value.copy(weight = weight)
    }

    fun setHeight(height: Int) {
        _data.value = _data.value.copy(height = height)
    }

    fun setFitnessGoal(goal: String) {
        _data.value = _data.value.copy(fitnessGoal = goal)
    }

    fun setSpecialization(spec: String) {
        _data.value = _data.value.copy(specialization = spec)
    }

    fun setExperience(exp: Int) {
        _data.value = _data.value.copy(experience = exp)
    }

    fun setBio(bio: String) {
        _data.value = _data.value.copy(bio = bio)
    }

    fun nextStep() {
        if (_currentStep.value < totalSteps - 1) {
            _currentStep.value = _currentStep.value + 1
        }
    }

    fun previousStep() {
        if (_currentStep.value > 0) {
            _currentStep.value = _currentStep.value - 1
        }
    }

    fun completeOnboarding() {
        viewModelScope.launch {
            _uiState.value = OnboardingUiState.Loading
            try {
                val currentData = _data.value
                val body = if (isTrainer) {
                    mapOf(
                        "specialization" to (currentData.specialization ?: "fitness"),
                        "experience" to currentData.experience,
                        "bio" to currentData.bio,
                        "gender" to currentData.gender,
                        "age" to currentData.age
                    )
                } else {
                    mapOf(
                        "fitness_goal" to (currentData.fitnessGoal ?: "stay_fit"),
                        "fitness_level" to currentData.fitnessLevel,
                        "gender" to currentData.gender,
                        "age" to currentData.age,
                        "weight" to currentData.weight.toFloat(),
                        "height" to currentData.height.toFloat()
                    )
                }
                ApiClient.getInstance(getApplication()).api.completeOnboarding(body)
                val tokenManager = TokenManager.getInstance(getApplication())
                tokenManager.hasCompletedOnboarding = true
                _uiState.value = OnboardingUiState.Success
            } catch (e: Exception) {
                _uiState.value = OnboardingUiState.Success // Still proceed even on error
                val tokenManager = TokenManager.getInstance(getApplication())
                tokenManager.hasCompletedOnboarding = true
            }
        }
    }
}
