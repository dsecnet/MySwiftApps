//
//  Constants.swift
//  FitnessApp
//
//  App-da istifadə ediləcək sabit dəyərlər
//

import SwiftUI

struct Layout {
    
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    
    // MARK: - Corner Radius (Künc radiusu)
    // Düymələr, kartlar üçün dairəvi küncklər
    
    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24
    
    // MARK: - Padding (Daxili boşluq)
    
    static let paddingS: CGFloat = 12
    static let paddingM: CGFloat = 16
    static let paddingL: CGFloat = 20
}

// MARK: - Font Sizes (Şrift ölçüləri)

struct Typography {
    static let titleLarge: CGFloat = 28
    static let titleMedium: CGFloat = 22
    static let titleSmall: CGFloat = 18
    static let body: CGFloat = 16
    static let caption: CGFloat = 14
    static let small: CGFloat = 12
}

// MARK: - Animation (Animasiya)

struct Animations {
    static let defaultDuration: Double = 0.3    // Default animasiya müddəti
    static let fastDuration: Double = 0.2       // Sürətli animasiya
    static let slowDuration: Double = 0.5       // Yavaş animasiya
}


// Struct-lar namespace kimi işləyir və dəyərləri qruplaşdırır
// Məsələn: Layout.spacingM, Typography.body

// MARK: - İstifadə nümunəsi:
/*
 VStack(spacing: Layout.spacingM) {
     Text("Başlıq")
         .font(.system(size: Typography.titleLarge))
     
     RoundedRectangle(cornerRadius: Layout.cornerRadiusM)
         .frame(height: 100)
 }
 .padding(Layout.paddingM)
 */
