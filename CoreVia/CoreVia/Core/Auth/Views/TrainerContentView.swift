//
//  TrainerContentView.swift
//  CoreVia
//

import SwiftUI

// MARK: - Trainer Content List View (for trainers to manage content)
struct TrainerContentView: View {
    @ObservedObject private var contentManager = ContentManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showCreateSheet = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.localized("content_title"))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text(loc.localized("content_subtitle"))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }

                    Spacer()

                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                .padding()

                if contentManager.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if contentManager.myContents.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.tertiaryText)

                        Text(loc.localized("content_empty"))
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        Text(loc.localized("content_empty_desc"))
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                            .multilineTextAlignment(.center)

                        Button {
                            showCreateSheet = true
                        } label: {
                            Text(loc.localized("content_create"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(AppTheme.Colors.accent)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .padding()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(contentManager.myContents) { content in
                                ContentCard(content: content, isOwner: true)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            Task { await contentManager.fetchMyContent() }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateContentSheet()
        }
    }
}

// MARK: - Content Card
struct ContentCard: View {
    let content: ContentResponse
    var isOwner: Bool = false
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var contentManager = ContentManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(content.trainerName.prefix(1)))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.accent)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(content.trainerName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text(content.createdAt, style: .date)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }

                Spacer()

                if content.isPremiumOnly {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                        Text("Premium")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.Colors.premiumGradientStart)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.premiumGradientStart.opacity(0.1))
                    .cornerRadius(8)
                }
            }

            // Title
            Text(content.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            // Body
            if let body = content.body, !body.isEmpty {
                Text(body)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .lineSpacing(3)
            }

            // Image
            if let imageUrl = content.imageUrl, !imageUrl.isEmpty {
                let fullURL = imageUrl.hasPrefix("http") ? imageUrl : APIService.shared.baseURL + imageUrl
                AsyncImage(url: URL(string: fullURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.Colors.separator)
                            .frame(height: 100)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(AppTheme.Colors.tertiaryText)
                            )
                    case .empty:
                        ProgressView().frame(height: 100)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            // Delete (only for owner)
            if isOwner {
                Button(role: .destructive) {
                    Task { await contentManager.deleteContent(contentId: content.id) }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text(loc.localized("common_delete"))
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }
}

// MARK: - Create Content Sheet
struct CreateContentSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var contentManager = ContentManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var title = ""
    @State private var bodyText = ""
    @State private var isPremiumOnly = true
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("content_field_title"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            TextField(loc.localized("content_title_placeholder"), text: $title)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                        }

                        // Body
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc.localized("content_field_body"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            TextEditor(text: $bodyText)
                                .frame(height: 150)
                                .padding(8)
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                                .foregroundColor(AppTheme.Colors.primaryText)
                        }

                        // Premium Only Toggle
                        Toggle(isOn: $isPremiumOnly) {
                            HStack(spacing: 8) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(AppTheme.Colors.premiumGradientStart)
                                Text(loc.localized("content_premium_only"))
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                            }
                        }
                        .tint(AppTheme.Colors.accent)
                        .padding()
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(12)

                        Spacer(minLength: 20)

                        // Submit
                        Button {
                            isSubmitting = true
                            Task {
                                let success = await contentManager.createContent(
                                    title: title,
                                    body: bodyText.isEmpty ? nil : bodyText,
                                    contentType: "text",
                                    isPremiumOnly: isPremiumOnly
                                )
                                isSubmitting = false
                                if success {
                                    showSuccess = true
                                } else {
                                    showError = true
                                }
                            }
                        } label: {
                            HStack {
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                    Text(loc.localized("content_create"))
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(title.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent)
                            .cornerRadius(12)
                        }
                        .disabled(title.isEmpty || isSubmitting)
                    }
                    .padding()
                }
            }
            .navigationTitle(loc.localized("content_create"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) { dismiss() }
                }
            }
            .alert(loc.localized("common_success"), isPresented: $showSuccess) {
                Button(loc.localized("common_ok")) { dismiss() }
            }
            .alert(loc.localized("common_error"), isPresented: $showError) {
                Button(loc.localized("common_ok"), role: .cancel) {}
            } message: {
                Text(contentManager.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Student Content View (Trainer content goruntuleme - student terefinden)
struct StudentContentView: View {
    let trainerId: String
    @ObservedObject private var contentManager = ContentManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.localized("content_trainer_posts"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            if contentManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if contentManager.contents.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text(loc.localized("content_no_posts"))
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(contentManager.contents) { content in
                    ContentCard(content: content, isOwner: false)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
        .onAppear {
            Task { await contentManager.fetchTrainerContent(trainerId: trainerId) }
        }
    }
}
