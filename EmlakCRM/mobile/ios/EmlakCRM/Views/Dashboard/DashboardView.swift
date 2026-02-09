import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Modern Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Xoş gəlmisiniz,")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)

                                Text(authVM.currentUser?.name ?? "")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Spacer()

                            // Profile/Notification buttons
                            HStack(spacing: 12) {
                                Button {
                                    // Notification action
                                } label: {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .frame(width: 44, height: 44)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(12)
                                        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 2)
                                }

                                Button {
                                    authVM.logout()
                                } label: {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.primaryColor)
                                        .frame(width: 44, height: 44)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(12)
                                        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 100)
                        } else if let stats = viewModel.stats {
                            // Balance Card - similar to reference
                            BalanceCard(
                                title: "Toplam Əmlak Dəyəri",
                                amount: "₼\(stats.totalProperties * 100000)",
                                subtitle: "Son 30 gün"
                            )
                            .padding(.horizontal, 20)

                            // Overview Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("İcmal")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.horizontal, 20)

                                // Stats Grid - 2x2
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    ModernStatCard(
                                        title: "Əmlaklar",
                                        value: "\(stats.totalProperties)",
                                        icon: "building.2.fill",
                                        trend: "+30%",
                                        color: AppTheme.primaryColor
                                    )

                                    ModernStatCard(
                                        title: "Müştərilər",
                                        value: "\(stats.totalClients)",
                                        icon: "person.2.fill",
                                        trend: "+12%",
                                        color: AppTheme.secondaryColor
                                    )

                                    ModernStatCard(
                                        title: "Fəaliyyətlər",
                                        value: "\(stats.totalActivities)",
                                        icon: "calendar.badge.clock",
                                        trend: nil,
                                        color: AppTheme.accentColor
                                    )

                                    ModernStatCard(
                                        title: "Sövdələşmələr",
                                        value: "\(stats.totalDeals)",
                                        icon: "chart.line.uptrend.xyaxis",
                                        trend: "+8%",
                                        color: AppTheme.successColor
                                    )
                                }
                                .padding(.horizontal, 20)
                            }

                            // Quick Actions
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Sürətli Əməliyyatlar")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.horizontal, 20)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        QuickActionCard(
                                            title: "Əmlak Əlavə Et",
                                            icon: "plus.square.fill",
                                            color: AppTheme.primaryColor
                                        )

                                        QuickActionCard(
                                            title: "Müştəri Əlavə Et",
                                            icon: "person.crop.circle.badge.plus",
                                            color: AppTheme.secondaryColor
                                        )

                                        QuickActionCard(
                                            title: "Fəaliyyət Planla",
                                            icon: "calendar.badge.plus",
                                            color: AppTheme.accentColor
                                        )

                                        QuickActionCard(
                                            title: "Hesabat",
                                            icon: "chart.bar.doc.horizontal.fill",
                                            color: AppTheme.successColor
                                        )
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.errorColor)
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.loadStats()
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadStats()
            }
        }
    }
}

// Quick Action Card Component
struct QuickActionCard: View {
    let title: String
    let icon: String
    var color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(14)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 100)
        }
        .frame(width: 120, height: 120)
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 4)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
