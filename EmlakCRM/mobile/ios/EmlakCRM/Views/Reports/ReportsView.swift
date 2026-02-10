import SwiftUI

struct ReportsView: View {
    @StateObject private var dashboardVM = DashboardViewModel()
    @State private var selectedPeriod: TimePeriod = .thisMonth

    enum TimePeriod: String, CaseIterable {
        case today = "Bu gün"
        case thisWeek = "Bu həftə"
        case thisMonth = "Bu ay"
        case thisYear = "Bu il"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Period Selector
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                ForEach(TimePeriod.allCases, id: \.self) { period in
                                    PeriodButton(
                                        title: period.rawValue,
                                        isSelected: selectedPeriod == period
                                    ) {
                                        selectedPeriod = period
                                    }
                                }
                            }
                        }
                        .padding()

                        if let stats = dashboardVM.stats {
                            // Revenue Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.successColor)

                                    Text("Gəlir Analizi")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)

                                    Spacer()
                                }

                                HStack(alignment: .bottom, spacing: 8) {
                                    Text("₼\(stats.totalProperties * 50000)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)

                                    Text("+12.5%")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.successColor)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.successColor.opacity(0.15))
                                        .cornerRadius(8)
                                }

                                Divider()

                                // Revenue breakdown
                                VStack(spacing: 12) {
                                    RevenueRow(
                                        title: "Satışlardan",
                                        amount: stats.totalProperties * 40000,
                                        percentage: 80,
                                        color: AppTheme.successColor
                                    )

                                    RevenueRow(
                                        title: "Kirayədən",
                                        amount: stats.totalProperties * 10000,
                                        percentage: 20,
                                        color: AppTheme.secondaryColor
                                    )
                                }
                            }
                            .padding()
                            .cardStyle()
                            .padding(.horizontal)

                            // Activity Stats
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.primaryColor)

                                    Text("Fəaliyyət Statistikası")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)

                                    Spacer()
                                }

                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    StatBox(
                                        title: "Zənglər",
                                        value: "\(stats.totalActivities / 3)",
                                        icon: "phone.fill",
                                        color: AppTheme.primaryColor
                                    )

                                    StatBox(
                                        title: "Görüşlər",
                                        value: "\(stats.totalActivities / 4)",
                                        icon: "person.2.fill",
                                        color: AppTheme.secondaryColor
                                    )

                                    StatBox(
                                        title: "Baxışlar",
                                        value: "\(stats.totalActivities / 5)",
                                        icon: "eye.fill",
                                        color: AppTheme.accentColor
                                    )

                                    StatBox(
                                        title: "Email",
                                        value: "\(stats.totalActivities / 6)",
                                        icon: "envelope.fill",
                                        color: AppTheme.infoColor
                                    )
                                }
                            }
                            .padding()
                            .cardStyle()
                            .padding(.horizontal)

                            // Performance Metrics
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "target")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.accentColor)

                                    Text("Performans")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)

                                    Spacer()
                                }

                                VStack(spacing: 16) {
                                    ProgressMetric(
                                        title: "Konversiya Nisbəti",
                                        value: 35,
                                        color: AppTheme.successColor
                                    )

                                    ProgressMetric(
                                        title: "Müştəri Məmnuniyyəti",
                                        value: 92,
                                        color: AppTheme.primaryColor
                                    )

                                    ProgressMetric(
                                        title: "Cavab Sürəti",
                                        value: 78,
                                        color: AppTheme.accentColor
                                    )
                                }
                            }
                            .padding()
                            .cardStyle()
                            .padding(.horizontal)

                            // Top Properties
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.warningColor)

                                    Text("Top Əmlaklar")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)

                                    Spacer()
                                }

                                VStack(spacing: 12) {
                                    TopPropertyRow(rank: 1, title: "Yasamal Residence", views: 245)
                                    TopPropertyRow(rank: 2, title: "Port Baku Towers", views: 198)
                                    TopPropertyRow(rank: 3, title: "White City Mansion", views: 176)
                                }
                            }
                            .padding()
                            .cardStyle()
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await dashboardVM.loadStats()
                }
            }
            .navigationTitle("Hesabatlar")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await dashboardVM.loadStats()
            }
        }
    }
}

struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primaryGradient : LinearGradient(colors: [AppTheme.cardBackground], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
                .shadow(color: isSelected ? AppTheme.primaryColor.opacity(0.3) : .clear, radius: 4)
        }
    }
}

struct RevenueRow: View {
    let title: String
    let amount: Int
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textSecondary)

                Spacer()

                Text("₼\(amount)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(percentage) / 100, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .cornerRadius(12)

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.backgroundColor)
        .cornerRadius(12)
    }
}

struct ProgressMetric: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Text("\(value)%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.backgroundColor)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(value) / 100, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct TopPropertyRow: View {
    let rank: Int
    let title: String
    let views: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    rank == 1 ? AppTheme.warningColor :
                    rank == 2 ? AppTheme.textSecondary :
                    AppTheme.accentColor
                )
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text("\(views) baxış")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "eye.fill")
                .foregroundColor(AppTheme.primaryColor)
        }
        .padding()
        .background(AppTheme.backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    ReportsView()
}
