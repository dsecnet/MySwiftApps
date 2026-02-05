//
//  Colors.swift
//  CoreVia
//

import SwiftUI

extension Color {

    // MARK: - Adaptive Background Colors
    static let adaptiveBackground = Color(UIColor.systemBackground)
    static let adaptiveSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let adaptiveTertiaryBackground = Color(UIColor.tertiarySystemBackground)

    // MARK: - Adaptive Text Colors
    static let adaptiveText = Color(UIColor.label)
    static let adaptiveSecondaryText = Color(UIColor.secondaryLabel)
    static let adaptiveTertiaryText = Color(UIColor.tertiaryLabel)

    // MARK: - Brand / Accent
    static let primaryRed = AppTheme.Colors.accent
    static let accentOrange = AppTheme.Colors.accentDark
    static let accentGreen = AppTheme.Colors.success
    static let accentPurple = AppTheme.Colors.accentDark
    static let accentBlue = AppTheme.Colors.info

    // MARK: - Status Colors
    static let statusSuccess = AppTheme.Colors.success
    static let statusError = AppTheme.Colors.error
    static let statusWarning = AppTheme.Colors.warning
    static let statusInfo = AppTheme.Colors.info

    // MARK: - Card Backgrounds
    static var cardBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }

    static var subtleCardBackground: Color {
        Color(UIColor.systemGray6)
    }
}

// MARK: - Convenience
extension Color {
    static var viewBackground: Color { adaptiveBackground }
}
