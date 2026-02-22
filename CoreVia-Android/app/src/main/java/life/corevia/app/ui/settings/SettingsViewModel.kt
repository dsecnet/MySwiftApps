package life.corevia.app.ui.settings

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.api.TokenManager
import life.corevia.app.data.models.ChangePasswordRequest
import life.corevia.app.data.models.DeleteAccountRequest
import life.corevia.app.data.models.UserSettingsResponse
import life.corevia.app.data.models.UserSettingsUpdateRequest

/**
 * iOS SettingsView.swift — Android SettingsViewModel
 *
 * Loads and saves user settings via the API.
 * Also handles change-password and delete-account actions.
 */
class SettingsViewModel(application: Application) : AndroidViewModel(application) {

    private val api = ApiClient.getInstance(application).api
    private val tokenManager = TokenManager.getInstance(application)

    private val _settings = MutableStateFlow<UserSettingsResponse?>(null)
    val settings: StateFlow<UserSettingsResponse?> = _settings.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    private val _accountDeleted = MutableStateFlow(false)
    val accountDeleted: StateFlow<Boolean> = _accountDeleted.asStateFlow()

    init {
        loadSettings()
    }

    fun loadSettings() {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val result = api.getSettings()
                withContext(Dispatchers.Main) { _settings.value = result }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    _errorMessage.value = ErrorParser.parseMessage(e)
                }
            }
        }
    }

    fun updateNotificationsEnabled(enabled: Boolean) {
        updateSetting(UserSettingsUpdateRequest(notificationsEnabled = enabled))
    }

    fun updateWorkoutReminders(enabled: Boolean) {
        updateSetting(UserSettingsUpdateRequest(workoutReminders = enabled))
    }

    fun updateMealReminders(enabled: Boolean) {
        updateSetting(UserSettingsUpdateRequest(mealReminders = enabled))
    }

    fun updateWeeklyReport(enabled: Boolean) {
        updateSetting(UserSettingsUpdateRequest(weeklyReports = enabled))
    }

    fun updateLanguage(language: String) {
        tokenManager.selectedLanguage = language
        updateSetting(UserSettingsUpdateRequest(language = language))
    }

    fun updateDarkMode(enabled: Boolean) {
        updateSetting(UserSettingsUpdateRequest(darkMode = enabled))
    }

    private fun updateSetting(request: UserSettingsUpdateRequest) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val result = api.updateSettings(request)
                withContext(Dispatchers.Main) { _settings.value = result }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    _errorMessage.value = ErrorParser.parseMessage(e)
                }
            }
        }
    }

    fun changePassword(currentPassword: String, newPassword: String) {
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            try {
                api.changePassword(ChangePasswordRequest(currentPassword, newPassword))
                withContext(Dispatchers.Main) {
                    _successMessage.value = "Sifre ugurla deyisdirildi"
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    _errorMessage.value = ErrorParser.parseMessage(e)
                }
            }
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun deleteAccount(password: String) {
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            try {
                api.deleteAccount(DeleteAccountRequest(password))
                withContext(Dispatchers.Main) {
                    tokenManager.clearTokens()
                    _accountDeleted.value = true
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    _errorMessage.value = ErrorParser.parseMessage(e)
                }
            }
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
