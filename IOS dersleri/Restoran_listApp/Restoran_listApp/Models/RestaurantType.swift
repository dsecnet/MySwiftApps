//
//  RestaurantType.swift
//  Restoran_listApp
//
//  Created by Vusal Dadashov on 05.03.26.
//

import SwiftUI

// MARK: - Restaurant Model
struct Restaurant: Identifiable {
    let id = UUID()
    let title: String
    let type: RestaurantType
    let location: String
    let image: String
    var isFavorite: Bool
    var description: String
    var phone: String
    var rating: Double

    static var sample = Restaurant(
        title: "Şirvanşah Muzey Restoranı",
        type: .milli,
        location: "İçərişəhər, Bakı",
        image: "cafedeadend",
        isFavorite: true,
        description: "Azərbaycan mətbəxinin ən yaxşı nümunələri.",
        phone: "+994501234567",
        rating: 4.8
    )
}


enum RestaurantType: String {
    case milli = "Milli Mətbəx"
    case cafe = "Kafe"
    case fastFood = "Fast Food"
    case steakhouse = "Steakhouse"
    case seafood = "Dəniz Məhsulları"
    case italian = "İtalyan"
    case asian = "Asiya"
    case bakery = "Şirniyyat"

    var icon: String {
        switch self {
        case .milli:     return "🇦🇿"
        case .cafe:      return "☕️"
        case .fastFood:  return "🍔"
        case .steakhouse: return "🥩"
        case .seafood:   return "🦐"
        case .italian:   return "🍕"
        case .asian:     return "🍜"
        case .bakery:    return "🧁"
        }
    }
}
