//
//  ProfileComponents.swift
//  CoreVia
//
//  ProfileView üçün bütün komponentlər
//

import SwiftUI

// MARK: - Type Button
struct TypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.system(size: 14))
            .foregroundColor(isSelected ? .white : AppTheme.Colors.primaryText)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Client Stat Card (Compact)
struct ClientStatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(10)
    }
}

// MARK: - Trainer Stat Card
struct TrainerStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    var badge: String? = nil
    var badgeColor: Color = .gray
    var iconColor: Color? = nil
    var titleColor: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor ?? AppTheme.Colors.accent)
                    .frame(width: 24)

                Text(title)
                    .foregroundColor(titleColor ?? AppTheme.Colors.primaryText)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeColor.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .font(.caption)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }
}
