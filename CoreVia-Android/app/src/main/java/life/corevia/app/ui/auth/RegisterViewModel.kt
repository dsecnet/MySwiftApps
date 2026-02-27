package life.corevia.app.ui.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.repository.AuthRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class RegisterUiState(
    val name: String = "",
    val email: String = "",
    val password: String = "",
    val confirmPassword: String = "",
    val userType: String = "client", // "client" or "trainer"
    val isPasswordVisible: Boolean = false,
    val isConfirmPasswordVisible: Boolean = false,
    val acceptTerms: Boolean = false,
    val isLoading: Boolean = false,
    val currentStep: Int = 1, // 1 = form, 2 = OTP verification
    val otpCode: String = "",
    val errorMessage: String? = null,
    val isRegistered: Boolean = false,

    // Trainer extra fields
    val instagram: String = "",
    val selectedSpecialization: String = "Fitness",
    val experience: Int = 1,
    val bio: String = ""
) {
    // Password strength (0-3)
    val passwordStrength: Int
        get() {
            if (password.length < 6) return 0
            if (password.length < 8) return 1
            if (password.length >= 8 && password.any { it.isDigit() }) return 2
            return 3
        }

    val strengthText: String
        get() = when (passwordStrength) {
            0, 1 -> "Zəif"
            2 -> "Orta"
            3 -> "Güclü"
            else -> ""
        }

    val passwordsMatch: Boolean
        get() = confirmPassword.isNotEmpty() && password == confirmPassword

    val isFormValid: Boolean
        get() = name.isNotBlank() &&
                email.isNotBlank() &&
                email.contains("@") &&
                password.length >= 6 &&
                passwordsMatch &&
                acceptTerms

    val isTrainer: Boolean
        get() = userType == "trainer"
}

val specializations = listOf("Fitness", "Yoga", "Kardio", "Güc", "Qidalanma")

@HiltViewModel
class RegisterViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(RegisterUiState())
    val uiState: StateFlow<RegisterUiState> = _uiState.asStateFlow()

    fun updateName(name: String) {
        _uiState.value = _uiState.value.copy(name = name, errorMessage = null)
    }

    fun updateEmail(email: String) {
        _uiState.value = _uiState.value.copy(email = email, errorMessage = null)
    }

    fun updatePassword(password: String) {
        _uiState.value = _uiState.value.copy(password = password, errorMessage = null)
    }

    fun updateConfirmPassword(confirmPassword: String) {
        _uiState.value = _uiState.value.copy(confirmPassword = confirmPassword, errorMessage = null)
    }

    fun updateUserType(type: String) {
        _uiState.value = _uiState.value.copy(userType = type, errorMessage = null)
    }

    fun togglePasswordVisibility() {
        _uiState.value = _uiState.value.copy(isPasswordVisible = !_uiState.value.isPasswordVisible)
    }

    fun toggleConfirmPasswordVisibility() {
        _uiState.value = _uiState.value.copy(isConfirmPasswordVisible = !_uiState.value.isConfirmPasswordVisible)
    }

    fun toggleAcceptTerms() {
        _uiState.value = _uiState.value.copy(acceptTerms = !_uiState.value.acceptTerms, errorMessage = null)
    }

    fun updateOtpCode(code: String) {
        _uiState.value = _uiState.value.copy(
            otpCode = code.filter { it.isDigit() }.take(6),
            errorMessage = null
        )
    }

    // Trainer extra fields
    fun updateInstagram(value: String) {
        _uiState.value = _uiState.value.copy(instagram = value, errorMessage = null)
    }

    fun updateSpecialization(value: String) {
        _uiState.value = _uiState.value.copy(selectedSpecialization = value)
    }

    fun updateExperience(value: Int) {
        _uiState.value = _uiState.value.copy(experience = value)
    }

    fun updateBio(value: String) {
        if (value.length <= 500) {
            _uiState.value = _uiState.value.copy(bio = value, errorMessage = null)
        }
    }

    fun goBackToForm() {
        _uiState.value = _uiState.value.copy(
            currentStep = 1,
            otpCode = "",
            errorMessage = null
        )
    }

    /** Qeydiyyat prosesi — trainer birbasa, client OTP ile */
    fun sendOTPOrRegister() {
        val state = _uiState.value
        if (!state.isFormValid) {
            _uiState.value = state.copy(errorMessage = "Butun saheleri duzgun doldurun")
            return
        }

        _uiState.value = state.copy(isLoading = true, errorMessage = null)

        if (state.isTrainer) {
            registerTrainerDirectly()
        } else {
            requestOTP()
        }
    }

    private fun requestOTP() {
        viewModelScope.launch {
            val email = _uiState.value.email.trim().lowercase()
            when (val result = authRepository.requestRegisterOTP(email)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        currentStep = 2,
                        errorMessage = null
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

    private fun registerTrainerDirectly() {
        viewModelScope.launch {
            val state = _uiState.value
            when (val result = authRepository.register(
                name = state.name.trim(),
                email = state.email.trim().lowercase(),
                password = state.password,
                userType = "trainer",
                otpCode = "",
                instagram = state.instagram.trim().ifBlank { null },
                specialization = state.selectedSpecialization,
                experienceYears = state.experience,
                bio = state.bio.trim().ifBlank { null }
            )) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        isRegistered = true,
                        errorMessage = null
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

    /** OTP tesdiq et ve qeydiyyati tamamla (client) */
    fun verifyOTPAndRegister() {
        val state = _uiState.value
        if (state.otpCode.length != 6) {
            _uiState.value = state.copy(errorMessage = "OTP 6 reqem olmalidir")
            return
        }

        _uiState.value = state.copy(isLoading = true, errorMessage = null)

        viewModelScope.launch {
            when (val result = authRepository.register(
                name = state.name.trim(),
                email = state.email.trim().lowercase(),
                password = state.password,
                userType = "client",
                otpCode = state.otpCode
            )) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        isRegistered = true,
                        errorMessage = null
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

    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }
}
