import SwiftUI

// MARK: - Notifications View
struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Filter Chips
                filterChips

                // MARK: - Content
                if viewModel.groupedNotifications.isEmpty {
                    emptyState
                } else {
                    notificationsList
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("notifications".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.clearAll()
                    } label: {
                        Text("clear_all".localized)
                            .font(AppTheme.Fonts.captionBold())
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
            }
        }
    }

    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }

    private func filterChip(_ filter: NotificationFilter) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedFilter = filter
            }
        } label: {
            Text(filter.displayKey.localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(
                    viewModel.selectedFilter == filter
                        ? .white
                        : AppTheme.Colors.textSecondary
                )
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    viewModel.selectedFilter == filter
                        ? AppTheme.Colors.accent
                        : AppTheme.Colors.cardBackground
                )
                .cornerRadius(AppTheme.CornerRadius.pill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                        .stroke(
                            viewModel.selectedFilter == filter
                                ? Color.clear
                                : AppTheme.Colors.inputBorder,
                            lineWidth: 1
                        )
                )
        }
    }

    // MARK: - Notifications List
    private var notificationsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: AppTheme.Spacing.xl, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.groupedNotifications) { group in
                    Section {
                        ForEach(group.notifications) { notification in
                            notificationRow(notification)
                                .onTapGesture {
                                    viewModel.markAsRead(notification)
                                }
                        }
                    } header: {
                        sectionHeader(group.title)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }

    // MARK: - Notification Row
    private func notificationRow(_ notification: AppNotification) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            // Icon with colored circle
            ZStack {
                Circle()
                    .fill(Color(hex: notification.type.iconColor).opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: notification.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: notification.type.iconColor))
            }

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack(alignment: .top) {
                    // Title (bold)
                    Text(notification.title)
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()

                    // Time ago
                    Text(notification.timeAgo)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    // Unread indicator (blue dot)
                    if !notification.isRead {
                        Circle()
                            .fill(AppTheme.Colors.accent)
                            .frame(width: 8, height: 8)
                    }
                }

                // Description
                Text(notification.body)
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .lineSpacing(2)

                // Embedded listing preview (if notification has listing data)
                if let data = notification.data, data.listingId != nil {
                    listingPreview(data)
                        .padding(.top, AppTheme.Spacing.sm)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            notification.isRead
                ? AppTheme.Colors.cardBackground
                : AppTheme.Colors.cardBackground.opacity(0.8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(
                    notification.isRead
                        ? Color.clear
                        : AppTheme.Colors.accent.opacity(0.2),
                    lineWidth: 1
                )
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }

    // MARK: - Listing Preview (embedded in notification)
    private func listingPreview(_ data: NotificationData) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Small image
            AsyncImage(url: URL(string: data.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Rectangle()
                        .fill(AppTheme.Colors.surfaceBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        )
                }
            }
            .frame(width: 56, height: 56)
            .cornerRadius(AppTheme.CornerRadius.small)
            .clipped()

            VStack(alignment: .leading, spacing: 2) {
                // Price
                if let price = data.price {
                    Text(price)
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.accent)
                }

                // Location
                if let location = data.location {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Text(location)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surfaceBackground)
        .cornerRadius(AppTheme.CornerRadius.small)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.Colors.textTertiary)

            Text("notifications".localized)
                .font(AppTheme.Fonts.heading3())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("Heç bir bildirişiniz yoxdur")
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.textSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    NotificationsView()
}
