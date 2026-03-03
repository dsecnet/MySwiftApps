import SwiftUI

// MARK: - Search View
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var activeChip: FilterChip?

    enum FilterChip: String, CaseIterable {
        case price
        case rooms
        case agentLevel

        var displayKey: String {
            switch self {
            case .price: return "price"
            case .rooms: return "rooms"
            case .agentLevel: return "agent_level"
            }
        }

        var icon: String {
            switch self {
            case .price: return "manat"
            case .rooms: return "bed.double.fill"
            case .agentLevel: return "person.badge.shield.checkmark.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Search Header
                searchHeader

                // MARK: - Filter Chips
                filterChipsRow

                // MARK: - Results Count & Map Toggle
                resultsBar

                // MARK: - Results List
                if viewModel.showMapView {
                    MapSearchView(viewModel: viewModel)
                } else {
                    resultsList
                }
            }

            // MARK: - Chip Dropdown Overlay
            if activeChip != nil {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeChip = nil
                        }
                    }

                chipDropdown
            }
        }
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterView(viewModel: viewModel)
        }
    }

    // MARK: - Search Header
    private var searchHeader: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textTertiary)

                TextField("search".localized, text: $viewModel.searchText)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .autocorrectionDisabled()

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )

            // Filter button
            Button {
                viewModel.showFilterSheet = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(
                        viewModel.filter.hasActiveFilters
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.textSecondary
                    )
                    .frame(width: 48, height: 48)
                    .background(AppTheme.Colors.inputBackground)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(
                                viewModel.filter.hasActiveFilters
                                    ? AppTheme.Colors.accent
                                    : AppTheme.Colors.inputBorder,
                                lineWidth: 1
                            )
                    )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.md)
    }

    // MARK: - Filter Chips Row
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(FilterChip.allCases, id: \.self) { chip in
                    filterChipButton(chip)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.bottom, AppTheme.Spacing.md)
    }

    private func filterChipButton(_ chip: FilterChip) -> some View {
        let isActive: Bool = {
            switch chip {
            case .price: return viewModel.selectedPriceRange != nil
            case .rooms: return viewModel.selectedRoomFilter != nil
            case .agentLevel: return viewModel.selectedAgentLevel != nil
            }
        }()

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if activeChip == chip {
                    activeChip = nil
                } else {
                    activeChip = chip
                }
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.xs) {
                if chip != .price {
                    Image(systemName: chip.icon)
                        .font(.system(size: 12))
                }

                Text(chip.displayKey.localized)
                    .font(AppTheme.Fonts.captionBold())

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(isActive ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isActive
                    ? AppTheme.Colors.accent.opacity(0.12)
                    : AppTheme.Colors.cardBackground
            )
            .cornerRadius(AppTheme.CornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                    .stroke(
                        isActive ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                        lineWidth: 1
                    )
            )
        }
    }

    // MARK: - Chip Dropdown
    private var chipDropdown: some View {
        VStack {
            Spacer()
                .frame(height: 140)

            VStack(spacing: 0) {
                switch activeChip {
                case .price:
                    priceDropdownContent
                case .rooms:
                    roomsDropdownContent
                case .agentLevel:
                    agentLevelDropdownContent
                case .none:
                    EmptyView()
                }
            }
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.3), radius: 12, y: 4)
            .padding(.horizontal, AppTheme.Spacing.lg)

            Spacer()
        }
    }

    private var priceDropdownContent: some View {
        VStack(spacing: 0) {
            dropdownItem(title: "any".localized, isSelected: viewModel.selectedPriceRange == nil) {
                viewModel.selectPriceRange(nil)
                activeChip = nil
            }
            Divider().background(AppTheme.Colors.inputBorder)
            dropdownItem(title: "0 - 100,000 AZN", isSelected: viewModel.selectedPriceRange == "0-100K") {
                viewModel.selectPriceRange("0-100K")
                activeChip = nil
            }
            Divider().background(AppTheme.Colors.inputBorder)
            dropdownItem(title: "100,000 - 300,000 AZN", isSelected: viewModel.selectedPriceRange == "100K-300K") {
                viewModel.selectPriceRange("100K-300K")
                activeChip = nil
            }
            Divider().background(AppTheme.Colors.inputBorder)
            dropdownItem(title: "300,000+ AZN", isSelected: viewModel.selectedPriceRange == "300K+") {
                viewModel.selectPriceRange("300K+")
                activeChip = nil
            }
        }
    }

    private var roomsDropdownContent: some View {
        VStack(spacing: 0) {
            dropdownItem(title: "any".localized, isSelected: viewModel.selectedRoomFilter == nil) {
                viewModel.selectRoomFilter(nil)
                activeChip = nil
            }
            ForEach(["1", "2", "3", "4+"], id: \.self) { room in
                Divider().background(AppTheme.Colors.inputBorder)
                dropdownItem(
                    title: "\(room) \("rooms".localized)",
                    isSelected: viewModel.selectedRoomFilter == room
                ) {
                    viewModel.selectRoomFilter(room == "4+" ? "4" : room)
                    activeChip = nil
                }
            }
        }
    }

    private var agentLevelDropdownContent: some View {
        VStack(spacing: 0) {
            dropdownItem(title: "any".localized, isSelected: viewModel.selectedAgentLevel == nil) {
                viewModel.selectedAgentLevel = nil
                activeChip = nil
            }
            ForEach(AgentLevel.allCases, id: \.self) { level in
                Divider().background(AppTheme.Colors.inputBorder)
                dropdownItem(
                    title: level.displayKey.localized,
                    isSelected: viewModel.selectedAgentLevel == level.displayKey
                ) {
                    viewModel.selectedAgentLevel = level.displayKey
                    activeChip = nil
                }
            }
        }
    }

    private func dropdownItem(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.textPrimary
                    )
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }

    // MARK: - Results Bar
    private var resultsBar: some View {
        HStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                    .scaleEffect(0.8)

                Text("loading".localized)
                    .font(AppTheme.Fonts.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            } else {
                Text("\(viewModel.totalResults) \("show_results".localized)")
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()

            // Map/List Toggle
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.toggleMapView()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: viewModel.showMapView ? "list.bullet" : "map.fill")
                        .font(.system(size: 14))

                    Text(viewModel.showMapView ? "list_view".localized : "map_view".localized)
                        .font(AppTheme.Fonts.captionBold())
                }
                .foregroundColor(AppTheme.Colors.accent)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.accent.opacity(0.12))
                .cornerRadius(AppTheme.CornerRadius.small)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.md)
    }

    // MARK: - Results List
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.lg) {
                if viewModel.results.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    ForEach(viewModel.results) { listing in
                        ListingCardView(listing: listing)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                }
            }
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer().frame(height: 40)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textTertiary)

            Text("no_favorites".localized)
                .font(AppTheme.Fonts.title())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("no_favorites_hint".localized)
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.resetFilters()
            } label: {
                Text("reset".localized)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.accent.opacity(0.12))
                    .cornerRadius(AppTheme.CornerRadius.small)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppTheme.Spacing.xxxl)
    }
}

// MARK: - Preview
#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
