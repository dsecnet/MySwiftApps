//
//  Models.swift
//  EmlakCRM
//
//  Data Models
//

import Foundation

// MARK: - Auth Models

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let phone: String
    let password: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let role: String
    let subscriptionPlan: String
    let totalProperties: Int
    let totalClients: Int
    let createdAt: Date
}

// MARK: - Property Models

struct Property: Codable, Identifiable {
    let id: String
    let agentId: String
    let title: String
    let propertyType: String
    let dealType: String
    let status: String
    let price: Double
    let currency: String
    let area: Double?
    let rooms: Int?
    let floor: Int?
    let city: String
    let district: String?
    let address: String?
    let description: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: Date
    let updatedAt: Date
}

struct PropertyCreate: Codable {
    let title: String
    let propertyType: String
    let dealType: String
    let price: Double
    let currency: String
    let area: Double?
    let rooms: Int?
    let floor: Int?
    let city: String
    let district: String?
    let address: String?
    let description: String?
}

struct PropertyListResponse: Codable {
    let properties: [Property]
    let total: Int
    let page: Int
    let totalPages: Int
}

struct PropertyStatsResponse: Codable {
    let totalProperties: Int
    let byStatus: [String: Int]
    let byType: [String: Int]
    let byCity: [String: Int]
    let avgPrice: Double
}

// MARK: - Client Models

struct Client: Codable, Identifiable {
    let id: String
    let agentId: String
    let name: String
    let phone: String
    let email: String?
    let clientType: String
    let leadStatus: String
    let budget: Double?
    let tags: [String]?
    let notes: String?
    let createdAt: Date
}

struct ClientCreate: Codable {
    let name: String
    let phone: String
    let email: String?
    let clientType: String
    let budget: Double?
    let tags: [String]?
    let notes: String?
}

struct ClientListResponse: Codable {
    let clients: [Client]
    let total: Int
    let page: Int
    let totalPages: Int
}

struct ClientStatsResponse: Codable {
    let totalClients: Int
    let byType: [String: Int]
    let byStatus: [String: Int]
    let hotLeads: Int
    let conversionRate: Double
}

// MARK: - Activity Models

struct Activity: Codable, Identifiable {
    let id: String
    let agentId: String
    let clientId: String?
    let propertyId: String?
    let activityType: String
    let status: String
    let title: String
    let description: String?
    let scheduledAt: Date?
    let completedAt: Date?
    let location: String?
    let createdAt: Date
}

struct ActivityCreate: Codable {
    let activityType: String
    let title: String
    let description: String?
    let clientId: String?
    let propertyId: String?
    let scheduledAt: Date?
    let location: String?
}

struct ActivityListResponse: Codable {
    let activities: [Activity]
    let total: Int
    let page: Int
    let totalPages: Int
}

// MARK: - Deal Models

struct Deal: Codable, Identifiable {
    let id: String
    let agentId: String
    let propertyId: String
    let clientId: String
    let status: String
    let agreedPrice: Double
    let currency: String
    let commissionPercentage: Double?
    let commissionAmount: Double?
    let depositAmount: Double?
    let notes: String?
    let createdAt: Date
    let closedAt: Date?
}

struct DealWithDetails: Codable, Identifiable {
    let id: String
    let agentId: String
    let propertyId: String
    let clientId: String
    let status: String
    let agreedPrice: Double
    let currency: String
    let commissionPercentage: Double?
    let commissionAmount: Double?
    let propertyTitle: String?
    let propertyAddress: String?
    let clientName: String?
    let clientPhone: String?
    let createdAt: Date
}

struct DealCreate: Codable {
    let propertyId: String
    let clientId: String
    let agreedPrice: Double
    let currency: String
    let commissionPercentage: Double?
    let depositAmount: Double?
    let notes: String?
}

struct DealStatsResponse: Codable {
    let totalDeals: Int
    let byStatus: [String: Int]
    let totalRevenue: Double
    let totalCommission: Double
    let avgDealValue: Double
    let thisMonthRevenue: Double
    let thisMonthCommission: Double
    let conversionRate: Double
}

// MARK: - Dashboard Models

struct DashboardStats: Codable {
    let totalProperties: Int
    let totalClients: Int
    let totalActivities: Int
    let totalDeals: Int

    let propertiesForSale: Int
    let propertiesForRent: Int
    let propertiesSold: Int

    let activeClients: Int
    let hotLeads: Int
    let conversionRate: Double

    let upcomingActivities: Int
    let todayActivities: Int
    let overdueActivities: Int

    let pendingDeals: Int
    let completedDeals: Int
    let totalRevenue: Double
    let totalCommission: Double
    let thisMonthRevenue: Double
    let thisMonthCommission: Double

    let avgPropertyPrice: Double
    let avgDealValue: Double
    let dealConversionRate: Double
}

struct RecentActivity: Codable, Identifiable {
    let id = UUID()
    let type: String
    let title: String
    let description: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case type, title, description, createdAt
    }
}

struct DashboardResponse: Codable {
    let stats: DashboardStats
    let recentActivities: [RecentActivity]
}
