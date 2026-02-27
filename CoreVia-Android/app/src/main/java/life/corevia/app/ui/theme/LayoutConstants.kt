package life.corevia.app.ui.theme

import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * iOS Constants.swift equivalent
 * Layout spacing, corner radius, typography sizes, animation durations
 */

// ─── Layout (Spacing) ───────────────────────────────────────────────

object Layout {
    val spacingXS = 4.dp
    val spacingS = 8.dp
    val spacingM = 16.dp
    val spacingL = 24.dp
    val spacingXL = 32.dp

    // Corner Radius
    val cornerRadiusS = 8.dp
    val cornerRadiusM = 12.dp
    val cornerRadiusL = 16.dp
    val cornerRadiusXL = 24.dp

    // Padding
    val paddingS = 12.dp
    val paddingM = 16.dp
    val paddingL = 20.dp
}

// ─── Typography Sizes ───────────────────────────────────────────────

object TypographySizes {
    val titleLarge = 28.sp
    val titleMedium = 22.sp
    val titleSmall = 18.sp
    val body = 16.sp
    val caption = 14.sp
    val small = 12.sp
}

// ─── Animation ──────────────────────────────────────────────────────

object Animations {
    const val defaultDuration = 300   // ms
    const val fastDuration = 200      // ms
    const val slowDuration = 500      // ms
}
