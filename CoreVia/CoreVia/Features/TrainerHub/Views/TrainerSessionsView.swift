//
//  TrainerSessionsView.swift
//  CoreVia
//
//  Trainer oz sessiyalarini gorur, yaradir, silir
//  Movcut LiveSessionCard, FilterChip dizayni qorunur
//

import SwiftUI

struct TrainerSessionsView: View {
    @StateObject private var viewModel = TrainerSessionsViewModel()
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showCreateSession = false

    var body: some View {
        ZStack {
            // Sessions Content
            VStack(spacing: 0) {
                // Filter Chips
                filterSection

                // List
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.sessions.isEmpty {
                    emptyState
                } else {
                    sessionsListView
                }
            }

            // FAB button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showCreateSession = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(AppTheme.Colors.accent)
                                    .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .task {
            await viewModel.loadSessions(refresh: true)
        }
        .refreshable {
            await viewModel.loadSessions(refresh: true)
        }
        .sheet(isPresented: $showCreateSession) {
            CreateLiveSessionView()
                .onDisappear {
                    Task { await viewModel.loadSessions(refresh: true) }
                }
        }
        .alert("Xeta", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: loc.localized("live_sessions_all"),
                    isSelected: viewModel.selectedFilter == .all
                ) {
                    viewModel.selectedFilter = .all
                    Task { await viewModel.loadSessions(refresh: true) }
                }

                FilterChip(
                    title: loc.localized("live_sessions_upcoming"),
                    isSelected: viewModel.selectedFilter == .upcoming
                ) {
                    viewModel.selectedFilter = .upcoming
                    Task { await viewModel.loadSessions(refresh: true) }
                }

                FilterChip(
                    title: loc.localized("live_sessions_live"),
                    isSelected: viewModel.selectedFilter == .live
                ) {
                    viewModel.selectedFilter = .live
                    Task { await viewModel.loadSessions(refresh: true) }
                }

                FilterChip(
                    title: loc.localized("live_sessions_completed"),
                    isSelected: viewModel.selectedFilter == .completed
                ) {
                    viewModel.selectedFilter = .completed
                    Task { await viewModel.loadSessions(refresh: true) }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Sessions List

    private var sessionsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.sessions) { session in
                    NavigationLink {
                        LiveSessionDetailView(sessionId: session.id)
                    } label: {
                        TrainerSessionCard(session: session) {
                            Task { await viewModel.deleteSession(session.id) }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if viewModel.hasMore {
                    ProgressView()
                        .onAppear {
                            Task { await viewModel.loadMore() }
                        }
                }
            }
            .padding()
            .padding(.bottom, 80) // FAB ucun yer
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "video.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(loc.localized("trainer_hub_no_sessions"))
                .font(.headline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(loc.localized("trainer_hub_no_sessions_desc"))
                .font(.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)

            Button {
                showCreateSession = true
            } label: {
                Text(loc.localized("trainer_hub_create_session"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(AppTheme.CornerRadius.md)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Trainer Session Card (with delete)

struct TrainerSessionCard: View {
    let session: LiveSession
    let onDelete: () -> Void
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                statusBadge
                Spacer()
                difficultyBadge

                // Delete button
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.error)
                        .padding(6)
                        .background(AppTheme.Colors.error.opacity(0.1))
                        .cornerRadius(AppTheme.CornerRadius.sm)
                }
            }

            // Title
            Text(session.title)
                .font(.headline)
                .foregroundColor(AppTheme.Colors.primaryText)

            // Description
            if let desc = session.description, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .lineLimit(2)
            }

            // Time & Duration
            HStack(spacing: 16) {
                Label(
                    session.scheduledStart.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)

                Label(
                    "\(session.durationMinutes) min",
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)
            }

            // Participants & Price
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.accent)

                Text("\(session.registeredCount ?? 0)/\(session.maxParticipants)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.secondaryText)

                Spacer()

                if session.isPaid {
                    Text("\(String(format: "%.2f", session.price)) \(session.currency)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.accent)
                } else {
                    Text("Pulsuz")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.success)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        .alert("Sessiyani silmek isteyirsiniz?", isPresented: $showDeleteAlert) {
            Button("Sil", role: .destructive) { onDelete() }
            Button("Legv et", role: .cancel) {}
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(session.status.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(AppTheme.CornerRadius.sm)
    }

    private var difficultyBadge: some View {
        Text(session.difficultyLevel.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(difficultyColor)
            .cornerRadius(AppTheme.CornerRadius.sm)
    }

    private var statusColor: Color {
        switch session.status {
        case "scheduled": return .blue
        case "live": return AppTheme.Colors.accent
        case "completed": return .gray
        case "cancelled": return .orange
        default: return .gray
        }
    }

    private var difficultyColor: Color {
        switch session.difficultyLevel {
        case "beginner": return AppTheme.Colors.success
        case "intermediate": return .orange
        case "advanced": return AppTheme.Colors.accent
        default: return .gray
        }
    }
}
