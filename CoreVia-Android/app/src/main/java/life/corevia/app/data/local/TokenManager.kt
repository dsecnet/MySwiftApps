package life.corevia.app.data.local

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import dagger.hilt.android.qualifiers.ApplicationContext
import life.corevia.app.util.Constants
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TokenManager @Inject constructor(
    @ApplicationContext context: Context
) {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val prefs: SharedPreferences = EncryptedSharedPreferences.create(
        context,
        Constants.TOKEN_PREFS,
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun saveTokens(accessToken: String, refreshToken: String) {
        prefs.edit()
            .putString(Constants.ACCESS_TOKEN_KEY, accessToken)
            .putString(Constants.REFRESH_TOKEN_KEY, refreshToken)
            .putBoolean(Constants.IS_LOGGED_IN_KEY, true)
            .apply()
    }

    fun getAccessToken(): String? = prefs.getString(Constants.ACCESS_TOKEN_KEY, null)

    fun getRefreshToken(): String? = prefs.getString(Constants.REFRESH_TOKEN_KEY, null)

    fun isLoggedIn(): Boolean = prefs.getBoolean(Constants.IS_LOGGED_IN_KEY, false)

    fun saveUserType(userType: String) {
        prefs.edit().putString(Constants.USER_TYPE_KEY, userType).apply()
    }

    fun getUserType(): String = prefs.getString(Constants.USER_TYPE_KEY, "client") ?: "client"

    fun saveUserInfo(name: String, email: String) {
        prefs.edit()
            .putString(Constants.USER_NAME_KEY, name)
            .putString(Constants.USER_EMAIL_KEY, email)
            .apply()
    }

    fun getUserName(): String = prefs.getString(Constants.USER_NAME_KEY, "İstifadəçi") ?: "İstifadəçi"

    fun getUserEmail(): String = prefs.getString(Constants.USER_EMAIL_KEY, "") ?: ""

    fun clearAll() {
        prefs.edit().clear().apply()
    }
}
