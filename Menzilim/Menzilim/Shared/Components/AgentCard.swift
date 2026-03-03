import SwiftUI

// MARK: - Agent Card Component
struct AgentCard: View {
    let agent: Agent
    var isFollowing: Bool = false
    var onFollowTap: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                // MARK: - Avatar with Level Border
                avatarSection

                // MARK: - Name
                Text(agent.displayName)
                    .font(AppTheme.Fonts.captionBold())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                // MARK: - Rating Stars
                ratingStars

                // MARK: - Trust Score Circle
                trustScoreCircle

                // MARK: - Follow Button
                followButton
            }
            .frame(width: 120)
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Avatar Section
    private var avatarSection: some View {
        ZStack(alignment: .bottom) {
            // Avatar with colored level border
            AsyncImage(url: URL(string: agent.avatarUrl ?? "")) { phase in
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
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        )
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(levelBorderColor, lineWidth: 3)
            )
            .shadow(color: levelBorderColor.opacity(0.3), radius: 6, x: 0, y: 2)

            // Level badge overlay
            Text(agent.level.badgeName)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(hex: agent.level.badgeColor))
                .cornerRadius(AppTheme.CornerRadius.small)
                .offset(y: 8)
        }
        .padding(.bottom, AppTheme.Spacing.xs)
    }

    // MARK: - Level Border Color
    private var levelBorderColor: Color {
        Color(hex: agent.level.badgeColor)
    }

    // MARK: - Rating Stars
    private var ratingStars: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: starImage(for: index))
                    .font(.system(size: 10))
                    .foregroundColor(starColor(for: index))
            }

            Text(agent.ratingFormatted)
                .font(AppTheme.Fonts.small())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }

    private func starImage(for index: Int) -> String {
        let rating = agent.rating
        if Double(index + 1) <= rating {
            return "star.fill"
        } else if Double(index) < rating {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }

    private func starColor(for index: Int) -> Color {
        Double(index) < agent.rating ? AppTheme.Colors.gold : AppTheme.Colors.textTertiary
    }

    // MARK: - Trust Score Circle
    private var trustScoreCircle: some View {
        let trustScore = computedTrustScore

        return ZStack {
            // Background track
            Circle()
                .stroke(AppTheme.Colors.inputBorder, lineWidth: 3)

            // Progress arc
            Circle()
                .trim(from: 0, to: trustScore / 100)
                .stroke(trustScoreColor(trustScore), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Percentage text
            VStack(spacing: 0) {
                Text("\(Int(trustScore))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
        .frame(width: 40, height: 40)
    }

    private var computedTrustScore: Double {
        // Trust score computed from rating, reviews, and level
        let ratingScore = (agent.rating / 5.0) * 40
        let levelScore = Double(agent.level.rawValue) / 5.0 * 30
        let reviewScore = min(Double(agent.totalReviews) / 50.0, 1.0) * 30
        return min(ratingScore + levelScore + reviewScore, 100)
    }

    private func trustScoreColor(_ score: Double) -> Color {
        if score >= 80 {
            return AppTheme.Colors.success
        } else if score >= 60 {
            return AppTheme.Colors.gold
        } else if score >= 40 {
            return AppTheme.Colors.warning
        } else {
            return AppTheme.Colors.error
        }
    }

    // MARK: - Follow Button
    private var followButton: some View {
        Button {
            onFollowTap?()
        } label: {
            Text("follow".localized)
                .font(AppTheme.Fonts.smallBold())
                .foregroundColor(isFollowing ? AppTheme.Colors.textSecondary : AppTheme.Colors.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(
                    isFollowing
                        ? AppTheme.Colors.inputBackground
                        : AppTheme.Colors.accent.opacity(0.12)
                )
                .cornerRadius(AppTheme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(
                            isFollowing ? AppTheme.Colors.inputBorder : AppTheme.Colors.accent.opacity(0.3),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Agent Row Card (Alternative layout for lists)
struct AgentRowCard: View {
    let agent: Agent
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                // Avatar
                AsyncImage(url: URL(string: agent.avatarUrl ?? "")) { phase in
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
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            )
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: agent.level.badgeColor), lineWidth: 2)
                )

                // Info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(agent.displayName)
                        .font(AppTheme.Fonts.bodyBold())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    HStack(spacing: AppTheme.Spacing.sm) {
                        // Rating
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.Colors.gold)
                            Text(agent.ratingFormatted)
                                .font(AppTheme.Fonts.small())
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }

                        // Level
                        Text(agent.level.displayKey.localized)
                            .font(AppTheme.Fonts.small())
                            .foregroundColor(Color(hex: agent.level.badgeColor))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
