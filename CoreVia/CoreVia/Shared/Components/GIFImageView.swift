//
//  ExerciseImageView.swift
//  CoreVia
//
//  Məşq şəkilləri üçün async image loader (GitHub CDN)
//

import SwiftUI

// MARK: - Exercise Image View
struct ExerciseImageView: View {
    let url: URL?
    var cornerRadius: CGFloat = 12

    var body: some View {
        Group {
            if let url = url, !url.absoluteString.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        failedView
                    case .empty:
                        loadingView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var loadingView: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
            VStack(spacing: 6) {
                ProgressView()
                    .controlSize(.small)
            }
        }
    }

    private var placeholderView: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.tertiaryText)
        }
    }

    private var failedView: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
            VStack(spacing: 4) {
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.tertiaryText)
            }
        }
    }
}
