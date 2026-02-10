import SwiftUI

struct MortgageCalculatorView: View {
    @StateObject private var viewModel = MortgageViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Input Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Əsas Məlumatlar")
                            .font(.headline)
                            .foregroundColor(.primary)

                        // Property Price
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Əmlak Qiyməti", systemImage: "house.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            TextField("150000", value: $viewModel.propertyPrice, format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 18, weight: .semibold))
                        }

                        // Down Payment
                        VStack(alignment: .leading, spacing: 8) {
                            Label("İlkin Ödəniş (%)", systemImage: "percent")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack {
                                Slider(value: $viewModel.downPaymentPercent, in: 10...50, step: 5)
                                    .accentColor(AppTheme.primaryColor)

                                Text("\(Int(viewModel.downPaymentPercent))%")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.primaryColor)
                                    .frame(width: 50)
                            }

                            Text("\(viewModel.calculatedDownPayment.toCurrency())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Term Years
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Müddət (il)", systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("Müddət", selection: $viewModel.termYears) {
                                ForEach([5, 10, 15, 20, 25, 30], id: \.self) { years in
                                    Text("\(years) il").tag(years)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // Currency
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Valyuta", systemImage: "dollarsign.circle")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("Valyuta", selection: $viewModel.currency) {
                                Text("AZN").tag("AZN")
                                Text("USD").tag("USD")
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)

                    // Calculate Button
                    Button {
                        Task {
                            await viewModel.calculate()
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "calculator")
                                Text("Hesabla")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading || viewModel.propertyPrice <= 0)

                    // Result
                    if let result = viewModel.result {
                        MortgageResultCard(result: result)
                    }

                    // Compare Banks Button
                    if viewModel.result != nil {
                        Button {
                            Task {
                                await viewModel.compareBanks()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "building.columns")
                                Text("Bankları Müqayisə et")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.successColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }

                    // Bank Comparison
                    if !viewModel.bankComparison.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bank Müqayisəsi")
                                .font(.headline)

                            ForEach(Array(viewModel.bankComparison.enumerated()), id: \.offset) { index, bank in
                                BankComparisonCard(bank: bank, rank: index + 1)
                            }
                        }
                    }

                    // Error
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Mortgage Kalkulyator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Bağla") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Result Card
struct MortgageResultCard: View {
    let result: MortgageResult

    var body: some View {
        VStack(spacing: 16) {
            Text("Nəticə")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Monthly Payment - Big
            VStack(spacing: 4) {
                Text("Aylıq Ödəniş")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(result.monthlyPayment.toCurrency())
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.primaryColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primaryColor.opacity(0.1))
            .cornerRadius(12)

            // Details Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ResultDetailItem(
                    icon: "banknote",
                    title: "Kredit Məbləği",
                    value: result.loanAmount.toCurrency()
                )

                ResultDetailItem(
                    icon: "percent",
                    title: "Faiz Dərəcəsi",
                    value: String(format: "%.1f%%", result.rate)
                )

                ResultDetailItem(
                    icon: "calendar",
                    title: "Müddət",
                    value: "\(result.termYears) il"
                )

                ResultDetailItem(
                    icon: "creditcard",
                    title: "İlkin Ödəniş",
                    value: result.downPayment.toCurrency()
                )

                ResultDetailItem(
                    icon: "sum",
                    title: "Ümumi Ödəniş",
                    value: result.totalPayment.toCurrency()
                )

                ResultDetailItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Ümumi Faiz",
                    value: result.totalInterest.toCurrency(),
                    color: .orange
                )
            }

            if let bank = result.bank {
                HStack {
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(AppTheme.primaryColor)
                    Text(bank)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

struct ResultDetailItem: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = .primary

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.primaryColor)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Bank Comparison Card
struct BankComparisonCard: View {
    let bank: BankInfo
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rank == 1 ? AppTheme.successColor : Color.gray.opacity(0.2))
                    .frame(width: 36, height: 36)

                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(rank == 1 ? .white : .primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(bank.name)
                    .font(.system(size: 16, weight: .semibold))

                HStack(spacing: 16) {
                    Label(String(format: "%.1f%%", bank.rate), systemImage: "percent")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(bank.monthlyPayment.toCurrency())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)
                }
            }

            Spacer()

            if rank == 1 {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(rank == 1 ? AppTheme.successColor.opacity(0.1) : Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - ViewModel
@MainActor
class MortgageViewModel: ObservableObject {
    @Published var propertyPrice: Double = 150000
    @Published var downPaymentPercent: Double = 20
    @Published var termYears: Int = 30
    @Published var currency: String = "AZN"

    @Published var result: MortgageResult?
    @Published var bankComparison: [BankInfo] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    var calculatedDownPayment: Double {
        propertyPrice * (downPaymentPercent / 100)
    }

    func calculate() async {
        isLoading = true
        errorMessage = nil

        do {
            result = try await MortgageService.shared.calculateMortgage(
                propertyPrice: propertyPrice,
                downPaymentPercent: downPaymentPercent,
                termYears: termYears,
                currency: currency
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func compareBanks() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await MortgageService.shared.compareBanks(
                propertyPrice: propertyPrice,
                downPaymentPercent: downPaymentPercent,
                termYears: termYears,
                currency: currency
            )

            bankComparison = response.banks
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    MortgageCalculatorView()
}
