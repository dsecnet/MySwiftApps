package life.corevia.app.ui.settings

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import life.corevia.app.data.local.TokenManager
import java.security.MessageDigest
import javax.inject.Inject

/**
 * iOS SettingsManager.swift equivalent
 * Tənzimləmələr — bildirişlər, biometrik, şifrə, premium
 */

data class SettingsUiState(
    // Notifications
    val notificationsEnabled: Boolean = true,
    val workoutReminders: Boolean = true,
    val mealReminders: Boolean = true,
    val weeklyReports: Boolean = false,

    // Security
    val biometricEnabled: Boolean = false,
    val hasAppPassword: Boolean = false,
    val biometricType: String = "Biometrik",

    // Premium
    val isPremium: Boolean = false,
    val hasPremiumAccess: Boolean = false,

    // UI
    val darkModeEnabled: Boolean = false,
    val selectedLanguage: String = "Azərbaycan dili",
    val appVersion: String = "1.0.0"
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    @ApplicationContext private val context: Context,
    private val tokenManager: TokenManager,
    private val sharedPreferences: SharedPreferences
) : ViewModel() {

    companion object {
        private const val SETTINGS_PREFIX = "settings_"
        private const val KEY_NOTIFICATIONS = "${SETTINGS_PREFIX}notifications"
        private const val KEY_WORKOUT_REMINDERS = "${SETTINGS_PREFIX}workout_reminders"
        private const val KEY_MEAL_REMINDERS = "${SETTINGS_PREFIX}meal_reminders"
        private const val KEY_WEEKLY_REPORTS = "${SETTINGS_PREFIX}weekly_reports"
        private const val KEY_BIOMETRIC_ENABLED = "${SETTINGS_PREFIX}biometric_enabled"
        private const val KEY_HAS_PASSWORD = "${SETTINGS_PREFIX}has_password"
        private const val KEY_PASSWORD_HASH = "${SETTINGS_PREFIX}password_hash"
        private const val KEY_IS_PREMIUM = "${SETTINGS_PREFIX}is_premium"
        private const val KEY_DARK_MODE = "${SETTINGS_PREFIX}dark_mode"
        private const val KEY_LANGUAGE = "${SETTINGS_PREFIX}language"
    }

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        loadSettings()
    }

    // ─── Load Settings ───────────────────────────────────────────────

    private fun loadSettings() {
        val userType = tokenManager.getUserType()
        val isPremium = sharedPreferences.getBoolean(KEY_IS_PREMIUM, false)

        _uiState.value = SettingsUiState(
            notificationsEnabled = sharedPreferences.getBoolean(KEY_NOTIFICATIONS, true),
            workoutReminders = sharedPreferences.getBoolean(KEY_WORKOUT_REMINDERS, true),
            mealReminders = sharedPreferences.getBoolean(KEY_MEAL_REMINDERS, true),
            weeklyReports = sharedPreferences.getBoolean(KEY_WEEKLY_REPORTS, false),
            biometricEnabled = sharedPreferences.getBoolean(KEY_BIOMETRIC_ENABLED, false),
            hasAppPassword = sharedPreferences.getBoolean(KEY_HAS_PASSWORD, false),
            biometricType = getBiometricType(),
            isPremium = isPremium,
            hasPremiumAccess = userType == "trainer" || isPremium,
            darkModeEnabled = sharedPreferences.getBoolean(KEY_DARK_MODE, false),
            selectedLanguage = sharedPreferences.getString(KEY_LANGUAGE, "Azərbaycan dili") ?: "Azərbaycan dili",
            appVersion = getAppVersion()
        )
    }

    // ─── Toggle Functions ────────────────────────────────────────────

    fun toggleNotifications(enabled: Boolean) {
        sharedPreferences.edit().putBoolean(KEY_NOTIFICATIONS, enabled).apply()
        _uiState.value = _uiState.value.copy(notificationsEnabled = enabled)
    }

    fun toggleWorkoutReminders(enabled: Boolean) {
        sharedPreferences.edit().putBoolean(KEY_WORKOUT_REMINDERS, enabled).apply()
        _uiState.value = _uiState.value.copy(workoutReminders = enabled)
    }

    fun toggleMealReminders(enabled: Boolean) {
        sharedPreferences.edit().putBoolean(KEY_MEAL_REMINDERS, enabled).apply()
        _uiState.value = _uiState.value.copy(mealReminders = enabled)
    }

    fun toggleWeeklyReports(enabled: Boolean) {
        sharedPreferences.edit().putBoolean(KEY_WEEKLY_REPORTS, enabled).apply()
        _uiState.value = _uiState.value.copy(weeklyReports = enabled)
    }

    fun toggleBiometric(enabled: Boolean) {
        sharedPreferences.edit().putBoolean(KEY_BIOMETRIC_ENABLED, enabled).apply()
        _uiState.value = _uiState.value.copy(biometricEnabled = enabled)
    }

    fun toggleDarkMode(enabled: Boolean) {
        sharedPreferences.edit().putBoolean(KEY_DARK_MODE, enabled).apply()
        _uiState.value = _uiState.value.copy(darkModeEnabled = enabled)
    }

    fun setLanguage(language: String) {
        sharedPreferences.edit().putString(KEY_LANGUAGE, language).apply()
        _uiState.value = _uiState.value.copy(selectedLanguage = language)
    }

    // ─── Password Management ─────────────────────────────────────────

    fun setPassword(password: String) {
        val hashed = hashPin(password)
        sharedPreferences.edit()
            .putString(KEY_PASSWORD_HASH, hashed)
            .putBoolean(KEY_HAS_PASSWORD, true)
            .apply()
        _uiState.value = _uiState.value.copy(hasAppPassword = true)
    }

    fun removePassword() {
        sharedPreferences.edit()
            .remove(KEY_PASSWORD_HASH)
            .putBoolean(KEY_HAS_PASSWORD, false)
            .apply()
        _uiState.value = _uiState.value.copy(hasAppPassword = false)
    }

    fun verifyPassword(password: String): Boolean {
        val savedHash = sharedPreferences.getString(KEY_PASSWORD_HASH, null) ?: return false
        return hashPin(password) == savedHash
    }

    private fun hashPin(pin: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val hashBytes = digest.digest(pin.toByteArray(Charsets.UTF_8))
        return hashBytes.joinToString("") { "%02x".format(it) }
    }

    // ─── Biometric ───────────────────────────────────────────────────

    private fun getBiometricType(): String {
        // Biometric: SDK P+ dəstəklənir, tam biometric support üçün androidx.biometric əlavə edilə bilər
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) "Biometrik" else "Mövcud deyil"
    }

    fun canUseBiometric(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.P
    }

    // ─── Helpers ─────────────────────────────────────────────────────

    private fun getAppVersion(): String {
        return try {
            val pInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            pInfo.versionName ?: "1.0.0"
        } catch (_: Exception) {
            "1.0.0"
        }
    }
}
