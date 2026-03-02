package life.corevia.app

import android.content.SharedPreferences
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import dagger.hilt.android.AndroidEntryPoint
import life.corevia.app.ui.navigation.AppNavigation
import life.corevia.app.ui.theme.CoreViaTheme
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var sharedPreferences: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val darkModePref = remember {
                mutableStateOf(sharedPreferences.getBoolean("settings_dark_mode", false))
            }

            // Listen for changes to dark mode preference
            DisposableEffect(Unit) {
                val listener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
                    if (key == "settings_dark_mode") {
                        darkModePref.value = sharedPreferences.getBoolean("settings_dark_mode", false)
                    }
                }
                sharedPreferences.registerOnSharedPreferenceChangeListener(listener)
                onDispose {
                    sharedPreferences.unregisterOnSharedPreferenceChangeListener(listener)
                }
            }

            val isSystemDark = isSystemInDarkTheme()
            val useDarkTheme = darkModePref.value || isSystemDark

            CoreViaTheme(darkTheme = useDarkTheme) {
                Surface(modifier = Modifier.fillMaxSize()) {
                    AppNavigation()
                }
            }
        }
    }
}
