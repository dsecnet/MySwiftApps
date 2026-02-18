//
//  TrainingPlanManager.swift
//  CoreVia
//
//  İdman planı modeli və idarəsi - Backend API ilə
//

import Foundation
import SwiftUI

// MARK: - Plan Type
enum PlanType: String, Codable, CaseIterable {
    case weightLoss = "weight_loss"
    case weightGain = "weight_gain"
    case strengthTraining = "strength_training"

    var icon: String {
        switch self {
        case .weightLoss: return "flame.fill"
        case .weightGain: return "arrow.up.circle.fill"
        case .strengthTraining: return "dumbbell.fill"
        }
    }

    var color: Color {
        switch self {
        case .weightLoss: return AppTheme.Colors.planWeightLoss
        case .weightGain: return AppTheme.Colors.planWeightGain
        case .strengthTraining: return AppTheme.Colors.planStrength
        }
    }

    var localizedName: String {
        let loc = LocalizationManager.shared
        switch self {
        case .weightLoss: return loc.localized("plan_type_weight_loss")
        case .weightGain: return loc.localized("plan_type_weight_gain")
        case .strengthTraining: return loc.localized("plan_type_strength")
        }
    }
}

// MARK: - Plan Workout (Plan daxilindəki məşq)
struct PlanWorkout: Identifiable, Codable {
    let id: String
    var name: String
    var sets: Int
    var reps: Int
    var duration: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, sets, reps, duration
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        sets: Int = 3,
        reps: Int = 12,
        duration: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.duration = duration
    }
}

// MARK: - Training Plan Model
struct TrainingPlan: Identifiable, Codable {
    let id: String
    var trainerId: String?
    var assignedStudentId: String?
    var title: String
    var planType: PlanType
    var workouts: [PlanWorkout]
    var assignedStudentName: String?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case id, title, workouts, notes
        case trainerId = "trainer_id"
        case assignedStudentId = "assigned_student_id"
        case planType = "plan_type"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(
        id: String = UUID().uuidString,
        trainerId: String? = nil,
        assignedStudentId: String? = nil,
        title: String,
        planType: PlanType,
        workouts: [PlanWorkout] = [],
        assignedStudentName: String? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.trainerId = trainerId
        self.assignedStudentId = assignedStudentId
        self.title = title
        self.planType = planType
        self.workouts = workouts
        self.assignedStudentName = assignedStudentName
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
    }

    // Custom decoder - backend is_completed/completed_at göndərməyə bilər
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        trainerId = try container.decodeIfPresent(String.self, forKey: .trainerId)
        assignedStudentId = try container.decodeIfPresent(String.self, forKey: .assignedStudentId)
        title = try container.decode(String.self, forKey: .title)
        planType = try container.decode(PlanType.self, forKey: .planType)
        workouts = try container.decodeIfPresent([PlanWorkout].self, forKey: .workouts) ?? []
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        assignedStudentName = nil
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: createdAt ?? Date())
    }

    // Backward compat - createdDate alias
    var createdDate: Date {
        createdAt ?? Date()
    }
}

// MARK: - Backend request models
private struct TrainingPlanCreateRequest: Encodable {
    let title: String
    let planType: String
    let notes: String?
    let assignedStudentId: String?
    let workouts: [PlanWorkoutCreateRequest]

    enum CodingKeys: String, CodingKey {
        case title, notes, workouts
        case planType = "plan_type"
        case assignedStudentId = "assigned_student_id"
    }
}

private struct PlanWorkoutCreateRequest: Encodable {
    let name: String
    let sets: Int
    let reps: Int
    let duration: Int?
}

private struct TrainingPlanUpdateRequest: Encodable {
    var title: String?
    var planType: String?
    var notes: String?
    var assignedStudentId: String?

    enum CodingKeys: String, CodingKey {
        case title, notes
        case planType = "plan_type"
        case assignedStudentId = "assigned_student_id"
    }
}

// MARK: - Training Plan Manager
class TrainingPlanManager: ObservableObject {

    static let shared = TrainingPlanManager()

