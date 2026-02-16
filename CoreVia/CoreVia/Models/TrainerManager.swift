//
//  TrainerManager.swift
//  CoreVia
//
//  Trainer API inteqrasiyası — fetch, assign, unassign
//

import Foundation

class TrainerManager: ObservableObject {
    static let shared = TrainerManager()

    @Published var trainers: [TrainerResponse] = []
    @Published var assignedTrainer: TrainerResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // NEW: My students (for trainers)
    @Published var myStudents: [UserResponse] = []
    @Published var isLoadingStudents = false

    private let api = APIService.shared

    private init() {}

    // MARK: - Butun trainer-leri getir

    @MainActor
    func fetchTrainers() async {
        isLoading = true
        errorMessage = nil
        do {
            let result: [TrainerResponse] = try await api.request(
                endpoint: "/api/v1/users/trainers"
            )
            trainers = result
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Trainer-e qosul (Premium lazimdir)

    @MainActor
    func assignTrainer(trainerId: String) async -> Bool {
        errorMessage = nil
        do {
            let _: UserResponse = try await api.request(
                endpoint: "/api/v1/users/assign-trainer/\(trainerId)",
                method: "POST"
            )
            // User melumatlarini yenile
            await AuthManager.shared.fetchCurrentUser()
            // Assigned trainer-i yukle
            await fetchAssignedTrainer(trainerId: trainerId)
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Trainer-den ayril

    @MainActor
    func unassignTrainer() async -> Bool {
        errorMessage = nil
        do {
            let _: UserResponse = try await api.request(
                endpoint: "/api/v1/users/unassign-trainer",
                method: "DELETE"
            )
            assignedTrainer = nil
            await AuthManager.shared.fetchCurrentUser()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // Alias funksiya - leaveTrainer = unassignTrainer
    @MainActor
    func leaveTrainer() async -> Bool {
        return await unassignTrainer()
    }

    // MARK: - Bagli trainer melumati getir

    @MainActor
    func fetchAssignedTrainer(trainerId: String) async {
        do {
            let trainer: TrainerResponse = try await api.request(
                endpoint: "/api/v1/users/trainer/\(trainerId)"
            )
            assignedTrainer = trainer
        } catch {
            assignedTrainer = nil
        }
    }

    // MARK: - Cari userin bagli trainer-ini yukle

    @MainActor
    func loadAssignedTrainer() async {
        guard let trainerId = AuthManager.shared.currentUser?.trainerId else {
            assignedTrainer = nil
            return
        }
        await fetchAssignedTrainer(trainerId: trainerId)
    }

    // MARK: - NEW: Fetch My Students (for trainers only)

    @MainActor
    func fetchMyStudents() async {
        isLoadingStudents = true
        errorMessage = nil
        do {
            let result: [UserResponse] = try await api.request(
                endpoint: "/api/v1/users/my-students"
            )
            myStudents = result
            isLoadingStudents = false
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoadingStudents = false
            print("❌ Failed to fetch students: \(error.errorDescription ?? "Unknown")")
        } catch {
            errorMessage = error.localizedDescription
            isLoadingStudents = false
            print("❌ Failed to fetch students: \(error.localizedDescription)")
        }
    }
}
