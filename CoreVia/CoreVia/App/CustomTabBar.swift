//
//  CustomTabBar.swift
//  CoreVia
//
//  Custom Tab Bar with glassmorphism effect for 5+ tabs
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let isTrainer: Bool
    @ObservedObject private var loc = LocalizationManager.shared
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            // Home
            TabBarItem(
                icon: "house.fill",
                title: loc.localized("tab_home"),
                index: 0,
                selectedTab: $selectedTab,
                animation: animation
            )

            // Workout/Plans
            TabBarItem(
                icon: "figure.strengthtraining.traditional",
                title: isTrainer ? loc.localized("tab_plans") : loc.localized("tab_workout"),
                index: 1,
                selectedTab: $selectedTab,
                animation: animation
            )

            // Food/Meal Plans
            TabBarItem(
                icon: "fork.knife",
                title: isTrainer ? loc.localized("tab_meal_plans") : loc.localized("tab_food"),
                index: 2,
                selectedTab: $selectedTab,
                animation: animation
            )

            // Chat
            TabBarItem(
                icon: "bubble.left.and.bubble.right",
                title: loc.localized("chat_title"),
                index: 3,
                selectedTab: $selectedTab,
                animation: animation
            )

            // More - with glassmorphism
            TabBarMoreButton(
                icon: "ellipsis.circle.fill",
                title: loc.localized("tab_more"),
                index: 4,
                selectedTab: $selectedTab,
                animation: animation,
                isTrainer: isTrainer
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Glassmorphism background
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)

                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.accent.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    let animation: Namespace.ID

    var isSelected: Bool {
        selectedTab == index
    }

    var body: some View {
        Button {
            withAnimation(.spring()) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(AppTheme.Colors.accent)
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                    }

                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 20 : 18))
                        .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
                }
                .frame(height: 40)

                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct TabBarMoreButton: View {
    let icon: String
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    let animation: Namespace.ID
    let isTrainer: Bool
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var showMoreSheet = false

    var isSelected: Bool {
        selectedTab >= index
    }

    var body: some View {
        Button {
            showMoreSheet = true
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.Colors.accent, AppTheme.Colors.accentDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                    }

                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 20 : 18))
                        .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
                }
                .frame(height: 40)

                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showMoreSheet) {
            MoreMenuSheet(selectedTab: $selectedTab, isTrainer: isTrainer)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - More Menu Sheet with Glassmorphism
struct MoreMenuSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Int
    let isTrainer: Bool
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    AppTheme.Colors.background,
                    AppTheme.Colors.accent.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header with reflection effect
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.Colors.accent.opacity(0.2), AppTheme.Colors.accentDark.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)

                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 28))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppTheme.Colors.accent, AppTheme.Colors.accentDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 15, x: 0, y: 8)
                    }

                    Text(loc.localized("tab_more"))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                }
                .padding(.top, 20)

                // Menu Items with reflection cards
                VStack(spacing: 16) {
                    // Activities / Content
                    MoreMenuItem(
                        icon: isTrainer ? "doc.richtext" : "figure.run",
                        title: isTrainer ? loc.localized("content_title") : loc.localized("activities_title"),
                        description: isTrainer ? loc.localized("content_subtitle") : loc.localized("activities_subtitle"),
                        gradient: [AppTheme.Colors.accent, AppTheme.Colors.accentDark]
                    ) {
                        selectedTab = 4
                        dismiss()
                    }

                    // Profile
                    MoreMenuItem(
                        icon: "person.fill",
                        title: loc.localized("tab_profile"),
                        description: loc.localized("profile_subtitle"),
                        gradient: [AppTheme.Colors.success, AppTheme.Colors.success.opacity(0.7)]
                    ) {
                        selectedTab = 5
                        dismiss()
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}

struct MoreMenuItem: View {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                // Icon with glassmorphism
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [gradient[0].opacity(0.2), gradient[1].opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.tertiaryText)
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: gradient[0].opacity(0.2), radius: 12, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}
