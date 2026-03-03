import SwiftUI

// MARK: - Reviews View
struct ReviewsView: View {
    let reviews: [Review]
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [Int: Int]

    @State private var likedReviews: Set<String> = []

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // MARK: - Average Rating Section
            averageRatingSection

            Divider()
                .background(AppTheme.Colors.inputBorder)
                .padding(.horizontal, AppTheme.Spacing.lg)

            // MARK: - Reviews List
            LazyVStack(spacing: AppTheme.Spacing.lg) {
                ForEach(reviews) { review in
                    reviewCard(review)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)

            // MARK: - Report a Problem Section
            reportProblemSection

            Spacer()
                .frame(height: AppTheme.Spacing.xxxl)
        }
        .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: - Average Rating Section
    private var averageRatingSection: some View {
        HStack(spacing: AppTheme.Spacing.xxl) {
            // Left: Big number and stars
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(String(format: "%.1f", averageRating))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                // Stars
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: starImageFor(index: index, rating: averageRating))
                            .font(.system(size: 16))
                            .foregroundColor(
                                Double(index) < averageRating
                                    ? AppTheme.Colors.gold
                                    : AppTheme.Colors.textTertiary
                            )
                    }
                }

                Text("\(totalReviews) \("reviews".localized)")
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            // Right: Bar chart distribution
            VStack(spacing: AppTheme.Spacing.xs) {
                ForEach((1...5).reversed(), id: \.self) { star in
                    ratingBar(star: star)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Rating Bar
    private func ratingBar(star: Int) -> some View {
        let count = ratingDistribution[star] ?? 0
        let maxCount = ratingDistribution.values.max() ?? 1
        let percentage = maxCount > 0 ? CGFloat(count) / CGFloat(maxCount) : 0

        return HStack(spacing: AppTheme.Spacing.sm) {
            Text("\(star)")
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(width: 12)

            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.gold)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.Colors.inputBorder)
                        .frame(height: 6)

                    // Filled bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.Colors.gold)
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)

            Text("\(count)")
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textTertiary)
                .frame(width: 24, alignment: .trailing)
        }
    }

    // MARK: - Review Card
    private func reviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // User row: avatar, name, stars, date
            HStack(spacing: AppTheme.Spacing.md) {
                // Avatar
                AsyncImage(url: URL(string: review.user?.avatarUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Circle()
                            .fill(AppTheme.Colors.surfaceBackground)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            )
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.user?.fullName ?? "User")
                        .font(AppTheme.Fonts.captionBold())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    // Stars and date
                    HStack(spacing: AppTheme.Spacing.sm) {
                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { index in
                                Image(systemName: index < review.rating ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(
                                        index < review.rating
                                            ? AppTheme.Colors.gold
                                            : AppTheme.Colors.textTertiary
                                    )
                            }
                        }

                        Text(review.timeAgo)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                }

                Spacer()
            }

            // Comment text
            Text(review.comment)
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineSpacing(3)

            // Like count and Reply button
            HStack(spacing: AppTheme.Spacing.lg) {
                // Like button
                Button {
                    toggleLike(review.id)
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: likedReviews.contains(review.id) ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(
                                likedReviews.contains(review.id)
                                    ? AppTheme.Colors.error
                                    : AppTheme.Colors.textTertiary
                            )
                        Text("\(Int.random(in: 2...24))")
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                }

                // Reply button
                Button {
                    // Reply action
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "arrowshape.turn.up.left")
                            .font(.system(size: 14))
                        Text("Reply")
                            .font(AppTheme.Fonts.small())
                    }
                    .foregroundColor(AppTheme.Colors.textTertiary)
                }

                Spacer()
            }

            // Agent Reply (indented, italic)
            if let agentReply = review.agentReply {
                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    Rectangle()
                        .fill(AppTheme.Colors.accent.opacity(0.5))
                        .frame(width: 2)

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("agent_reply".localized)
                            .font(AppTheme.Fonts.smallBold())
                            .foregroundColor(AppTheme.Colors.accent)

                        Text(agentReply)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .italic()
                            .lineSpacing(2)
                    }
                }
                .padding(.leading, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.xs)
            }

            Divider()
                .background(AppTheme.Colors.inputBorder)
                .padding(.top, AppTheme.Spacing.xs)
        }
    }

    // MARK: - Report a Problem Section
    private var reportProblemSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Divider()
                .background(AppTheme.Colors.inputBorder)
                .padding(.horizontal, AppTheme.Spacing.lg)

            NavigationLink {
                ComplaintView()
            } label: {
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.warning)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("report_problem".localized)
                            .font(AppTheme.Fonts.captionBold())
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("reviews_complaints".localized)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.top, AppTheme.Spacing.md)
    }

    // MARK: - Helpers
    private func starImageFor(index: Int, rating: Double) -> String {
        if Double(index + 1) <= rating {
            return "star.fill"
        } else if Double(index) < rating {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }

    private func toggleLike(_ reviewId: String) {
        if likedReviews.contains(reviewId) {
            likedReviews.remove(reviewId)
        } else {
            likedReviews.insert(reviewId)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ScrollView {
            ReviewsView(
                reviews: AgentProfileViewModel.mockReviews,
                averageRating: 4.7,
                totalReviews: 128,
                ratingDistribution: [5: 82, 4: 28, 3: 12, 2: 4, 1: 2]
            )
        }
        .background(AppTheme.Colors.background)
    }
}