    @Published var plans: [TrainingPlan] = []
    @Published var isLoading: Bool = false

    private let api = APIService.shared

    init() {
        loadPlans()
    }

    // MARK: - CRUD

    func addPlan(_ plan: TrainingPlan) {
        plans.insert(plan, at: 0)

        Task {
            do {
                let workoutRequests = plan.workouts.map {
                    PlanWorkoutCreateRequest(name: $0.name, sets: $0.sets, reps: $0.reps, duration: $0.duration)
                }
                let created: TrainingPlan = try await api.request(
                    endpoint: "/api/v1/plans/training",
                    method: "POST",
                    body: TrainingPlanCreateRequest(
                        title: plan.title,
                        planType: plan.planType.rawValue,
                        notes: plan.notes,
                        assignedStudentId: plan.assignedStudentId,
                        workouts: workoutRequests
                    )
                )
                await MainActor.run {
                    if let index = self.plans.firstIndex(where: { $0.id == plan.id }) {
                        self.plans[index] = created
                    }
                }
            } catch {
                print("Training plan create xətası: \(error)")
            }
        }
    }

    func updatePlan(_ plan: TrainingPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan

            Task {
                do {
                    let _: TrainingPlan = try await api.request(
                        endpoint: "/api/v1/plans/training/\(plan.id)",
                        method: "PUT",
                        body: TrainingPlanUpdateRequest(
                            title: plan.title,
                            planType: plan.planType.rawValue,
                            notes: plan.notes,
                            assignedStudentId: plan.assignedStudentId
                        )
                    )
                } catch {
                    print("Training plan update xətası: \(error)")
                }
            }
        }
    }

    func deletePlan(_ plan: TrainingPlan) {
        plans.removeAll { $0.id == plan.id }

        Task {
            do {
                try await api.requestVoid(endpoint: "/api/v1/plans/training/\(plan.id)")
            } catch {
                print("Training plan delete xətası: \(error)")
            }
        }
    }

    func deletePlan(at offsets: IndexSet) {
        let plansToDelete = offsets.map { plans[$0] }
        plans.remove(atOffsets: offsets)

        for plan in plansToDelete {
            Task {
                do {
                    try await api.requestVoid(endpoint: "/api/v1/plans/training/\(plan.id)")
                } catch {
                    print("Training plan delete xətası: \(error)")
                }
            }
        }
    }

    // MARK: - Complete Plan

    func completePlan(_ plan: TrainingPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index].isCompleted = true
            plans[index].completedAt = Date()
        }

        Task {
            do {
                let _: TrainingPlan = try await api.request(
                    endpoint: "/api/v1/plans/training/\(plan.id)/complete",
                    method: "PUT"
                )
            } catch {
                await MainActor.run {
                    if let index = self.plans.firstIndex(where: { $0.id == plan.id }) {
                        self.plans[index].isCompleted = false
                        self.plans[index].completedAt = nil
                    }
                }
                print("Training plan complete xətası: \(error)")
            }
        }
    }

    // MARK: - Filters

    func plansForType(_ type: PlanType) -> [TrainingPlan] {
        plans.filter { $0.planType == type }
    }

    func plansForStudent(_ studentName: String) -> [TrainingPlan] {
        plans.filter { $0.assignedStudentName == studentName }
    }

    var totalPlans: Int { plans.count }

    // MARK: - Backend Sync

    func loadPlans() {
        guard KeychainManager.shared.isLoggedIn else {
            print("⚠️ TrainingPlanManager: isLoggedIn=false, loadPlans keçildi")
            return
        }

        isLoading = true
        Task {
            do {
                let fetched: [TrainingPlan] = try await api.request(endpoint: "/api/v1/plans/training")
                print("✅ Training plans yükləndi: \(fetched.count) plan tapıldı")
                await MainActor.run {
                    self.plans = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                print("❌ Training plans yükləmə xətası: \(error)")
                if let de = error as? DecodingError { print("⚠️ Decode detalları: \(de)") }
            }
        }
    }

    func clearAllPlans() {
        plans = []
    }
}
