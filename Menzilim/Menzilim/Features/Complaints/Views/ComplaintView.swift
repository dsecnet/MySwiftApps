import SwiftUI
import PhotosUI

// MARK: - Complaint View
struct ComplaintView: View {
    @StateObject private var viewModel = ComplaintViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.xxl) {
                // MARK: - Header
                headerSection

                // MARK: - Complaint Type Selection
                complaintTypeSection

                // MARK: - Description
                descriptionSection

                // MARK: - Screenshot Attachment
                screenshotSection

                // MARK: - Submit Button
                submitButton

                Spacer()
                    .frame(height: AppTheme.Spacing.xxxl)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("report_problem".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onChange(of: viewModel.screenshotItems) { _ in
            Task {
                await viewModel.processSelectedPhotos()
            }
        }
        .alert("complaint_sent".localized, isPresented: $viewModel.showSuccessAlert) {
            Button("ok".localized) {
                viewModel.resetForm()
                dismiss()
            }
        } message: {
            Text("Şikayətiniz qeydə alındı. Ən qısa zamanda baxılacaq.")
        }
        .alert("error".localized, isPresented: $viewModel.showErrorAlert) {
            Button("ok".localized) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.warning.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.Colors.warning)
            }

            Text("report_problem".localized)
                .font(AppTheme.Fonts.heading2())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("Problemi bildirin, komandam\u{0131}z ən qısa zamanda baxacaq")
                .font(AppTheme.Fonts.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Complaint Type Section
    private var complaintTypeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Şikayət növü")
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                GridItem(.flexible(), spacing: AppTheme.Spacing.md)
            ], spacing: AppTheme.Spacing.md) {
                ForEach(ComplaintType.allCases, id: \.self) { type in
                    complaintTypeCard(type)
                }
            }
        }
    }

    private func complaintTypeCard(_ type: ComplaintType) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedComplaintType = type
            }
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(
                        viewModel.selectedComplaintType == type
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.textTertiary
                    )

                Text(type.displayKey.localized)
                    .font(AppTheme.Fonts.smallBold())
                    .foregroundColor(
                        viewModel.selectedComplaintType == type
                            ? AppTheme.Colors.textPrimary
                            : AppTheme.Colors.textSecondary
                    )
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                viewModel.selectedComplaintType == type
                    ? AppTheme.Colors.accent.opacity(0.1)
                    : AppTheme.Colors.cardBackground
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(
                        viewModel.selectedComplaintType == type
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.inputBorder,
                        lineWidth: viewModel.selectedComplaintType == type ? 1.5 : 1
                    )
            )
        }
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("complaint_description".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            ZStack(alignment: .topLeading) {
                if viewModel.descriptionText.isEmpty {
                    Text("Problemi ətraflı təsvir edin...")
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.md)
                }

                TextEditor(text: $viewModel.descriptionText)
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )

            // Character count
            HStack {
                Spacer()
                Text("\(viewModel.descriptionText.count)/500")
                    .font(AppTheme.Fonts.small())
                    .foregroundColor(
                        viewModel.descriptionText.count > 500
                            ? AppTheme.Colors.error
                            : AppTheme.Colors.textTertiary
                    )
            }
        }
    }

    // MARK: - Screenshot Section
    private var screenshotSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("attach_screenshot".localized)
                .font(AppTheme.Fonts.captionBold())
                .foregroundColor(AppTheme.Colors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    // Add photo button
                    PhotosPicker(
                        selection: $viewModel.screenshotItems,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.Colors.accent)

                            Text("add_photos".localized)
                                .font(AppTheme.Fonts.small())
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .frame(width: 90, height: 90)
                        .background(AppTheme.Colors.inputBackground)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(AppTheme.Colors.inputBorder, style: StrokeStyle(lineWidth: 1, dash: [6]))
                        )
                    }

                    // Preview images
                    ForEach(Array(viewModel.screenshotImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .cornerRadius(AppTheme.CornerRadius.medium)
                                .clipped()

                            Button {
                                viewModel.removeScreenshot(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                            .frame(width: 22, height: 22)
                                    )
                            }
                            .offset(x: 4, y: -4)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            viewModel.submitComplaint()
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                }
                Text("submit_complaint".localized)
                    .font(AppTheme.Fonts.bodyBold())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                viewModel.isFormValid
                    ? AppTheme.Colors.accent
                    : AppTheme.Colors.accent.opacity(0.4)
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
        .padding(.top, AppTheme.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ComplaintView()
    }
}
