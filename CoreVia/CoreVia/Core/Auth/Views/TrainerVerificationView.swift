//
//  TrainerVerificationView.swift
//  CoreVia
//

import SwiftUI
import PhotosUI

// MARK: - Verification Response Model
struct VerificationResponse: Codable {
    let verificationStatus: String
    let verificationScore: Double?
    let message: String

    enum CodingKeys: String, CodingKey {
        case verificationStatus = "verification_status"
        case verificationScore = "verification_score"
        case message
    }
}

// MARK: - Trainer Verification View
struct TrainerVerificationView: View {

    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var selectedImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var instagram: String = ""
    @State private var selectedSpecialization: String = "Fitness"
    @State private var experience: Int = 1
    @State private var bio: String = ""

    @State private var isLoading = false
    @State private var showResult = false
    @State private var resultStatus: String = ""
    @State private var resultMessage: String = ""
    @State private var resultScore: Double = 0
    @State private var showError = false
    @State private var errorMessage = ""

    let specializations = ["Fitness", "Yoga", "Kardio", "Guc", "Qidalanma"]

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            if showResult {
                resultView
            } else {
                formView
            }
        }
    }

    // MARK: - Form View
    private var formView: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    stepIndicator
                    photoSection
                    instagramSection
                    specializationSection
                    experienceSection
                    bioSection
                    submitButton
                }
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(loc.localized("verification_title"))
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(loc.localized("verification_subtitle"))
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                Spacer()

                Button {
                    authManager.logout()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .padding(10)
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .background(AppTheme.Colors.background)
    }

    // MARK: - Step Indicator
    private var stepIndicator: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.Colors.success)
                    .font(.system(size: 18))
                Text(loc.localized("verification_step_register"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.success)
            }

            Rectangle()
                .fill(AppTheme.Colors.accent)
                .frame(height: 2)
                .frame(maxWidth: 40)

            HStack(spacing: 6) {
                Image(systemName: "2.circle.fill")
                    .foregroundColor(AppTheme.Colors.accent)
                    .font(.system(size: 18))
                Text(loc.localized("verification_title"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.Colors.accent)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Fitness Sekiliniz", systemImage: "camera.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(loc.localized("verification_photo_hint"))
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)

            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.Colors.accent.opacity(0.5), lineWidth: 2)
                        )
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .background(Circle().fill(AppTheme.Colors.accent))
                                .padding(12)
                        }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.rectangle.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.Colors.accent.opacity(0.6))

                        Text(loc.localized("verification_select_photo"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundColor(AppTheme.Colors.accent.opacity(0.3))
                    )
                    .background(AppTheme.Colors.accent.opacity(0.05))
                    .cornerRadius(16)
                }
            }
            .onChange(of: photoPickerItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Instagram Section
    private var instagramSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Instagram", systemImage: "camera.circle")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 10) {
                Text("@")
                    .foregroundColor(AppTheme.Colors.accent)
                    .font(.system(size: 16, weight: .bold))

                TextField("instagram_username", text: $instagram)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .autocapitalization(.none)
                    .font(.system(size: 14))
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(instagram.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Specialization Section
    private var specializationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Ixtisas", systemImage: "star.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(specializations, id: \.self) { spec in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSpecialization = spec
                            }
                        } label: {
                            Text(spec)
                                .font(.system(size: 13, weight: selectedSpecialization == spec ? .bold : .medium))
                                .foregroundColor(selectedSpecialization == spec ? .white : AppTheme.Colors.primaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedSpecialization == spec ? AppTheme.Colors.accent : AppTheme.Colors.secondaryBackground)
                                )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Experience Section
    private var experienceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tecrube", systemImage: "clock.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack {
                Text("\(experience) il")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .frame(width: 60)

                Slider(value: Binding(
                    get: { Double(experience) },
                    set: { experience = Int($0) }
                ), in: 1...30, step: 1)
                .tint(AppTheme.Colors.accent)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Bio Section
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Haqqinizda", systemImage: "text.alignleft")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            TextEditor(text: $bio)
                .foregroundColor(AppTheme.Colors.primaryText)
                .font(.system(size: 14))
                .frame(height: 100)
                .padding(8)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.separator, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if bio.isEmpty {
                        Text(loc.localized("verification_bio_placeholder"))
                            .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }

            Text("\(bio.count)/500")
                .font(.system(size: 11))
                .foregroundColor(bio.count > 500 ? AppTheme.Colors.error : AppTheme.Colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        VStack(spacing: 12) {
            Button {
                submitVerification()
            } label: {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 16))
                        Text(loc.localized("verification_submit"))
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: isFormValid ? [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.8)] : [Color.gray, Color.gray.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: isFormValid ? AppTheme.Colors.accent.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
            }
            .disabled(isLoading || !isFormValid)
            .padding(.horizontal, 20)

            if showError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.Colors.error)
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.primaryText)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.error.opacity(0.15))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Result View
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: statusIcon)
                    .font(.system(size: 50))
                    .foregroundColor(statusColor)
            }

            Text(statusTitle)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(resultMessage)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if resultScore > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 12))
                    Text("\(loc.localized("verification_ai_score")): \(Int(resultScore * 100))%")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(statusColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(statusColor.opacity(0.15))
                .cornerRadius(20)
            }

            Spacer()

            if resultStatus == "verified" {
                Button {
                    Task {
                        await authManager.fetchCurrentUser()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text(loc.localized("verification_continue"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.success)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            } else if resultStatus == "pending" {
                Button {
                    Task {
                        await authManager.fetchCurrentUser()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                        Text(loc.localized("verification_waiting"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            } else {
                Button {
                    withAnimation {
                        showResult = false
                        selectedImage = nil
                        showError = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text(loc.localized("verification_retry"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }

            Button {
                authManager.logout()
            } label: {
                Text(loc.localized("verification_logout"))
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            .padding(.bottom, 30)
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        selectedImage != nil &&
        !instagram.isEmpty &&
        bio.count <= 500
    }

    private var statusColor: Color {
        switch resultStatus {
        case "verified": return AppTheme.Colors.success
        case "pending": return AppTheme.Colors.accent
        default: return AppTheme.Colors.error
        }
    }

    private var statusIcon: String {
        switch resultStatus {
        case "verified": return "checkmark.seal.fill"
        case "pending": return "hourglass"
        default: return "xmark.circle.fill"
        }
    }

    private var statusTitle: String {
        switch resultStatus {
        case "verified": return "Dogrulandiniz!"
        case "pending": return "Gozden Kecirilir"
        default: return "Redd Edildi"
        }
    }

    // MARK: - Actions

    private func submitVerification() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            showErrorMsg(loc.localized("verification_select_photo_error"))
            return
        }

        isLoading = true
        showError = false

        var fields: [String: String] = [
            "instagram": instagram,
            "specialization": selectedSpecialization,
            "experience": "\(experience)",
        ]
        if !bio.isEmpty {
            fields["bio"] = bio
        }

        Task {
            do {
                let data = try await APIService.shared.uploadImageWithFields(
                    endpoint: "/api/v1/auth/verify-trainer",
                    imageData: imageData,
                    fields: fields
                )

                let decoder = JSONDecoder()
                let response = try decoder.decode(VerificationResponse.self, from: data)

                await MainActor.run {
                    isLoading = false
                    resultStatus = response.verificationStatus
                    resultMessage = response.message
                    resultScore = response.verificationScore ?? 0

                    withAnimation(.spring(response: 0.5)) {
                        showResult = true
                    }
                }
            } catch let error as APIError {
                await MainActor.run {
                    isLoading = false
                    showErrorMsg(error.errorDescription ?? "Xeta bas verdi")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showErrorMsg(error.localizedDescription)
                }
            }
        }
    }

    private func showErrorMsg(_ msg: String) {
        errorMessage = msg
        withAnimation {
            showError = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation {
                showError = false
            }
        }
    }
}

#Preview {
    TrainerVerificationView()
}
