//
//  ChatView.swift
//  CoreVia
//

import SwiftUI

// MARK: - Conversations List
struct ConversationsView: View {
    @ObservedObject private var chatManager = ChatManager.shared
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var showPremium = false

    /// Trainer-lər premium olmadan da chat-a girə bilir
    private var isTrainer: Bool {
        AuthManager.shared.currentUser?.userType == "trainer"
    }

    private var canAccessChat: Bool {
        settingsManager.isPremium || isTrainer
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            if !canAccessChat {
                premiumRequiredView
            } else {
                VStack(spacing: 0) {
                    headerSection

                    if chatManager.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if chatManager.conversations.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 1) {
                                ForEach(chatManager.conversations) { conv in
                                    NavigationLink(destination: ChatDetailView(
                                        userId: conv.userId,
                                        userName: conv.userName,
                                        userProfileImage: conv.userProfileImage
                                    )) {
                                        ConversationRow(conversation: conv)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if canAccessChat {
                Task { await chatManager.fetchConversations() }
            }
        }
        .sheet(isPresented: $showPremium) {
            PremiumView()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(loc.localized("chat_title"))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            if let limit = chatManager.messageLimit {
                Text("\(loc.localized("chat_remaining")): \(limit.remaining)/\(limit.dailyLimit)")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(loc.localized("chat_empty"))
                .font(.headline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(loc.localized("chat_empty_desc"))
                .font(.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }

    private var premiumRequiredView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.premiumGradientStart)

            Text(loc.localized("chat_premium_required"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(loc.localized("chat_premium_desc"))
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                showPremium = true
            } label: {
                Text(loc.localized("activities_premium_go"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: ChatConversation

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let imageUrl = conversation.userProfileImage, !imageUrl.isEmpty {
                let fullURL = imageUrl.hasPrefix("http") ? imageUrl : APIService.shared.baseURL + imageUrl
                AsyncImage(url: URL(string: fullURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                            .frame(width: 50, height: 50).clipShape(Circle())
                    default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.userName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Spacer()

                    Text(conversation.lastMessageTime, style: .relative)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }

                HStack {
                    Text(conversation.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .lineLimit(1)

                    Spacer()

                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(AppTheme.Colors.accent)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(AppTheme.Colors.accent.opacity(0.2))
            .frame(width: 50, height: 50)
            .overlay(
                Text(String(conversation.userName.prefix(1)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.Colors.accent)
            )
    }
}

// MARK: - Chat Detail View
struct ChatDetailView: View {
    let userId: String
    let userName: String
    let userProfileImage: String?

    @ObservedObject private var chatManager = ChatManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var messageText = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(chatManager.messages) { msg in
                                MessageBubble(
                                    message: msg,
                                    isMe: msg.senderId == AuthManager.shared.currentUser?.id
                                )
                                .id(msg.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatManager.messages.count) { _, _ in
                        if let lastId = chatManager.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }

                // Limit Warning
                if let limit = chatManager.messageLimit, limit.remaining <= 3 {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("\(loc.localized("chat_remaining")): \(limit.remaining)")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }

                // Input Bar
                HStack(spacing: 10) {
                    TextField(loc.localized("chat_type_message"), text: $messageText)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(20)

                    Button {
                        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return }
                        messageText = ""
                        Task {
                            let success = await chatManager.sendMessage(receiverId: userId, message: text)
                            if !success { showError = true }
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.Colors.tertiaryText : AppTheme.Colors.accent)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(AppTheme.Colors.background)
            }
        }
        .navigationTitle(userName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await chatManager.fetchMessages(userId: userId)
                await chatManager.fetchMessageLimit()
            }
        }
        .alert(loc.localized("common_error"), isPresented: $showError) {
            Button(loc.localized("common_ok"), role: .cancel) {}
        } message: {
            Text(chatManager.errorMessage ?? loc.localized("teacher_unknown_error"))
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessageResponse
    let isMe: Bool

    var body: some View {
        HStack {
            if isMe { Spacer(minLength: 60) }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
                Text(message.message)
                    .font(.system(size: 15))
                    .foregroundColor(isMe ? .white : AppTheme.Colors.primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isMe ? AppTheme.Colors.accent : AppTheme.Colors.secondaryBackground)
                    .cornerRadius(18)

                Text(message.createdAt, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.Colors.tertiaryText)
            }

            if !isMe { Spacer(minLength: 60) }
        }
    }
}
