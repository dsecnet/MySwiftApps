package life.corevia.app.ui.theme

import androidx.compose.ui.graphics.Color

/**
 * iOS AppTheme.swift-in Android tam ekvivalenti.
 * Bütün rənglər iOS-dan götürülüb — eyni hex dəyərlər.
 *
 * iOS:  AppTheme.Colors.accent
 * Android: AppTheme.accent
 */
object AppTheme {

    // ─── Base (Light / Dark mode adaptive) ────────────────────────────────────
    // iOS: Color(UIColor.systemBackground) — avtomatik light/dark
    // Android: MaterialTheme.colorScheme istifadə edilir (CoreViaTheme-də təyin edilib)
    // Lakin dark mode üçün sabit rənglər:

    object Colors {
        // === Base ===
        val background          = Color(0xFF000000)          // iOS: systemBackground (dark)
        val secondaryBackground = Color(0xFF1C1C1E)          // iOS: secondarySystemBackground (dark)
        val cardBackground      = Color(0xFF2C2C2E)          // iOS: tertiarySystemBackground (dark)
        val primaryText         = Color(0xFFFFFFFF)          // iOS: label (dark)
        val secondaryText       = Color(0xFF8E8E93)          // iOS: secondaryLabel (dark)
        val tertiaryText        = Color(0xFF636366)          // iOS: tertiaryLabel (dark)
        val placeholderText     = Color(0xFF3C3C43).copy(alpha = 0.6f)
        val separator           = Color(0xFF38383A)          // iOS: separator (dark)

        // === Brand (iOS: Color.red) ===
        val accent              = Color(0xFFFF3B30)          // iOS: Color.red  (Apple system red)
        val accentDark          = Color(0xFFB20000)          // iOS: Color(red:0.7, green:0.0, blue:0.0)
        val accentLight         = Color(0xFFFF3B30).copy(alpha = 0.15f)  // iOS: .red.opacity(0.15)

        // === Semantic ===
        val success             = Color(0xFF34C759)          // iOS: Color(red:0.2, green:0.78, blue:0.35)
        val warning             = Color(0xFFFFCC00)          // iOS: Color(red:1.0, green:0.8, blue:0.0)
        val error               = Color(0xFFE63333)          // iOS: Color(red:0.9, green:0.2, blue:0.2)
        val info                = Color(0xFF4D4D4D)          // iOS: Color(red:0.3, green:0.3, blue:0.3)

        // === Interactive ===
        val buttonPrimary       = Color(0xFFFF3B30)          // iOS: Color.red
        val buttonSecondary     = Color(0xFF1C1C1E)          // iOS: secondarySystemBackground
        val link                = Color(0xFFFF3B30)

        // === Category (workout categories) ===
        val catFitness          = Color(0xFFFF3B30)          // iOS: Color.red
        val catStrength         = Color(0xFFD93326)          // iOS: Color(red:0.85, green:0.2, blue:0.15)
        val catCardio           = Color(0xFFF24D4D)          // iOS: Color(red:0.95, green:0.3, blue:0.3)
        val catYoga             = Color(0xFF991A1A)          // iOS: Color(red:0.6, green:0.1, blue:0.1)
        val catNutrition        = Color(0xFF660000)          // iOS: Color(red:0.4, green:0.0, blue:0.0)

        // === Meal type ===
        val mealBreakfast       = Color(0xFFE65940)          // iOS: Color(red:0.9, green:0.35, blue:0.25)
        val mealLunch           = Color(0xFFCC3333)          // iOS: Color(red:0.8, green:0.2, blue:0.2)
        val mealDinner          = Color(0xFF8C1A1A)          // iOS: Color(red:0.55, green:0.1, blue:0.1)
        val mealSnack           = Color(0xFFB22626)          // iOS: Color(red:0.7, green:0.15, blue:0.15)

        // === Plan type ===
        val planWeightLoss      = Color(0xFFD94033)          // iOS: Color(red:0.85, green:0.25, blue:0.2)
        val planWeightGain      = Color(0xFFB21A1A)          // iOS: Color(red:0.7, green:0.1, blue:0.1)
        val planStrength        = Color(0xFFFF3B30)          // iOS: Color.red

        // === Activity type ===
        val actWalking          = Color(0xFFCC2626)          // iOS: Color(red:0.8, green:0.15, blue:0.15)
        val actRunning          = Color(0xFFFF3B30)          // iOS: Color.red
        val actCycling          = Color(0xFF8C0D0D)          // iOS: Color(red:0.55, green:0.05, blue:0.05)

        // === Progress ===
        val progressHigh        = Color(0xFF34C759)          // iOS: green (success)
        val progressMedium      = Color(0xFFFF3B30).copy(alpha = 0.7f)
        val progressLow         = Color(0xFFFF3B30)

        // === Stats & icons ===
        val statIcon            = Color(0xFFFF3B30)

        // === Gradients (başlanğıc/son rənglər) ===
        val gradientStart       = Color(0xFFFF3B30).copy(alpha = 0.3f)
        val gradientEnd         = Color(0xFFFF3B30)
        val premiumGradientStart = Color(0xFF260000)         // iOS: Color(red:0.15, green:0.0, blue:0.0)
        val premiumGradientEnd  = Color(0xFFFF3B30)

        // === Avatar palette ===
        val avatarPalette = listOf(
            Color(0xFFFF3B30),   // iOS: Color.red
            Color(0xFFD93326),   // iOS: Color(red:0.85, green:0.2, blue:0.15)
            Color(0xFFB21A1A),   // iOS: Color(red:0.7, green:0.1, blue:0.1)
            Color(0xFF8C0D0D),   // iOS: Color(red:0.55, green:0.05, blue:0.05)
            Color(0xFF660000),   // iOS: Color(red:0.4, green:0.0, blue:0.0)
            Color(0xFFF24D4D),   // iOS: Color(red:0.95, green:0.3, blue:0.3)
            Color(0xFF991A1A),   // iOS: Color(red:0.6, green:0.1, blue:0.1)
            Color(0xFFBF2626),   // iOS: Color(red:0.75, green:0.15, blue:0.15)
        )

        // === Star rating ===
        val starFilled          = Color(0xFFFF3B30)
        val starEmpty           = Color(0xFF636366)          // iOS: systemGray4

        // === Badge ===
        val badgeVerified       = Color(0xFF34C759)          // iOS: green
        val badgePending        = Color(0xFFE68A1A)          // iOS: Color(red:0.9, green:0.55, blue:0.1)
        val badgeRejected       = Color(0xFFFF3B30)
    }

    // ─── Spacing (iOS AppTheme.Spacing) ──────────────────────────────────────
    object Spacing {
        val sm = 8
        val md = 12
        val lg = 16
        val xl = 24
    }

    // ─── Corner Radius (iOS AppTheme.CornerRadius) ────────────────────────────
    object CornerRadius {
        val sm = 8
        val md = 12
        val lg = 16
    }
}
