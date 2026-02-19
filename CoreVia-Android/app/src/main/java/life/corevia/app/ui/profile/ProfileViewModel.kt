package life.corevia.app.ui.profile

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.ProfileUpdateRequest
import life.corevia.app.data.models.UserResponse
import life.corevia.app.data.repository.UserRepository

/**
 * iOS ProfileView.swift → Android ProfileViewModel
 */
class ProfileViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = UserRepository.getInstance(application)

    private val _user = MutableStateFlow<UserResponse?>(null)
    val user: StateFlow<UserResponse?> = _user.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    init {
        loadUser()
    }

    fun loadUser() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getMe().fold(
                onSuccess = { _user.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun updateProfile(request: ProfileUpdateRequest) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.updateProfile(request).fold(
                onSuccess = {
                    _user.value = it
                    _successMessage.value = "Profil yeniləndi"
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // iOS: profileCompletion computed property
    val profileCompletion: Float
        get() {
            val u = _user.value ?: return 0f
            var filled = 0
            val total = 6
            if (!u.name.isNullOrBlank()) filled++
            if (u.age != null) filled++
            if (u.weight != null) filled++
            if (u.height != null) filled++
            if (!u.goal.isNullOrBlank()) filled++
            if (!u.profileImageUrl.isNullOrBlank()) filled++
            return filled.toFloat() / total
        }

    val isTrainer: Boolean
        get() = _user.value?.userType == "trainer"

    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
