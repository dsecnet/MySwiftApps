package life.corevia.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.graphics.Color

/**
 * CoreVia Material3 Theme — Qırmızı rəng sistemi.
 * Dark + Light mode dəstəyi.
 *
 * CompositionLocalProvider ilə AppTheme.Colors avtomatik dark/light qaytarır.
 */

// ─── Dark Color Scheme (Material3) ──────────────────────────────────────────
private val CoreViaDarkColorScheme = darkColorScheme(
    primary            = DarkCoreViaColors.accent,
    onPrimary          = Color.White,
    primaryContainer   = DarkCoreViaColors.accentDark,
    onPrimaryContainer = Color.White,

    secondary          = DarkCoreViaColors.accentDark,
    onSecondary        = Color.White,
    secondaryContainer = DarkCoreViaColors.accentLight,
    onSecondaryContainer = DarkCoreViaColors.accent,

    tertiary           = DarkCoreViaColors.success,
    onTertiary         = Color.White,

    background         = DarkCoreViaColors.background,
    onBackground       = DarkCoreViaColors.primaryText,

    surface            = DarkCoreViaColors.secondaryBackground,
    onSurface          = DarkCoreViaColors.primaryText,

    surfaceVariant     = DarkCoreViaColors.cardBackground,
    onSurfaceVariant   = DarkCoreViaColors.secondaryText,

    outline            = DarkCoreViaColors.separator,
    outlineVariant     = DarkCoreViaColors.separator.copy(alpha = 0.5f),

    error              = DarkCoreViaColors.error,
    onError            = Color.White,
    errorContainer     = DarkCoreViaColors.error.copy(alpha = 0.15f),
    onErrorContainer   = DarkCoreViaColors.error,
)

// ─── Light Color Scheme (Material3) ─────────────────────────────────────────
private val CoreViaLightColorScheme = lightColorScheme(
    primary            = LightCoreViaColors.accent,
    onPrimary          = Color.White,
    primaryContainer   = LightCoreViaColors.accentLight,
    onPrimaryContainer = LightCoreViaColors.accentDark,

    secondary          = LightCoreViaColors.accentDark,
    onSecondary        = Color.White,
    secondaryContainer = LightCoreViaColors.accentLight,
    onSecondaryContainer = LightCoreViaColors.accentDark,

    tertiary           = LightCoreViaColors.success,
    onTertiary         = Color.White,

    background         = LightCoreViaColors.background,
    onBackground       = LightCoreViaColors.primaryText,

    surface            = LightCoreViaColors.secondaryBackground,
    onSurface          = LightCoreViaColors.primaryText,

    surfaceVariant     = LightCoreViaColors.cardBackground,
    onSurfaceVariant   = LightCoreViaColors.secondaryText,

    outline            = LightCoreViaColors.separator,
    outlineVariant     = LightCoreViaColors.separator.copy(alpha = 0.5f),

    error              = LightCoreViaColors.error,
    onError            = Color.White,
    errorContainer     = LightCoreViaColors.error.copy(alpha = 0.15f),
    onErrorContainer   = LightCoreViaColors.error,
)

// ─── Theme Composable ────────────────────────────────────────────────────────
@Composable
fun CoreViaTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) CoreViaDarkColorScheme else CoreViaLightColorScheme
    val coreViaColors = if (darkTheme) DarkCoreViaColors else LightCoreViaColors

    CompositionLocalProvider(LocalCoreViaColors provides coreViaColors) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography  = Typography,
            content     = content
        )
    }
}
