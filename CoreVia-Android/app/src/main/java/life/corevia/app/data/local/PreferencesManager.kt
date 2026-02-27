package life.corevia.app.data.local

import android.content.Context
import android.content.SharedPreferences
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PreferencesManager @Inject constructor(
    @ApplicationContext context: Context
) {
    private val prefs: SharedPreferences = context.getSharedPreferences("corevia_prefs", Context.MODE_PRIVATE)

    fun getString(key: String, default: String = ""): String = prefs.getString(key, default) ?: default

    fun putString(key: String, value: String) = prefs.edit().putString(key, value).apply()

    fun getBoolean(key: String, default: Boolean = false): Boolean = prefs.getBoolean(key, default)

    fun putBoolean(key: String, value: Boolean) = prefs.edit().putBoolean(key, value).apply()

    fun getInt(key: String, default: Int = 0): Int = prefs.getInt(key, default)

    fun putInt(key: String, value: Int) = prefs.edit().putInt(key, value).apply()

    fun clear() = prefs.edit().clear().apply()
}
