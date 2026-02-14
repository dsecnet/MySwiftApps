//
//  PermissionsView.swift
//  CoreVia
//
//  İlk açılışda location, camera və photo library permissions
//

import SwiftUI
import CoreLocation
import AVFoundation
import Photos

struct PermissionsView: View {
    @ObservedObject private var locationManager = LocationManager.shared
    @Binding var isGranted: Bool

    @State private var currentStep = 0 // 0: Location, 1: Camera, 2: Photos
    @State private var hasRequestedLocation = false
    @State private var hasRequestedCamera = false
    @State private var hasRequestedPhotos = false

    private let totalSteps = 3

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    AppTheme.Colors.accent.opacity(0.1),
                    AppTheme.Colors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.accent.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Image(systemName: iconForStep)
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.accent, AppTheme.Colors.accentDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.bottom, 20)

                // Title & Description
                VStack(spacing: 16) {
                    Text(titleForStep)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(descriptionForStep)
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                Spacer()

                // Buttons
                VStack(spacing: 16) {
                    // Allow Button
                    Button {
                        handleAllowTap()
                    } label: {
                        HStack {
                            Text("İcazə Ver")
                                .font(.system(size: 18, weight: .semibold))

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.Colors.accent, AppTheme.Colors.accentDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }

                    // Skip Button
                    Button {
                        goToNextStep()
                    } label: {
                        Text("Keç")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            if hasRequestedLocation && currentStep == 0 {
                // Location permission response
                if status == .authorizedWhenInUse || status == .authorizedAlways ||
                   status == .denied || status == .restricted {
                    goToNextStep()
                }
            }
        }
    }

    // MARK: - Step Content

    private var iconForStep: String {
        switch currentStep {
        case 0: return "location.fill"
        case 1: return "camera.fill"
        case 2: return "photo.fill"
        default: return "checkmark.circle.fill"
        }
    }

    private var titleForStep: String {
        switch currentStep {
        case 0: return "Lokasiya İcazəsi"
        case 1: return "Kamera İcazəsi"
        case 2: return "Şəkillər İcazəsi"
        default: return "Hazırsınız!"
        }
    }

    private var descriptionForStep: String {
        switch currentStep {
        case 0: return "Hərəkətlərinizi izləmək və marşrutları qeyd etmək üçün lokasiya icazəsi lazımdır."
        case 1: return "Qida şəkillərini çəkmək və AI analizi üçün kamera icazəsi tələb olunur."
        case 2: return "Foto kitabxanadan şəkil seçmək və yükləmək üçün icazə lazımdır."
        default: return "Bütün icazələr verildi!"
        }
    }

    // MARK: - Permission Requests

    private func handleAllowTap() {
        switch currentStep {
        case 0:
            requestLocationPermission()
        case 1:
            requestCameraPermission()
        case 2:
            requestPhotosPermission()
        default:
            completePermissions()
        }
    }

    private func requestLocationPermission() {
        hasRequestedLocation = true
        locationManager.requestPermission()

        // Əgər artıq icazə varsa, birbaşa keç
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            goToNextStep()
        }
    }

    private func requestCameraPermission() {
        hasRequestedCamera = true

        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                goToNextStep()
            }
        }
    }

    private func requestPhotosPermission() {
        hasRequestedPhotos = true

        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completePermissions()
            }
        }
    }

    private func goToNextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            completePermissions()
        }
    }

    private func completePermissions() {
        // Permission flow tamamlandı
        UserDefaults.standard.set(true, forKey: "hasSeenPermissions")
        isGranted = true
    }
}
