//
//  ContentModels.swift
//  CoreVia
//

import Foundation

// MARK: - Content Response
struct ContentResponse: Codable, Identifiable {
    let id: String
    let trainerId: String
    let trainerName: String
    let trainerProfileImage: String?
    let title: String
    let body: String?
    let contentType: String
    let imageUrl: String?
    let isPremiumOnly: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case trainerId = "trainer_id"
        case trainerName = "trainer_name"
        case trainerProfileImage = "trainer_profile_image"
        case contentType = "content_type"
        case imageUrl = "image_url"
        case isPremiumOnly = "is_premium_only"
        case createdAt = "created_at"
    }
}

// MARK: - Content Create
struct ContentCreateRequest: Codable {
    let title: String
    let body: String?
    let contentType: String
    let isPremiumOnly: Bool

    enum CodingKeys: String, CodingKey {
        case title, body
        case contentType = "content_type"
        case isPremiumOnly = "is_premium_only"
    }
}

// MARK: - Content Manager
class ContentManager: ObservableObject {
    static let shared = ContentManager()

    @Published var contents: [ContentResponse] = []
    @Published var myContents: [ContentResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIService.shared
    private init() {}

    @MainActor
    func fetchTrainerContent(trainerId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result: [ContentResponse] = try await api.request(
                endpoint: "/api/v1/content/trainer/\(trainerId)"
            )
            contents = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func fetchMyContent() async {
        isLoading = true
        errorMessage = nil
        do {
            let result: [ContentResponse] = try await api.request(
                endpoint: "/api/v1/content/my"
            )
            myContents = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func createContent(title: String, body: String?, contentType: String, isPremiumOnly: Bool) async -> Bool {
        errorMessage = nil
        do {
            let request = ContentCreateRequest(
                title: title,
                body: body,
                contentType: contentType,
                isPremiumOnly: isPremiumOnly
            )
            let _: ContentResponse = try await api.request(
                endpoint: "/api/v1/content/",
                method: "POST",
                body: request
            )
            await fetchMyContent()
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func uploadContentImage(contentId: String, imageData: Data) async -> Bool {
        do {
            _ = try await api.uploadImage(
                endpoint: "/api/v1/content/\(contentId)/image",
                imageData: imageData
            )
            await fetchMyContent()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func deleteContent(contentId: String) async -> Bool {
        do {
            try await api.requestVoid(
                endpoint: "/api/v1/content/\(contentId)",
                method: "DELETE"
            )
            await fetchMyContent()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
