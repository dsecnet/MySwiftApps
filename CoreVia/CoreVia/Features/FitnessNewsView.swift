import SwiftUI

struct FitnessNewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedCategory: String = "All"

    var filteredNews: [NewsArticle] {
        if selectedCategory == "All" {
            return viewModel.articles
        }
        return viewModel.articles.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        NewsCategoryChip(
                            title: "Hamısı",
                            isSelected: selectedCategory == "All"
                        ) {
                            selectedCategory = "All"
                        }

                        ForEach(viewModel.categories, id: \.id) { category in
                            NewsCategoryChip(
                                title: category.name,
                                isSelected: selectedCategory == category.name
                            ) {
                                selectedCategory = category.name
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground).opacity(0.9))

                // News List
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Xəbərlər yüklənir...")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)

                        Text("Xəta baş verdi")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button {
                            Task {
                                await viewModel.loadNews()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Yenidən Cəhd Et")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredNews.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "newspaper")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("Xəbər tapılmadı")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("Bu kateqoriyada xəbər yoxdur")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredNews) { article in
                                NewsCard(article: article)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadNews(forceRefresh: true)
                    }
                }
            }
            .navigationTitle("Fitness Xəbərləri")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.loadNews(forceRefresh: true)
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                if viewModel.articles.isEmpty {
                    await viewModel.loadNews()
                }
            }
        }
    }
}

// MARK: - News Category Chip
struct NewsCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - News Card
struct NewsCard: View {
    @Environment(\.colorScheme) var colorScheme
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: article.categoryIcon)
                        .font(.caption)
                    Text(article.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(categoryColor(for: article.category).opacity(colorScheme == .dark ? 0.3 : 0.2))
                .foregroundColor(categoryColor(for: article.category))
                .cornerRadius(12)

                Spacer()

                // Reading time
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(article.readingTime) dəq")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

            // Title
            Text(article.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)

            // Summary
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            // Footer
            HStack {
                // Source
                Text(article.source)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Time ago
                Text(article.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            colorScheme == .dark
                ? Color(.systemGray6)
                : Color(.systemBackground)
        )
        .cornerRadius(16)
        .shadow(
            color: colorScheme == .dark
                ? Color.white.opacity(0.05)
                : Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 2
        )
    }

    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "workout": return .blue
        case "nutrition": return .green
        case "research": return .purple
        case "tips": return .orange
        case "lifestyle": return .pink
        default: return .gray
        }
    }
}

// MARK: - ViewModel
@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var categories: [NewsCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadNews(forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            // Load news
            let newsResponse = try await NewsService.shared.getFitnessNews(
                limit: 20,
                forceRefresh: forceRefresh
            )
            articles = newsResponse.articles

            // Load categories if empty
            if categories.isEmpty {
                do {
                    let categoriesResponse = try await NewsService.shared.getNewsCategories()
                    categories = categoriesResponse.categories
                } catch {
                    // Categories are optional, don't fail the whole request
                    print("Failed to load categories: \(error)")
                }
            }

        } catch NewsAPIError.unauthorized {
            errorMessage = "Giriş tələb olunur. Zəhmət olmasa yenidən daxil olun."
        } catch NewsAPIError.serverError(let code) {
            errorMessage = "Server xətası (\(code)). Zəhmət olmasa bir az sonra cəhd edin."
        } catch {
            errorMessage = "İnternet bağlantınızı yoxlayın və yenidən cəhd edin."
            print("News loading error: \(error)")
        }

        isLoading = false
    }
}

// #Preview { // iOS 17+ only
//     FitnessNewsView()
// }
