package life.corevia.app.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

// ═══════════════════════════════════════════════════════════════════════════════
// CoreVia Qırmızı Rəng Sistemi — Dark + Light Theme
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Bütün rəngləri saxlayan data class.
 * Dark və Light versiyaları ayrı-ayrı təyin edilir.
 * CompositionLocal ilə hər yerdə əlçatan olur.
 */
data class CoreViaColors(
    // === Base ===
    val background: Color,
    val secondaryBackground: Color,
    val cardBackground: Color,
    val primaryText: Color,
    val secondaryText: Color,
    val tertiaryText: Color,
    val placeholderText: Color,
    val separator: Color,

    // === Brand (Qırmızı) ===
    val accent: Color,
    val accentDark: Color,
    val accentLight: Color,

    // === Semantic ===
    val success: Color,
    val warning: Color,
    val error: Color,
    val info: Color,

    // === Interactive ===
    val buttonPrimary: Color,
    val buttonSecondary: Color,
    val link: Color,

    // === Category (workout categories) ===
    val catFitness: Color,
    val catStrength: Color,
    val catCardio: Color,
    val catYoga: Color,
    val catNutrition: Color,

    // === Meal type ===
    val mealBreakfast: Color,
    val mealLunch: Color,
    val mealDinner: Color,
    val mealSnack: Color,

    // === Plan type ===
    val planWeightLoss: Color,
    val planWeightGain: Color,
    val planStrength: Color,

    // === Activity type ===
    val actWalking: Color,
    val actRunning: Color,
    val actCycling: Color,

    // === Progress ===
    val progressHigh: Color,
    val progressMedium: Color,
    val progressLow: Color,

    // === Stats & icons ===
    val statIcon: Color,
    val statDistance: Color,
    val statSpeed: Color,

    // === Gradients ===
    val gradientStart: Color,
    val gradientEnd: Color,
    val premiumGradientStart: Color,
    val premiumGradientEnd: Color,

    // === Avatar palette ===
    val avatarPalette: List<Color>,

    // === Star rating ===
    val starFilled: Color,
    val starEmpty: Color,

    // === Badge ===
    val badgeVerified: Color,
    val badgePending: Color,
    val badgeRejected: Color,
)

