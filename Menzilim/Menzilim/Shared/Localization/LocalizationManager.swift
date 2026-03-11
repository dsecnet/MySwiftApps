import SwiftUI
import Combine

// MARK: - Supported Languages
enum AppLanguage: String, CaseIterable {
    case azerbaijani = "az"
    case russian = "ru"

    var displayName: String {
        switch self {
        case .azerbaijani: return "Azərbaycan"
        case .russian: return "Русский"
        }
    }

    var flag: String {
        switch self {
        case .azerbaijani: return "🇦🇿"
        case .russian: return "🇷🇺"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "az"
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .azerbaijani
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }

    // MARK: - Localized String
    func localized(_ key: String) -> String {
        return L10n.strings[currentLanguage]?[key] ?? key
    }
}

// MARK: - Localization Strings
struct L10n {
    static let strings: [AppLanguage: [String: String]] = [
        .azerbaijani: az,
        .russian: ru
    ]

    // MARK: - Azerbaijani
    static let az: [String: String] = [
        // General
        "app_name": "Mənzilim",
        "ok": "Oldu",
        "cancel": "Ləğv et",
        "save": "Saxla",
        "delete": "Sil",
        "edit": "Redaktə",
        "done": "Hazır",
        "loading": "Yüklənir...",
        "error": "Xəta",
        "success": "Uğurlu",
        "retry": "Yenidən cəhd et",
        "search": "Axtar",
        "filter": "Filtr",
        "sort": "Sırala",
        "all": "Hamısı",
        "see_all": "Hamısına bax",
        "back": "Geri",
        "next": "Növbəti",
        "skip": "Keç",
        "close": "Bağla",
        "share": "Paylaş",
        "report": "Şikayət et",
        "reset": "Sıfırla",

        // Auth
        "welcome": "Mənzilimə xoş gəlmisiniz",
        "welcome_subtitle": "Telefon nömrənizi daxil edərək davam edin",
        "get_started": "Başla",
        "sign_in": "Daxil ol",
        "sign_up": "Qeydiyyat",
        "log_out": "Çıxış",
        "phone_number": "Telefon nömrəsi",
        "phone_code": "Kod",
        "send_code": "Kod göndər",
        "verify": "Təsdiqlə",
        "verification": "Təsdiqləmə",
        "enter_verification_code": "Təsdiq kodunu daxil edin",
        "code_sent_to": "Kod göndərildi:",
        "didnt_receive_code": "Kod almadınız?",
        "resend_code": "Yenidən göndər",
        "create_profile": "Profil yarat",
        "full_name": "Ad Soyad",
        "select_role": "Rol seçin",
        "terms_agree": "Davam etməklə Qaydalar və Şərtlərlə razılaşırsınız",
        "email": "E-poçt",
        "email_placeholder": "E-poçt ünvanınızı daxil edin",
        "password": "Şifrə",
        "password_placeholder": "Şifrənizi daxil edin",
        "confirm_password": "Şifrəni təsdiqlə",
        "confirm_password_placeholder": "Şifrəni yenidən daxil edin",
        "login_subtitle": "Hesabınıza daxil olun",
        "register_subtitle": "Yeni hesab yaradın",
        "no_account": "Hesabınız yoxdur?",
        "already_have_account": "Artıq hesabınız var?",
        "welcome_hero_title_1": "Növbəti Evini Tap",
        "welcome_hero_title_2": "Mənzilim ilə",
        "welcome_hero_highlight": "Etibarlı",
        "welcome_hero_title_3": "Agentlərlə",
        "welcome_hero_subtitle": "Təsdiqlənmiş mülkiyyətçilər və peşəkar agentlərlə birbaşa əlaqə qurun",

        // Roles
        "role_user": "İstifadəçi",
        "role_agent": "Realtor",
        "role_owner": "Mülkiyyətçi",

        // Tab Bar
        "tab_home": "Ana Səhifə",
        "tab_search": "Axtarış",
        "tab_create": "Elan Ver",
        "tab_notifications": "Bildirişlər",
        "tab_profile": "Profil",

        // Home
        "featured_listings": "Seçilmiş Elanlar",
        "new_listings": "Yeni Elanlar",
        "top_agents": "Ən Yaxşı Maklerlər",
        "popular_areas": "Populyar Ərazilər",
        "vip_listings": "VIP Elanlar",
        "recently_viewed": "Son Baxılanlar",
        "recommended": "Tövsiyə olunanlar",

        // Listings
        "for_sale": "Satılır",
        "for_rent": "Kirayə",
        "daily_rent": "Günlük kirayə",
        "rooms": "Otaq",
        "beds": "Otaq",
        "baths": "Hamam",
        "area_sqm": "Sahə (m²)",
        "land_area": "Torpaq sahəsi",
        "floor": "Mərtəbə",
        "price": "Qiymət",
        "description": "Təsvir",
        "location": "Ünvan",
        "contact": "Əlaqə",
        "contact_agent": "Maklerə yazın",
        "call": "Zəng",
        "whatsapp": "WhatsApp",
        "book_viewing": "Baxış sifariş et",
        "similar_listings": "Oxşar elanlar",
        "key_amenities": "Əsas xüsusiyyətlər",

        // Property Types
        "old_building": "Köhnə tikili",
        "new_building": "Yeni tikili",
        "house": "Həyət evi / Bağ evi",
        "office": "Ofis",
        "garage": "Qaraj",
        "land": "Torpaq",
        "commercial": "Obyekt",

        // Renovation
        "renovation_none": "Təmirsiz",
        "renovation_medium": "Orta təmirli",
        "renovation_good": "Yaxşı təmirli",
        "renovation_excellent": "Əla təmirli",

        // Filters
        "filters": "Filtrlər",
        "listing_type": "Elan növü",
        "property_type": "Emlak növü",
        "price_range": "Qiymət aralığı",
        "number_of_rooms": "Otaq sayı",
        "area_range": "Sahə (m²)",
        "floor_range": "Mərtəbə",
        "renovation_status": "Təmir vəziyyəti",
        "city": "Şəhər",
        "district": "Rayon",
        "show_results": "Nəticələri göstər",
        "any": "İstənilən",

        // Create Listing
        "post_property": "Elan Ver",
        "basic_details": "Əsas Məlumatlar",
        "property_details": "Əmlak Detalları",
        "photos_media": "Şəkillər",
        "pricing_location": "Qiymət və Ünvan",
        "step_of": "Addım %d / %d",
        "property_type_label": "Əmlak növü",
        "deal_type": "Əməliyyat növü",
        "residential": "Yaşayış",
        "commercial_type": "Kommersiya",
        "address": "Ünvan",
        "enter_address": "Ünvan daxil edin",
        "current_location": "Cari məkan",
        "add_photos": "Şəkil əlavə edin",
        "photos_hint": "Minimum 5, maksimum 10 şəkil. İlk şəkil əsas olacaq.",
        "photos_count": "%d / 10 şəkil",
        "select_district": "Rayon seçin",
        "select_on_map": "Xəritədən seç",
        "show_on_map": "Xəritədə göstər",
        "select_city": "Şəhər seçin",
        "room_size": "Otaq ölçüsü",
        "total_area": "Ümumi sahə",
        "current_floor": "Mərtəbə",
        "total_floors": "Ümumi mərtəbə",
        "has_elevator": "Lift var",
        "total_price": "Ümumi qiymət",
        "save_draft": "Qaralamaya saxla",
        "publish": "Dərc et",
        "next_step": "Növbəti addım",
        "preview": "Önizləmə",

        // Agent
        "find_agent": "Makler tap",
        "agent_profile": "Makler profili",
        "agent_level": "Makler səviyyəsi",
        "listings_count": "Elan",
        "followers": "İzləyici",
        "sold": "Satılıb",
        "follow": "İzlə",
        "message": "Mesaj",
        "active_listings": "Aktiv elanlar",
        "reviews": "Reylər",
        "top_rated": "Ən yüksək reytinq",
        "most_active": "Ən aktiv",
        "nearest": "Ən yaxın",
        "new_agent": "Yeni Makler",
        "active_agent": "Aktiv Makler",
        "professional_agent": "Peşəkar Makler",
        "expert_agent": "Ekspert Makler",
        "premium_agent": "Premium Makler",
        "write_review": "Rey yaz",
        "agent_reply": "Makler cavabı",

        // Favorites
        "saved_properties": "Saxlanılmış Elanlar",
        "no_favorites": "Hələ heç nə saxlamayıbsınız",
        "no_favorites_hint": "Bəyəndiyiniz elanları ❤️ ilə saxlayın",

        // Notifications
        "notifications": "Bildirişlər",
        "price_drops": "Qiymət endirimləri",
        "new_listings_notif": "Yeni elanlar",
        "system": "Sistem",
        "clear_all": "Hamısını sil",
        "today": "Bu gün",
        "yesterday": "Dünən",
        "mark_read": "Oxundu işarələ",

        // Profile / Settings
        "profile": "Profil",
        "settings": "Tənzimləmələr",
        "dashboard": "İdarə paneli",
        "saved_homes": "Saxlanılmışlar",
        "recent_views": "Son baxışlar",
        "personal_info": "Şəxsi məlumatlar",
        "privacy_security": "Gizlilik və Təhlükəsizlik",
        "help_support": "Kömək və Dəstək",
        "about_app": "Mənzilim haqqında",
        "language": "Dil",
        "dark_mode": "Qaranlıq rejim",
        "currency": "Valyuta",
        "switch_to_agent": "Makler rejiminə keç",
        "manage_listings": "Elanları idarə et",
        "my_listings": "Mənim elanlarım",

        // Premium
        "upgrade_premium": "Premium-a keç",
        "unlock_pro": "Mənzilim Pro-nu Açın",
        "premium_subtitle": "Limitsiz elan, prioritet dəstək və genişləndirilmiş analitika",
        "monthly": "Aylıq",
        "yearly": "İllik",
        "best_value": "ƏN SƏRFƏLİ",
        "save_percent": "33% qənaət",
        "start_monthly": "Aylıq başla",
        "start_yearly": "İllik başla",
        "unlimited_listings": "Limitsiz elan",
        "basic_analytics": "Əsas analitika",
        "email_support": "E-poçt dəstəyi",
        "priority_support": "Prioritet dəstək",
        "advanced_analytics": "Genişləndirilmiş analitika",
        "verified_badge": "Təsdiqlənmiş nişan",
        "boost_listing": "Elanı irəlilət",
        "boost_subtitle": "7 gün ərzində 3x daha çox baxış",
        "boost_now": "İrəlilət",
        "restore_purchases": "Satınalmaları bərpa et",

        // Complaints
        "reviews_complaints": "Reylər və Şikayətlər",
        "report_problem": "Problem bildir",
        "fake_listing": "Saxta elan",
        "wrong_price": "Yanlış qiymət",
        "wrong_photos": "Yanlış şəkillər",
        "agent_behavior": "Makler davranışı",
        "fraud": "Fırıldaqçılıq",
        "other": "Digər",
        "complaint_description": "Şikayəti təsvir edin",
        "attach_screenshot": "Ekran görüntüsü əlavə edin",
        "submit_complaint": "Şikayəti göndər",
        "complaint_sent": "Şikayətiniz göndərildi",

        // Map
        "map_view": "Xəritə",
        "list_view": "Siyahı",
        "properties_in_area": "Bu ərazidə",
        "draw_region": "Ərazi seçin",

        // Currency
        "currency_azn": "AZN",
        "currency_usd": "USD",
        "currency_eur": "EUR",

        // Messages
        "messages": "Mesajlar",
        "search_agents": "Agent və ya ünvan axtar...",
        "unread": "Oxunmamış",
        "agents": "Agentlər",
        "archived": "Arxivlənmiş",

        // Onboarding
        "onboarding_title_1": "Növbəti Evinizi Tapın",
        "onboarding_desc_1": "Etibarlı agentlər və mülkiyyətçilərdən minlərlə elan",
        "onboarding_title_2": "Etibarlı Agentlər",
        "onboarding_desc_2": "Reytinq və reylərlə yoxlanmış maklerlərə birbaşa əlaqə",
        "onboarding_title_3": "Asan Axtarış",
        "onboarding_desc_3": "Xəritə üzrə, filtrlərlə və ya ərazi üzrə rahatlıqla axtarın",
    ]

