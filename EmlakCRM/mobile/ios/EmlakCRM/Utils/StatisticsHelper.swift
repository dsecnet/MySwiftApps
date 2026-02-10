import Foundation

struct StatisticsHelper {
    // MARK: - Property Statistics
    static func calculatePropertyStats(properties: [Property]) -> PropertyStats {
        let total = properties.count
        let available = properties.filter { $0.status == .available }.count
        let sold = properties.filter { $0.status == .sold }.count
        let rented = properties.filter { $0.status == .rented }.count
        let reserved = properties.filter { $0.status == .reserved }.count

        let forSale = properties.filter { $0.dealType == .sale }.count
        let forRent = properties.filter { $0.dealType == .rent }.count

        let totalValue = properties.reduce(0.0) { $0 + $1.price }
        let averagePrice = total > 0 ? totalValue / Double(total) : 0

        let totalArea = properties.compactMap { $0.areaSqm }.reduce(0.0, +)
        let averageArea = properties.compactMap { $0.areaSqm }.count > 0 ?
            totalArea / Double(properties.compactMap { $0.areaSqm }.count) : 0

        // Price per square meter
        let pricesPerSqm = properties.compactMap { property -> Double? in
            guard let area = property.areaSqm, area > 0 else { return nil }
            return property.price / area
        }
        let averagePricePerSqm = pricesPerSqm.isEmpty ? 0 : pricesPerSqm.reduce(0, +) / Double(pricesPerSqm.count)

        // Property type distribution
        let apartments = properties.filter { $0.propertyType == .apartment }.count
        let houses = properties.filter { $0.propertyType == .house }.count
        let offices = properties.filter { $0.propertyType == .office }.count
        let lands = properties.filter { $0.propertyType == .land }.count
        let commercial = properties.filter { $0.propertyType == .commercial }.count

        // City distribution
        let cityGroups = Dictionary(grouping: properties) { $0.city }
        let topCities = cityGroups.sorted { $0.value.count > $1.value.count }
            .prefix(5)
            .map { CityCount(city: $0.key, count: $0.value.count) }

        return PropertyStats(
            total: total,
            available: available,
            sold: sold,
            rented: rented,
            reserved: reserved,
            forSale: forSale,
            forRent: forRent,
            totalValue: totalValue,
            averagePrice: averagePrice,
            totalArea: totalArea,
            averageArea: averageArea,
            averagePricePerSqm: averagePricePerSqm,
            apartments: apartments,
            houses: houses,
            offices: offices,
            lands: lands,
            commercial: commercial,
            topCities: topCities
        )
    }

    // MARK: - Client Statistics
    static func calculateClientStats(clients: [Client]) -> ClientStats {
        let total = clients.count
        let active = clients.filter { $0.status == .active }.count
        let potential = clients.filter { $0.status == .potential }.count
        let inactive = clients.filter { $0.status == .inactive }.count

        let buyers = clients.filter { $0.clientType == .buyer }.count
        let sellers = clients.filter { $0.clientType == .seller }.count
        let renters = clients.filter { $0.clientType == .renter }.count
        let landlords = clients.filter { $0.clientType == .landlord }.count

        // Source distribution
        let sourceGroups = Dictionary(grouping: clients) { $0.source }
        let sourceDistribution = sourceGroups.mapValues { $0.count }

        // Recent additions (last 7 days)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentClients = clients.filter { $0.createdAt >= sevenDaysAgo }.count

        return ClientStats(
            total: total,
            active: active,
            potential: potential,
            inactive: inactive,
            buyers: buyers,
            sellers: sellers,
            renters: renters,
            landlords: landlords,
            sourceDistribution: sourceDistribution,
            recentAdditions: recentClients
        )
    }

