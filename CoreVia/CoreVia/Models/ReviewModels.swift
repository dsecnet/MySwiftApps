//
//  ReviewModels.swift
//  CoreVia
//

import Foundation
import os.log

// MARK: - Review Response
struct ReviewResponse: Codable, Identifiable {
    let id: String
    let trainerId: String
    let studentId: String
    let studentName: String
    let studentProfileImage: String?
    let rating: Int
    let comment: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, rating, comment
        case trainerId = "trainer_id"
        case studentId = "student_id"
        case studentName = "student_name"
        case studentProfileImage = "student_profile_image"
        case createdAt = "created_at"
    }
}

// MARK: - Review Create
struct ReviewCreateRequest: Codable {
    let rating: Int
    let comment: String?
}

// MARK: - Review Summary
struct ReviewSummaryResponse: Codable {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [String: Int]

    enum CodingKeys: String, CodingKey {
        case averageRating = "average_rating"
        case totalReviews = "total_reviews"
        case ratingDistribution = "rating_distribution"
    }
}

// MARK: - Review Manager
class ReviewManager: ObservableObject {
    static let shared = ReviewManager()

    @Published var reviews: [ReviewResponse] = []
    @Published var summary: ReviewSummaryResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIService.shared
    private init() {}

    @MainActor
    func fetchReviews(trainerId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result: [ReviewResponse] = try await api.request(
                endpoint: "/api/v1/trainer/\(trainerId)/reviews"
            )
            reviews = result
        } catch {
            AppLogger.network.error("Fetch reviews xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func fetchSummary(trainerId: String) async {
        do {
            let result: ReviewSummaryResponse = try await api.request(
                endpoint: "/api/v1/trainer/\(trainerId)/reviews/summary"
            )
            summary = result
        } catch {
            AppLogger.network.error("Fetch review summary xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func submitReview(trainerId: String, rating: Int, comment: String?) async -> Bool {
        errorMessage = nil
        do {
            let body = ReviewCreateRequest(rating: rating, comment: comment)
            let _: ReviewResponse = try await api.request(
                endpoint: "/api/v1/trainer/\(trainerId)/reviews",
                method: "POST",
                body: body
            )
            await fetchReviews(trainerId: trainerId)
            await fetchSummary(trainerId: trainerId)
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            AppLogger.network.error("Submit review xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func deleteReview(trainerId: String) async -> Bool {
        do {
            try await api.requestVoid(
                endpoint: "/api/v1/trainer/\(trainerId)/reviews",
                method: "DELETE"
            )
            await fetchReviews(trainerId: trainerId)
            await fetchSummary(trainerId: trainerId)
            return true
        } catch {
            AppLogger.network.error("Delete review xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return false
        }
    }
}
