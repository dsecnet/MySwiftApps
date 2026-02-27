package life.corevia.app.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val LightColorScheme = lightColorScheme(
    primary = CoreViaPrimary,
    onPrimary = Color.White,
    primaryContainer = CoreViaPrimary.copy(alpha = 0.1f),
    secondary = CoreViaSecondary,
    onSecondary = Color.White,
    background = CoreViaBackground,
    onBackground = TextPrimary,
    surface = CoreViaSurface,
    onSurface = TextPrimary,
    error = CoreViaError,
    onError = Color.White,
    surfaceVariant = Color(0xFFF0F0F5),
    onSurfaceVariant = TextSecondary,
    outline = Color(0xFFE0E0E0)
)

private val DarkColorScheme = darkColorScheme(
    primary = CoreViaPrimaryNight,
    onPrimary = Color.Black,
    primaryContainer = CoreViaPrimaryNight.copy(alpha = 0.2f),
    secondary = CoreViaSecondary,
    onSecondary = Color.Black,
    background = CoreViaBackgroundNight,
    onBackground = CoreViaOnSurfaceNight,
    surface = CoreViaSurfaceNight,
    onSurface = CoreViaOnSurfaceNight,
    error = CoreViaError,
    onError = Color.Black,
    surfaceVariant = Color(0xFF2C2C2C),
    onSurfaceVariant = Color(0xFFB0B0B0),
    outline = Color(0xFF3C3C3C)
)

@Composable
fun CoreViaTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = Color.Transparent.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
