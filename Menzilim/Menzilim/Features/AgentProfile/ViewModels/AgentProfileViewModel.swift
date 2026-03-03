import SwiftUI
import Combine

// MARK: - Agent Profile ViewModel
@MainActor
class AgentProfileViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var agent: Agent
    @Published var listings: [Listing] = []
    @Published var reviews: [Review] = []
    @Published var isFollowing: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedTab: AgentProfileTab = .grid
    @Published var followersCount: Int = 1247

    // MARK: - Review Stats
    @Published var averageRating: Double = 4.7
    @Published var totalReviewsCount: Int = 128
    @Published var ratingDistribution: [Int: Int] = [5: 82, 4: 28, 3: 12, 2: 4, 1: 2]

    // MARK: - Tab Options
    enum AgentProfileTab: String, CaseIterable {
        case grid
        case reviews
    }

    // MARK: - Init
    init(agent: Agent? = nil) {
        self.agent = agent ?? Self.mockAgent
        loadMockData()
    }

    // MARK: - Actions
    func toggleFollow() {
        isFollowing.toggle()
        followersCount += isFollowing ? 1 : -1
    }

    func likeReview(_ reviewId: String) {
        // Handle review like
    }

    // MARK: - Load Mock Data
    private func loadMockData() {
        listings = Self.mockListings
        reviews = Self.mockReviews
    }

    // MARK: - Mock Agent
    static let mockAgent: Agent = Agent(
        id: "agent_001",
        userId: "user_001",
        companyName: "Baku Premium Realty",
        licenseNumber: "AZ-2024-001",
        level: .expert,
        rating: 4.7,
        totalReviews: 128,
        totalListings: 45,
        totalSales: 312,
        bio: "10+ il təcrübəsi olan peşəkar daşınmaz əmlak agenti. Bakının mərkəzi rayonlarında mənzil və villalar üzrə ixtisaslaşmışam.",
        isPremium: true,
        premiumExpiresAt: nil,
        user: User(
            id: "user_001",
            phone: "+994501234567",
            email: "elvin.mammadov@bakurealty.az",
            fullName: "Elvin Məmmədov",
            avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
            role: .agent,
            isVerified: true,
            createdAt: nil,
            updatedAt: nil
        )
    )

    // MARK: - Mock Listings
    static let mockListings: [Listing] = [
        Listing(
            id: "l1", userId: "user_001", agentId: "agent_001",
            title: "Dəniz mənzərəli lüks mənzil",
            description: "Port Baku Residence-da 3 otaqlı mənzil",
            listingType: .sale, propertyType: .apartment,
            price: 450000, currency: .AZN,
            city: "Bakı", district: "Nəsimi", address: "Port Baku, 14-cü mərtəbə",
            latitude: 40.3725, longitude: 49.8431,
            rooms: 3, areaSqm: 145, floor: 14, totalFloors: 22,
            renovation: .excellent,
            images: ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400"],
            videoUrl: nil, status: .active, viewsCount: 1245,
            isBoosted: true, boostType: .vip
        ),
        Listing(
            id: "l2", userId: "user_001", agentId: "agent_001",
            title: "Yeni tikili studio mənzil",
            description: "Xətai rayonunda yeni tikili studio",
            listingType: .sale, propertyType: .apartment,
            price: 85000, currency: .AZN,
            city: "Bakı", district: "Xətai", address: "Babək pr., 42",
            latitude: 40.3880, longitude: 49.8692,
            rooms: 1, areaSqm: 52, floor: 8, totalFloors: 16,
            renovation: .good,
            images: ["https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400"],
            videoUrl: nil, status: .active, viewsCount: 834,
            isBoosted: false
        ),
        Listing(
            id: "l3", userId: "user_001", agentId: "agent_001",
            title: "Həyət evi Mərdəkan",
            description: "Mərdəkanda geniş həyət evi",
            listingType: .sale, propertyType: .house,
            price: 320000, currency: .AZN,
            city: "Bakı", district: "Mərdəkan", address: "Dəniz küçəsi, 15",
            latitude: 40.4956, longitude: 50.1487,
            rooms: 5, areaSqm: 280, floor: 2, totalFloors: 2,
            renovation: .excellent,
            images: ["https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400"],
            videoUrl: nil, status: .active, viewsCount: 567,
            isBoosted: false
        ),
        Listing(
            id: "l4", userId: "user_001", agentId: "agent_001",
            title: "Ofis sahəsi Nərimanov",
            description: "Nərimanov rayonunda ofis",
            listingType: .rent, propertyType: .office,
            price: 2500, currency: .AZN,
            city: "Bakı", district: "Nərimanov", address: "Təbriz küçəsi, 8",
            latitude: 40.4093, longitude: 49.8671,
            rooms: 4, areaSqm: 120, floor: 5, totalFloors: 12,
            renovation: .good,
            images: ["https://images.unsplash.com/photo-1497366216548-37526070297c?w=400"],
            videoUrl: nil, status: .active, viewsCount: 423,
            isBoosted: false
        ),
        Listing(
            id: "l5", userId: "user_001", agentId: "agent_001",
            title: "Villa Şüvəlan",
            description: "Şüvəlanda dənizə yaxın villa",
            listingType: .sale, propertyType: .villa,
            price: 780000, currency: .AZN,
            city: "Bakı", district: "Şüvəlan", address: "Sahil küçəsi, 3",
            latitude: 40.5241, longitude: 50.1821,
            rooms: 6, areaSqm: 450, floor: 3, totalFloors: 3,
            renovation: .excellent,
            images: ["https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=400"],
            videoUrl: nil, status: .active, viewsCount: 892,
            isBoosted: true, boostType: .premium
        ),
        Listing(
            id: "l6", userId: "user_001", agentId: "agent_001",
            title: "2 otaqlı mənzil Yasamal",
            description: "Yasamal rayonunda 2 otaqlı mənzil",
            listingType: .sale, propertyType: .apartment,
            price: 135000, currency: .AZN,
            city: "Bakı", district: "Yasamal", address: "Ş.Bədəlbəyli küç., 20",
            latitude: 40.3925, longitude: 49.8380,
            rooms: 2, areaSqm: 78, floor: 6, totalFloors: 9,
            renovation: .medium,
            images: ["https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400"],
            videoUrl: nil, status: .active, viewsCount: 612,
            isBoosted: false
        ),
        Listing(
            id: "l7", userId: "user_001", agentId: "agent_001",
            title: "Penthouse Flame Towers",
            description: "Alov Qüllələrində penthouse",
            listingType: .sale, propertyType: .apartment,
            price: 1200000, currency: .AZN,
            city: "Bakı", district: "Səbail", address: "Alov Qüllələri",
            latitude: 40.3592, longitude: 49.8317,
            rooms: 4, areaSqm: 320, floor: 28, totalFloors: 30,
            renovation: .excellent,
            images: ["https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400"],
            videoUrl: nil, status: .active, viewsCount: 2341,
            isBoosted: true, boostType: .vip
        ),
        Listing(
            id: "l8", userId: "user_001", agentId: "agent_001",
            title: "Günlük kirayə İçərişəhər",
            description: "İçərişəhərdə günlük kirayə mənzil",
            listingType: .dailyRent, propertyType: .apartment,
            price: 80, currency: .AZN,
            city: "Bakı", district: "Səbail", address: "İçərişəhər, Kicik Qala",
            latitude: 40.3663, longitude: 49.8372,
            rooms: 2, areaSqm: 65, floor: 3, totalFloors: 4,
            renovation: .excellent,
            images: ["https://images.unsplash.com/photo-1598928506311-c55ez89a2cc8?w=400"],
            videoUrl: nil, status: .active, viewsCount: 1567,
            isBoosted: false
        ),
        Listing(
            id: "l9", userId: "user_001", agentId: "agent_001",
            title: "Torpaq sahəsi Novxanı",
            description: "Novxanıda tikintiyə yararlı torpaq",
            listingType: .sale, propertyType: .land,
            price: 95000, currency: .AZN,
            city: "Bakı", district: "Novxanı", address: "Novxanı qəsəbəsi",
            latitude: 40.5032, longitude: 50.0154,
            rooms: 0, areaSqm: 600, floor: nil, totalFloors: nil,
            renovation: .none,
            images: ["https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=400"],
            videoUrl: nil, status: .active, viewsCount: 234,
            isBoosted: false
        )
    ]

    // MARK: - Mock Reviews
    static let mockReviews: [Review] = [
        Review(
            id: "r1", agentId: "agent_001", userId: "user_101",
            rating: 5,
            comment: "Elvin bəy çox peşəkar yanaşdı. Evin bütün sənədlərini çox tez hazırladı. Tövsiyə edirəm!",
            agentReply: "Təşəkkür edirəm, sizinlə işləmək mənim üçün xoş oldu!",
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            user: User(id: "user_101", phone: "+994551112233", email: nil, fullName: "Aynur Həsənova", avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100", role: .user, isVerified: true, createdAt: nil, updatedAt: nil)
        ),
        Review(
            id: "r2", agentId: "agent_001", userId: "user_102",
            rating: 5,
            comment: "Çox yaxşı agent, hər şeyi ətraflı izah etdi. Mənzilimizi çox tez tapdıq.",
            agentReply: nil,
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            user: User(id: "user_102", phone: "+994552223344", email: nil, fullName: "Rəşad Əliyev", avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100", role: .user, isVerified: true, createdAt: nil, updatedAt: nil)
        ),
        Review(
            id: "r3", agentId: "agent_001", userId: "user_103",
            rating: 4,
            comment: "Ümumiyyətlə razıyam, amma bəzən cavab vermək bir az uzun çəkdi.",
            agentReply: "Rəyinizə görə təşəkkür. Xidmətimizi yaxşılaşdırmaq üçün nəzərə alacağıq.",
            createdAt: Calendar.current.date(byAdding: .day, value: -12, to: Date()),
            user: User(id: "user_103", phone: "+994553334455", email: nil, fullName: "Nigar Quliyeva", avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100", role: .user, isVerified: false, createdAt: nil, updatedAt: nil)
        ),
        Review(
            id: "r4", agentId: "agent_001", userId: "user_104",
            rating: 5,
            comment: "Mükəmməl xidmət! 3 gün ərzində mənzilimi satdı. Bazar qiymətindən yuxarı satdı!",
            agentReply: nil,
            createdAt: Calendar.current.date(byAdding: .day, value: -20, to: Date()),
            user: User(id: "user_104", phone: "+994554445566", email: nil, fullName: "Tural Mahmudov", avatarUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100", role: .user, isVerified: true, createdAt: nil, updatedAt: nil)
        ),
        Review(
            id: "r5", agentId: "agent_001", userId: "user_105",
            rating: 3,
            comment: "Normal idi, amma qiymət barədə razılaşma çətin oldu.",
            agentReply: "Təəssüf edirəm ki tam razı qalmamısınız. Gələcək əməkdaşlıqda daha yaxşı olacağıq.",
            createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date()),
            user: User(id: "user_105", phone: "+994555556677", email: nil, fullName: "Leyla İsmayılova", avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100", role: .user, isVerified: false, createdAt: nil, updatedAt: nil)
        ),
        Review(
            id: "r6", agentId: "agent_001", userId: "user_106",
            rating: 4,
            comment: "Professional agent. Bildiklərim arasında ən yaxşılarından biri. Sənədləşmə prosesi çox rahat keçdi.",
            agentReply: nil,
            createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()),
            user: User(id: "user_106", phone: "+994556667788", email: nil, fullName: "Fuad Babayev", avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100", role: .user, isVerified: true, createdAt: nil, updatedAt: nil)
        )
    ]
}
