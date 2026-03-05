//
//  ClientSettingsView.swift
//  CoreVia
//
//  Client/Telebe ucun settings sheet — Bildirisl, Tehlukesizlik, Premium, Haqqinda, Hesabi Sil
//

import SwiftUI

struct ClientSettingsView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject private var loc = LocalizationManager.shared
    @StateObject private var settingsManager = SettingsManager.shared

    // Navigation states
    @State private var showNotifications = false
    @State private var showSecurity = false
    @State private var showPremium = false
    @State private var showAbout = false

    // Delete Account
    @State private var showDeleteAccountAlert = false
    @State private var showDeletePasswordSheet = false
    @State private var deletePassword: String = ""
    @State private var deleteError: String? = nil
    @State private var isDeleting: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Notifications
                        SettingsRow(
                            icon: "bell.fill",
                            title: loc.localized("settings_notifications"),
                            badge: settingsManager.notificationsEnabled ? loc.localized("common_active") : nil,
                            badgeColor: AppTheme.Colors.success
                        ) {
                            showNotifications = true
                        }

                        // Security
                        SettingsRow(
                            icon: "lock.fill",
                            title: loc.localized("settings_security"),
                            badge: settingsManager.faceIDEnabled || settingsManager.hasAppPassword ? "ON" : nil,
                            badgeColor: AppTheme.Colors.accent
                        ) {
                            showSecurity = true
                        }

                        // Premium
                        SettingsRow(
                            icon: "sparkles",
                            title: loc.localized("settings_premium"),
                            badge: settingsManager.isPremium ? loc.localized("premium_active_badge") : nil,
                            badgeColor: settingsManager.isPremium ? AppTheme.Colors.success : AppTheme.Colors.accentDark
                        ) {
                            showPremium = true
                        }

                        // About
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: loc.localized("settings_about")
                        ) {
                            showAbout = true
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Delete Account
                        SettingsRow(
                            icon: "trash.fill",
                            title: loc.localized("delete_account_title"),
                            iconColor: AppTheme.Colors.error,
                            titleColor: AppTheme.Colors.error
                        ) {
                            showDeleteAccountAlert = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(loc.localized("profile_settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsSettingsView()
            }
            .sheet(isPresented: $showSecurity) {
                SecuritySettingsView()
            }
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .alert(loc.localized("delete_account_title"), isPresented: $showDeleteAccountAlert) {
                Button(loc.localized("common_cancel"), role: .cancel) { }
                Button(loc.localized("common_delete"), role: .destructive) {
                    showDeletePasswordSheet = true
                }
            } message: {
                Text(loc.localized("delete_account_warning"))
            }
            .sheet(isPresented: $showDeletePasswordSheet) {
                DeleteAccountSheet(
                    password: $deletePassword,
                    error: $deleteError,
                    isDeleting: $isDeleting
                ) {
                    Task {
                        isDeleting = true
                        deleteError = nil
                        let result = await AuthManager.shared.deleteAccount(password: deletePassword)
                        isDeleting = false
                        if result.success {
                            showDeletePasswordSheet = false
                            deletePassword = ""
                            dismiss()
                        } else {
                            deleteError = result.error ?? loc.localized("delete_account_error")
                        }
                    }
                }
            }
        }
    }
}
