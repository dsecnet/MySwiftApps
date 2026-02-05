import SwiftUI

/// Reusable Filter Chip Component
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    var color: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(icon != nil ? .caption : .subheadline)
                    .fontWeight(isSelected ? .semibold : .bold)
            }
            .foregroundColor(isSelected ? .white : (color ?? Color("PrimaryColor")))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? (color ?? Color("PrimaryColor")) : (color ?? Color("PrimaryColor")).opacity(0.15))
            .cornerRadius(20)
        }
    }
}
