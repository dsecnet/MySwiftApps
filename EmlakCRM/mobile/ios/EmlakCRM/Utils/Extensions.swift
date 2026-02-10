import SwiftUI
import Foundation

// MARK: - Date Extensions
extension Date {
    func toFormattedString(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "az_AZ")
        return formatter.string(from: self)
    }

    func toFullString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "az_AZ")
        return formatter.string(from: self)
    }

    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: now)

        if let year = components.year, year > 0 {
            return "\(year) il əvvəl"
        }
        if let month = components.month, month > 0 {
            return "\(month) ay əvvəl"
        }
        if let day = components.day, day > 0 {
            return "\(day) gün əvvəl"
        }
        if let hour = components.hour, hour > 0 {
            return "\(hour) saat əvvəl"
        }
        if let minute = components.minute, minute > 0 {
            return "\(minute) dəqiqə əvvəl"
        }
        return "İndicə"
    }
}

// MARK: - Double Extensions
extension Double {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AZN"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self)) ₼"
    }

    func toArea() -> String {
        return "\(Int(self)) m²"
    }

    func toCompactString() -> String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", self / 1_000_000)
        } else if self >= 1000 {
            return String(format: "%.1fK", self / 1000)
        }
        return String(format: "%.0f", self)
    }
}

// MARK: - String Extensions
extension String {
    func toPhoneFormat() -> String {
        let cleaned = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)

        guard cleaned.count >= 9 else { return self }

        let areaCode = String(cleaned.prefix(3))
        let middle = String(cleaned.dropFirst(3).prefix(3))
        let last = String(cleaned.dropFirst(6).prefix(4))

        return "(\(areaCode)) \(middle)-\(last)"
    }

    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    var isValidPhone: Bool {
        let phoneRegex = "^[0-9]{9,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Array Extensions
extension Array where Element: Identifiable {
    func unique() -> [Element] {
        var seen = Set<Element.ID>()
        return filter { seen.insert($0.id).inserted }
    }
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Haptic Feedback
enum HapticFeedback {
    case success
    case warning
    case error
    case light
    case medium
    case heavy

    func trigger() {
        switch self {
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}
