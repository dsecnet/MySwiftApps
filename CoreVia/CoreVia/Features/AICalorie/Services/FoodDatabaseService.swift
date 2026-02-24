//
//  FoodDatabaseService.swift
//  CoreVia
//
//  On-device qida verilənlər bazası servisi
//  USDA + Azerbaycan yeməkləri — offline nutrition lookup
//  Backend food_database.py ilə eyni matching logic
//

import Foundation

// MARK: - Models

struct FoodNutritionInfo {
    let foodName: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let portionGrams: Double
    let portionDesc: String
}

struct PortionNutrition {
    let foodName: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let portionGrams: Double
    let portionDesc: String
    let confidence: Double
    let matched: Bool
}

// MARK: - Service

class FoodDatabaseService {
    static let shared = FoodDatabaseService()

    private var foods: [String: FoodNutritionInfo] = [:]
    private var foodNames: [String] = []

    private init() {
        loadDatabase()
    }

    // MARK: - Load

    private func loadDatabase() {
        guard let url = Bundle.main.url(forResource: "food_database", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]]
        else {
            print("⚠️ food_database.json yuklenmedi")
            return
        }

        for (name, info) in json {
            // Həm orijinal, həm lowercase key saxla — lookup asanlaşır
            let lowerName = name.lowercased()
            let displayName = name.replacingOccurrences(of: "_", with: " ")
                .split(separator: " ").map { $0.capitalized }.joined(separator: " ")
            let entry = FoodNutritionInfo(
                foodName: displayName,
                caloriesPer100g: (info["calories"] as? NSNumber)?.doubleValue ?? 0,
                proteinPer100g: (info["protein"] as? NSNumber)?.doubleValue ?? 0,
                carbsPer100g: (info["carbs"] as? NSNumber)?.doubleValue ?? 0,
                fatPer100g: (info["fat"] as? NSNumber)?.doubleValue ?? 0,
                portionGrams: (info["portion_g"] as? NSNumber)?.doubleValue ?? 200,
                portionDesc: info["portion_desc"] as? String ?? "1 portion"
            )
            // Orijinal key
            foods[name] = entry
            // Lowercase key (əgər fərqlidirsə)
            if lowerName != name { foods[lowerName] = entry }
            // Underscore variant
            let underscoreKey = lowerName.replacingOccurrences(of: " ", with: "_")
            if underscoreKey != lowerName { foods[underscoreKey] = entry }
            // Space variant
            let spaceKey = lowerName.replacingOccurrences(of: "_", with: " ")
            if spaceKey != lowerName { foods[spaceKey] = entry }
        }
        foodNames = Array(foods.keys)
        print("✅ FoodDatabase: \(foods.count) qida yuklendi")
    }

    // MARK: - Lookup

    /// Qida adına görə beslenme dəyərlərini qaytarır (porsiya üçün hesablanmış)
    func getNutrition(for foodName: String) -> PortionNutrition {
        let query = foodName.lowercased().trimmingCharacters(in: .whitespaces)
        // Underscore ↔ space normalization (model "bell_pepper" qaytara bilər, DB "Bell Pepper" saxlayır)
        let queryUnderscore = query.replacingOccurrences(of: " ", with: "_")
        let querySpace = query.replacingOccurrences(of: "_", with: " ")

        // 1. Exact match (3 variant: original, underscore, space)
        for variant in [query, queryUnderscore, querySpace] {
            if let food = foods[variant] {
                return calculatePortion(food)
            }
        }

        // 2. Partial match (hər iki format yoxla)
        for name in foodNames {
            let nameLower = name.lowercased()
            if nameLower.contains(query) || query.contains(nameLower)
                || nameLower.contains(querySpace) || querySpace.contains(nameLower)
                || nameLower.contains(queryUnderscore) || queryUnderscore.contains(nameLower) {
                if let food = foods[name] {
                    return calculatePortion(food)
                }
            }
        }

        // 3. Fuzzy match (LCS similarity > 0.55)
        var bestMatch: String?
        var bestScore: Double = 0

        for name in foodNames {
            let score = stringSimilarity(query, name)
            if score > bestScore {
                bestScore = score
                bestMatch = name
            }
        }

        if let match = bestMatch, bestScore > 0.55, let food = foods[match] {
            return calculatePortion(food)
        }

        // 4. Default fallback
        return PortionNutrition(
            foodName: foodName.capitalized,
            calories: 200,
            protein: 10.0,
            carbs: 25.0,
            fat: 8.0,
            portionGrams: 200,
            portionDesc: "1 portion (~200g)",
            confidence: 0.3,
            matched: false
        )
    }

    // MARK: - Helpers

    private func calculatePortion(_ food: FoodNutritionInfo) -> PortionNutrition {
        let multiplier = food.portionGrams / 100.0
        return PortionNutrition(
            foodName: food.foodName.capitalized,
            calories: Int((food.caloriesPer100g * multiplier).rounded()),
            protein: (food.proteinPer100g * multiplier * 10).rounded() / 10,
            carbs: (food.carbsPer100g * multiplier * 10).rounded() / 10,
            fat: (food.fatPer100g * multiplier * 10).rounded() / 10,
            portionGrams: food.portionGrams,
            portionDesc: food.portionDesc,
            confidence: 0.9,
            matched: true
        )
    }

    /// SequenceMatcher ekvivalenti — Longest Common Subsequence ratio
    private func stringSimilarity(_ a: String, _ b: String) -> Double {
        let aChars = Array(a)
        let bChars = Array(b)
        let aLen = aChars.count
        let bLen = bChars.count
        guard aLen > 0, bLen > 0 else { return 0 }

        // LCS dynamic programming
        var dp = Array(repeating: Array(repeating: 0, count: bLen + 1), count: aLen + 1)
        for i in 1...aLen {
            for j in 1...bLen {
                if aChars[i - 1] == bChars[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        return Double(2 * dp[aLen][bLen]) / Double(aLen + bLen)
    }
}
