import CoreLocation

// MARK: - Location Hierarchy: City → District → Microdistrict
struct AzerbaijanCity: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let span: Double // map zoom level
    let districts: [CityDistrict]
}

struct CityDistrict: Identifiable {
    let id: String
    let name: String
    let microdistricts: [String]
}

// MARK: - Azerbaijan Location Database
struct LocationData {

    static let cities: [AzerbaijanCity] = [
        bakuCity,
        sumgayitCity,
        ganjaCity,
        lankaranCity,
        mingachevirCity,
        shekiCity,
        shirvanCity,
        nakhchivanCity,
        yevlakhCity,
        shamakhiCity,
        qubCity,
        zagatalaCity,
        ismayilliCity,
        gabalaCity,
        lerikCity,
    ]

    // MARK: - Bakı
    static let bakuCity = AzerbaijanCity(
        id: "baku",
        name: "Bakı",
        coordinate: CLLocationCoordinate2D(latitude: 40.4093, longitude: 49.8671),
        span: 0.15,
        districts: [
            CityDistrict(id: "binagadi", name: "Binəqədi", microdistricts: [
                "6-cı mkr", "7-ci mkr", "8-ci mkr", "9-cu mkr",
                "Biləcəri", "M.Ə.Rəsulzadə", "Xırdalan yolu"
            ]),
            CityDistrict(id: "xatai", name: "Xətai", microdistricts: [
                "Əhmədli", "Köhnə Günəşli", "Yeni Günəşli",
                "Həzi Aslanov", "Nobel prospekti", "Xətai metrosu"
            ]),
            CityDistrict(id: "xazar", name: "Xəzər", microdistricts: [
                "Mərdəkan", "Buzovna", "Şüvəlan", "Türkan",
                "Bina", "Şağan"
            ]),
            CityDistrict(id: "narimanov", name: "Nərimanov", microdistricts: [
                "Montin", "Qantemir", "Gənclik", "Təbriz küçəsi",
                "Nərimanov metrosu", "Ağ şəhər"
            ]),
            CityDistrict(id: "nasimi", name: "Nəsimi", microdistricts: [
                "28 May", "Şəhidlər xiyabanı", "Elmlər Akademiyası",
                "Nizami küçəsi", "İstiqlaliyyət küçəsi", "R.Behbudov küç."
            ]),
            CityDistrict(id: "nizami", name: "Nizami", microdistricts: [
                "8 Noyabr", "Qara Qarayev", "Azadlıq prospekti",
                "Keşlə", "Bakmil"
            ]),
            CityDistrict(id: "pirallahi", name: "Pirallahı", microdistricts: [
                "Pirallahı qəsəbəsi"
            ]),
            CityDistrict(id: "qaradag", name: "Qaradağ", microdistricts: [
                "Lökbatan", "Ələt", "Sahil qəsəbəsi",
                "Qobustan", "Ümid"
            ]),
            CityDistrict(id: "sabunchu", name: "Sabunçu", microdistricts: [
                "Bakıxanov", "Maştağa", "Zabrat",
                "Nardaran", "Ramana", "Kürdəxanı",
                "Balaxanı", "Sabunçu qəsəbəsi"
            ]),
            CityDistrict(id: "sabail", name: "Səbail", microdistricts: [
                "İçərişəhər", "Sahil", "Dağüstü park",
                "Bayıl", "Bibiheybət", "Badamdar"
            ]),
            CityDistrict(id: "suraxani", name: "Suraxanı", microdistricts: [
                "Hövsan", "Qaraçuxur", "Yeni Suraxanı",
                "Atatürk", "Əmircan"
            ]),
            CityDistrict(id: "yasamal", name: "Yasamal", microdistricts: [
                "Yeni Yasamal", "İnşaatçılar", "Memar Əcəmi",
                "Şərur küçəsi", "Elmlər", "Asan xidmət"
            ])
        ]
    )

    // MARK: - Sumqayıt
    static let sumgayitCity = AzerbaijanCity(
        id: "sumgayit",
        name: "Sumqayıt",
        coordinate: CLLocationCoordinate2D(latitude: 40.5855, longitude: 49.6317),
        span: 0.08,
        districts: [
            CityDistrict(id: "sum_mkr", name: "Mikrorayonlar", microdistricts: [
                "1-ci mkr", "2-ci mkr", "3-cü mkr", "4-cü mkr",
                "5-ci mkr", "6-cı mkr", "7-ci mkr", "8-ci mkr",
                "9-cu mkr", "10-cu mkr", "11-ci mkr", "12-ci mkr",
                "13-cü mkr", "14-cü mkr", "15-ci mkr", "16-cı mkr",
                "17-ci mkr"
            ]),
            CityDistrict(id: "sum_mehelle", name: "Məhəllələr", microdistricts: [
                "Kimyaçılar", "Corat", "Yeni Sumqayıt",
                "Hacı Zeynalabdin", "Xırdalan"
            ]),
            CityDistrict(id: "sum_merkez", name: "Mərkəz", microdistricts: [
                "Şəhər mərkəzi", "Dəniz kənarı park", "Sumqayıt bulvarı"
            ])
        ]
    )

