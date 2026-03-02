//
//  ChatModels.swift
//  CoreVia
//

import Foundation
import os.log

// MARK: - Chat Message Response
struct ChatMessageResponse: Codable, Identifiable {
    let id: String
    let senderId: String
    let receiverId: String
    let senderName: String
    let senderProfileImage: String?
    let message: String
    let isRead: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, message
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case senderName = "sender_name"
        case senderProfileImage = "sender_profile_image"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

// MARK: - Chat Message Create
struct ChatMessageCreate: Codable {
    let receiverId: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case receiverId = "receiver_id"
        case message
    }
}

// MARK: - Chat Conversation
struct ChatConversation: Codable, Identifiable {
    var id: String { userId }
    let userId: String
    let userName: String
    let userProfileImage: String?
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case userProfileImage = "user_profile_image"
        case lastMessage = "last_message"
        case lastMessageTime = "last_message_time"
        case unreadCount = "unread_count"
    }
}

// MARK: - Message Limit
struct MessageLimitResponse: Codable {
    let dailyLimit: Int
    let usedToday: Int
    let remaining: Int

    enum CodingKeys: String, CodingKey {
        case dailyLimit = "daily_limit"
        case usedToday = "used_today"
        case remaining
    }
}

// MARK: - Chat Manager
class ChatManager: ObservableObject {
    static let shared = ChatManager()

    @Published var conversations: [ChatConversation] = []
    @Published var messages: [ChatMessageResponse] = []
    @Published var messageLimit: MessageLimitResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIService.shared
    private init() {}

    @MainActor
    func fetchConversations() async {
        isLoading = true
        errorMessage = nil
        do {
            let result: [ChatConversation] = try await api.request(
                endpoint: "/api/v1/chat/conversations"
            )
            conversations = result
        } catch {
            AppLogger.network.error("Conversations fetch xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func fetchMessages(userId: String) async {
        isLoading = true
        do {
            let result: [ChatMessageResponse] = try await api.request(
                endpoint: "/api/v1/chat/history/\(userId)"
            )
            messages = result
        } catch {
            AppLogger.network.error("Messages fetch xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func sendMessage(receiverId: String, message: String) async -> Bool {
        errorMessage = nil
        do {
            let body = ChatMessageCreate(receiverId: receiverId, message: message)
            let result: ChatMessageResponse = try await api.request(
                endpoint: "/api/v1/chat/send",
                method: "POST",
                body: body
            )
            messages.append(result)
            await fetchMessageLimit()
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            AppLogger.network.error("Send message xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func fetchMessageLimit() async {
        do {
            let result: MessageLimitResponse = try await api.request(
                endpoint: "/api/v1/chat/limit"
            )
            messageLimit = result
        } catch {
            AppLogger.network.error("Message limit fetch xetasi: \(error.localizedDescription)")
        }
    }
}
