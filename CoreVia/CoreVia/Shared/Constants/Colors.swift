//
//  Colors.swift
//  CoreVia
//
//  Adaptiv rəng sistemi - Light və Dark mode dəstəyi
//

import SwiftUI

extension Color {

    // MARK: - Adaptive Background Colors
    // Bu rənglər sistem theme-ə görə avtomatik dəyişir
    
    /// Əsas arxa fon - sistem theme-ə uyğun (ağ/qara)
    static let adaptiveBackground = Color(UIColor.systemBackground)
    
    /// İkinci dərəcəli arxa fon - card, container üçün
    static let adaptiveSecondaryBackground = Color(UIColor.secondarySystemBackground)
    
    /// Üçüncü dərəcəli arxa fon - grouped list, deeper cards
    static let adaptiveTertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // MARK: - Adaptive Text Colors
    // Sistem theme-ə görə avtomatik dəyişən mətn rəngləri
    
    /// Əsas mətn - light-da qara, dark-da ağ
    static let adaptiveText = Color(UIColor.label)
    
    /// İkinci dərəcəli mətn - az önəmli mətn üçün
    static let adaptiveSecondaryText = Color(UIColor.secondaryLabel)
    
    /// Üçüncü dərəcəli mətn - placeholder, disabled mətn
    static let adaptiveTertiaryText = Color(UIColor.tertiaryLabel)
    
    // MARK: - Accent Colors (Theme-dən asılı olmur)
    // Bu rənglər həmişə eyni qalır
    
    static let primaryRed = Color(red: 1.0, green: 0.0, blue: 0.0)
    static let accentOrange = Color.orange
    static let accentGreen = Color.green
    static let accentPurple = Color.purple
    static let accentBlue = Color.blue
    
    // MARK: - Status Colors
    
    static let success = Color.green
    static let error = Color.red
    static let warning = Color.yellow
    static let info = Color.blue
    
    // MARK: - Card Background with Opacity
    // Adaptiv fonda opacity ilə card background
    
    static var cardBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    static var subtleCardBackground: Color {
        Color(UIColor.systemGray6)
    }
}

// MARK: - Convenience Computed Properties

extension Color {
    
    /// View background - sistem theme-ə uyğun
    static var viewBackground: Color {
        adaptiveBackground
    }
    
    /// Primary text color
    static var primaryText: Color {
        adaptiveText
    }
    
    /// Secondary text color
    static var secondaryText: Color {
        adaptiveSecondaryText
    }
    
    /// Placeholder text
    static var placeholderText: Color {
        adaptiveTertiaryText
    }
}

// MARK: - Usage Example
/*
 
 // View background (adaptiv)
 ZStack {
     Color.viewBackground.ignoresSafeArea()
     
     VStack {
         // Card
         VStack {
             Text("Başlıq")
                 .foregroundColor(.primaryText)
             
             Text("Alt başlıq")
                 .foregroundColor(.secondaryText)
         }
         .padding()
         .background(Color.cardBackground)
         .cornerRadius(12)
         
         // Button (həmişə qırmızı)
         Button("Əlavə et") { }
             .foregroundColor(.white)
             .padding()
             .background(Color.primaryRed)
             .cornerRadius(12)
     }
 }
 
 */
