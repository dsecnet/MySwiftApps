import SwiftUI

enum DealSortOption: String, CaseIterable {
    case dateNewest = "Tarix (Yeni)"
    case dateOldest = "Tarix (Köhnə)"
    case priceHighest = "Qiymət (Yüksək)"
    case priceLowest = "Qiymət (Aşağı)"
}

struct DealsListView: View {
    @StateObject private var viewModel = DealsViewModel()
    @State private var searchText = ""
    @State private var showAddDeal = false
    @State private var filterStatus: DealStatus? = nil
    @State private var sortOption: DealSortOption = .dateNewest
    @State private var showSortMenu = false

    var filteredDeals: [Deal] {
        var filtered = viewModel.deals

        if let status = filterStatus {
            filtered = filtered.filter { $0.status == status }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                ($0.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Apply sorting
        switch sortOption {
        case .dateNewest:
            filtered = filtered.sorted { $0.createdAt > $1.createdAt }
        case .dateOldest:
            filtered = filtered.sorted { $0.createdAt < $1.createdAt }
        case .priceHighest:
            filtered = filtered.sorted { $0.agreedPrice > $1.agreedPrice }
        case .priceLowest:
            filtered = filtered.sorted { $0.agreedPrice < $1.agreedPrice }
        }

        return filtered
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Stats Header
                    HStack(spacing: 16) {
                        DealStatCard(
                            title: "Toplam",
                            value: formatPrice(viewModel.totalAmount),
                            icon: "dollarsign.circle.fill",
                            color: AppTheme.successColor
                        )

                        DealStatCard(
                            title: "Aktiv",
                            value: "\(viewModel.activeDeals)",
                            icon: "chart.line.uptrend.xyaxis",
                            color: AppTheme.primaryColor
                        )
                    }
                    .padding()

                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterPill(title: "Hamısı", isSelected: filterStatus == nil) {
                                filterStatus = nil
                            }

                            ForEach([DealStatus.pending, .inProgress, .completed, .cancelled], id: \.self) { status in
                                FilterPill(
                                    title: status.displayName,
                                    isSelected: filterStatus == status
                                ) {
                                    filterStatus = status
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(AppTheme.cardBackground)

                    if viewModel.isLoading && viewModel.deals.isEmpty {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredDeals.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "briefcase.fill",
                            title: "Sövdələşmə yoxdur",
                            message: "Yeni sövdələşmə əlavə edin"
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredDeals) { deal in
                                    NavigationLink(destination: DealDetailView(deal: deal)) {
                                        DealRowView(deal: deal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Task {
                                                await deleteDeal(deal)
                                            }
                                        } label: {
                                            Label("Sil", systemImage: "trash")
                                        }
                                    }
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
            .navigationTitle("Sövdələşmələr")
            .searchable(text: $searchText, prompt: "Axtar...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(DealSortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                                .foregroundColor(AppTheme.primaryColor)
                            Text("Sırala")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.primaryColor)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddDeal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.primaryGradient)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddDeal) {
                AddDealView {
                    await viewModel.refresh()
                }
            }
            .task {
                await viewModel.loadDeals()
            }
        }
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price)) ₼"
    }

    private func deleteDeal(_ deal: Deal) async {
        do {
            try await APIService.shared.deleteDeal(id: deal.id)
            await viewModel.refresh()
        } catch {
            print("Error deleting deal: \(error)")
        }
    }
}

struct DealRowView: View {
    let deal: Deal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    if let notes = deal.notes {
                        Text(notes)
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(2)
                    } else {
                        Text("Sövdələşmə")
                            .font(AppTheme.headline())
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }

                Spacer()

                DealStatusBadge(status: deal.status)
            }

            Divider()

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(AppTheme.successGradient)
                    Text(formatPrice(deal.agreedPrice))
                        .font(AppTheme.title2())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.bold)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(formatDate(deal.createdAt))
                        .font(AppTheme.caption())
                }
                .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .cardStyle()
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price)) ₼"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct DealStatusBadge: View {
    let status: DealStatus

    var body: some View {
        Text(status.displayName)
            .font(AppTheme.caption2())
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(colorForStatus(status))
            .cornerRadius(12)
    }

    private func colorForStatus(_ status: DealStatus) -> Color {
        switch status {
        case .pending: return AppTheme.warningColor
        case .inProgress: return AppTheme.primaryColor
        case .completed: return AppTheme.successColor
        case .cancelled: return AppTheme.errorColor
        }
    }
}

struct DealStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(title)
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    DealsListView()
}
