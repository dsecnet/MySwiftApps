//
//  TrainerMarketplaceView.swift
//  CoreVia
//
//  Trainer oz mehsullarini gorur, yaradir, silir
//  Movcut ProductCard dizayni qorunur
//

import SwiftUI

struct TrainerMarketplaceView: View {
    @StateObject private var viewModel = TrainerMarketplaceViewModel()
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showCreateProduct = false
    @State private var selectedProductType: String = "all"

    let productTypes = ["all", "workout_plan", "meal_plan", "training_program", "ebook", "video_course"]

    var body: some View {
        ZStack {
            // Content
            VStack(spacing: 0) {
                // Filter Chips
                filterSection

                // List
                if viewModel.isLoading && viewModel.products.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.products.isEmpty {
                    emptyState
                } else {
                    productsListView
                }
            }

            // FAB button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showCreateProduct = true
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
            await viewModel.loadMyProducts(refresh: true)
        }
        .refreshable {
            await viewModel.loadMyProducts(refresh: true)
        }
        .sheet(isPresented: $showCreateProduct) {
            CreateProductView()
                .onDisappear {
                    Task { await viewModel.loadMyProducts(refresh: true) }
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
                ForEach(productTypes, id: \.self) { type in
                    FilterChip(
                        title: loc.localized("marketplace_\(type)"),
                        isSelected: selectedProductType == type
                    ) {
                        selectedProductType = type
                        Task {
                            await viewModel.loadMyProducts(
                                productType: type == "all" ? nil : type,
                                refresh: true
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Products List

    private var productsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.products) { product in
                    TrainerProductCard(product: product) {
                        Task { await viewModel.deleteProduct(product.id) }
                    }
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
            Image(systemName: "bag.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(loc.localized("trainer_hub_no_products"))
                .font(.headline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(loc.localized("trainer_hub_no_products_desc"))
                .font(.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)

            Button {
                showCreateProduct = true
            } label: {
                Text(loc.localized("trainer_hub_create_product"))
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

// MARK: - Trainer Product Card (with delete)

struct TrainerProductCard: View {
    let product: MarketplaceProduct
    let onDelete: () -> Void
    @State private var showDeleteAlert = false
    let loc = LocalizationManager.shared

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Cover Image
            if let imageUrl = product.coverImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 100, height: 100)
                .cornerRadius(AppTheme.CornerRadius.md)
            } else {
                ZStack {
                    AppTheme.Colors.accent.opacity(0.1)
                    Image(systemName: productIcon)
                        .font(.title)
                        .foregroundColor(AppTheme.Colors.accent)
                }
                .frame(width: 100, height: 100)
                .cornerRadius(AppTheme.CornerRadius.md)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Product Type Badge
                HStack {
                    Text(loc.localized("marketplace_\(product.productType)"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.accent.opacity(0.1))
                        .cornerRadius(6)

                    Spacer()

                    // Active/Inactive Badge
                    Text(product.isPublished ? "Yay\u{0131}mda" : "Gizli")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(product.isPublished ? AppTheme.Colors.success : AppTheme.Colors.secondaryText)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background((product.isPublished ? AppTheme.Colors.success : AppTheme.Colors.secondaryText).opacity(0.1))
                        .cornerRadius(4)
                }

                // Title
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                // Price & Delete
                HStack {
                    Text("\(String(format: "%.2f", product.price)) \(product.currency)")
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.accent)

                    Spacer()

                    // Rating
                    if let rating = product.averageRating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.starFilled)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }

                    // Delete
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.error)
                            .padding(5)
                            .background(AppTheme.Colors.error.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        .alert("Mehsulu silmek isteyirsiniz?", isPresented: $showDeleteAlert) {
            Button("Sil", role: .destructive) { onDelete() }
            Button("Legv et", role: .cancel) {}
        }
    }

    private var productIcon: String {
        switch product.productType {
        case "workout_plan": return "figure.strengthtraining.traditional"
        case "meal_plan": return "fork.knife"
        case "ebook": return "book.closed"
        case "training_program": return "figure.run"
        case "video_course": return "play.rectangle"
        default: return "bag"
        }
    }
}
