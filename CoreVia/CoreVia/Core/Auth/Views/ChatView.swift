//
//  ChatView.swift
//  CoreVia
//

import SwiftUI

// MARK: - Conversations List
struct ConversationsView: View {
    @ObservedObject private var chatManager = ChatManager.shared
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var trainerManager = TrainerManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var showPremium = false

    /// Bağlı müəllim var mı?
    private var hasAssignedTrainer: Bool {
        AuthManager.shared.currentUser?.trainerId != nil
    }

    /// Trainer-lər premium olmadan da chat-a girə bilir
    private var isTrainer: Bool {
        AuthManager.shared.currentUser?.userType == "trainer"
    }

    private var canAccessChat: Bool {
        // Premium users and trainers can access chat
        return settingsManager.isPremium || isTrainer
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
                    } else if chatManager.conversations.isEmpty && !hasAssignedTrainer {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                // Müəllim bölməsi
                                if hasAssignedTrainer, let trainer = trainerManager.assignedTrainer {
                                    myTrainerSection(trainer: trainer)
                                }

                                // Söhbətlər (müəllimi çıxar)
                                if !chatManager.conversations.isEmpty {
                                    ForEach(chatManager.conversations.filter { conv in
                                        conv.userId != AuthManager.shared.currentUser?.trainerId
                                    }) { conv in
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
                            .padding(.horizontal)
                            .padding(.top, 12)
                        }
                    }
                }
            }
        }
        .onAppear {
            if canAccessChat {
                Task {
                    await chatManager.fetchConversations()
                    if hasAssignedTrainer {
                        await trainerManager.loadAssignedTrainer()
                    }
                }
            }
        }
        .sheet(isPresented: $showPremium) {
            PremiumView()
        }
    }
    
    // MARK: - My Trainer Section
    @ViewBuilder
    private func myTrainerSection(trainer: TrainerResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("my_trainer"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
                .padding(.horizontal, 4)

            NavigationLink(destination: ChatDetailView(
                userId: trainer.id,
                userName: trainer.name,
                userProfileImage: trainer.profileImageUrl
            )) {
                HStack(spacing: 16) {
                    // Avatar
                    TrainerAvatarView(
                        profileImageUrl: trainer.profileImageUrl,
                        category: trainer.category,
                        size: 56
                    )

                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(trainer.name)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            if trainer.verificationStatus == "verified" {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                        }

                        Text(trainer.specialization ?? loc.localized("trainer_personal_trainer"))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 12))
                            Text(loc.localized("teacher_send_message"))
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(Color.red)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.red)
                }
                .padding()
                .background(Color.red.opacity(0.05))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 8)
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
        VStack(spacing: 24) {
            Spacer()

            // Coming Soon Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.Colors.premiumGradientStart.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.premiumGradientStart, AppTheme.Colors.premiumGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Text("Premium Chat")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text("COMING SOON")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(3)
                    .foregroundColor(AppTheme.Colors.premiumGradientStart)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.Colors.premiumGradientStart.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.Colors.premiumGradientStart.opacity(0.3), lineWidth: 1)
                    )

                Text("Müəllimlərlə söhbət funksiyası tezliklə aktiv olacaq")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

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
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        if chatManager.messages.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppTheme.Colors.tertiaryText)
                                Text(loc.localized("chat_no_messages"))
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Text(loc.localized("chat_start_conversation"))
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.Colors.tertiaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 100)
                        } else {
                            ForEach(chatManager.messages) { msg in
                                MessageBubble(
                                    message: msg,
                                    isMe: msg.senderId == AuthManager.shared.currentUser?.id
                                )
                                .id(msg.id)
                            }
                        }
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: chatManager.messages.count) { _ in
                    if let lastId = chatManager.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            VStack(spacing: 0) {
                Divider()
                    .frame(height: 1)
                    .background(Color.red.opacity(0.6))

                HStack(spacing: 12) {
                    TextField(loc.localized("chat_type_message"), text: $messageText)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        )

                    Button {
                        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return }
                        messageText = ""
                        Task {
                            await chatManager.sendMessage(receiverId: userId, message: text)
                        }
                    } label: {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.red, Color.red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46, height: 46)
                            .overlay(
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 19, weight: .semibold))
                            )
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .padding(.bottom, 85)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.background, Color.red.opacity(0.02)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(userName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await chatManager.fetchMessages(userId: userId)
            }
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
