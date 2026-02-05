import Foundation

extension Date {
    /// Convert date to "time ago" format (e.g., "2 hours ago", "3 days ago")
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: self, to: now)

        let loc = LocalizationManager.shared

        if let years = components.year, years > 0 {
            return years == 1 ? "1 \(loc.localized("time_year_ago"))" : "\(years) \(loc.localized("time_years_ago"))"
        }

        if let months = components.month, months > 0 {
            return months == 1 ? "1 \(loc.localized("time_month_ago"))" : "\(months) \(loc.localized("time_months_ago"))"
        }

        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1 \(loc.localized("time_week_ago"))" : "\(weeks) \(loc.localized("time_weeks_ago"))"
        }

        if let days = components.day, days > 0 {
            if days == 1 {
                return loc.localized("common_yesterday")
            }
            return "\(days) \(loc.localized("time_days_ago"))"
        }

        if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 \(loc.localized("time_hour_ago"))" : "\(hours) \(loc.localized("time_hours_ago"))"
        }

        if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 \(loc.localized("time_minute_ago"))" : "\(minutes) \(loc.localized("time_minutes_ago"))"
        }

        if let seconds = components.second, seconds > 30 {
            return "\(seconds) \(loc.localized("time_seconds_ago"))"
        }

        return loc.localized("time_just_now")
    }
}
