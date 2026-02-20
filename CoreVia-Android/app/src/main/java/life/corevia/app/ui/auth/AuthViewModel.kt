package life.corevia.app.ui.auth

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import life.corevia.app.data.models.UserResponse
import life.corevia.app.data.repository.AuthRepository

/**
 * iOS AuthenticationManager + UserProfileManager-in Android ViewModel ekvivalenti.
 *
 * Login: 2-step (email+password → OTP → token)
 * Register: 2-step (register-request → OTP → token)
 * Forgot Password: 2-step (email → OTP+new password birlikdə, iOS ilə eyni)
 */
class AuthViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = AuthRepository.getInstance(application)

    private val _uiState = MutableStateFlow<AuthUiState>(AuthUiState.Idle)
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    private val _currentUser = MutableStateFlow<UserResponse?>(null)
    val currentUser: StateFlow<UserResponse?> = _currentUser.asStateFlow()

    val isLoggedIn: Boolean get() = repository.isLoggedIn()

    // ═══════════════════════════════════════════════════════════════════════════
    // LOGIN
    // ═══════════════════════════════════════════════════════════════════════════

    fun login(email: String, password: String) {
        _uiState.value = AuthUiState.Loading
        viewModelScope.launch(Dispatchers.IO) {
            repository.sendLoginOtp(email, password).fold(
                onSuccess = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.OtpSent } },
                onFailure = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.Error(it.message ?: "Xəta baş verdi") } }
            )
        }
    }

    fun verifyOtp(email: String, otpCode: String) {
        _uiState.value = AuthUiState.Loading
        viewModelScope.launch(Dispatchers.IO) {
            repository.verifyLoginOtp(email, otpCode).fold(
                onSuccess = { user ->
                    withContext(Dispatchers.Main) {
                        _currentUser.value = user
                        _uiState.value = AuthUiState.Success(user)
                    }
                },
                onFailure = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.Error(it.message ?: "OTP səhvdir") } }
            )
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REGISTER (2-step with OTP)
    // ═══════════════════════════════════════════════════════════════════════════

    fun register(name: String, email: String, password: String, userType: String) {
        _uiState.value = AuthUiState.Loading
        viewModelScope.launch(Dispatchers.IO) {
            repository.sendRegisterOtp(name, email, password, userType).fold(
                onSuccess = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.RegisterOtpSent } },
                onFailure = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.Error(it.message ?: "Qeydiyyat uğursuz oldu") } }
            )
        }
    }

    fun verifyRegisterOtp(name: String, email: String, password: String, userType: String, otpCode: String) {
        _uiState.value = AuthUiState.Loading
        viewModelScope.launch(Dispatchers.IO) {
            repository.verifyRegisterOtp(name, email, password, userType, otpCode).fold(
                onSuccess = {
                    withContext(Dispatchers.Main) { _uiState.value = AuthUiState.RegisterSuccess }
                },
                onFailure = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.Error(it.message ?: "OTP səhvdir") } }
            )
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FORGOT PASSWORD (2-step, iOS ilə eyni)
    // ═══════════════════════════════════════════════════════════════════════════

    fun sendForgotPasswordOtp(email: String) {
        _uiState.value = AuthUiState.Loading
        viewModelScope.launch(Dispatchers.IO) {
            repository.sendForgotPasswordOtp(email).fold(
                onSuccess = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.ForgotOtpSent } },
                onFailure = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.Error(it.message ?: "Xəta baş verdi") } }
            )
        }
    }

    fun resetPassword(email: String, otpCode: String, newPassword: String) {
        _uiState.value = AuthUiState.Loading
        viewModelScope.launch(Dispatchers.IO) {
            repository.resetPassword(email, otpCode, newPassword).fold(
                onSuccess = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.PasswordReset } },
                onFailure = { withContext(Dispatchers.Main) { _uiState.value = AuthUiState.Error(it.message ?: "Xəta baş verdi") } }
            )
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // COMMON
    // ═══════════════════════════════════════════════════════════════════════════

    fun logout() {
        repository.logout()
        _currentUser.value = null
        _uiState.value = AuthUiState.LoggedOut
    }

    fun clearError() {
        if (_uiState.value is AuthUiState.Error) {
            _uiState.value = AuthUiState.Idle
        }
    }

    fun resetToIdle() {
        _uiState.value = AuthUiState.Idle
    }
}

// ─── UiState ──────────────────────────────────────────────────────────────────
sealed class AuthUiState {
    object Idle               : AuthUiState()
    object Loading            : AuthUiState()
    object OtpSent            : AuthUiState()    // Login Step 2
    object RegisterOtpSent    : AuthUiState()    // Register Step 2
    object ForgotOtpSent      : AuthUiState()    // Forgot Password Step 2
    object RegisterSuccess    : AuthUiState()    // Qeydiyyat uğurlu — login ekranına yönləndir
    object PasswordReset      : AuthUiState()    // Şifrə uğurla dəyişdi
    object LoggedOut          : AuthUiState()
    data class Success(val user: UserResponse) : AuthUiState()
    data class Error(val message: String)      : AuthUiState()
}
