import SwiftUI
import Combine

// MARK: - Home ViewModel
@MainActor
class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var featuredListings: [Listing] = []
    @Published var vipListings: [Listing] = []
    @Published var recentListings: [Listing] = []
    @Published var topAgents: [Agent] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var selectedPropertyType: PropertyType? = nil
    @Published var errorMessage: String? = nil

    // MARK: - Pagination
    private(set) var currentPage: Int = 1
    private(set) var hasMore: Bool = true
    private let perPage: Int = 20

    // MARK: - Mock Data Flag
    private let useMockData: Bool = true

    // MARK: - Init
    init() {
        Task {
            await fetchHome()
        }
    }

    // MARK: - Fetch Home (All Sections)
    func fetchHome() async {
        isLoading = true
        errorMessage = nil

        if useMockData {
            try? await Task.sleep(nanoseconds: 500_000_000)
            loadMockData()
            isLoading = false
            return
        }

        async let featured: () = fetchFeaturedListings()
        async let vip: () = fetchVIPListings()
        async let agents: () = fetchTopAgents()
        async let recent: () = fetchRecentListings(reset: true)

        _ = await (featured, vip, agents, recent)
        isLoading = false
    }

    // MARK: - Refresh (Pull to Refresh)
    func refresh() async {
        currentPage = 1
        hasMore = true
        errorMessage = nil
        await fetchHome()
    }

    // MARK: - Load More (Pagination)
    func loadMore() async {
        guard hasMore, !isLoadingMore else { return }
        isLoadingMore = true

        if useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            // Simulate adding more listings
            let moreListings = Self.mockListings.prefix(3).map { listing in
                var copy = listing
                copy = Listing(
                    id: UUID().uuidString,
                    userId: listing.userId,
                    agentId: listing.agentId,
                    title: listing.title,
                    description: listing.description,
                    listingType: listing.listingType,
                    propertyType: listing.propertyType,
                    price: listing.price,
                    currency: listing.currency,
                    city: listing.city,
                    district: listing.district,
                    address: listing.address,
                    latitude: listing.latitude,
                    longitude: listing.longitude,
                    rooms: listing.rooms,
                    areaSqm: listing.areaSqm,
                    floor: listing.floor,
                    totalFloors: listing.totalFloors,
                    renovation: listing.renovation,
                    images: listing.images,
                    videoUrl: listing.videoUrl,
                    status: listing.status,
                    viewsCount: listing.viewsCount,
                    isBoosted: listing.isBoosted,
                    boostType: listing.boostType,
                    boostExpiresAt: listing.boostExpiresAt,
                    createdAt: listing.createdAt,
                    updatedAt: listing.updatedAt
                )
                return copy
            }
            recentListings.append(contentsOf: moreListings)
            currentPage += 1
            if currentPage > 3 { hasMore = false }
            isLoadingMore = false
            return
        }

        await fetchRecentListings()
        isLoadingMore = false
    }

    // MARK: - Load More If Needed
    func loadMoreIfNeeded(currentItem: Listing) async {
        guard let lastItem = recentListings.last,
              lastItem.id == currentItem.id,
              !isLoadingMore,
              hasMore else { return }
        await loadMore()
    }

    // MARK: - Property Type Selection
    func selectPropertyType(_ type: PropertyType?) async {
        selectedPropertyType = type
        isLoading = true

        if useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if let type = type {
                featuredListings = Self.mockListings.filter { $0.propertyType == type }
                recentListings = Self.mockListings.filter { $0.propertyType == type }
            } else {
                featuredListings = Array(Self.mockListings.prefix(5))
                recentListings = Self.mockListings
            }
            isLoading = false
            return
        }

        async let featured: () = fetchFeaturedListings()
        async let recent: () = fetchRecentListings(reset: true)
        _ = await (featured, recent)
        isLoading = false
    }

    // MARK: - API Fetch Methods
    private func fetchFeaturedListings() async {
        do {
            var params: [String: String] = [
                "page": "1",
                "per_page": "10",
                "is_boosted": "true"
            ]
            if let propertyType = selectedPropertyType {
                params["property_type"] = propertyType.rawValue
            }
            let response: PaginatedResponse<Listing> = try await APIService.shared.request(
                endpoint: "/listings",
                queryParams: params
            )
            featuredListings = response.items
        } catch {
            print("[HomeViewModel] fetchFeaturedListings error: \(error.localizedDescription)")
        }
    }

    private func fetchVIPListings() async {
        do {
            let params: [String: String] = [
                "page": "1",
                "per_page": "10",
                "boost_type": "vip"
            ]
            let response: PaginatedResponse<Listing> = try await APIService.shared.request(
                endpoint: "/listings",
                queryParams: params
            )
            vipListings = response.items
        } catch {
            print("[HomeViewModel] fetchVIPListings error: \(error.localizedDescription)")
        }
    }

    private func fetchTopAgents() async {
        do {
            let params: [String: String] = [
                "page": "1",
                "per_page": "10",
                "sort": "rating"
            ]
            let response: PaginatedResponse<Agent> = try await APIService.shared.request(
                endpoint: "/agents",
                queryParams: params
            )
            topAgents = response.items
        } catch {
            print("[HomeViewModel] fetchTopAgents error: \(error.localizedDescription)")
        }
    }

    private func fetchRecentListings(reset: Bool = false) async {
        if reset {
            currentPage = 1
            hasMore = true
        }
        guard hasMore else { return }

        do {
            var params: [String: String] = [
                "page": "\(currentPage)",
                "per_page": "\(perPage)",
                "sort": SortOption.newest.rawValue
            ]
            if let propertyType = selectedPropertyType {
                params["property_type"] = propertyType.rawValue
            }
            let response: PaginatedResponse<Listing> = try await APIService.shared.request(
                endpoint: "/listings",
                queryParams: params
            )
            if reset {
                recentListings = response.items
            } else {
                recentListings.append(contentsOf: response.items)
            }
            hasMore = currentPage < response.totalPages
            if hasMore { currentPage += 1 }
        } catch {
            print("[HomeViewModel] fetchRecentListings error: \(error.localizedDescription)")
            if reset { errorMessage = error.localizedDescription }
        }
    }

    // MARK: - Load Mock Data
    private func loadMockData() {
        featuredListings = Array(Self.mockListings.prefix(5))
        vipListings = Self.mockListings.filter { $0.boostType == .vip }
        recentListings = Self.mockListings
        topAgents = Self.mockAgents
    }

    // MARK: - Mock Listings
    static let mockListings: [Listing] = [
        Listing(
            id: "1",
            userId: "u1",
            agentId: "a1",
            title: "Nasimi rayonunda 3 otaql\u{0131} m\u{0259}nzil",
            description: "G\u{00F6}z\u{0259}l m\u{0259}nz\u{0259}r\u{0259}li, tam t\u{0259}mirli m\u{0259}nzil. Bak\u{0131}n\u{0131}n m\u{0259}rk\u{0259}zind\u{0259} yerl\u{0259}\u{015F}ir. Yax\u{0131}nl\u{0131}qda metro stansyas\u{0131}, m\u{0259}kt\u{0259}b v\u{0259} xəst\u{0259}xana var. M\u{0259}nzild\u{0259} kondisioner, kombi v\u{0259} m\u{0259}rk\u{0259}zi istilik sistemi m\u{00F6}vcuddur. Lift var. Parkinq yeri daxildir.",
            listingType: .sale,
            propertyType: .apartment,
            price: 185000,
            currency: .AZN,
            city: "Bak\u{0131}",
            district: "N\u{0259}simi",
            address: "N\u{0259}simi ray., S. V\u{0259}zirov k\u{00FC}\u{00E7}., 45",
            latitude: 40.4093,
            longitude: 49.8671,
            rooms: 3,
            areaSqm: 120,
            floor: 9,
            totalFloors: 16,
            renovation: .excellent,
            images: [
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800",
                "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800",
                "https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800"
            ],
            videoUrl: nil,
            status: .active,
            viewsCount: 342,
            isBoosted: true,
            boostType: .vip,
            boostExpiresAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "2",
            userId: "u2",
            agentId: "a2",
            title: "Yasamal rayonunda 2 otaql\u{0131} studio",
            description: "M\u{00FC}asir dizaynl\u{0131} studio m\u{0259}nzil. A\u{00E7}\u{0131}q plan, geni\u{015F} m\u{0259}tb\u{0259}x v\u{0259} ya\u{015F}ay\u{0131}\u{015F} zonas\u{0131}. Yeni tikili binada, tam t\u{0259}mirli v\u{0259} m\u{0259}bl\u{0259}li. Bulvar\u{0131}n yax\u{0131}nl\u{0131}\u{011F}\u{0131}nda. M\u{0259}nzil\u{0259} investisiya \u{00FC}\u{00E7}\u{00FC}n ideald\u{0131}r.",
            listingType: .sale,
            propertyType: .apartment,
            price: 95000,
            currency: .AZN,
            city: "Bak\u{0131}",
            district: "Yasamal",
            address: "Yasamal ray., H\u{00FC}seyn Cavid pr., 102",
            latitude: 40.3955,
            longitude: 49.8285,
            rooms: 2,
            areaSqm: 75,
            floor: 12,
            totalFloors: 20,
            renovation: .good,
            images: [
                "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800",
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800"
            ],
            videoUrl: nil,
            status: .active,
            viewsCount: 218,
            isBoosted: true,
            boostType: .premium,
            boostExpiresAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "3",
            userId: "u3",
            agentId: "a3",
            title: "N\u{0259}rimanov rayonunda 4 otaql\u{0131} villa",
            description: "2 m\u{0259}rt\u{0259}b\u{0259}li villa, h\u{0259}y\u{0259}t v\u{0259} qaraj daxil. G\u{0259}ni\u{015F} h\u{0259}y\u{0259}t sahas\u{0131}nda hovuz v\u{0259} ba\u{011F} var. D\u{00F6}rd otaq, \u{00FC}\u{00E7} hamam. Tam t\u{0259}mirli, m\u{0259}rk\u{0259}zi istilik sistemi. S\u{0259}bahi parkin yax\u{0131}nl\u{0131}\u{011F}\u{0131}nda yerl\u{0259}\u{015F}ir.",
            listingType: .sale,
            propertyType: .villa,
            price: 450000,
            currency: .AZN,
            city: "Bak\u{0131}",
            district: "N\u{0259}rimanov",
            address: "N\u{0259}rimanov ray., T\u{0259}briz k\u{00FC}\u{00E7}., 18",
            latitude: 40.4186,
            longitude: 49.8755,
            rooms: 4,
            areaSqm: 280,
            floor: 1,
            totalFloors: 2,
            renovation: .excellent,
            images: [
                "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800",
                "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800",
                "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
                "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800"
            ],
            videoUrl: nil,
            status: .active,
            viewsCount: 567,
            isBoosted: true,
            boostType: .vip,
            boostExpiresAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "4",
            userId: "u4",
            agentId: "a1",
            title: "X\u{0259}tai rayonunda 1 otaql\u{0131} m\u{0259}nzil",
            description: "Kiray\u{0259} verilir. Tam m\u{0259}bl\u{0259}li, t\u{0259}mirli m\u{0259}nzil. Metronun yax\u{0131}nl\u{0131}\u{011F}\u{0131}nda. \u{018F}lah\u{0259}dd\u{0259} koridoru var. M\u{0259}nzil\u{0259} subay v\u{0259} ya c\u{00FC}tl\u{00FC}k \u{00FC}\u{00E7}\u{00FC}n ideald\u{0131}r.",
            listingType: .rent,
            propertyType: .apartment,
            price: 650,
            currency: .AZN,
            city: "Bak\u{0131}",
            district: "X\u{0259}tai",
            address: "X\u{0259}tai ray., Babək pr., 78",
            latitude: 40.3895,
            longitude: 49.8622,
            rooms: 1,
            areaSqm: 45,
            floor: 5,
            totalFloors: 12,
            renovation: .good,
            images: [
                "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800",
                "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800"
            ],
            videoUrl: nil,
            status: .active,
            viewsCount: 145,
            isBoosted: false,
            boostType: nil,
            boostExpiresAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "5",
            userId: "u5",
            agentId: "a2",
            title: "Sab\u{0259}il rayonunda 5 otaql\u{0131} penthouse",
            description: "D\u{0259}niz m\u{0259}nz\u{0259}r\u{0259}li l\u{00FC}ks penthouse. Geni\u{015F} teras, panoramik p\u{0259}nc\u{0259}r\u{0259}l\u{0259}r. Smart ev sistemi qura\u{015F}d\u{0131}r\u{0131}l\u{0131}b. 2 parkinq yeri daxildir. Bayraq meydan\u{0131}n\u{0131}n yax\u{0131}nl\u{0131}\u{011F}\u{0131}nda. Premium s\u{0259}viyy\u{0259}li ya\u{015F}ay\u{0131}\u{015F} \u{00FC}\u{00E7}\u{00FC}n.",
            listingType: .sale,
            propertyType: .apartment,
            price: 780000,
            currency: .AZN,
            city: "Bak\u{0131}",
            district: "S\u{0259}bail",
            address: "S\u{0259}bail ray., Neft\u{00E7}il\u{0259}r pr., 155",
            latitude: 40.3635,
            longitude: 49.8382,
            rooms: 5,
            areaSqm: 220,
            floor: 25,
            totalFloors: 25,
            renovation: .excellent,
            images: [
                "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800",
                "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800",
                "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800"
            ],
            videoUrl: nil,
            status: .active,
            viewsCount: 891,
            isBoosted: true,
            boostType: .vip,
            boostExpiresAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "6",
            userId: "u3",
            agentId: "a3",
            title: "Bin\u{0259}q\u{0259}di rayonunda ofis",
            description: "Ticar\u{0259}t m\u{0259}rk\u{0259}zind\u{0259} 80 kvm ofis. Tam t\u{0259}mirli, kondisionerli. A\u{00E7}\u{0131}q planlama, 3 ayr\u{0131} otaq. Parkinq mo\u{0308}vcuddur.",
            listingType: .rent,
            propertyType: .office,
            price: 1200,
            currency: .AZN,
            city: "Bak\u{0131}",
            district: "Bin\u{0259}q\u{0259}di",
            address: "Bin\u{0259}q\u{0259}di ray., 8 Noyabr pr., 25",
            latitude: 40.4530,
            longitude: 49.9320,
            rooms: 3,
            areaSqm: 80,
            floor: 4,
            totalFloors: 10,
            renovation: .good,
            images: [
                "https://images.unsplash.com/photo-1497366216548-37526070297c?w=800",
                "https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800"
            ],
            videoUrl: nil,
            status: .active,
            viewsCount: 98,
            isBoosted: false,
            boostType: nil,
            boostExpiresAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "7",
            userId: "u1",
            agentId: "a2",
            title: "N\u{0259}simi rayonunda 2 otaql\u{0131} m\u{0259}nzil",
            description: "G\u{00FC}nl\u{00FC}k kiray\u{0259}. M\u{0259}rk\u{0259}zd\u{0259}, Fountain Square-in yax\u{0131}nl\u{0131}\u{011F}\u{0131}nda. Tam m\u{0259}bl\u{0259}li, WiFi, kondisioner. Turistl\u{0259}r \u{00FC}\u{00E7}\u{00FC}n ideal.",
            listingType: .dailyRent,
            propertyType: .apartment,
            price: 80,
            currency: .AZN,
            city: "Bak\u{0131}",
            district: "N\u{0259}simi",
            address: "N\u{0259}simi ray., Nizami k\u{00FC}\u{00E7}., 33",
            latitude: 40.4085,
            longitude: 49.8672,
            rooms: 2,
            areaSqm: 65,
            floor: 7,
            totalFloors: 14,
            renovation: .excellent,
            images: [
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800",
                "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800"
            ],
            videoUrl: nil,
            status: .active,
            viewsCount: 412,
            isBoosted: true,
            boostType: .premium,
            boostExpiresAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]

    // MARK: - Mock Agents
    static let mockAgents: [Agent] = [
        Agent(
            id: "a1",
            userId: "u1",
            companyName: "Baku Premium Realty",
            licenseNumber: "AZ-2024-001",
            level: .professional,
            rating: 4.9,
            totalReviews: 87,
            totalListings: 42,
            totalSales: 156,
            bio: "10 illik t\u{0259}cr\u{00FC}b\u{0259}li pe\u{015F}\u{0259}kar makler. L\u{00FC}ks m\u{0259}nzill\u{0259}r \u{00FC}zr\u{0259} ixtisasla\u{015F}m\u{0131}\u{015F}am.",
            isPremium: true,
            premiumExpiresAt: nil,
            user: User(
                id: "u1",
                phone: "+994501234567",
                email: "elvin@bakurealty.az",
                fullName: "Elvin M\u{0259}mm\u{0259}dov",
                avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
                role: .agent,
                isVerified: true,
                createdAt: nil,
                updatedAt: nil
            )
        ),
        Agent(
            id: "a2",
            userId: "u2",
            companyName: "Az Estate Group",
            licenseNumber: "AZ-2024-015",
            level: .expert,
            rating: 4.7,
            totalReviews: 63,
            totalListings: 38,
            totalSales: 112,
            bio: "Yasamal v\u{0259} N\u{0259}simi rayonlar\u{0131}nda ixtisasla\u{015F}m\u{0131}\u{015F} makler.",
            isPremium: true,
            premiumExpiresAt: nil,
            user: User(
                id: "u2",
                phone: "+994502345678",
                email: "aysel@azestate.az",
                fullName: "Ays\u{0259}l H\u{00FC}seynova",
                avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
                role: .agent,
                isVerified: true,
                createdAt: nil,
                updatedAt: nil
            )
        ),
        Agent(
            id: "a3",
            userId: "u3",
            companyName: nil,
            licenseNumber: "AZ-2024-042",
            level: .active,
            rating: 4.5,
            totalReviews: 29,
            totalListings: 15,
            totalSales: 45,
            bio: "Villalar v\u{0259} h\u{0259}y\u{0259}t evl\u{0259}ri \u{00FC}zr\u{0259} t\u{0259}cr\u{00FC}b\u{0259}li makler.",
            isPremium: false,
            premiumExpiresAt: nil,
            user: User(
                id: "u3",
                phone: "+994503456789",
                email: nil,
                fullName: "R\u{0259}\u{015F}ad \u{018F}liyev",
                avatarUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200",
                role: .agent,
                isVerified: true,
                createdAt: nil,
                updatedAt: nil
            )
        ),
        Agent(
            id: "a4",
            userId: "u4",
            companyName: "Caspian Homes",
            licenseNumber: "AZ-2024-078",
            level: .premium,
            rating: 4.8,
            totalReviews: 104,
            totalListings: 67,
            totalSales: 230,
            bio: "Bak\u{0131}n\u{0131}n b\u{00FC}t\u{00FC}n rayonlar\u{0131}nda xidm\u{0259}t g\u{00F6}st\u{0259}rir\u{0259}m. Premium agentlik.",
            isPremium: true,
            premiumExpiresAt: nil,
            user: User(
                id: "u4",
                phone: "+994504567890",
                email: "leyla@caspianhomes.az",
                fullName: "Leyla Quliyeva",
                avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200",
                role: .agent,
                isVerified: true,
                createdAt: nil,
                updatedAt: nil
            )
        ),
        Agent(
            id: "a5",
            userId: "u5",
            companyName: nil,
            licenseNumber: "AZ-2024-099",
            level: .newbie,
            rating: 4.2,
            totalReviews: 8,
            totalListings: 5,
            totalSales: 12,
            bio: "Yeni ba\u{015F}layan, amma m\u{0259}suliyy\u{0259}tli makler.",
            isPremium: false,
            premiumExpiresAt: nil,
            user: User(
                id: "u5",
                phone: "+994505678901",
                email: nil,
                fullName: "Tural Namazov",
                avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
                role: .agent,
                isVerified: false,
                createdAt: nil,
                updatedAt: nil
            )
        )
    ]
}