    // MARK: - Deal Statistics
    static func calculateDealStats(deals: [Deal]) -> DealStats {
        let total = deals.count
        let pending = deals.filter { $0.status == .pending }.count
        let inProgress = deals.filter { $0.status == .inProgress }.count
        let completed = deals.filter { $0.status == .completed }.count
        let cancelled = deals.filter { $0.status == .cancelled }.count

        let totalValue = deals.reduce(0.0) { $0 + $1.agreedPrice }
        let completedValue = deals.filter { $0.status == .completed }.reduce(0.0) { $0 + $1.agreedPrice }
        let averageDealValue = total > 0 ? totalValue / Double(total) : 0

        let conversionRate = total > 0 ? Double(completed) / Double(total) * 100 : 0

        // This month stats
        let calendar = Calendar.current
        let thisMonth = deals.filter { calendar.isDate($0.createdAt, equalTo: Date(), toGranularity: .month) }
        let thisMonthCount = thisMonth.count
        let thisMonthValue = thisMonth.reduce(0.0) { $0 + $1.agreedPrice }

        return DealStats(
            total: total,
            pending: pending,
            inProgress: inProgress,
            completed: completed,
            cancelled: cancelled,
            totalValue: totalValue,
            completedValue: completedValue,
            averageDealValue: averageDealValue,
            conversionRate: conversionRate,
            thisMonthCount: thisMonthCount,
            thisMonthValue: thisMonthValue
        )
    }

    // MARK: - Activity Statistics
    static func calculateActivityStats(activities: [Activity]) -> ActivityStats {
        let total = activities.count
        let completed = activities.filter { $0.completedAt != nil }.count
        let pending = activities.filter { $0.completedAt == nil }.count

        let completionRate = total > 0 ? Double(completed) / Double(total) * 100 : 0

        // Type distribution
        let calls = activities.filter { $0.activityType == .call }.count
        let meetings = activities.filter { $0.activityType == .meeting }.count
        let emails = activities.filter { $0.activityType == .email }.count
        let viewings = activities.filter { $0.activityType == .viewing }.count
        let messages = activities.filter { $0.activityType == .message }.count
        let notes = activities.filter { $0.activityType == .note }.count

        // This week stats
        let calendar = Calendar.current
        let thisWeek = activities.filter { calendar.isDate($0.createdAt, equalTo: Date(), toGranularity: .weekOfYear) }
        let thisWeekCount = thisWeek.count
        let thisWeekCompleted = thisWeek.filter { $0.completedAt != nil }.count

        // Upcoming activities
        let upcoming = activities.filter { activity in
            guard let scheduledAt = activity.scheduledAt else { return false }
            return scheduledAt > Date() && activity.completedAt == nil
        }.count

        return ActivityStats(
            total: total,
            completed: completed,
            pending: pending,
            completionRate: completionRate,
            calls: calls,
            meetings: meetings,
            emails: emails,
            viewings: viewings,
            messages: messages,
            notes: notes,
            thisWeekCount: thisWeekCount,
            thisWeekCompleted: thisWeekCompleted,
            upcoming: upcoming
        )
    }
}

// MARK: - Stats Models
struct PropertyStats {
    let total: Int
    let available: Int
    let sold: Int
    let rented: Int
    let reserved: Int
    let forSale: Int
    let forRent: Int
    let totalValue: Double
    let averagePrice: Double
    let totalArea: Double
    let averageArea: Double
    let averagePricePerSqm: Double
    let apartments: Int
    let houses: Int
    let offices: Int
    let lands: Int
    let commercial: Int
    let topCities: [CityCount]
}

struct ClientStats {
    let total: Int
    let active: Int
    let potential: Int
    let inactive: Int
    let buyers: Int
    let sellers: Int
    let renters: Int
    let landlords: Int
    let sourceDistribution: [ClientSource: Int]
    let recentAdditions: Int
}

struct DealStats {
    let total: Int
    let pending: Int
    let inProgress: Int
    let completed: Int
    let cancelled: Int
    let totalValue: Double
    let completedValue: Double
    let averageDealValue: Double
    let conversionRate: Double
    let thisMonthCount: Int
    let thisMonthValue: Double
}

struct ActivityStats {
    let total: Int
    let completed: Int
    let pending: Int
    let completionRate: Double
    let calls: Int
    let meetings: Int
    let emails: Int
    let viewings: Int
    let messages: Int
    let notes: Int
    let thisWeekCount: Int
    let thisWeekCompleted: Int
    let upcoming: Int
}

struct CityCount {
    let city: String
    let count: Int
}
