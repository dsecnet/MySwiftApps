import SwiftUI

struct ActivitiesListView: View {
    @StateObject private var viewModel = ActivitiesViewModel()
    @State private var searchText = ""
    @State private var showAddActivity = false
    @State private var filterType: ActivityType? = nil

    var filteredActivities: [Activity] {
        var filtered = viewModel.activities

        if let type = filterType {
            filtered = filtered.filter { $0.activityType == type }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return filtered
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterPill(title: "Hamısı", isSelected: filterType == nil) {
                                filterType = nil
                            }

                            ForEach(ActivityType.allCases, id: \.self) { type in
                                FilterPill(
                                    title: type.displayName,
                                    icon: type.icon,
                                    isSelected: filterType == type
                                ) {
                                    filterType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(AppTheme.cardBackground)

                    if viewModel.isLoading && viewModel.activities.isEmpty {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredActivities.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "calendar.badge.clock",
                            title: "Fəaliyyət yoxdur",
                            message: "Yeni fəaliyyət əlavə edin"
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredActivities) { activity in
                                    NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                        ActivityRowView(activity: activity, viewModel: viewModel)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }

                                if viewModel.hasMore {
                                    ProgressView()
                                        .padding()
                                        .task {
                                            await viewModel.loadMore()
                                        }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.refresh()
                        }
                    }
                }
            }
            .navigationTitle("Fəaliyyətlər")
            .searchable(text: $searchText, prompt: "Axtar...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddActivity = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.primaryGradient)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddActivity) {
                AddActivityView {
                    await viewModel.refresh()
                }
            }
            .task {
                await viewModel.loadActivities()
            }
        }
    }
}

struct ActivityRowView: View {
    let activity: Activity
    @ObservedObject var viewModel: ActivitiesViewModel

    var body: some View {
        HStack(spacing: 16) {
            // Type Icon
            ZStack {
                Circle()
                    .fill(colorForType(activity.activityType).opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: activity.activityType.icon)
                    .font(.title3)
                    .foregroundColor(colorForType(activity.activityType))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(activity.title)
                    .font(AppTheme.headline())
                    .foregroundColor(AppTheme.textPrimary)

                if let description = activity.description {
                    Text(description)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    if let scheduledAt = activity.scheduledAt {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(formatDate(scheduledAt))
                                .font(AppTheme.caption2())
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }

                    if activity.completedAt != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("Tamamlandı")
                                .font(AppTheme.caption2())
                        }
                        .foregroundColor(AppTheme.successColor)
                    }
                }
            }

            Spacer()

            if activity.completedAt == nil {
                Button {
                    Task {
                        await viewModel.completeActivity(id: activity.id)
                    }
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(AppTheme.successColor)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    private func colorForType(_ type: ActivityType) -> Color {
        switch type {
        case .call: return AppTheme.primaryColor
        case .meeting: return AppTheme.secondaryColor
        case .email: return AppTheme.infoColor
        case .viewing: return AppTheme.accentColor
        case .message: return AppTheme.successColor
        case .note: return AppTheme.textSecondary
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct FilterPill: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(AppTheme.subheadline())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? AppTheme.primaryGradient : LinearGradient(
                    colors: [AppTheme.backgroundColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
            .cornerRadius(20)
            .shadow(color: isSelected ? AppTheme.primaryColor.opacity(0.3) : .clear, radius: 4)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.primaryGradient)

            Text(title)
                .font(AppTheme.title2())
                .foregroundColor(AppTheme.textPrimary)

            Text(message)
                .font(AppTheme.callout())
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    ActivitiesListView()
}
