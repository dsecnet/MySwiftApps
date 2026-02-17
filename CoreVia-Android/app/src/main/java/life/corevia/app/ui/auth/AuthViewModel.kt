package life.corevia.app.ui.auth

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.models.UserResponse
import life.corevia.app.data.repository.AuthRepository

/**
 * iOS AuthenticationManager + UserProfileManager-in Android ViewModel ekvivalenti.
 *
 * 2-step login axını (iOS LoginView.swift ilə eyni):
 *  - login(email, password) → POST /api/v1/auth/login → OTP göndərilir → OtpSent state
 *  - verifyOtp(email, otp) → POST /api/v1/auth/login-verify → token alınır → Success state
 *
 * Screen → ViewModel.login() çağırır
 * ViewModel → AuthRepository.login() çağırır
 * Screen → uiState.collectAsState() ilə UI yeniləyir
 *
 * Screen-i dəyişsən bu fayl dəyişmir.
 * API dəyişsə yalnız AuthRepository dəyişir.
 */
class AuthViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = AuthRepository.getInstance(application)

    // ─── UiState ──────────────────────────────────────────────────────────────
    // iOS: @Published var isLoading, @Published var errorMessage, currentStep
    private val _uiState = MutableStateFlow<AuthUiState>(AuthUiState.Idle)
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    // iOS: @Published var currentUser: UserResponse?
    private val _currentUser = MutableStateFlow<UserResponse?>(null)
    val currentUser: StateFlow<UserResponse?> = _currentUser.asStateFlow()

    // iOS: var isLoggedIn: Bool
    val isLoggedIn: Boolean get() = repository.isLoggedIn()

    // ─── Actions ───────────────────────────────────────────────────────────────

    /**
     * iOS loginAction() ilə eyni — Step 1:
     * POST /api/v1/auth/login → 200 = OTP göndərildi → currentStep = 2
     */
    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            val result = repository.sendLoginOtp(email, password)
            result.fold(
                onSuccess = {
                    // OTP göndərildi — Step 2-yə keç
                    _uiState.value = AuthUiState.OtpSent
                },
                onFailure = { error ->
                    _uiState.value = AuthUiState.Error(
                        error.message ?: "Email və ya şifrə səhvdir"
                    )
                }
            )
        }
    }

    /**
     * iOS verifyOTPAndLogin() ilə eyni — Step 2:
     * POST /api/v1/auth/login-verify + {email, otp_code} → token alınır
     */
    fun verifyOtp(email: String, otpCode: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            val result = repository.verifyLoginOtp(email, otpCode)
            result.fold(
                onSuccess = { user ->
                    _currentUser.value = user
                    _uiState.value = AuthUiState.Success(user)
                },
                onFailure = { error ->
                    _uiState.value = AuthUiState.Error(
                        error.message ?: "OTP səhvdir və ya vaxtı keçib"
                    )
                }
            )
        }
    }

    // iOS: func register(name:email:password:userType:)
    fun register(name: String, email: String, password: String, userType: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            val result = repository.register(name, email, password, userType)
            result.fold(
                onSuccess = { user ->
                    _currentUser.value = user
                    _uiState.value = AuthUiState.Success(user)
                },
                onFailure = { error ->
                    _uiState.value = AuthUiState.Error(
                        error.message ?: "Qeydiyyat uğursuz oldu"
                    )
                }
            )
        }
    }

    // iOS: func logout()
    fun logout() {
        repository.logout()
        _currentUser.value = null
        _uiState.value = AuthUiState.LoggedOut
    }

    // Xəta mesajını sıfırla (istifadəçi dismiss etdikdən sonra)
    fun clearError() {
        if (_uiState.value is AuthUiState.Error) {
            _uiState.value = AuthUiState.Idle
        }
    }

    // OtpSent-dən geri qayıdanda sıfırla
    fun resetToIdle() {
        _uiState.value = AuthUiState.Idle
    }
}

// ─── UiState ──────────────────────────────────────────────────────────────────
// iOS-da bu @Published var-larla idarə olunurdu
// Android-da sealed class daha təmizdir — Screen switch-case edir
sealed class AuthUiState {
    object Idle      : AuthUiState()          // başlanğıc hal
    object Loading   : AuthUiState()          // iOS: isLoading = true
    object OtpSent   : AuthUiState()          // iOS: currentStep = 2 → OTP ekranına keç
    object LoggedOut : AuthUiState()          // logout sonrası → Login-ə yönləndir
    data class Success(val user: UserResponse) : AuthUiState()   // → əsas ekrana
    data class Error(val message: String)      : AuthUiState()   // → xəta göstər
}