    // MARK: - Gəncə
    static let ganjaCity = AzerbaijanCity(
        id: "ganja",
        name: "Gəncə",
        coordinate: CLLocationCoordinate2D(latitude: 40.6828, longitude: 46.3606),
        span: 0.08,
        districts: [
            CityDistrict(id: "ganja_kapaz", name: "Kəpəz", microdistricts: [
                "Kəpəz rayonu", "Avtovağzal", "Həkimabad"
            ]),
            CityDistrict(id: "ganja_nizami", name: "Nizami", microdistricts: [
                "Nizami rayonu", "Şəhər mərkəzi", "Gəncə Mall"
            ])
        ]
    )

    // MARK: - Lənkəran
    static let lankaranCity = AzerbaijanCity(
        id: "lankaran",
        name: "Lənkəran",
        coordinate: CLLocationCoordinate2D(latitude: 38.7529, longitude: 48.8475),
        span: 0.06,
        districts: [
            CityDistrict(id: "lnk_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi", "Dəniz kənarı", "Bazar ətrafı"
            ])
        ]
    )

    // MARK: - Mingəçevir
    static let mingachevirCity = AzerbaijanCity(
        id: "mingachevir",
        name: "Mingəçevir",
        coordinate: CLLocationCoordinate2D(latitude: 40.7700, longitude: 47.0481),
        span: 0.06,
        districts: [
            CityDistrict(id: "ming_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi", "Su kənarı", "Yeni tikililər"
            ])
        ]
    )

    // MARK: - Şəki
    static let shekiCity = AzerbaijanCity(
        id: "sheki",
        name: "Şəki",
        coordinate: CLLocationCoordinate2D(latitude: 41.1919, longitude: 47.1706),
        span: 0.05,
        districts: [
            CityDistrict(id: "sheki_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi", "Xan Sarayı ətrafı", "Yuxarı bazar"
            ])
        ]
    )

    // MARK: - Şirvan
    static let shirvanCity = AzerbaijanCity(
        id: "shirvan",
        name: "Şirvan",
        coordinate: CLLocationCoordinate2D(latitude: 39.9380, longitude: 48.9275),
        span: 0.05,
        districts: [
            CityDistrict(id: "shirvan_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi"
            ])
        ]
    )

    // MARK: - Naxçıvan
    static let nakhchivanCity = AzerbaijanCity(
        id: "nakhchivan",
        name: "Naxçıvan",
        coordinate: CLLocationCoordinate2D(latitude: 39.2089, longitude: 45.4122),
        span: 0.06,
        districts: [
            CityDistrict(id: "nax_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi", "Yeni tikililər"
            ])
        ]
    )

    // MARK: - Yevlax
    static let yevlakhCity = AzerbaijanCity(
        id: "yevlakh",
        name: "Yevlax",
        coordinate: CLLocationCoordinate2D(latitude: 40.6186, longitude: 47.1500),
        span: 0.05,
        districts: [
            CityDistrict(id: "yev_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi"
            ])
        ]
    )

    // MARK: - Şamaxı
    static let shamakhiCity = AzerbaijanCity(
        id: "shamakhi",
        name: "Şamaxı",
        coordinate: CLLocationCoordinate2D(latitude: 40.6318, longitude: 48.6413),
        span: 0.05,
        districts: [
            CityDistrict(id: "sham_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi"
            ])
        ]
    )

    // MARK: - Quba
    static let qubCity = AzerbaijanCity(
        id: "quba",
        name: "Quba",
        coordinate: CLLocationCoordinate2D(latitude: 41.3614, longitude: 48.5133),
        span: 0.05,
        districts: [
            CityDistrict(id: "qub_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi"
            ])
        ]
    )

    // MARK: - Zaqatala
    static let zagatalaCity = AzerbaijanCity(
        id: "zagatala",
        name: "Zaqatala",
        coordinate: CLLocationCoordinate2D(latitude: 41.6031, longitude: 46.6385),
        span: 0.05,
        districts: [
            CityDistrict(id: "zaq_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi"
            ])
        ]
    )

    // MARK: - İsmayıllı
    static let ismayilliCity = AzerbaijanCity(
        id: "ismayilli",
        name: "İsmayıllı",
        coordinate: CLLocationCoordinate2D(latitude: 40.7880, longitude: 48.1520),
        span: 0.05,
        districts: [
            CityDistrict(id: "ism_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi"
            ])
        ]
    )

    // MARK: - Qəbələ
    static let gabalaCity = AzerbaijanCity(
        id: "gabala",
        name: "Qəbələ",
        coordinate: CLLocationCoordinate2D(latitude: 40.9814, longitude: 47.8456),
        span: 0.05,
        districts: [
            CityDistrict(id: "gab_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi", "Tufandağ ətrafı"
            ])
        ]
    )

    // MARK: - Lerik
    static let lerikCity = AzerbaijanCity(
        id: "lerik",
        name: "Lerik",
        coordinate: CLLocationCoordinate2D(latitude: 38.7736, longitude: 48.4150),
        span: 0.05,
        districts: [
            CityDistrict(id: "ler_merkez", name: "Şəhər", microdistricts: [
                "Şəhər mərkəzi"
            ])
        ]
    )

    // MARK: - Helpers
    static func city(byName name: String) -> AzerbaijanCity? {
        cities.first { $0.name == name }
    }

    static func city(byId id: String) -> AzerbaijanCity? {
        cities.first { $0.id == id }
    }
}
