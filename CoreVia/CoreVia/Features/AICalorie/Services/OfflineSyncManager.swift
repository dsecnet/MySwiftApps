//
//  OfflineSyncManager.swift
//  CoreVia
//
//  On-device analiz nəticələrini backend-ə sync edir
//  Offline olduqda nəticələri UserDefaults-da queue-layır
//  Network geri gəldikdə avtomatik sync edir
//
//  Backend-in mövcud POST /api/v1/food/ endpoint-ini istifadə edir
//

import Foundation
import Network
import os.log

// MARK: - Pending Analysis Model

struct PendingFoodAnalysis: Codable {
    let id: String
    let foodName: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fats: Double
    let confidence: Double
    let analyzedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case foodName = "food_name"
        case calories, protein, carbs, fats, confidence
        case analyzedAt = "analyzed_at"
    }
}

// MARK: - Sync Manager

class OfflineSyncManager {
    static let shared = OfflineSyncManager()

    private let pendingKey = "corevia_pending_food_analyses"
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.corevia.networkMonitor")
    private var isConnected = true
    private var isSyncing = false

    private init() {
        startNetworkMonitoring()
    }

    // MARK: - Network Monitoring

    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let wasConnected = self?.isConnected ?? false
            self?.isConnected = (path.status == .satisfied)

            // Network geri gəldikdə sync et
            if !wasConnected && path.status == .satisfied {
                Task { [weak self] in
                    await self?.syncPendingAnalyses()
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    // MARK: - Queue

    /// Analiz nəticəsini sync queue-ya əlavə et
    func queueForSync(_ result: AICalorieResult) {
        let foodNames = result.foods.map { $0.name }.joined(separator: ", ")

        let pending = PendingFoodAnalysis(
            id: UUID().uuidString,
            foodName: foodNames,
            calories: Int(result.totalCalories),
            protein: result.totalProtein,
            carbs: result.totalCarbs,
            fats: result.totalFat,
            confidence: result.confidence,
            analyzedAt: Date()
        )

        var queue = loadPendingQueue()
        queue.append(pending)
        savePendingQueue(queue)

        // Online olduqda dərhal sync et
        if isConnected {
            Task { await syncPendingAnalyses() }
        }
    }

    // MARK: - Sync

    /// Bütün pending analizləri backend-ə göndər
    func syncPendingAnalyses() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        let queue = loadPendingQueue()
        guard !queue.isEmpty else { return }

        var remaining: [PendingFoodAnalysis] = []

        for analysis in queue {
            do {
                try await sendToBackend(analysis)
            } catch {
                // Göndərilə bilmədi — queue-da saxla
                AppLogger.food.error("Offline sync gondermesi ugursuz: \(error.localizedDescription)")
                remaining.append(analysis)
            }
        }

        savePendingQueue(remaining)

        if remaining.isEmpty {
            AppLogger.network.info("Butun pending analizler sync olundu")
        } else {
            AppLogger.network.warning("\(remaining.count) analiz sync olunmadi, novbeti defe cehd edilecek")
        }
    }

    /// Pending item sayını qaytarır
    var pendingCount: Int {
        loadPendingQueue().count
    }

    // MARK: - Backend Send

    private func sendToBackend(_ analysis: PendingFoodAnalysis) async throws {
        // Backend-in mövcud POST /api/v1/food/ endpoint-ini istifadə edirik
        // FoodEntryCreate schema: name, calories, protein, carbs, fats, meal_type
        struct FoodSyncRequest: Encodable {
            let name: String
            let calories: Int
            let protein: Double
            let carbs: Double
            let fats: Double
            let mealType: String
            let aiAnalyzed: Bool
            let aiConfidence: Double

            enum CodingKeys: String, CodingKey {
                case name, calories, protein, carbs, fats
                case mealType = "meal_type"
                case aiAnalyzed = "ai_analyzed"
                case aiConfidence = "ai_confidence"
            }
        }

        let body = FoodSyncRequest(
            name: analysis.foodName,
            calories: analysis.calories,
            protein: analysis.protein,
            carbs: analysis.carbs,
            fats: analysis.fats,
            mealType: estimateMealType(),
            aiAnalyzed: true,
            aiConfidence: analysis.confidence
        )

        try await APIService.shared.requestVoid(
            endpoint: "/api/v1/food/",
            method: "POST",
            body: body
        )
    }

    /// Saat əsasında öğün tipini təxmin et
    private func estimateMealType() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<11: return "breakfast"
        case 11..<15: return "lunch"
        case 15..<17: return "snack"
        case 17..<22: return "dinner"
        default: return "snack"
        }
    }

    // MARK: - Persistence (UserDefaults)

    private func loadPendingQueue() -> [PendingFoodAnalysis] {
        guard let data = UserDefaults.standard.data(forKey: pendingKey),
              let queue = try? JSONDecoder().decode([PendingFoodAnalysis].self, from: data)
        else { return [] }
        return queue
    }

    private func savePendingQueue(_ queue: [PendingFoodAnalysis]) {
        let data = try? JSONEncoder().encode(queue)
        UserDefaults.standard.set(data, forKey: pendingKey)
    }
}
