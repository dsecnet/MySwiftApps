//
//  ReviewView.swift
//  CoreVia
//

import SwiftUI

// MARK: - Reviews Section (Trainer Detail-da istifade olunacaq)
struct ReviewsSection: View {
    let trainerId: String
    @ObservedObject private var reviewManager = ReviewManager.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var showWriteReview = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(loc.localized("review_title"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                if let summary = reviewManager.summary {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.starFilled)
                        Text(String(format: "%.1f", summary.averageRating))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                        Text("(\(summary.totalReviews))")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }

            // Rating Distribution
            if let summary = reviewManager.summary, summary.totalReviews > 0 {
                RatingDistributionView(summary: summary)
            }

            // Write Review Button
            if AuthManager.shared.currentUser?.userType == "client" {
                Button {
                    showWriteReview = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text(loc.localized("review_write"))
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(10)
                }
            }

            // Reviews List
            if reviewManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if reviewManager.reviews.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text(loc.localized("review_empty"))
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(reviewManager.reviews) { review in
                    ReviewCard(review: review)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
        .onAppear {
            Task {
                await reviewManager.fetchReviews(trainerId: trainerId)
                await reviewManager.fetchSummary(trainerId: trainerId)
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewSheet(trainerId: trainerId)
        }
    }
}

// MARK: - Rating Distribution
struct RatingDistributionView: View {
    let summary: ReviewSummaryResponse

    var body: some View {
        VStack(spacing: 4) {
            ForEach((1...5).reversed(), id: \.self) { star in
                HStack(spacing: 8) {
                    Text("\(star)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(width: 12)

                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.starFilled)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppTheme.Colors.separator)
                                .frame(height: 6)

                            let count = summary.ratingDistribution["\(star)"] ?? 0
                            let ratio = summary.totalReviews > 0 ? CGFloat(count) / CGFloat(summary.totalReviews) : 0
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppTheme.Colors.starFilled)
                                .frame(width: geo.size.width * ratio, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(summary.ratingDistribution["\(star)"] ?? 0)")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                        .frame(width: 20)
                }
            }
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let review: ReviewResponse
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                // Avatar
                if let imageUrl = review.studentProfileImage, !imageUrl.isEmpty {
                    let fullURL = imageUrl.hasPrefix("http") ? imageUrl : APIService.shared.baseURL + imageUrl
                    AsyncImage(url: URL(string: fullURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(width: 36, height: 36).clipShape(Circle())
                        default:
                            Circle().fill(AppTheme.Colors.accent.opacity(0.2))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text(String(review.studentName.prefix(1)))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.accent)
                                )
                        }
                    }
                } else {
                    Circle().fill(AppTheme.Colors.accent.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(String(review.studentName.prefix(1)))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.Colors.accent)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.studentName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: i < review.rating ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.Colors.starFilled)
                        }
                    }
                }

                Spacer()

                Text(review.createdAt, style: .date)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Colors.tertiaryText)
            }

            if let comment = review.comment, !comment.isEmpty {
                Text(comment)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .lineSpacing(3)
            }
        }
        .padding(12)
        .background(AppTheme.Colors.background)
        .cornerRadius(12)
    }
}

// MARK: - Write Review Sheet
struct WriteReviewSheet: View {
    let trainerId: String
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var reviewManager = ReviewManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var selectedRating: Int = 0
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Star Selection
                    VStack(spacing: 12) {
                        Text(loc.localized("review_rate_trainer"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedRating = star
                                    }
                                } label: {
                                    Image(systemName: star <= selectedRating ? "star.fill" : "star")
                                        .font(.system(size: 36))
                                        .foregroundColor(AppTheme.Colors.starFilled)
                                        .scaleEffect(star <= selectedRating ? 1.1 : 1.0)
                                }
                            }
                        }

                        if selectedRating > 0 {
                            Text(ratingLabel)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(16)

                    // Comment
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(loc.localized("review_comment")) (\(loc.localized("common_optional")))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        TextEditor(text: $comment)
                            .frame(height: 120)
                            .padding(8)
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }

                    Spacer()

                    // Submit Button
                    Button {
                        isSubmitting = true
                        Task {
                            let success = await reviewManager.submitReview(
                                trainerId: trainerId,
                                rating: selectedRating,
                                comment: comment.isEmpty ? nil : comment
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
                                Image(systemName: "paperplane.fill")
                                Text(loc.localized("review_submit"))
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedRating > 0 ? AppTheme.Colors.accent : AppTheme.Colors.separator)
                        .cornerRadius(12)
                    }
                    .disabled(selectedRating == 0 || isSubmitting)
                }
                .padding()
            }
            .navigationTitle(loc.localized("review_write"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(loc.localized("common_cancel")) { dismiss() }
                }
            }
            .alert(loc.localized("common_success"), isPresented: $showSuccess) {
                Button(loc.localized("common_ok")) { dismiss() }
            } message: {
                Text(loc.localized("review_success_msg"))
            }
            .alert(loc.localized("common_error"), isPresented: $showError) {
                Button(loc.localized("common_ok"), role: .cancel) {}
            } message: {
                Text(reviewManager.errorMessage ?? loc.localized("teacher_unknown_error"))
            }
        }
    }

    var ratingLabel: String {
        switch selectedRating {
        case 1: return loc.localized("review_rating_1")
        case 2: return loc.localized("review_rating_2")
        case 3: return loc.localized("review_rating_3")
        case 4: return loc.localized("review_rating_4")
        case 5: return loc.localized("review_rating_5")
        default: return ""
        }
    }
}