// ─── Dark Theme Rəngləri (Qara + Qırmızı) ──────────────────────────────────
val DarkCoreViaColors = CoreViaColors(
    // Base
    background          = Color(0xFF0A0A0A),          // Dərin qara (OLED)
    secondaryBackground = Color(0xFF1A1A1A),          // Tünd boz
    cardBackground      = Color(0xFF222222),          // Kart
    primaryText         = Color(0xFFFFFFFF),          // Ağ
    secondaryText       = Color(0xFF9E9E9E),          // Boz
    tertiaryText        = Color(0xFF6B6B6B),          // Tünd boz
    placeholderText     = Color(0xFF5A5A5A),          // Placeholder
    separator           = Color(0xFF333333),          // Separator

    // Brand (Qırmızı)
    accent              = Color(0xFFFF3B30),          // Apple Red (əsas)
    accentDark          = Color(0xFFCC2D25),          // Tünd qırmızı
    accentLight         = Color(0xFFFF3B30).copy(alpha = 0.15f),

    // Semantic
    success             = Color(0xFF34C759),          // Yaşıl
    warning             = Color(0xFFFFB800),          // Narıncı-sarı
    error               = Color(0xFFFF3B30),          // Qırmızı
    info                = Color(0xFF6B6B6B),          // Neytral

    // Interactive
    buttonPrimary       = Color(0xFFFF3B30),
    buttonSecondary     = Color(0xFF1A1A1A),
    link                = Color(0xFFFF3B30),

    // Category
    catFitness          = Color(0xFFFF3B30),
    catStrength         = Color(0xFFE03428),
    catCardio           = Color(0xFFFF5247),
    catYoga             = Color(0xFFCC2D25),
    catNutrition        = Color(0xFFB32720),

    // Meal
    mealBreakfast       = Color(0xFFFF3B30),
    mealLunch           = Color(0xFFE03428),
    mealDinner          = Color(0xFFCC2D25),
    mealSnack           = Color(0xFFFF5247),

    // Plan
    planWeightLoss      = Color(0xFFFF5247),
    planWeightGain      = Color(0xFFCC2D25),
    planStrength        = Color(0xFFFF3B30),

    // Activity
    actWalking          = Color(0xFFE03428),
    actRunning          = Color(0xFFFF3B30),
    actCycling          = Color(0xFFCC2D25),

    // Progress
    progressHigh        = Color(0xFF34C759),
    progressMedium      = Color(0xFFFF3B30).copy(alpha = 0.7f),
    progressLow         = Color(0xFFFF3B30),

    // Stats
    statIcon            = Color(0xFFFF3B30),
    statDistance         = Color(0xFF5B9BD5),          // Mavi
    statSpeed            = Color(0xFF9B72CF),          // Bənövşəyi

    // Gradients
    gradientStart       = Color(0xFFFF3B30).copy(alpha = 0.3f),
    gradientEnd         = Color(0xFFCC2D25),
    premiumGradientStart = Color(0xFF3D0000),
    premiumGradientEnd  = Color(0xFFFF3B30),

    // Avatar
    avatarPalette = listOf(
        Color(0xFFFF3B30),
        Color(0xFFFF5247),
        Color(0xFFE03428),
        Color(0xFFCC2D25),
        Color(0xFFB32720),
        Color(0xFF991F1A),
        Color(0xFFFF6961),
        Color(0xFFFF7B73),
    ),

    // Star
    starFilled          = Color(0xFFFF3B30),
    starEmpty           = Color(0xFF6B6B6B),

    // Badge
    badgeVerified       = Color(0xFF34C759),
    badgePending        = Color(0xFFFFB800),
    badgeRejected       = Color(0xFFFF3B30),
)

