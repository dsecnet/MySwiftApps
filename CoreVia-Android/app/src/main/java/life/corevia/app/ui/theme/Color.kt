package life.corevia.app.ui.theme

import androidx.compose.ui.graphics.Color

/**
 * CoreVia Design System — iOS AppTheme.swift equivalent
 * Bütün dizayn bu rənglər üzrə gedir.
 */

// ═══════════════════════════════════════════════════════════════════
// BRAND (Əsas)
// ═══════════════════════════════════════════════════════════════════
val CoreViaPrimary = Color(0xFFFF4444)          // accent — qırmızı
val CoreViaPrimaryDark = Color(0xFFB30000)      // accentDark
val CoreViaPrimaryLight = Color(0xFFFF6B6B)     // accentLight (solid)
val CoreViaAccentLight = Color(0x26FF4444)      // accentLight (0.15 opacity)

// ═══════════════════════════════════════════════════════════════════
// SEMANTIC
// ═══════════════════════════════════════════════════════════════════
val CoreViaSuccess = Color(0xFF33C759)          // success — yaşıl
val CoreViaWarning = Color(0xFFFFCC00)          // warning — sarı
val CoreViaError = Color(0xFFE63333)            // error — qırmızı
val CoreViaInfo = Color(0xFF4D4D4D)             // info — boz

// ═══════════════════════════════════════════════════════════════════
// BACKGROUNDS (Light / Dark)
// ═══════════════════════════════════════════════════════════════════
val CoreViaBackground = Color(0xFFF8F9FA)       // systemBackground (light)
val CoreViaBackgroundNight = Color(0xFF121212)   // systemBackground (dark)
val CoreViaSurface = Color(0xFFFFFFFF)          // secondaryBackground (light)
val CoreViaSurfaceNight = Color(0xFF1E1E1E)     // secondaryBackground (dark)
val CardBackground = Color(0xFFF2F2F7)          // tertiaryBackground (light)
val CardBackgroundDark = Color(0xFF2C2C2E)      // tertiaryBackground (dark)

// ═══════════════════════════════════════════════════════════════════
// TEXT
// ═══════════════════════════════════════════════════════════════════
val TextPrimary = Color(0xFF1A1A2E)             // label
val TextSecondary = Color(0xFF6B7280)           // secondaryLabel
val TextTertiary = Color(0xFF9CA3AF)            // tertiaryLabel
val TextHint = Color(0xFFC7C7CC)                // placeholderText
val TextSeparator = Color(0xFFC6C6C8)           // separator

// ═══════════════════════════════════════════════════════════════════
// INTERACTIVE (Buttons, Links)
// ═══════════════════════════════════════════════════════════════════
val ButtonPrimary = Color(0xFFFF4444)           // buttonPrimary = accent
val ButtonSecondary = Color(0xFFF2F2F7)         // buttonSecondary
val LinkColor = Color(0xFFFF4444)               // link = accent

// ═══════════════════════════════════════════════════════════════════
// CATEGORY (Trainer Specialties)
// ═══════════════════════════════════════════════════════════════════
val CatFitness = Color(0xFFFF0000)              // catFitness
val CatStrength = Color(0xFFD93326)             // catStrength
val CatCardio = Color(0xFFF24D4D)              // catCardio
val CatYoga = Color(0xFF991A1A)                // catYoga
val CatNutrition = Color(0xFF660000)           // catNutrition

// ═══════════════════════════════════════════════════════════════════
// MEAL TYPE
// ═══════════════════════════════════════════════════════════════════
val MealBreakfast = Color(0xFFE65940)           // mealBreakfast
val MealLunch = Color(0xFFCC3333)               // mealLunch
val MealDinner = Color(0xFF8C1A1A)              // mealDinner
val MealSnack = Color(0xFFB32626)               // mealSnack

// ═══════════════════════════════════════════════════════════════════
// PLAN TYPE
// ═══════════════════════════════════════════════════════════════════
val PlanWeightLoss = Color(0xFFD94033)          // planWeightLoss
val PlanWeightGain = Color(0xFFB31A1A)          // planWeightGain
val PlanStrength = Color(0xFFFF0000)            // planStrength

// ═══════════════════════════════════════════════════════════════════
// ACTIVITY TYPE
// ═══════════════════════════════════════════════════════════════════
val ActivityWalking = Color(0xFFCC2626)          // actWalking
val ActivityRunning = Color(0xFFFF0000)          // actRunning
val ActivityCycling = Color(0xFF8C0D0D)          // actCycling

// ═══════════════════════════════════════════════════════════════════
// PROGRESS
// ═══════════════════════════════════════════════════════════════════
val ProgressHigh = Color(0xFF33C759)            // progressHigh — yaşıl
val ProgressMedium = Color(0xB3FF4444)          // progressMedium — 0.7 opacity
val ProgressLow = Color(0xFFFF4444)             // progressLow — qırmızı

// ═══════════════════════════════════════════════════════════════════
// STATS
// ═══════════════════════════════════════════════════════════════════
val StatIcon = Color(0xFFFF4444)                // statIcon = accent

// ═══════════════════════════════════════════════════════════════════
// GRADIENT HELPERS
// ═══════════════════════════════════════════════════════════════════
val GradientStart = Color(0x4DFF4444)           // 0.3 opacity
val GradientEnd = Color(0xFFFF4444)             // solid red

val PremiumGradientStart = Color(0xFF260000)    // tünd qırmızı
val PremiumGradientEnd = Color(0xFFFF4444)      // qırmızı

// ═══════════════════════════════════════════════════════════════════
// AVATAR PALETTE
// ═══════════════════════════════════════════════════════════════════
val AvatarPalette = listOf(
    Color(0xFFFF0000),
    Color(0xFFD93326),
    Color(0xFFB31A1A),
    Color(0xFF8C0D0D),
    Color(0xFF660000),
    Color(0xFFF24D4D),
    Color(0xFF991A1A),
    Color(0xFFBF2626)
)

// ═══════════════════════════════════════════════════════════════════
// STAR RATING
// ═══════════════════════════════════════════════════════════════════
val StarFilled = Color(0xFFFF4444)              // starFilled = accent
val StarEmpty = Color(0xFFD1D1D6)               // starEmpty

// ═══════════════════════════════════════════════════════════════════
// BADGE
// ═══════════════════════════════════════════════════════════════════
val BadgeVerified = Color(0xFF33C759)           // yaşıl
val BadgePending = Color(0xFFE68C1A)            // narıncı
val BadgeRejected = Color(0xFFFF4444)           // qırmızı

// ═══════════════════════════════════════════════════════════════════
// DARK THEME ON-SURFACE
// ═══════════════════════════════════════════════════════════════════
val CoreViaPrimaryNight = Color(0xFFFF6B6B)
val CoreViaOnSurfaceNight = Color(0xFFE0E0E0)

// ═══════════════════════════════════════════════════════════════════
// LEGACY ALIASES (köhnə referanslar üçün)
// ═══════════════════════════════════════════════════════════════════
val CoreViaSecondary = CoreViaPrimaryDark       // secondary = accentDark
val StatusSuccess = CoreViaSuccess
val StatusError = CoreViaError
val StatusWarning = CoreViaWarning
val StatusInfo = CoreViaInfo
val SubtleCardBackground = CardBackground
val AccentPurple = Color(0xFF9C27B0)
val AccentBlue = Color(0xFF2196F3)
val AccentOrange = Color(0xFFFF9800)
val AccentGreen = Color(0xFF4CAF50)
