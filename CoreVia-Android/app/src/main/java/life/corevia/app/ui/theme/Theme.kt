package life.corevia.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/**
 * iOS AppTheme.swift-ə uyğun CoreVia Material3 Theme.
 * Dynamic color söndürülüb — iOS-dakı kimi sabit qırmızı tema.
 *
 * iOS: AppTheme.Colors.accent = Color.red (#FF3B30)
 * Bütün primary rənglər iOS accent (red) ilə əvəz edilib.
 */

// ─── Dark Color Scheme (iOS dark mode-a uyğun) ────────────────────────────────
private val CoreViaDarkColorScheme = darkColorScheme(
    primary          = AppTheme.Colors.accent,           // #FF3B30
    onPrimary        = Color.White,
    primaryContainer = AppTheme.Colors.accentDark,       // #B20000
    onPrimaryContainer = Color.White,

    secondary        = AppTheme.Colors.accentDark,
    onSecondary      = Color.White,
    secondaryContainer = AppTheme.Colors.accentLight,
    onSecondaryContainer = AppTheme.Colors.accent,

    tertiary         = AppTheme.Colors.success,          // #34C759
    onTertiary       = Color.White,

    background       = AppTheme.Colors.background,       // #000000
    onBackground     = AppTheme.Colors.primaryText,      // #FFFFFF

    surface          = AppTheme.Colors.secondaryBackground, // #1C1C1E
    onSurface        = AppTheme.Colors.primaryText,

    surfaceVariant   = AppTheme.Colors.cardBackground,   // #2C2C2E
    onSurfaceVariant = AppTheme.Colors.secondaryText,    // #8E8E93

    outline          = AppTheme.Colors.separator,        // #38383A
    outlineVariant   = AppTheme.Colors.separator.copy(alpha = 0.5f),

    error            = AppTheme.Colors.error,            // #E63333
    onError          = Color.White,
    errorContainer   = AppTheme.Colors.error.copy(alpha = 0.15f),
    onErrorContainer = AppTheme.Colors.error,
)

// ─── Light Color Scheme ────────────────────────────────────────────────────────
private val CoreViaLightColorScheme = lightColorScheme(
    primary          = AppTheme.Colors.accent,
    onPrimary        = Color.White,
    primaryContainer = AppTheme.Colors.accentLight,
    onPrimaryContainer = AppTheme.Colors.accentDark,

    secondary        = AppTheme.Colors.accentDark,
    onSecondary      = Color.White,
    secondaryContainer = AppTheme.Colors.accentLight,
    onSecondaryContainer = AppTheme.Colors.accentDark,

    tertiary         = AppTheme.Colors.success,
    onTertiary       = Color.White,

    background       = Color(0xFFF2F2F7),               // iOS: systemBackground (light)
    onBackground     = Color(0xFF000000),

    surface          = Color(0xFFFFFFFF),
    onSurface        = Color(0xFF000000),

    surfaceVariant   = Color(0xFFE5E5EA),               // iOS: secondarySystemBackground (light)
    onSurfaceVariant = Color(0xFF3C3C43),

    outline          = Color(0xFFC6C6C8),               // iOS: separator (light)

    error            = AppTheme.Colors.error,
    onError          = Color.White,
)

// ─── Theme Composable ─────────────────────────────────────────────────────────
@Composable
fun CoreViaTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    // iOS kimi: dynamic color yoxdur, həmişə öz rəng sistemi
    val colorScheme = if (darkTheme) CoreViaDarkColorScheme else CoreViaLightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography  = Typography,
        content     = content
    )
}
