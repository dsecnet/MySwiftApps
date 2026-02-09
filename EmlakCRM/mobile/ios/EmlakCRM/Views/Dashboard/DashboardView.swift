import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Salam,")
                                    .font(AppTheme.body())
                                    .foregroundColor(AppTheme.textSecondary)

                                Text(authVM.currentUser?.fullName ?? "")
                                    .font(AppTheme.title())
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Spacer()

                            Button {
                                authVM.logout()
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.errorColor)
                            }
                        }
                        .padding()

                        // Stats Grid
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 100)
                        } else if let stats = viewModel.stats {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                StatCard(
                                    title: "Əmlaklar",
                                    value: "\(stats.totalProperties)",
                                    icon: "building.2.fill",
                                    color: AppTheme.primaryColor
                                )

                                StatCard(
                                    title: "Müştərilər",
                                    value: "\(stats.totalClients)",
                                    icon: "person.2.fill",
                                    color: AppTheme.secondaryColor
                                )

                                StatCard(
                                    title: "Fəaliyyətlər",
                                    value: "\(stats.totalActivities)",
                                    icon: "list.bullet.clipboard.fill",
                                    color: AppTheme.warningColor
                                )

                                StatCard(
                                    title: "Sövdələşmələr",
                                    value: "\(stats.totalDeals)",
                                    icon: "dollarsign.circle.fill",
                                    color: AppTheme.successColor
                                )
                            }
                            .padding(.horizontal)
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(AppTheme.caption())
                                .foregroundColor(AppTheme.errorColor)
                                .padding()
                        }

                        Spacer(minLength: 40)
                    }
                }
                .refreshable {
                    await viewModel.loadStats()
                }
            }
            .navigationTitle("Ana Səhifə")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadStats()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(title)
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
