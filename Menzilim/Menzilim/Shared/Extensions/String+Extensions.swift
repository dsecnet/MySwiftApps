import Foundation

// MARK: - String Validation Extensions
extension String {

    // MARK: - Phone Number Validation
    /// Validates an Azerbaijani phone number format (+994XXXXXXXXX or 0XXXXXXXXX)
    var isValidAzerbaijaniPhone: Bool {
        let cleaned = self.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        // +994XXXXXXXXX format (12 digits with +)
        let internationalPattern = "^\\+994(50|51|55|70|77|99|10|12|18|20|21|22|23|24|25|26|36)\\d{7}$"
        // 0XXXXXXXXX format (10 digits)
        let localPattern = "^0(50|51|55|70|77|99|10|12|18|20|21|22|23|24|25|26|36)\\d{7}$"

        let internationalTest = NSPredicate(format: "SELF MATCHES %@", internationalPattern)
        let localTest = NSPredicate(format: "SELF MATCHES %@", localPattern)

        return internationalTest.evaluate(with: cleaned) || localTest.evaluate(with: cleaned)
    }

    // MARK: - Email Validation
    /// Validates a standard email address format
    var isValidEmail: Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: self)
    }

    // MARK: - Phone Formatting
    /// Formats a phone number string for display (e.g., "+994 50 123 45 67")
    var formattedPhoneNumber: String {
        var cleaned = self.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        // Normalize to +994 format
        if cleaned.hasPrefix("0") && cleaned.count == 10 {
            cleaned = "+994" + String(cleaned.dropFirst())
        }

        guard cleaned.hasPrefix("+994"), cleaned.count == 13 else {
            return self
        }

        let prefix = "+994"
        let remaining = String(cleaned.dropFirst(4))
        let operatorCode = String(remaining.prefix(2))
        let part1 = String(remaining.dropFirst(2).prefix(3))
        let part2 = String(remaining.dropFirst(5).prefix(2))
        let part3 = String(remaining.dropFirst(7).prefix(2))

        return "\(prefix) \(operatorCode) \(part1) \(part2) \(part3)"
    }

    // MARK: - Extract Digits Only
    /// Returns only digit characters from the string
    var digitsOnly: String {
        self.filter { $0.isNumber }
    }

    // MARK: - Trimmed
    /// Returns a trimmed version of the string with no leading/trailing whitespace
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Is Not Blank
    /// Returns true if the string contains non-whitespace characters
    var isNotBlank: Bool {
        !self.trimmed.isEmpty
    }

    // MARK: - Price Formatting
    /// Formats a numeric string as a price with thousand separators (e.g., "185,000")
    var formattedPrice: String {
        guard let number = Double(self.digitsOnly) else { return self }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? self
    }

    // MARK: - Area Formatting
    /// Formats area with unit suffix (e.g., "120 m²")
    var formattedArea: String {
        guard let number = Double(self) else { return self }
        let formatted = number.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", number)
            : String(format: "%.1f", number)
        return "\(formatted) m\u{00B2}"
    }

    // MARK: - Capitalized First Letter
    /// Returns the string with only the first letter capitalized
    var capitalizedFirst: String {
        guard let first = self.first else { return self }
        return String(first).uppercased() + self.dropFirst()
    }

    // MARK: - URL Encoding
    /// Returns a URL-safe encoded string
    var urlEncoded: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    // MARK: - Contains Only Digits
    /// Returns true if the string contains only numeric characters
    var isNumeric: Bool {
        !self.isEmpty && self.allSatisfy { $0.isNumber }
    }

    // MARK: - OTP Code Validation
    /// Validates that the string is a valid 6-digit OTP code
    var isValidOTPCode: Bool {
        self.count == 6 && self.isNumeric
    }

    // MARK: - Full Name Validation
    /// Validates that a full name has at least two parts and minimum length
    var isValidFullName: Bool {
        let parts = self.trimmed.split(separator: " ").filter { !$0.isEmpty }
        return parts.count >= 2 && self.trimmed.count >= 3
    }

    // MARK: - Listing Title Validation
    /// Validates a listing title has appropriate length
    var isValidListingTitle: Bool {
        let trimmed = self.trimmed
        return trimmed.count >= 5 && trimmed.count <= 200
    }

    // MARK: - Truncated
    /// Truncates the string to a maximum length, appending "..." if needed
    func truncated(to maxLength: Int) -> String {
        guard self.count > maxLength else { return self }
        let endIndex = self.index(self.startIndex, offsetBy: maxLength)
        return String(self[..<endIndex]) + "..."
    }
}