// ─── Light Theme Rəngləri (Ağ fon + Qırmızı) ──────────────────────────────
val LightCoreViaColors = CoreViaColors(
    // Base — təmiz ağ fon, yüksək kontrast
    background          = Color(0xFFFAFAFA),          // Təmiz ağ
    secondaryBackground = Color(0xFFFFFFFF),          // Ağ kart/surface
    cardBackground      = Color(0xFFFFFFFF),          // Ağ kart
    primaryText         = Color(0xFF1A1A1A),          // Qara text
    secondaryText       = Color(0xFF5C5C5C),          // Tünd boz
    tertiaryText        = Color(0xFF8A8A8A),          // Orta boz
    placeholderText     = Color(0xFFAAAAAA),          // Açıq boz placeholder
    separator           = Color(0xFFE5E5E5),          // Neytral separator

    // Brand — qırmızı, yüksək kontrast ağ fonda
    accent              = Color(0xFFE02D22),          // Açıq qırmızı (əsas)
    accentDark          = Color(0xFFB32720),          // Tünd qırmızı
    accentLight         = Color(0xFFE02D22).copy(alpha = 0.10f),

    // Semantic — tünd versiyalar ağ fonda yaxşı oxunur
    success             = Color(0xFF1E8E3E),          // Tünd yaşıl
    warning             = Color(0xFFCC8400),          // Tünd narıncı
    error               = Color(0xFFC62828),          // Tünd qırmızı
    info                = Color(0xFF757575),          // Neytral boz

    // Interactive
    buttonPrimary       = Color(0xFFE02D22),
    buttonSecondary     = Color(0xFFF5F5F5),
    link                = Color(0xFFE02D22),

    // Category — qırmızı tonlar
    catFitness          = Color(0xFFE02D22),
    catStrength         = Color(0xFFC62828),
    catCardio           = Color(0xFFEF4136),
    catYoga             = Color(0xFFB32720),
    catNutrition        = Color(0xFF991F1A),

    // Meal — qırmızı tonlar
    mealBreakfast       = Color(0xFFE02D22),
    mealLunch           = Color(0xFFC62828),
    mealDinner          = Color(0xFFB32720),
    mealSnack           = Color(0xFFEF4136),

    // Plan
    planWeightLoss      = Color(0xFFEF4136),
    planWeightGain      = Color(0xFFB32720),
    planStrength        = Color(0xFFE02D22),

    // Activity
    actWalking          = Color(0xFFC62828),
    actRunning          = Color(0xFFE02D22),
    actCycling          = Color(0xFFB32720),

    // Progress
    progressHigh        = Color(0xFF1E8E3E),
    progressMedium      = Color(0xFFE02D22).copy(alpha = 0.7f),
    progressLow         = Color(0xFFE02D22),

    // Stats
    statIcon            = Color(0xFFE02D22),
    statDistance         = Color(0xFF2E7AB8),          // Tünd mavi
    statSpeed            = Color(0xFF7B4FB0),          // Tünd bənövşəyi

    // Gradients — ağ fon üçün incə gradient
    gradientStart       = Color(0xFFE02D22).copy(alpha = 0.15f),
    gradientEnd         = Color(0xFFC62828),
    premiumGradientStart = Color(0xFFFFF0F0),
    premiumGradientEnd  = Color(0xFFE02D22),

    // Avatar
    avatarPalette = listOf(
        Color(0xFFE02D22),
        Color(0xFFEF4136),
        Color(0xFFC62828),
        Color(0xFFB32720),
        Color(0xFF991F1A),
        Color(0xFFFF5247),
        Color(0xFFFF6961),
        Color(0xFFFF7B73),
    ),

    // Star
    starFilled          = Color(0xFFE02D22),
    starEmpty           = Color(0xFFCCCCCC),

    // Badge
    badgeVerified       = Color(0xFF1E8E3E),
    badgePending        = Color(0xFFCC8400),
    badgeRejected       = Color(0xFFC62828),
)

// ─── CompositionLocal ────────────────────────────────────────────────────────
val LocalCoreViaColors = staticCompositionLocalOf { DarkCoreViaColors }

// ═══════════════════════════════════════════════════════════════════════════════
// AppTheme — əvvəlki API-ni qoruyur: AppTheme.Colors.accent
// ═══════════════════════════════════════════════════════════════════════════════
object AppTheme {

    /**
     * AppTheme.Colors.accent — bütün ekranlar bunu istifadə edir.
     * CompositionLocal-dan oxuyur, theme-ə görə dark/light qaytarır.
     */
    object Colors {
        // Composable kontekst lazımdır — inline getter istifadə edirik
        val background: Color          @Composable get() = LocalCoreViaColors.current.background
        val secondaryBackground: Color @Composable get() = LocalCoreViaColors.current.secondaryBackground
        val cardBackground: Color      @Composable get() = LocalCoreViaColors.current.cardBackground
        val primaryText: Color         @Composable get() = LocalCoreViaColors.current.primaryText
        val secondaryText: Color       @Composable get() = LocalCoreViaColors.current.secondaryText
        val tertiaryText: Color        @Composable get() = LocalCoreViaColors.current.tertiaryText
        val placeholderText: Color     @Composable get() = LocalCoreViaColors.current.placeholderText
        val separator: Color           @Composable get() = LocalCoreViaColors.current.separator

        val accent: Color              @Composable get() = LocalCoreViaColors.current.accent
        val accentDark: Color          @Composable get() = LocalCoreViaColors.current.accentDark
        val accentLight: Color         @Composable get() = LocalCoreViaColors.current.accentLight