    // MARK: - Russian
    static let ru: [String: String] = [
        // General
        "app_name": "Мензилим",
        "ok": "Ок",
        "cancel": "Отмена",
        "save": "Сохранить",
        "delete": "Удалить",
        "edit": "Редактировать",
        "done": "Готово",
        "loading": "Загрузка...",
        "error": "Ошибка",
        "success": "Успешно",
        "retry": "Повторить",
        "search": "Поиск",
        "filter": "Фильтр",
        "sort": "Сортировать",
        "all": "Все",
        "see_all": "Смотреть все",
        "back": "Назад",
        "next": "Далее",
        "skip": "Пропустить",
        "close": "Закрыть",
        "share": "Поделиться",
        "report": "Пожаловаться",
        "reset": "Сбросить",

        // Auth
        "welcome": "Добро пожаловать в Mənzilim",
        "welcome_subtitle": "Введите номер телефона для продолжения",
        "get_started": "Начать",
        "sign_in": "Войти",
        "sign_up": "Регистрация",
        "log_out": "Выйти",
        "phone_number": "Номер телефона",
        "phone_code": "Код",
        "send_code": "Отправить код",
        "verify": "Подтвердить",
        "verification": "Верификация",
        "enter_verification_code": "Введите код подтверждения",
        "code_sent_to": "Код отправлен на:",
        "didnt_receive_code": "Не получили код?",
        "resend_code": "Отправить снова",
        "create_profile": "Создать профиль",
        "full_name": "Имя Фамилия",
        "select_role": "Выберите роль",
        "terms_agree": "Продолжая, вы соглашаетесь с Условиями и Политикой",
        "email": "Эл. почта",
        "email_placeholder": "Введите адрес эл. почты",
        "password": "Пароль",
        "password_placeholder": "Введите пароль",
        "confirm_password": "Подтвердите пароль",
        "confirm_password_placeholder": "Введите пароль ещё раз",
        "login_subtitle": "Войдите в свой аккаунт",
        "register_subtitle": "Создайте новый аккаунт",
        "no_account": "Нет аккаунта?",
        "already_have_account": "Уже есть аккаунт?",
        "welcome_hero_title_1": "Найдите Свой",
        "welcome_hero_title_2": "Новый Дом",
        "welcome_hero_highlight": "с Надёжными",
        "welcome_hero_title_3": "Агентами",

        "welcome_hero_subtitle": "Свяжитесь напрямую с проверенными собственниками и профессиональными агентами",

        // Roles
        "role_user": "Пользователь",
        "role_agent": "Риэлтор",
        "role_owner": "Собственник",

        // Tab Bar
        "tab_home": "Главная",
        "tab_search": "Поиск",
        "tab_create": "Подать",
        "tab_notifications": "Уведомления",
        "tab_profile": "Профиль",

        // Home
        "featured_listings": "Избранные объявления",
        "new_listings": "Новые объявления",
        "top_agents": "Лучшие агенты",
        "popular_areas": "Популярные районы",
        "vip_listings": "VIP объявления",
        "recently_viewed": "Недавно просмотренные",
        "recommended": "Рекомендуемые",

        // Listings
        "for_sale": "Продажа",
        "for_rent": "Аренда",
        "daily_rent": "Посуточная аренда",
        "rooms": "Комнат",
        "beds": "Комнат",
        "baths": "Ванных",
        "area_sqm": "Площадь (м²)",
        "land_area": "Площадь участка",
        "floor": "Этаж",
        "price": "Цена",
        "description": "Описание",
        "location": "Адрес",
        "contact": "Контакт",
        "contact_agent": "Написать агенту",
        "call": "Позвонить",
        "whatsapp": "WhatsApp",
        "book_viewing": "Записаться на просмотр",
        "similar_listings": "Похожие объявления",
        "key_amenities": "Основные удобства",

        // Property Types
        "old_building": "Старое строение",
        "new_building": "Новостройка",
        "house": "Частный дом / Вилла",
        "office": "Офис",
        "garage": "Гараж",
        "land": "Земля",
        "commercial": "Коммерция",

        // Renovation
        "renovation_none": "Без ремонта",
        "renovation_medium": "Средний ремонт",
        "renovation_good": "Хороший ремонт",
        "renovation_excellent": "Отличный ремонт",

        // Filters
        "filters": "Фильтры",
        "listing_type": "Тип объявления",
        "property_type": "Тип недвижимости",
        "price_range": "Диапазон цен",
        "number_of_rooms": "Количество комнат",
        "area_range": "Площадь (м²)",
        "floor_range": "Этаж",
        "renovation_status": "Состояние ремонта",
        "city": "Город",
        "district": "Район",
        "show_results": "Показать результаты",
        "any": "Любой",

        // Create Listing
        "post_property": "Подать объявление",
        "basic_details": "Основная информация",
        "property_details": "Детали объекта",
        "photos_media": "Фотографии",
        "pricing_location": "Цена и адрес",
        "step_of": "Шаг %d из %d",
        "property_type_label": "Тип объекта",
        "deal_type": "Тип сделки",
        "residential": "Жилая",
        "commercial_type": "Коммерческая",
        "address": "Адрес",
        "enter_address": "Введите адрес",
        "current_location": "Текущее местоположение",
        "add_photos": "Добавить фото",
        "photos_hint": "Минимум 5, максимум 10 фото. Первое фото будет обложкой.",
        "photos_count": "%d / 10 фото",
        "select_district": "Выберите район",
        "select_on_map": "Выбрать на карте",
        "show_on_map": "Показать на карте",
        "select_city": "Выберите город",
        "room_size": "Размер комнат",
        "total_area": "Общая площадь",
        "current_floor": "Этаж",
        "total_floors": "Всего этажей",
        "has_elevator": "Есть лифт",
        "total_price": "Общая цена",
        "save_draft": "Сохранить черновик",
        "publish": "Опубликовать",
        "next_step": "Следующий шаг",
        "preview": "Предпросмотр",

        // Agent
        "find_agent": "Найти агента",
        "agent_profile": "Профиль агента",
        "agent_level": "Уровень агента",
        "listings_count": "Объявлений",
        "followers": "Подписчиков",
        "sold": "Продано",
        "follow": "Подписаться",
        "message": "Написать",
        "active_listings": "Активные объявления",
        "reviews": "Отзывы",
        "top_rated": "По рейтингу",
        "most_active": "Самые активные",
        "nearest": "Ближайшие",
        "new_agent": "Новый агент",
        "active_agent": "Активный агент",
        "professional_agent": "Профессиональный агент",
        "expert_agent": "Эксперт агент",
        "premium_agent": "Премиум агент",
        "write_review": "Написать отзыв",
        "agent_reply": "Ответ агента",

        // Favorites
        "saved_properties": "Сохранённые объявления",
        "no_favorites": "Пока ничего не сохранено",
        "no_favorites_hint": "Сохраняйте понравившиеся объявления ❤️",

        // Notifications
        "notifications": "Уведомления",
        "price_drops": "Снижение цен",
        "new_listings_notif": "Новые объявления",
        "system": "Системные",
        "clear_all": "Очистить",
        "today": "Сегодня",
        "yesterday": "Вчера",
        "mark_read": "Отметить прочитанным",

        // Profile / Settings
        "profile": "Профиль",
        "settings": "Настройки",
        "dashboard": "Панель управления",
        "saved_homes": "Сохранённые",
        "recent_views": "Недавние просмотры",
        "personal_info": "Личная информация",
        "privacy_security": "Конфиденциальность",
        "help_support": "Помощь и поддержка",
        "about_app": "О Мензилим",
        "language": "Язык",
        "dark_mode": "Тёмный режим",
        "currency": "Валюта",
        "switch_to_agent": "Перейти в режим агента",
        "manage_listings": "Управление объявлениями",
        "my_listings": "Мои объявления",

        // Premium
        "upgrade_premium": "Перейти на Премиум",
        "unlock_pro": "Откройте Mənzilim Pro",
        "premium_subtitle": "Безлимитные объявления, приоритетная поддержка и расширенная аналитика",
        "monthly": "Ежемесячно",
        "yearly": "Ежегодно",
        "best_value": "ЛУЧШАЯ ЦЕНА",
        "save_percent": "Экономия 33%",
        "start_monthly": "Начать ежемесячно",
        "start_yearly": "Начать ежегодно",
        "unlimited_listings": "Безлимитные объявления",
        "basic_analytics": "Базовая аналитика",
        "email_support": "Поддержка по email",
        "priority_support": "Приоритетная поддержка",
        "advanced_analytics": "Расширенная аналитика",
        "verified_badge": "Верифицированный значок",
        "boost_listing": "Продвинуть объявление",
        "boost_subtitle": "3x больше просмотров за 7 дней",
        "boost_now": "Продвинуть",
        "restore_purchases": "Восстановить покупки",

        // Complaints
        "reviews_complaints": "Отзывы и жалобы",
        "report_problem": "Сообщить о проблеме",
        "fake_listing": "Фальшивое объявление",
        "wrong_price": "Неверная цена",
        "wrong_photos": "Неверные фотографии",
        "agent_behavior": "Поведение агента",
        "fraud": "Мошенничество",
        "other": "Другое",
        "complaint_description": "Опишите жалобу",
        "attach_screenshot": "Прикрепить скриншот",
        "submit_complaint": "Отправить жалобу",
        "complaint_sent": "Жалоба отправлена",

        // Map
        "map_view": "Карта",
        "list_view": "Список",
        "properties_in_area": "В этом районе",
        "draw_region": "Выберите область",

        // Currency
        "currency_azn": "AZN",
        "currency_usd": "USD",
        "currency_eur": "EUR",

        // Messages
        "messages": "Сообщения",
        "search_agents": "Поиск агента или адреса...",
        "unread": "Непрочитанные",
        "agents": "Агенты",
        "archived": "Архив",

        // Onboarding
        "onboarding_title_1": "Найдите свой новый дом",
        "onboarding_desc_1": "Тысячи объявлений от проверенных агентов и собственников",
        "onboarding_title_2": "Надёжные агенты",
        "onboarding_desc_2": "Проверенные агенты с рейтингами и отзывами",
        "onboarding_title_3": "Удобный поиск",
        "onboarding_desc_3": "Ищите по карте, фильтрам или районам",
    ]
}

// MARK: - Convenience accessor
extension String {
    var localized: String {
        LocalizationManager.shared.localized(self)
    }
}
