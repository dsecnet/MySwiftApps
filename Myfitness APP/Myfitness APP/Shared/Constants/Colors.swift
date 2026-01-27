//
//  Colors.swift
//  FitnessApp
//
//  Qara + Qırmızı Theme üçün rəng sistemi
//

import SwiftUI

extension Color {

    // MARK: - Primary Colors (Əsas Rənglər)
    // App-ın əsas rəng sxemidir (aksentlər, button, logo)
    
    static let primaryRed = Color(red: 1.0, green: 0.0, blue: 0.0)       // Qırmızı aksent
    static let primaryDark = Color(red: 0.0, green: 0.0, blue: 0.0)      // Tam qara, əsas fon
    static let primaryGray = Color(red: 0.15, green: 0.15, blue: 0.15)   // Tünd boz, card arxa fon üçün
    static let primaryLightGray = Color(red: 0.25, green: 0.25, blue: 0.25) // Yüngül tünd boz, hover / alt background

    // MARK: - Background Colors (Arxa fon rənglər)

    static let background = Color.primaryDark       // Əsas arxa fon
    static let cardBackground = Color.primaryGray   // Kart / container arxa fon
    static let darkBackground = Color.black         // Hard black lazım olduqda
    
    // MARK: - Text Colors (Mətn rənglər)

    static let textPrimary = Color.white            // Əsas mətn (qara fon üzərində)
    static let textSecondary = Color.gray           // İkinci dərəcəli mətn
    static let textLight = Color.primaryRed         // Highlight / aksent mətni
    
    // MARK: - Status Colors (Status rənglər)

    static let success = Color.green                // Uğurlu
    static let error = Color.red                    // Xəta
    static let warning = Color.yellow              // Xəbərdarlıq
    static let info = Color.primaryRed             // Məlumat / aksent üçün
}

// MARK: - İstifadə nümunəsi:
/*
Text("Salam")
    .foregroundColor(.textPrimary)

Rectangle()
    .fill(Color.cardBackground)

Button("Daxil ol") {
    // Action
}
.background(Color.primaryRed)
.foregroundColor(.textPrimary)
.cornerRadius(12)
*/