        val success: Color             @Composable get() = LocalCoreViaColors.current.success
        val warning: Color             @Composable get() = LocalCoreViaColors.current.warning
        val error: Color               @Composable get() = LocalCoreViaColors.current.error
        val info: Color                @Composable get() = LocalCoreViaColors.current.info

        val buttonPrimary: Color       @Composable get() = LocalCoreViaColors.current.buttonPrimary
        val buttonSecondary: Color     @Composable get() = LocalCoreViaColors.current.buttonSecondary
        val link: Color                @Composable get() = LocalCoreViaColors.current.link

        val catFitness: Color          @Composable get() = LocalCoreViaColors.current.catFitness
        val catStrength: Color         @Composable get() = LocalCoreViaColors.current.catStrength
        val catCardio: Color           @Composable get() = LocalCoreViaColors.current.catCardio
        val catYoga: Color             @Composable get() = LocalCoreViaColors.current.catYoga
        val catNutrition: Color        @Composable get() = LocalCoreViaColors.current.catNutrition

        val mealBreakfast: Color       @Composable get() = LocalCoreViaColors.current.mealBreakfast
        val mealLunch: Color           @Composable get() = LocalCoreViaColors.current.mealLunch
        val mealDinner: Color          @Composable get() = LocalCoreViaColors.current.mealDinner
        val mealSnack: Color           @Composable get() = LocalCoreViaColors.current.mealSnack

        val planWeightLoss: Color      @Composable get() = LocalCoreViaColors.current.planWeightLoss
        val planWeightGain: Color      @Composable get() = LocalCoreViaColors.current.planWeightGain
        val planStrength: Color        @Composable get() = LocalCoreViaColors.current.planStrength

        val actWalking: Color          @Composable get() = LocalCoreViaColors.current.actWalking
        val actRunning: Color          @Composable get() = LocalCoreViaColors.current.actRunning
        val actCycling: Color          @Composable get() = LocalCoreViaColors.current.actCycling

        val progressHigh: Color        @Composable get() = LocalCoreViaColors.current.progressHigh
        val progressMedium: Color      @Composable get() = LocalCoreViaColors.current.progressMedium
        val progressLow: Color         @Composable get() = LocalCoreViaColors.current.progressLow

        val statIcon: Color            @Composable get() = LocalCoreViaColors.current.statIcon
        val statDistance: Color         @Composable get() = LocalCoreViaColors.current.statDistance
        val statSpeed: Color           @Composable get() = LocalCoreViaColors.current.statSpeed

        val gradientStart: Color       @Composable get() = LocalCoreViaColors.current.gradientStart
        val gradientEnd: Color         @Composable get() = LocalCoreViaColors.current.gradientEnd
        val premiumGradientStart: Color @Composable get() = LocalCoreViaColors.current.premiumGradientStart
        val premiumGradientEnd: Color  @Composable get() = LocalCoreViaColors.current.premiumGradientEnd

        val avatarPalette: List<Color> @Composable get() = LocalCoreViaColors.current.avatarPalette

        val starFilled: Color          @Composable get() = LocalCoreViaColors.current.starFilled
        val starEmpty: Color           @Composable get() = LocalCoreViaColors.current.starEmpty

        val badgeVerified: Color       @Composable get() = LocalCoreViaColors.current.badgeVerified
        val badgePending: Color        @Composable get() = LocalCoreViaColors.current.badgePending
        val badgeRejected: Color       @Composable get() = LocalCoreViaColors.current.badgeRejected
    }

    // ─── Spacing ─────────────────────────────────────────────────────────────
    object Spacing {
        val sm = 8
        val md = 12
        val lg = 16
        val xl = 24
    }

    // ─── Corner Radius ───────────────────────────────────────────────────────
    object CornerRadius {
        val sm = 8
        val md = 12
        val lg = 16
    }

    // ─── Card Style ──────────────────────────────────────────────────────────
    object CardStyle {
        val defaultElevation = 4
        val borderAlpha = 0.08f
        val shadowAlpha = 0.06f
    }
}
