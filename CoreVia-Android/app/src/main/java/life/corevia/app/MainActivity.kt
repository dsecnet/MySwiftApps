package life.corevia.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import life.corevia.app.data.api.TokenManager
import life.corevia.app.ui.navigation.AppNavigation
import life.corevia.app.ui.theme.CoreViaTheme

/**
 * iOS-da: @main App struct + ContentView
 * Android-da: MainActivity → AppNavigation (NavHost + BottomBar)
 *
 * Bu fayl minimal qalır — yalnız giriş nöqtəsi.
 * Bütün navigation məntiqi AppNavigation.kt-dədir.
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val tokenManager = TokenManager.getInstance(applicationContext)

        setContent {
            CoreViaTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color(0xFF0A0A0F)
                ) {
                    AppNavigation(tokenManager = tokenManager)
                }
            }
        }
    }
}
