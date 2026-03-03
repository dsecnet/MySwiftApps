import SwiftUI

// MARK: - Image Carousel
struct ImageCarousel: View {

    let imageURLs: [String]
    var height: CGFloat = 260
    var cornerRadius: CGFloat = AppTheme.CornerRadius.large

    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(imageURLs.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: imageURLs[index])) { phase in
                        switch phase {
                        case .empty:
                            shimmerPlaceholder
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            failurePlaceholder
                        @unknown default:
                            shimmerPlaceholder
                        }
                    }
                    .frame(height: height)
                    .clipped()
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

            // Page Indicator Dots
            if imageURLs.count > 1 {
                pageIndicator
                    .padding(.bottom, AppTheme.Spacing.md)
            }
        }
    }

    // MARK: - Page Indicator
    private var pageIndicator: some View {
        HStack(spacing: AppTheme.Spacing.xs + 2) {
            ForEach(imageURLs.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? AppTheme.Colors.accent : Color.white.opacity(0.5))
                    .frame(
                        width: index == currentIndex ? 20 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.4))
        )
    }

    // MARK: - Shimmer Placeholder
    private var shimmerPlaceholder: some View {
        Rectangle()
            .fill(AppTheme.Colors.cardBackgroundLight)
            .frame(height: height)
            .overlay(
                ProgressView()
                    .tint(AppTheme.Colors.accent)
            )
    }

    // MARK: - Failure Placeholder
    private var failurePlaceholder: some View {
        Rectangle()
            .fill(AppTheme.Colors.cardBackgroundLight)
            .frame(height: height)
            .overlay(
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    Text("error".localized)
                        .font(AppTheme.Fonts.small())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            )
    }
}

// MARK: - Preview
#Preview {
    ImageCarousel(
        imageURLs: [
            "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800",
            "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800",
            "https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800"
        ]
    )
    .padding()
    .background(AppTheme.Colors.background)
}
