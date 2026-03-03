import Foundation

// MARK: - Date Extensions
extension Date {

    // MARK: - Relative Time String
    /// Returns a human-readable relative time string (e.g., "5 dəq əvvəl", "2 saat əvvəl")
    var relativeTimeString: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        // Future dates
        if interval < 0 {
            return listingDateString
        }

        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        let weeks = days / 7
        let months = days / 30
        let years = days / 365

        if seconds < 60 {
            return "indicə"
        } else if minutes < 60 {
            return "\(minutes) dəq əvvəl"
        } else if hours < 24 {
            return "\(hours) saat əvvəl"
        } else if days == 1 {
            return "dünən"
        } else if days < 7 {
            return "\(days) gün əvvəl"
        } else if weeks < 4 {
            return "\(weeks) həftə əvvəl"
        } else if months < 12 {
            return "\(months) ay əvvəl"
        } else {
            return "\(years) il əvvəl"
        }
    }

    // MARK: - Listing Date Format
    /// Returns a formatted date suitable for listing display (e.g., "15 Yanvar 2025")
    var listingDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "az_AZ")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: self)
    }

    // MARK: - Short Date Format
    /// Returns a short formatted date (e.g., "15.01.2025")
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }

    // MARK: - Time Only
    /// Returns time only format (e.g., "14:30")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    // MARK: - Notification Date Format
    /// Returns a date string appropriate for notification display
    var notificationDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Bu gün, \(timeString)"
        } else if calendar.isDateInYesterday(self) {
            return "Dünən, \(timeString)"
        } else if calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "az_AZ")
            formatter.dateFormat = "EEEE, HH:mm"
            return formatter.string(from: self)
        } else {
            return "\(shortDateString), \(timeString)"
        }
    }

    // MARK: - ISO 8601 String
    /// Returns an ISO 8601 formatted date string for API requests
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }

    // MARK: - From ISO 8601
    /// Creates a Date from an ISO 8601 string
    static func fromISO8601(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }

    // MARK: - Boost Expiry Display
    /// Returns remaining time for boost expiration (e.g., "3 gün qalıb")
    var boostExpiryString: String? {
        let now = Date()
        guard self > now else { return nil }

        let interval = self.timeIntervalSince(now)
        let hours = Int(interval) / 3600
        let days = hours / 24

        if days > 0 {
            return "\(days) gün qalıb"
        } else if hours > 0 {
            return "\(hours) saat qalıb"
        } else {
            let minutes = Int(interval) / 60
            return "\(max(1, minutes)) dəq qalıb"
        }
    }

    // MARK: - Start of Day
    /// Returns the start of the day for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    // MARK: - Days Since
    /// Returns the number of days between this date and another date
    func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date.startOfDay, to: self.startOfDay)
        return components.day ?? 0
    }

    // MARK: - Member Since String
    /// Returns a "member since" style string (e.g., "Yanvar 2024-dən üzv")
    var memberSinceString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "az_AZ")
        formatter.dateFormat = "MMMM yyyy"
        return "\(formatter.string(from: self))-dən üzv"
    }
}
