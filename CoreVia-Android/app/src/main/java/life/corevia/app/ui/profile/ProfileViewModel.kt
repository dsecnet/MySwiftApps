package life.corevia.app.ui.profile

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.api.TokenManager
import life.corevia.app.data.models.ProfileUpdateRequest
import life.corevia.app.data.models.UserResponse
import life.corevia.app.data.repository.UserRepository

/**
 * iOS ProfileView.swift → Android ProfileViewModel
 */
class ProfileViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = UserRepository.getInstance(application)
    private val tokenManager = TokenManager.getInstance(application)

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
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            repository.getMe().fold(
                onSuccess = {
                    // iOS kimi: userType-ı həmişə sync saxla
                    tokenManager.userType = it.userType
                    withContext(Dispatchers.Main) { _user.value = it }
                },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun updateProfile(request: ProfileUpdateRequest) {
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            repository.updateProfile(request).fold(
                onSuccess = {
                    withContext(Dispatchers.Main) {
                        _user.value = it
                        _successMessage.value = "Profil yeniləndi"
                    }
                },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
            withContext(Dispatchers.Main) { _isLoading.value = false }
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

    // iOS: trainerProfileCompletion — 8 sahə (name, email, bio, specialization, experience, pricePerSession, instagramHandle, profileImageUrl)
    val trainerProfileCompletion: Float
        get() {
            val u = _user.value ?: return 0f
            var filled = 0
            val total = 8
            if (!u.name.isNullOrBlank()) filled++
            if (!u.email.isNullOrBlank()) filled++
            if (!u.bio.isNullOrBlank()) filled++
            if (!u.specialization.isNullOrBlank()) filled++
            if (u.experience != null && u.experience > 0) filled++
            if (u.pricePerSession != null && u.pricePerSession > 0) filled++
            if (!u.instagramHandle.isNullOrBlank()) filled++
            if (!u.profileImageUrl.isNullOrBlank()) filled++
            return filled.toFloat() / total
        }

    val isTrainer: Boolean
        get() = _user.value?.userType == "trainer"

    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
