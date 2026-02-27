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

data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val otpCode: String = "",
    val userType: String = "client",
    val isPasswordVisible: Boolean = false,
    val isLoading: Boolean = false,
    val currentStep: Int = 1,  // 1 = login form, 2 = OTP verification
    val errorMessage: String? = null,
    val isLoggedIn: Boolean = false
)

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    init {
        // Check if already logged in — userType da yüklə
        if (authRepository.isLoggedIn()) {
            _uiState.value = _uiState.value.copy(
                isLoggedIn = true,
                userType = authRepository.getUserType()
            )
        }
    }

    fun updateEmail(email: String) {
        _uiState.value = _uiState.value.copy(email = email, errorMessage = null)
    }

    fun updatePassword(password: String) {
        _uiState.value = _uiState.value.copy(password = password, errorMessage = null)
    }

    fun updateOtpCode(code: String) {
        _uiState.value = _uiState.value.copy(otpCode = code.filter { it.isDigit() }.take(6), errorMessage = null)
    }

    fun updateUserType(type: String) {
        _uiState.value = _uiState.value.copy(userType = type)
    }

    fun togglePasswordVisibility() {
        _uiState.value = _uiState.value.copy(isPasswordVisible = !_uiState.value.isPasswordVisible)
    }

    fun login() {
        val state = _uiState.value
        val trimmedEmail = state.email.trim()

        // Validation
        when {
            trimmedEmail.isEmpty() -> {
                _uiState.value = state.copy(errorMessage = "Email boşdur")
                return
            }
            state.password.isEmpty() -> {
                _uiState.value = state.copy(errorMessage = "Şifrə boşdur")
                return
            }
            !trimmedEmail.contains("@") -> {
                _uiState.value = state.copy(errorMessage = "Email düzgün deyil")
                return
            }
            state.password.length < 6 -> {
                _uiState.value = state.copy(errorMessage = "Şifrə minimum 6 simvol olmalıdır")
                return
            }
        }

        _uiState.value = state.copy(isLoading = true, errorMessage = null)

        viewModelScope.launch {
            when (val result = authRepository.login(trimmedEmail, state.password, state.userType)) {
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

    fun verifyOtp() {
        val state = _uiState.value
        if (state.otpCode.length != 6) {
            _uiState.value = state.copy(errorMessage = "OTP 6 rəqəm olmalıdır")
            return
        }

        _uiState.value = state.copy(isLoading = true, errorMessage = null)

        viewModelScope.launch {
            when (val result = authRepository.verifyOtp(state.email.trim(), state.otpCode)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        isLoggedIn = true,
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

    fun goBackToLogin() {
        _uiState.value = _uiState.value.copy(
            currentStep = 1,
            otpCode = "",
            errorMessage = null
        )
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }
}
