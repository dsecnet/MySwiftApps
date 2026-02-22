package life.corevia.app.data.api

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * iOS KeychainManager.swift-in Android ekvivalenti.
 * Tokenləri AES-256 ilə şifrəli saxlayır (EncryptedSharedPreferences).
 *
 * iOS-da:
 *   KeychainManager.shared.accessToken = token
 *   KeychainManager.shared.clearTokens()
 *
 * Android-da:
 *   TokenManager.getInstance(context).accessToken = token
 *   TokenManager.getInstance(context).clearTokens()
 */
class TokenManager private constructor(context: Context) {

    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val prefs = EncryptedSharedPreferences.create(
        context,
        "corevia_secure_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    // iOS: var accessToken: String?
    var accessToken: String?
        get() = prefs.getString(KEY_ACCESS_TOKEN, null)
        set(value) = prefs.edit().putString(KEY_ACCESS_TOKEN, value).apply()

    // iOS: var refreshToken: String?
    var refreshToken: String?
        get() = prefs.getString(KEY_REFRESH_TOKEN, null)
        set(value) = prefs.edit().putString(KEY_REFRESH_TOKEN, value).apply()

    // iOS: var isLoggedIn: Bool
    val isLoggedIn: Boolean
        get() = accessToken != null

    // iOS: UserDefaults.set(user.userType, forKey: "userType")
    // Login zamanı saxlanır, app açılanda dərhal mövcuddur (API gözləmədən)
    var userType: String?
        get() = prefs.getString(KEY_USER_TYPE, null)
        set(value) = prefs.edit().putString(KEY_USER_TYPE, value).apply()

    val isTrainer: Boolean
        get() = userType == "trainer"

    // Onboarding flag
    var hasCompletedOnboarding: Boolean
        get() = prefs.getBoolean(KEY_ONBOARDING_COMPLETED, false)
        set(value) = prefs.edit().putBoolean(KEY_ONBOARDING_COMPLETED, value).apply()

    // Language selection persistence
    var selectedLanguage: String
        get() = prefs.getString(KEY_LANGUAGE, "az") ?: "az"
        set(value) = prefs.edit().putString(KEY_LANGUAGE, value).apply()

    // iOS: func clearTokens()
    fun clearTokens() {
        prefs.edit()
            .remove(KEY_ACCESS_TOKEN)
            .remove(KEY_REFRESH_TOKEN)
            .remove(KEY_USER_TYPE)
            .remove(KEY_ONBOARDING_COMPLETED)
            .apply()
    }

    companion object {
        private const val KEY_ACCESS_TOKEN = "access_token"
        private const val KEY_REFRESH_TOKEN = "refresh_token"
        private const val KEY_USER_TYPE = "user_type"
        private const val KEY_ONBOARDING_COMPLETED = "onboarding_completed"
        private const val KEY_LANGUAGE = "selected_language"

        @Volatile
        private var instance: TokenManager? = null

        fun getInstance(context: Context): TokenManager {
            return instance ?: synchronized(this) {
                instance ?: TokenManager(context.applicationContext).also { instance = it }
            }
        }
    }
}
