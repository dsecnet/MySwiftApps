//
//  AICalorieAnalysisView.swift
//  CoreVia
//
//  AI Kalori analiz ekrani — foto cek, backend ML analiz etsin
//  Movcut app dizaynina tam uygun (AppTheme, card radius, shadow)
//

import SwiftUI
import PhotosUI
import AVFoundation
import os.log

struct AICalorieAnalysisView: View {
    @StateObject private var viewModel = AICalorieViewModel()
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    headerCard

                    // Photo Section
                    photoSection

                    // Analyze Button
                    if viewModel.selectedImage != nil && viewModel.result == nil {
                        analyzeButton
                    }

                    // Loading
                    if viewModel.isAnalyzing {
                        analyzingView
                    }

                    // Result
                    if let result = viewModel.result {
                        resultView(result)
                    }

                    // Error
                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(loc.localized("ai_calorie_title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.accent)

            Text(loc.localized("ai_calorie_header"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)

            Text(loc.localized("ai_calorie_desc"))
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(AppTheme.Colors.accent.opacity(0.08))
        )
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(spacing: 12) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                // Change photo button
                Button {
                    viewModel.resetAnalysis()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                        Text(loc.localized("ai_calorie_change_photo"))
                    }
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.accent)
                }
            } else {
                // Photo picker buttons
                HStack(spacing: 16) {
                    // Camera
                    PhotoOptionButton(
                        icon: "camera.fill",
                        title: loc.localized("ai_calorie_camera"),
                        action: { viewModel.checkCameraPermission() }
                    )

                    // Gallery
                    PhotoOptionButton(
                        icon: "photo.on.rectangle",
                        title: loc.localized("ai_calorie_gallery"),
                        action: { viewModel.showPhotoPicker = true }
                    )
                }
            }
        }
        .sheet(isPresented: $viewModel.showCamera) {
            ImagePickerView(image: $viewModel.selectedImage, sourceType: .camera)
        }
        .alert("Kamera İcazəsi", isPresented: $viewModel.showCameraPermissionAlert) {
            Button("Ayarlara Keç") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Ləğv et", role: .cancel) {}
        } message: {
            Text("Kamera istifadəsi üçün icazə lazımdır. Ayarlardan aktiv edin.")
        }
        .photosPicker(isPresented: $viewModel.showPhotoPicker, selection: $viewModel.photosPickerItem, matching: .images)
        .onChange(of: viewModel.photosPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.selectedImage = uiImage
                }
            }
        }
    }

    // MARK: - Analyze Button

    private var analyzeButton: some View {
        Button {
            Task { await viewModel.analyzeFood() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text(loc.localized("ai_calorie_analyze"))
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.accent, AppTheme.Colors.accentDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppTheme.CornerRadius.md)
            .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Analyzing View

    private var analyzingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(AppTheme.Colors.accent)

            Text(loc.localized("ai_calorie_analyzing"))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .padding(.vertical, 30)
    }

    // MARK: - Result View

    private func resultView(_ result: AICalorieResult) -> some View {
        VStack(spacing: 16) {
            // Total Macros Card
            macrosCard(result)

            // Detected Foods
            VStack(alignment: .leading, spacing: 12) {
                Text(loc.localized("ai_calorie_detected_foods"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                ForEach(result.foods, id: \.stableId) { food in
                    foodItemRow(food)
                }
            }

            // Confidence
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppTheme.Colors.success)
                Text("\(loc.localized("ai_calorie_confidence")): \(Int(result.confidence * 100))%")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Macros Card

    private func macrosCard(_ result: AICalorieResult) -> some View {
        VStack(spacing: 16) {
            // Total Calories
            Text("\(Int(result.totalCalories))")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(AppTheme.Colors.accent)
            + Text(" kcal")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppTheme.Colors.secondaryText)

            // Macros Grid
            HStack(spacing: 0) {
                macroItem(
                    title: "Protein",
                    value: "\(Int(result.totalProtein))g",
                    color: Color.blue
                )
                macroItem(
                    title: "Karb",
                    value: "\(Int(result.totalCarbs))g",
                    color: .orange
                )
                macroItem(
                    title: "Yag",
                    value: "\(Int(result.totalFat))g",
                    color: Color.purple
                )
            }
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    private func macroItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(value)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color)
                )

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Food Item Row

    private func foodItemRow(_ food: DetectedFood) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppTheme.Colors.accent.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.accent)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text("\(Int(food.portionGrams))g")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            Spacer()

            Text("\(Int(food.calories)) kcal")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.Colors.accent)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.md)
    }

    // MARK: - Error View

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30))
                .foregroundColor(AppTheme.Colors.error)

            Text(error)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.error)
                .multilineTextAlignment(.center)

            Button {
                viewModel.errorMessage = nil
            } label: {
                Text(loc.localized("common_ok"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(AppTheme.CornerRadius.sm)
            }
        }
        .padding()
        .background(AppTheme.Colors.error.opacity(0.08))
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
}

// MARK: - Photo Option Button

struct PhotoOptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(AppTheme.Colors.accent)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .strokeBorder(AppTheme.Colors.accent.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [8]))
            )
        }
    }
}

// MARK: - Image Picker (UIKit Bridge)

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - ViewModel

@MainActor
class AICalorieViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var result: AICalorieResult?
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var showCamera = false
    @Published var showCameraPermissionAlert = false
    @Published var showPhotoPicker = false
    @Published var photosPickerItem: PhotosPickerItem?

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { self.showCamera = true }
                    else { self.showCameraPermissionAlert = true }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert = true
        @unknown default:
            showCameraPermissionAlert = true
        }
    }

    func analyzeFood() async {
        guard let image = selectedImage else { return }
        isAnalyzing = true
        errorMessage = nil

        do {
            result = try await AICalorieService.shared.analyzeFood(image: image)
        } catch {
            AppLogger.food.error("AI calorie analysis xetasi: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    func resetAnalysis() {
        selectedImage = nil
        result = nil
        errorMessage = nil
        photosPickerItem = nil
    }
}
