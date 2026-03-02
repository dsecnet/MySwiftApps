//
//  AICalorieService.swift
//  CoreVia
//
//  On-device Core ML kalori analiz servisi
//  Şəkil analizi tamamilə cihazda olur (YOLOv8 + EfficientNet + USDA DB)
//  Nəticə backend-ə sync olunur (offline support)
//  Tarixçə backend-dən gəlir
//

import Foundation
import UIKit
import os.log

// MARK: - Response Models

struct AICalorieResult: Codable {
    let foods: [DetectedFood]
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let confidence: Double
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case foods
        case totalCalories = "total_calories"
        case totalProtein = "total_protein"
        case totalCarbs = "total_carbs"
        case totalFat = "total_fat"
        case confidence
        case imageUrl = "image_url"
    }
}

struct DetectedFood: Identifiable, Codable {
    let id: String?
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let portionGrams: Double
    let confidence: Double

    enum CodingKeys: String, CodingKey {
        case id, name, calories, protein, carbs, fat, confidence
        case portionGrams = "portion_grams"
    }

    // Identifiable fallback
    var stableId: String { id ?? name }
}

struct CalorieHistoryResponse: Codable {
    let analyses: [CalorieHistoryItem]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case analyses, total, page
        case pageSize = "page_size"
        case hasMore = "has_more"
    }
}

struct CalorieHistoryItem: Identifiable, Codable {
    let id: String
    let imageUrl: String?
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let foodCount: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
        case totalCalories = "total_calories"
        case totalProtein = "total_protein"
        case totalCarbs = "total_carbs"
        case totalFat = "total_fat"
        case foodCount = "food_count"
        case createdAt = "created_at"
    }
}

// MARK: - Backend Response Model (fərqli format!)

private struct BackendFoodAnalysisResponse: Codable {
    let success: Bool?
    let foodName: String?
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let fats: Double?
    let portionSize: String?
    let confidence: Double?
    let foodsDetail: [BackendFoodDetail]?

    enum CodingKeys: String, CodingKey {
        case success
        case foodName = "food_name"
        case calories, protein, carbs, fats
        case portionSize = "portion_size"
        case confidence
        case foodsDetail = "foods_detail"
    }
}

private struct BackendFoodDetail: Codable {
    let name: String?
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let fats: Double?
    let portionSize: String?

    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fats
        case portionSize = "portion_size"
    }
}

// MARK: - Service

class AICalorieService {
    static let shared = AICalorieService()
    private init() {}

    /// On-device Core ML ilə qida analizi (network lazım deyil!)
    /// Nəticə avtomatik backend-ə sync olunur
    func analyzeFood(image: UIImage) async throws -> AICalorieResult {
        do {
            // On-device analiz — Core ML (YOLOv8 + EfficientNet + USDA DB)
            let result = try await OnDeviceFoodAnalyzer.shared.analyzeFood(image: image)

            // Nəticəni backend-ə sync et (fire-and-forget, offline olduqda queue-lanır)
            OfflineSyncManager.shared.queueForSync(result)

            return result
        } catch {
            // Core ML xəta verərsə → backend API-yə fallback
            AppLogger.ml.warning("On-device analiz xetasi: \(error.localizedDescription)")
            AppLogger.ml.info("Backend fallback istifade olunur...")
            return try await analyzeFoodViaBackend(image: image)
        }
    }

    /// Backend fallback — Core ML işləmədikdə
    private func analyzeFoodViaBackend(image: UIImage) async throws -> AICalorieResult {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.noData
        }

        let data = try await APIService.shared.uploadImage(
            endpoint: "/api/v1/food/analyze",
            imageData: imageData,
            fieldName: "file",
            fileName: "food_photo.jpg"
        )

        // Backend fərqli format qaytarır — mapping lazımdır
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let backendResponse = try decoder.decode(BackendFoodAnalysisResponse.self, from: data)

        // Backend response → AICalorieResult mapping
        return mapBackendResponse(backendResponse)
    }

    /// Backend response-u AICalorieResult formatına çevir
    private func mapBackendResponse(_ response: BackendFoodAnalysisResponse) -> AICalorieResult {
        var foods: [DetectedFood] = []

        // Əgər foods_detail varsa — hər birini ayrıca DetectedFood yarat
        if let details = response.foodsDetail, !details.isEmpty {
            for detail in details {
                foods.append(DetectedFood(
                    id: UUID().uuidString,
                    name: detail.name ?? "Food",
                    calories: detail.calories ?? 0,
                    protein: detail.protein ?? 0,
                    carbs: detail.carbs ?? 0,
                    fat: detail.fats ?? 0,
                    portionGrams: 200,
                    confidence: response.confidence ?? 0.5
                ))
            }
        } else {
            // Tək yemək — əsas response-dan yarat
            foods.append(DetectedFood(
                id: UUID().uuidString,
                name: response.foodName ?? "Food",
                calories: response.calories ?? 0,
                protein: response.protein ?? 0,
                carbs: response.carbs ?? 0,
                fat: response.fats ?? 0,
                portionGrams: 200,
                confidence: response.confidence ?? 0.5
            ))
        }

        let totalCalories = foods.reduce(0) { $0 + $1.calories }
        let totalProtein = foods.reduce(0) { $0 + $1.protein }
        let totalCarbs = foods.reduce(0) { $0 + $1.carbs }
        let totalFat = foods.reduce(0) { $0 + $1.fat }

        return AICalorieResult(
            foods: foods,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            confidence: response.confidence ?? 0.5,
            imageUrl: nil
        )
    }

    /// Kalori analiz tarixçəsi (həmişə backend-dən)
    func getHistory(page: Int = 1, pageSize: Int = 20) async throws -> CalorieHistoryResponse {
        return try await APIService.shared.request(
            endpoint: "/api/v1/food",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "page_size", value: "\(pageSize)")
            ]
        )
    }
}
