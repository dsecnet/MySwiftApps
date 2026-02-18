//
//  LocalizationManager.swift
//  CoreVia
//
//  Mərkəzləşdirilmiş lokalizasiya sistemi - AZ, EN, RU
//

import Foundation
import SwiftUI

// MARK: - App Language
enum AppLanguage: String, CaseIterable, Codable {
    case az = "az"
    case en = "en"
    case ru = "ru"

    var displayName: String {
        switch self {
        case .az: return "AZ"
        case .en: return "EN"
        case .ru: return "RU"
        }
    }

    var flag: String {
        switch self {
        case .az: return "\u{1F1E6}\u{1F1FF}"
        case .en: return "\u{1F1EC}\u{1F1E7}"
        case .ru: return "\u{1F1F7}\u{1F1FA}"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {

    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
        }
    }

    private let languageKey = "app_language"

    init() {
        if let saved = UserDefaults.standard.string(forKey: languageKey),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            self.currentLanguage = .az
        }
    }

    func localized(_ key: String) -> String {
        return strings[key]?[currentLanguage] ?? key
    }

    // MARK: - All Strings
    private let strings: [String: [AppLanguage: String]] = [

        // ============================================================
        // MARK: - Common
        // ============================================================
        "common_save": [.az: "Saxla", .en: "Save", .ru: "\u{0421}\u{043E}\u{0445}\u{0440}\u{0430}\u{043D}\u{0438}\u{0442}\u{044C}"],
        "common_cancel": [.az: "L\u{0259}\u{011F}v et", .en: "Cancel", .ru: "\u{041E}\u{0442}\u{043C}\u{0435}\u{043D}\u{0430}"],
        "common_yes": [.az: "Bəli", .en: "Yes", .ru: "Да"],
        "common_close": [.az: "Ba\u{011F}la", .en: "Close", .ru: "\u{0417}\u{0430}\u{043A}\u{0440}\u{044B}\u{0442}\u{044C}"],
        "common_delete": [.az: "Sil", .en: "Delete", .ru: "\u{0423}\u{0434}\u{0430}\u{043B}\u{0438}\u{0442}\u{044C}"],
        "common_ok": [.az: "OK", .en: "OK", .ru: "OK"],
        "common_or": [.az: "v\u{0259} ya", .en: "or", .ru: "\u{0438}\u{043B}\u{0438}"],
        "common_email": [.az: "Email", .en: "Email", .ru: "Email"],
        "common_password": [.az: "\u{015E}ifr\u{0259}", .en: "Password", .ru: "\u{041F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}"],
        "common_success": [.az: "U\u{011F}urlu!", .en: "Success!", .ru: "\u{0423}\u{0441}\u{043F}\u{0435}\u{0445}!"],
        "common_error": [.az: "X\u{0259}ta", .en: "Error", .ru: "\u{041E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430}"],
        "common_loading": [.az: "Y\u{00FC}kl\u{0259}nir...", .en: "Loading...", .ru: "\u{0417}\u{0430}\u{0433}\u{0440}\u{0443}\u{0437}\u{043A}\u{0430}..."],
        "common_gram": [.az: "qram", .en: "gram", .ru: "\u{0433}\u{0440}\u{0430}\u{043C}\u{043C}"],
        "common_min": [.az: "d\u{0259}q", .en: "min", .ru: "\u{043C}\u{0438}\u{043D}"],
        "common_kcal": [.az: "kcal", .en: "kcal", .ru: "\u{043A}\u{043A}\u{0430}\u{043B}"],
        "common_kg": [.az: "kg", .en: "kg", .ru: "\u{043A}\u{0433}"],
        "common_cm": [.az: "sm", .en: "cm", .ru: "\u{0441}\u{043C}"],
        "common_year": [.az: "il", .en: "year", .ru: "\u{043B}\u{0435}\u{0442}"],
        "common_person": [.az: "n\u{0259}f\u{0259}r", .en: "people", .ru: "\u{0447}\u{0435}\u{043B}."],
        "common_piece": [.az: "\u{0259}d\u{0259}d", .en: "pcs", .ru: "\u{0448}\u{0442}."],
        "common_optional": [.az: "opsional", .en: "optional", .ru: "\u{043D}\u{0435}\u{043E}\u{0431}\u{044F}\u{0437}."],
        "common_change": [.az: "Dəyiş", .en: "Change", .ru: "Изменить"],
        "common_today": [.az: "Bugün", .en: "Today", .ru: "Сегодня"],
        "common_yesterday": [.az: "Dünən", .en: "Yesterday", .ru: "Вчера"],

        // ============================================================
        // MARK: - Login
        // ============================================================
        "login_slogan": [.az: "G\u{00DC}C\u{018E} GED\u{018E}N YOL", .en: "PATH TO POWER", .ru: "\u{041F}\u{0423}\u{0422}\u{042C} \u{041A} \u{0421}\u{0418}\u{041B}\u{0415}"],
        "login_account_type": [.az: "Hesab n\u{00F6}v\u{00FC}", .en: "Account type", .ru: "\u{0422}\u{0438}\u{043F} \u{0430}\u{043A}\u{043A}\u{0430}\u{0443}\u{043D}\u{0442}\u{0430}"],
        "login_student": [.az: "T\u{0259}l\u{0259}b\u{0259}", .en: "Student", .ru: "\u{0421}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}"],
        "login_teacher": [.az: "M\u{00FC}\u{0259}llim", .en: "Teacher", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}"],
        "login_email_placeholder": [.az: "example@mail.com", .en: "example@mail.com", .ru: "example@mail.com"],
        "login_password_placeholder": [.az: "\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}", .en: "\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}", .ru: "\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}"],
        "login_forgot_password": [.az: "\u{015E}ifr\u{0259}ni unutdunuz?", .en: "Forgot password?", .ru: "\u{0417}\u{0430}\u{0431}\u{044B}\u{043B}\u{0438} \u{043F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}?"],
        "login_as_student": [.az: "T\u{0259}l\u{0259}b\u{0259} olaraq daxil ol", .en: "Login as Student", .ru: "\u{0412}\u{043E}\u{0439}\u{0442}\u{0438} \u{043A}\u{0430}\u{043A} \u{0441}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}"],
        "login_as_teacher": [.az: "M\u{00FC}\u{0259}llim olaraq daxil ol", .en: "Login as Teacher", .ru: "\u{0412}\u{043E}\u{0439}\u{0442}\u{0438} \u{043A}\u{0430}\u{043A} \u{0442}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}"],
        "login_no_account": [.az: "Hesab\u{0131}n\u{0131}z yoxdur?", .en: "Don't have an account?", .ru: "\u{041D}\u{0435}\u{0442} \u{0430}\u{043A}\u{043A}\u{0430}\u{0443}\u{043D}\u{0442}\u{0430}?"],
        "login_register": [.az: "Qeydiyyatdan keçin", .en: "Register", .ru: "Регистрация"],
        "login_error_email_empty": [.az: "Email daxil edin", .en: "Enter your email", .ru: "Введите email"],
        "login_error_password_empty": [.az: "Şifrə daxil edin", .en: "Enter your password", .ru: "Введите пароль"],
        "login_error_email_invalid": [.az: "Düzgün email daxil edin", .en: "Enter a valid email", .ru: "Введите корректный email"],
        "login_error_password_short": [.az: "Şifrə ən az 6 simvol olmalıdır", .en: "Password must be at least 6 characters", .ru: "Пароль должен быть не менее 6 символов"],
        "login_error_wrong_credentials": [.az: "Email və ya şifrə yanlışdır", .en: "Incorrect email or password", .ru: "Неверный email или пароль"],
        "login_error_wrong_type": [.az: "Bu giriş məlumatları seçilmiş hesab növünə uyğun deyil", .en: "These credentials don't match the selected account type", .ru: "Эти данные не соответствуют выбранному типу аккаунта"],
        "login_enter_email": [.az: "Email daxil edin", .en: "Enter email", .ru: "\u{0412}\u{0432}\u{0435}\u{0434}\u{0438}\u{0442}\u{0435} email"],
        "login_enter_password": [.az: "\u{015E}ifr\u{0259} daxil edin", .en: "Enter password", .ru: "\u{0412}\u{0432}\u{0435}\u{0434}\u{0438}\u{0442}\u{0435} \u{043F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}"],
        "login_valid_email": [.az: "D\u{00FC}zg\u{00FC}n email daxil edin", .en: "Enter a valid email", .ru: "\u{0412}\u{0432}\u{0435}\u{0434}\u{0438}\u{0442}\u{0435} \u{043A}\u{043E}\u{0440}\u{0440}\u{0435}\u{043A}\u{0442}\u{043D}\u{044B}\u{0439} email"],
        "login_password_min": [.az: "\u{015E}ifr\u{0259} \u{0259}n az 6 simvol olmal\u{0131}d\u{0131}r", .en: "Password must be at least 6 characters", .ru: "\u{041F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C} \u{043C}\u{0438}\u{043D}\u{0438}\u{043C}\u{0443}\u{043C} 6 \u{0441}\u{0438}\u{043C}\u{0432}\u{043E}\u{043B}\u{043E}\u{0432}"],
        "login_wrong_credentials": [.az: "Email v\u{0259} ya \u{015F}ifr\u{0259} yanl\u{0131}\u{015F}d\u{0131}r", .en: "Invalid email or password", .ru: "\u{041D}\u{0435}\u{0432}\u{0435}\u{0440}\u{043D}\u{044B}\u{0439} email \u{0438}\u{043B}\u{0438} \u{043F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}"],
        "login_wrong_type": [.az: "Bu giri\u{015F} m\u{0259}lumatlar\u{0131} se\u{00E7}diyiniz hesab tipi il\u{0259} uy\u{011F}un deyil", .en: "These credentials don't match the selected account type", .ru: "\u{042D}\u{0442}\u{0438} \u{0434}\u{0430}\u{043D}\u{043D}\u{044B}\u{0435} \u{043D}\u{0435} \u{0441}\u{043E}\u{043E}\u{0442}\u{0432}\u{0435}\u{0442}\u{0441}\u{0442}\u{0432}\u{0443}\u{044E}\u{0442} \u{0442}\u{0438}\u{043F}\u{0443} \u{0430}\u{043A}\u{043A}\u{0430}\u{0443}\u{043D}\u{0442}\u{0430}"],

        // ============================================================
        // MARK: - Register
        // ============================================================
        "register_title": [.az: "Qeydiyyat", .en: "Registration", .ru: "\u{0420}\u{0435}\u{0433}\u{0438}\u{0441}\u{0442}\u{0440}\u{0430}\u{0446}\u{0438}\u{044F}"],
        "register_subtitle": [.az: "CoreVia ail\u{0259}sin\u{0259} qo\u{015F}ulun", .en: "Join the CoreVia family", .ru: "\u{041F}\u{0440}\u{0438}\u{0441}\u{043E}\u{0435}\u{0434}\u{0438}\u{043D}\u{044F}\u{0439}\u{0442}\u{0435}\u{0441}\u{044C} \u{043A} CoreVia"],
        "register_select_type": [.az: "Hesab n\u{00F6}v\u{00FC} se\u{00E7}in", .en: "Select account type", .ru: "\u{0412}\u{044B}\u{0431}\u{0435}\u{0440}\u{0438}\u{0442}\u{0435} \u{0442}\u{0438}\u{043F} \u{0430}\u{043A}\u{043A}\u{0430}\u{0443}\u{043D}\u{0442}\u{0430}"],
        "register_name": [.az: "Ad v\u{0259} Soyad", .en: "Full Name", .ru: "\u{0418}\u{043C}\u{044F} \u{0438} \u{0424}\u{0430}\u{043C}\u{0438}\u{043B}\u{0438}\u{044F}"],
        "register_password_repeat": [.az: "\u{015E}ifr\u{0259} t\u{0259}krar\u{0131}", .en: "Confirm password", .ru: "\u{041F}\u{043E}\u{0434}\u{0442}\u{0432}\u{0435}\u{0440}\u{0434}\u{0438}\u{0442}\u{0435} \u{043F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}"],
        "register_terms": [.az: "\u{015E}\u{0259}rtl\u{0259}r v\u{0259} qaydalar il\u{0259} raz\u{0131}yam", .en: "I agree to the Terms and Conditions", .ru: "\u{042F} \u{0441}\u{043E}\u{0433}\u{043B}\u{0430}\u{0441}\u{0435}\u{043D} \u{0441} \u{0443}\u{0441}\u{043B}\u{043E}\u{0432}\u{0438}\u{044F}\u{043C}\u{0438}"],
        "register_button": [.az: "Qeydiyyatdan ke\u{00E7}", .en: "Register", .ru: "\u{0417}\u{0430}\u{0440}\u{0435}\u{0433}\u{0438}\u{0441}\u{0442}\u{0440}\u{0438}\u{0440}\u{043E}\u{0432}\u{0430}\u{0442}\u{044C}\u{0441}\u{044F}"],
        "register_have_account": [.az: "Art\u{0131}q hesab\u{0131}n\u{0131}z var?", .en: "Already have an account?", .ru: "\u{0423}\u{0436}\u{0435} \u{0435}\u{0441}\u{0442}\u{044C} \u{0430}\u{043A}\u{043A}\u{0430}\u{0443}\u{043D}\u{0442}?"],
        "register_login": [.az: "Daxil olun", .en: "Login", .ru: "\u{0412}\u{043E}\u{0439}\u{0442}\u{0438}"],
        "register_client_desc": [.az: "Fitness h\u{0259}d\u{0259}fl\u{0259}rinizi izl\u{0259}yin", .en: "Track your fitness goals", .ru: "\u{041E}\u{0442}\u{0441}\u{043B}\u{0435}\u{0436}\u{0438}\u{0432}\u{0430}\u{0439}\u{0442}\u{0435} \u{0446}\u{0435}\u{043B}\u{0438}"],
        "register_trainer_desc": [.az: "T\u{0259}l\u{0259}b\u{0259}l\u{0259}rinizi idar\u{0259} edin", .en: "Manage your students", .ru: "\u{0423}\u{043F}\u{0440}\u{0430}\u{0432}\u{043B}\u{044F}\u{0439}\u{0442}\u{0435} \u{0441}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}\u{0430}\u{043C}\u{0438}"],

        // ============================================================
        // MARK: - Tabs
        // ============================================================
        "tab_home": [.az: "\u{018F}sas", .en: "Home", .ru: "\u{0413}\u{043B}\u{0430}\u{0432}\u{043D}\u{0430}\u{044F}"],
        "tab_workout": [.az: "M\u{0259}\u{015F}q", .en: "Workout", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0430}"],
        "tab_food": [.az: "Qida", .en: "Food", .ru: "\u{041F}\u{0438}\u{0442}\u{0430}\u{043D}\u{0438}\u{0435}"],
        "tab_teachers": [.az: "M\u{00FC}\u{0259}lliml\u{0259}r", .en: "Teachers", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}\u{044B}"],
        "tab_profile": [.az: "Profil", .en: "Profile", .ru: "Профиль"],
        "tab_plans": [.az: "Planlar", .en: "Plans", .ru: "Планы"],
        "tab_meal_plans": [.az: "Qida Planı", .en: "Meal Plans", .ru: "Питание"],
        "tab_more": [.az: "Daha çox", .en: "More", .ru: "Ещё"],
        "profile_subtitle": [.az: "Hesab və parametrlər", .en: "Account and settings", .ru: "Аккаунт и настройки"],

        // ============================================================
        // MARK: - Home
        // ============================================================
        "home_hello": [.az: "Salam", .en: "Hello", .ru: "\u{041F}\u{0440}\u{0438}\u{0432}\u{0435}\u{0442}"],
        "home_focus": [.az: "Bu g\u{00FC}n h\u{0259}d\u{0259}fl\u{0259}rin\u{0259} fokuslan!", .en: "Focus on your goals today!", .ru: "\u{0421}\u{043E}\u{0441}\u{0440}\u{0435}\u{0434}\u{043E}\u{0442}\u{043E}\u{0447}\u{044C}\u{0442}\u{0435}\u{0441}\u{044C} \u{043D}\u{0430} \u{0446}\u{0435}\u{043B}\u{044F}\u{0445}!"],
        "home_workout": [.az: "M\u{0259}\u{015F}q", .en: "Workout", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0430}"],
        "home_calories": [.az: "Kalori", .en: "Calories", .ru: "\u{041A}\u{0430}\u{043B}\u{043E}\u{0440}\u{0438}\u{0438}"],
        "home_daily_goal": [.az: "G\u{00FC}nl\u{00FC}k H\u{0259}d\u{0259}f", .en: "Daily Goal", .ru: "\u{0414}\u{043D}\u{0435}\u{0432}\u{043D}\u{0430}\u{044F} \u{0446}\u{0435}\u{043B}\u{044C}"],
        "home_today_workouts": [.az: "Bug\u{00FC}nk\u{00FC} M\u{0259}\u{015F}ql\u{0259}r", .en: "Today's Workouts", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0438} \u{0441}\u{0435}\u{0433}\u{043E}\u{0434}\u{043D}\u{044F}"],
        "home_see_all": [.az: "Ham\u{0131}s\u{0131}na bax", .en: "See all", .ru: "\u{0421}\u{043C}\u{043E}\u{0442}\u{0440}\u{0435}\u{0442}\u{044C} \u{0432}\u{0441}\u{0435}"],
        "home_quick_actions": [.az: "Tez \u{018F}m\u{0259}liyyatlar", .en: "Quick Actions", .ru: "\u{0411}\u{044B}\u{0441}\u{0442}\u{0440}\u{044B}\u{0435} \u{0434}\u{0435}\u{0439}\u{0441}\u{0442}\u{0432}\u{0438}\u{044F}"],
        "home_add_workout": [.az: "M\u{0259}\u{015F}q \u{018F}lav\u{0259} Et", .en: "Add Workout", .ru: "\u{0414}\u{043E}\u{0431}. \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0443}"],
        "home_add_food": [.az: "Qida \u{018F}lav\u{0259} Et", .en: "Add Food", .ru: "\u{0414}\u{043E}\u{0431}. \u{043F}\u{0438}\u{0442}\u{0430}\u{043D}\u{0438}\u{0435}"],
        "home_this_week": [.az: "Bu H\u{0259}ft\u{0259}", .en: "This Week", .ru: "\u{042D}\u{0442}\u{0430} \u{043D}\u{0435}\u{0434}\u{0435}\u{043B}\u{044F}"],
        "home_completed": [.az: "Tamamland\u{0131}", .en: "Completed", .ru: "\u{0417}\u{0430}\u{0432}\u{0435}\u{0440}\u{0448}\u{0435}\u{043D}\u{043E}"],
        "home_minutes": [.az: "D\u{0259}qiq\u{0259}", .en: "Minutes", .ru: "\u{041C}\u{0438}\u{043D}\u{0443}\u{0442}\u{044B}"],
        "home_no_workouts": [.az: "Bug\u{00FC}n m\u{0259}\u{015F}q yoxdur", .en: "No workouts today", .ru: "\u{041D}\u{0435}\u{0442} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043E}\u{043A} \u{0441}\u{0435}\u{0433}\u{043E}\u{0434}\u{043D}\u{044F}"],

        // ============================================================
        // MARK: - Workout
        // ============================================================
        "workout_tracking": [.az: "M\u{0259}\u{015F}q Tracking", .en: "Workout Tracking", .ru: "\u{041E}\u{0442}\u{0441}\u{043B}\u{0435}\u{0436}\u{0438}\u{0432}\u{0430}\u{043D}\u{0438}\u{0435}"],
        "workout_subtitle": [.az: "Bug\u{00FC}nk\u{00FC} m\u{0259}\u{015F}ql\u{0259}r v\u{0259} statistikalar", .en: "Today's workouts and stats", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0438} \u{0438} \u{0441}\u{0442}\u{0430}\u{0442}\u{0438}\u{0441}\u{0442}\u{0438}\u{043A}\u{0430}"],
        "workout_today_goal": [.az: "Bug\u{00FC}nk\u{00FC} H\u{0259}d\u{0259}f", .en: "Today's Goal", .ru: "\u{0426}\u{0435}\u{043B}\u{044C} \u{043D}\u{0430} \u{0441}\u{0435}\u{0433}\u{043E}\u{0434}\u{043D}\u{044F}"],
        "workout_today": [.az: "Bug\u{00FC}nk\u{00FC} M\u{0259}\u{015F}ql\u{0259}r", .en: "Today's Workouts", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0438}"],
        "workout_future": [.az: "G\u{0259}l\u{0259}c\u{0259}k M\u{0259}\u{015F}ql\u{0259}r", .en: "Future Workouts", .ru: "\u{0411}\u{0443}\u{0434}\u{0443}\u{0449}\u{0438}\u{0435}"],
        "workout_no_workouts": [.az: "H\u{0259}l\u{0259} m\u{0259}\u{015F}q yoxdur", .en: "No workouts yet", .ru: "\u{041F}\u{043E}\u{043A}\u{0430} \u{043D}\u{0435}\u{0442} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043E}\u{043A}"],
        "workout_add_first": [.az: "\u{0130}lk m\u{0259}\u{015F}qinizi \u{0259}lav\u{0259} edin!", .en: "Add your first workout!", .ru: "\u{0414}\u{043E}\u{0431}\u{0430}\u{0432}\u{044C}\u{0442}\u{0435} \u{043F}\u{0435}\u{0440}\u{0432}\u{0443}\u{044E}!"],
        "workout_new": [.az: "Yeni M\u{0259}\u{015F}q \u{018F}lav\u{0259} Et", .en: "Add New Workout", .ru: "\u{0414}\u{043E}\u{0431}\u{0430}\u{0432}\u{0438}\u{0442}\u{044C} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0443}"],
        "workout_name": [.az: "M\u{0259}\u{015F}qin Ad\u{0131}", .en: "Workout Name", .ru: "\u{041D}\u{0430}\u{0437}\u{0432}\u{0430}\u{043D}\u{0438}\u{0435}"],
        "workout_category": [.az: "Kateqoriya", .en: "Category", .ru: "\u{041A}\u{0430}\u{0442}\u{0435}\u{0433}\u{043E}\u{0440}\u{0438}\u{044F}"],
        "workout_duration": [.az: "M\u{00FC}dd\u{0259}t (d\u{0259}qiq\u{0259})", .en: "Duration (minutes)", .ru: "\u{041F}\u{0440}\u{043E}\u{0434}\u{043E}\u{043B}\u{0436}. (\u{043C}\u{0438}\u{043D}.)"],
        "workout_calories_optional": [.az: "Kalori (opsional)", .en: "Calories (optional)", .ru: "\u{041A}\u{0430}\u{043B}\u{043E}\u{0440}\u{0438}\u{0438} (\u{043D}\u{0435}\u{043E}\u{0431}.)"],
        "workout_date": [.az: "Tarix", .en: "Date", .ru: "\u{0414}\u{0430}\u{0442}\u{0430}"],
        "workout_notes": [.az: "Qeydl\u{0259}r (opsional)", .en: "Notes (optional)", .ru: "\u{0417}\u{0430}\u{043C}\u{0435}\u{0442}\u{043A}\u{0438} (\u{043D}\u{0435}\u{043E}\u{0431}.)"],
        "workout_notes_placeholder": [.az: "M\u{0259}\u{015F}q haqq\u{0131}nda qeydl\u{0259}r yaz\u{0131}n...", .en: "Write notes about workout...", .ru: "\u{0417}\u{0430}\u{043C}\u{0435}\u{0442}\u{043A}\u{0438} \u{043E} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0435}..."],
        "workout_save": [.az: "M\u{0259}\u{015F}qi Saxla", .en: "Save Workout", .ru: "\u{0421}\u{043E}\u{0445}\u{0440}\u{0430}\u{043D}\u{0438}\u{0442}\u{044C}"],
        "workout_added": [.az: "M\u{0259}\u{015F}q u\u{011F}urla \u{0259}lav\u{0259} olundu!", .en: "Workout added successfully!", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0430} \u{0434}\u{043E}\u{0431}\u{0430}\u{0432}\u{043B}\u{0435}\u{043D}\u{0430}!"],
        "workout_cat_strength": [.az: "G\u{00FC}c", .en: "Strength", .ru: "\u{0421}\u{0438}\u{043B}\u{0430}"],
        "workout_cat_cardio": [.az: "Kardio", .en: "Cardio", .ru: "\u{041A}\u{0430}\u{0440}\u{0434}\u{0438}\u{043E}"],
        "workout_cat_flexibility": [.az: "\u{00C7}eviklik", .en: "Flexibility", .ru: "\u{0413}\u{0438}\u{0431}\u{043A}\u{043E}\u{0441}\u{0442}\u{044C}"],
        "workout_cat_endurance": [.az: "D\u{00F6}z\u{00FC}ml\u{00FC}l\u{00FC}k", .en: "Endurance", .ru: "\u{0412}\u{044B}\u{043D}\u{043E}\u{0441}\u{043B}\u{0438}\u{0432}\u{043E}\u{0441}\u{0442}\u{044C}"],
        "workout_today_text": [.az: "Bu g\u{00FC}n", .en: "Today", .ru: "\u{0421}\u{0435}\u{0433}\u{043E}\u{0434}\u{043D}\u{044F}"],
        "workout_yesterday": [.az: "D\u{00FC}n\u{0259}n", .en: "Yesterday", .ru: "\u{0412}\u{0447}\u{0435}\u{0440}\u{0430}"],

        // ============================================================
        // MARK: - Food
        // ============================================================
        "food_tracking": [.az: "Qida Tracking", .en: "Food Tracking", .ru: "\u{041E}\u{0442}\u{0441}\u{043B}\u{0435}\u{0436}\u{0438}\u{0432}\u{0430}\u{043D}\u{0438}\u{0435} \u{043F}\u{0438}\u{0442}\u{0430}\u{043D}\u{0438}\u{044F}"],
        "food_subtitle": [.az: "Bug\u{00FC}nk\u{00FC} qidalanman\u{0131}z\u{0131} izl\u{0259}yin", .en: "Track today's nutrition", .ru: "\u{041E}\u{0442}\u{0441}\u{043B}\u{0435}\u{0436}\u{0438}\u{0432}\u{0430}\u{0439}\u{0442}\u{0435} \u{043F}\u{0438}\u{0442}\u{0430}\u{043D}\u{0438}\u{0435}"],
        "food_remaining": [.az: "Qal\u{0131}b", .en: "Remaining", .ru: "\u{041E}\u{0441}\u{0442}\u{0430}\u{043B}\u{043E}\u{0441}\u{044C}"],
        "food_completed": [.az: "Tamamland\u{0131}", .en: "Completed", .ru: "\u{0417}\u{0430}\u{0432}\u{0435}\u{0440}\u{0448}\u{0435}\u{043D}\u{043E}"],
        "food_meal": [.az: "\u{00D6}\u{011F}\u{00FC}n", .en: "Meal", .ru: "\u{041F}\u{0440}\u{0438}\u{0451}\u{043C} \u{043F}\u{0438}\u{0449}\u{0438}"],
        "food_edit_goal": [.az: "H\u{0259}d\u{0259}fi D\u{0259}yi\u{015F}", .en: "Edit Goal", .ru: "\u{0418}\u{0437}\u{043C}\u{0435}\u{043D}\u{0438}\u{0442}\u{044C} \u{0446}\u{0435}\u{043B}\u{044C}"],
        "food_macro_breakdown": [.az: "Makro Q\u{0131}r\u{0131}lmas\u{0131}", .en: "Macro Breakdown", .ru: "\u{041C}\u{0430}\u{043A}\u{0440}\u{043E}\u{043D}\u{0443}\u{0442}\u{0440}\u{0438}\u{0435}\u{043D}\u{0442}\u{044B}"],
        "food_protein": [.az: "Protein", .en: "Protein", .ru: "\u{0411}\u{0435}\u{043B}\u{043A}\u{0438}"],
        "food_carbs": [.az: "Karbohidrat", .en: "Carbs", .ru: "\u{0423}\u{0433}\u{043B}\u{0435}\u{0432}\u{043E}\u{0434}\u{044B}"],
        "food_fats": [.az: "Ya\u{011F}", .en: "Fats", .ru: "\u{0416}\u{0438}\u{0440}\u{044B}"],
        "food_add": [.az: "Qida \u{0259}lav\u{0259} et", .en: "Add food", .ru: "\u{0414}\u{043E}\u{0431}\u{0430}\u{0432}\u{0438}\u{0442}\u{044C} \u{0435}\u{0434}\u{0443}"],
        "food_add_title": [.az: "Qida \u{018F}lav\u{0259} Et", .en: "Add Food", .ru: "\u{0414}\u{043E}\u{0431}\u{0430}\u{0432}\u{0438}\u{0442}\u{044C} \u{0435}\u{0434}\u{0443}"],
        "food_take_photo": [.az: "Qidan\u{0131} \u{00C7}\u{0259}k", .en: "Take Photo", .ru: "\u{0421}\u{0444}\u{043E}\u{0442}\u{043E}\u{0433}\u{0440}\u{0430}\u{0444}\u{0438}\u{0440}\u{0443}\u{0439}\u{0442}\u{0435}"],
        "food_take_photo_desc": [.az: "Qidan\u{0131}z\u{0131}n \u{015E}\u{0259}klini \u{00C7}\u{0259}kin", .en: "Take a Photo of Your Food", .ru: "\u{0421}\u{0444}\u{043E}\u{0442}\u{043E}\u{0433}\u{0440}\u{0430}\u{0444}\u{0438}\u{0440}\u{0443}\u{0439}\u{0442}\u{0435} \u{0435}\u{0434}\u{0443}"],
        "food_ai_calc": [.az: "AI kalori hesablamas\u{0131}", .en: "AI calorie calculation", .ru: "AI \u{043F}\u{043E}\u{0434}\u{0441}\u{0447}\u{0451}\u{0442} \u{043A}\u{0430}\u{043B}\u{043E}\u{0440}\u{0438}\u{0439}"],
        "food_analyzing": [.az: "Analiz edilir...", .en: "Analyzing...", .ru: "\u{0410}\u{043D}\u{0430}\u{043B}\u{0438}\u{0437}..."],
        "food_analysis_done": [.az: "Analiz tamamland\u{0131}", .en: "Analysis complete", .ru: "\u{0410}\u{043D}\u{0430}\u{043B}\u{0438}\u{0437} \u{0437}\u{0430}\u{0432}\u{0435}\u{0440}\u{0448}\u{0451}\u{043D}"],
        "food_results_filled": [.az: "N\u{0259}tic\u{0259}l\u{0259}r formada dolduruldu", .en: "Results filled in the form", .ru: "\u{0420}\u{0435}\u{0437}\u{0443}\u{043B}\u{044C}\u{0442}\u{0430}\u{0442}\u{044B} \u{0437}\u{0430}\u{043F}\u{043E}\u{043B}\u{043D}\u{0435}\u{043D}\u{044B}"],
        "food_retake": [.az: "Yenid\u{0259}n \u{00C7}\u{0259}k", .en: "Retake", .ru: "\u{041F}\u{0435}\u{0440}\u{0435}\u{0441}\u{043D}\u{044F}\u{0442}\u{044C}"],
        "food_quick_add": [.az: "Tez \u{018F}lav\u{0259} Et", .en: "Quick Add", .ru: "\u{0411}\u{044B}\u{0441}\u{0442}\u{0440}\u{043E}\u{0435} \u{0434}\u{043E}\u{0431}\u{0430}\u{0432}\u{043B}\u{0435}\u{043D}\u{0438}\u{0435}"],
        "food_meal_type": [.az: "Öğün Növü", .en: "Meal Type", .ru: "Тип приёма"],
        "food_meal_breakfast": [.az: "Səhər", .en: "Breakfast", .ru: "Завтрак"],
        "food_meal_lunch": [.az: "Günorta", .en: "Lunch", .ru: "Обед"],
        "food_meal_dinner": [.az: "Axşam", .en: "Dinner", .ru: "Ужин"],
        "food_meal_snack": [.az: "Snack", .en: "Snack", .ru: "Перекус"],
        "food_name": [.az: "Qida Ad\u{0131}", .en: "Food Name", .ru: "\u{041D}\u{0430}\u{0437}\u{0432}\u{0430}\u{043D}\u{0438}\u{0435} \u{0435}\u{0434}\u{044B}"],
        "food_name_placeholder": [.az: "m\u{0259}s: Yumurta omlet", .en: "e.g: Egg omelette", .ru: "\u{043D}\u{0430}\u{043F}\u{0440}.: \u{041E}\u{043C}\u{043B}\u{0435}\u{0442}"],
        "food_calories": [.az: "Kalori (kcal)", .en: "Calories (kcal)", .ru: "\u{041A}\u{0430}\u{043B}\u{043E}\u{0440}\u{0438}\u{0438} (kcal)"],
        "food_calories_placeholder": [.az: "m\u{0259}s: 250", .en: "e.g: 250", .ru: "\u{043D}\u{0430}\u{043F}\u{0440}.: 250"],
        "food_macros": [.az: "Makrolar (opsional)", .en: "Macros (optional)", .ru: "\u{041C}\u{0430}\u{043A}\u{0440}\u{043E}\u{0441}\u{044B} (\u{043D}\u{0435}\u{043E}\u{0431}.)"],
        "food_notes_placeholder": [.az: "\u{018F}lav\u{0259} m\u{0259}lumat yaz\u{0131}n...", .en: "Write additional info...", .ru: "\u{0414}\u{043E}\u{043F}. \u{0438}\u{043D}\u{0444}\u{043E}\u{0440}\u{043C}\u{0430}\u{0446}\u{0438}\u{044F}..."],
        "food_added": [.az: "Qida u\u{011F}urla \u{0259}lav\u{0259} olundu!", .en: "Food added successfully!", .ru: "\u{0415}\u{0434}\u{0430} \u{0434}\u{043E}\u{0431}\u{0430}\u{0432}\u{043B}\u{0435}\u{043D}\u{0430}!"],
        "food_calorie_goal": [.az: "Kalori H\u{0259}d\u{0259}fi", .en: "Calorie Goal", .ru: "\u{0426}\u{0435}\u{043B}\u{044C} \u{043A}\u{0430}\u{043B}\u{043E}\u{0440}\u{0438}\u{0439}"],
        "food_daily_goal_set": [.az: "G\u{00FC}nl\u{00FC}k kalori h\u{0259}d\u{0259}fini t\u{0259}yin edin", .en: "Set daily calorie goal", .ru: "\u{0423}\u{0441}\u{0442}\u{0430}\u{043D}\u{043E}\u{0432}\u{0438}\u{0442}\u{0435} \u{0446}\u{0435}\u{043B}\u{044C}"],
        "food_quick_selection": [.az: "S\u{00FC}r\u{0259}tli se\u{00E7}im:", .en: "Quick selection:", .ru: "\u{0411}\u{044B}\u{0441}\u{0442}\u{0440}\u{044B}\u{0439} \u{0432}\u{044B}\u{0431}\u{043E}\u{0440}:"],
        "food_details": [.az: "Detallar", .en: "Details", .ru: "\u{0414}\u{0435}\u{0442}\u{0430}\u{043B}\u{0438}"],
        "food_notes_label": [.az: "Qeydl\u{0259}r", .en: "Notes", .ru: "\u{0417}\u{0430}\u{043C}\u{0435}\u{0442}\u{043A}\u{0438}"],
        "food_no_notes": [.az: "Qeyd yoxdur", .en: "No notes", .ru: "\u{041D}\u{0435}\u{0442} \u{0437}\u{0430}\u{043C}\u{0435}\u{0442}\u{043E}\u{043A}"],
        "food_breakfast": [.az: "S\u{0259}h\u{0259}r", .en: "Breakfast", .ru: "\u{0417}\u{0430}\u{0432}\u{0442}\u{0440}\u{0430}\u{043A}"],
        "food_lunch": [.az: "G\u{00FC}norta", .en: "Lunch", .ru: "\u{041E}\u{0431}\u{0435}\u{0434}"],
        "food_dinner": [.az: "Ax\u{015F}am", .en: "Dinner", .ru: "\u{0423}\u{0436}\u{0438}\u{043D}"],
        "food_snack": [.az: "Snack", .en: "Snack", .ru: "\u{041F}\u{0435}\u{0440}\u{0435}\u{043A}\u{0443}\u{0441}"],

        // ============================================================
        // MARK: - Profile
        // ============================================================
        "profile_type_client": [.az: "M\u{00FC}\u{015F}t\u{0259}ri", .en: "Client", .ru: "\u{041A}\u{043B}\u{0438}\u{0435}\u{043D}\u{0442}"],
        "profile_type_trainer": [.az: "M\u{00FC}\u{0259}llim", .en: "Trainer", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}"],
        "profile_edit": [.az: "Profili Redakt\u{0259} Et", .en: "Edit Profile", .ru: "\u{0420}\u{0435}\u{0434}\u{0430}\u{043A}\u{0442}\u{0438}\u{0440}\u{043E}\u{0432}\u{0430}\u{0442}\u{044C}"],
        "profile_weekly_progress": [.az: "H\u{0259}ft\u{0259}lik T\u{0259}r\u{0259}qqi", .en: "Weekly Progress", .ru: "\u{041D}\u{0435}\u{0434}\u{0435}\u{043B}\u{044C}\u{043D}\u{044B}\u{0439} \u{043F}\u{0440}\u{043E}\u{0433}\u{0440}\u{0435}\u{0441}\u{0441}"],
        "profile_workouts": [.az: "M\u{0259}\u{015F}ql\u{0259}r", .en: "Workouts", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0438}"],
        "profile_today": [.az: "Bu G\u{00FC}n", .en: "Today", .ru: "\u{0421}\u{0435}\u{0433}\u{043E}\u{0434}\u{043D}\u{044F}"],
        "profile_meals": [.az: "\u{00D6}\u{011F}\u{00FC}nl\u{0259}r", .en: "Meals", .ru: "\u{041F}\u{0440}\u{0438}\u{0451}\u{043C}\u{044B} \u{043F}\u{0438}\u{0449}\u{0438}"],
        "profile_goals": [.az: "M\u{0259}qs\u{0259}dl\u{0259}rim", .en: "My Goals", .ru: "\u{041C}\u{043E}\u{0438} \u{0446}\u{0435}\u{043B}\u{0438}"],
        "profile_age": [.az: "Ya\u{015F}", .en: "Age", .ru: "\u{0412}\u{043E}\u{0437}\u{0440}\u{0430}\u{0441}\u{0442}"],
        "profile_weight": [.az: "\u{00C7}\u{0259}ki", .en: "Weight", .ru: "\u{0412}\u{0435}\u{0441}"],
        "profile_height": [.az: "Boy", .en: "Height", .ru: "\u{0420}\u{043E}\u{0441}\u{0442}"],
        "profile_goal_label": [.az: "M\u{0259}qs\u{0259}d:", .en: "Goal:", .ru: "\u{0426}\u{0435}\u{043B}\u{044C}:"],
        "profile_settings": [.az: "T\u{0259}nziml\u{0259}m\u{0259}l\u{0259}r", .en: "Settings", .ru: "\u{041D}\u{0430}\u{0441}\u{0442}\u{0440}\u{043E}\u{0439}\u{043A}\u{0438}"],
        "profile_logout": [.az: "\u{00C7}\u{0131}x\u{0131}\u{015F}", .en: "Logout", .ru: "\u{0412}\u{044B}\u{0439}\u{0442}\u{0438}"],
        "profile_logout_confirm": [.az: "Hesabdan \u{00E7}\u{0131}xmaq ist\u{0259}diyiniz\u{0259} \u{0259}minsiniz?", .en: "Are you sure you want to logout?", .ru: "\u{0412}\u{044B} \u{0443}\u{0432}\u{0435}\u{0440}\u{0435}\u{043D}\u{044B} \u{0447}\u{0442}\u{043E} \u{0445}\u{043E}\u{0442}\u{0438}\u{0442}\u{0435} \u{0432}\u{044B}\u{0439}\u{0442}\u{0438}?"],
        "profile_statistics": [.az: "Statistikalar", .en: "Statistics", .ru: "\u{0421}\u{0442}\u{0430}\u{0442}\u{0438}\u{0441}\u{0442}\u{0438}\u{043A}\u{0430}"],
        "profile_rating": [.az: "Reytinq", .en: "Rating", .ru: "\u{0420}\u{0435}\u{0439}\u{0442}\u{0438}\u{043D}\u{0433}"],
        "profile_students": [.az: "T\u{0259}l\u{0259}b\u{0259}", .en: "Students", .ru: "\u{0421}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}\u{044B}"],
        "profile_experience": [.az: "T\u{0259}cr\u{00FC}b\u{0259}", .en: "Experience", .ru: "\u{041E}\u{043F}\u{044B}\u{0442}"],
        "profile_active_students": [.az: "Aktiv T\u{0259}l\u{0259}b\u{0259}l\u{0259}r", .en: "Active Students", .ru: "\u{0410}\u{043A}\u{0442}\u{0438}\u{0432}\u{043D}\u{044B}\u{0435} \u{0441}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}\u{044B}"],
        "profile_all_students": [.az: "B\u{00FC}t\u{00FC}n T\u{0259}l\u{0259}b\u{0259}l\u{0259}r", .en: "All Students", .ru: "\u{0412}\u{0441}\u{0435} \u{0441}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}\u{044B}"],
        "profile_specialty_bio": [.az: "\u{0130}xtisas v\u{0259} Bio", .en: "Specialty & Bio", .ru: "\u{0421}\u{043F}\u{0435}\u{0446}\u{0438}\u{0430}\u{043B}\u{0438}\u{0437}\u{0430}\u{0446}\u{0438}\u{044F} \u{0438} Bio"],
        "profile_specialty": [.az: "\u{0130}xtisas:", .en: "Specialty:", .ru: "\u{0421}\u{043F}\u{0435}\u{0446}.:"],
        "profile_bio": [.az: "Bio:", .en: "Bio:", .ru: "Bio:"],

        // ============================================================
        // MARK: - Edit Profile
        // ============================================================
        "edit_name": [.az: "Ad v\u{0259} Soyad", .en: "Full Name", .ru: "\u{0418}\u{043C}\u{044F} \u{0438} \u{0424}\u{0430}\u{043C}\u{0438}\u{043B}\u{0438}\u{044F}"],
        "edit_age": [.az: "Ya\u{015F}", .en: "Age", .ru: "\u{0412}\u{043E}\u{0437}\u{0440}\u{0430}\u{0441}\u{0442}"],
        "edit_weight": [.az: "\u{00C7}\u{0259}ki (kg)", .en: "Weight (kg)", .ru: "\u{0412}\u{0435}\u{0441} (\u{043A}\u{0433})"],
        "edit_height": [.az: "Boy (sm)", .en: "Height (cm)", .ru: "\u{0420}\u{043E}\u{0441}\u{0442} (\u{0441}\u{043C})"],
        "edit_goal": [.az: "M\u{0259}qs\u{0259}d", .en: "Goal", .ru: "\u{0426}\u{0435}\u{043B}\u{044C}"],
        "edit_goal_lose": [.az: "Ar\u{0131}qlamaq", .en: "Lose weight", .ru: "\u{041F}\u{043E}\u{0445}\u{0443}\u{0434}\u{0435}\u{0442}\u{044C}"],
        "edit_goal_muscle": [.az: "\u{018F}z\u{0259}l\u{0259} toplamaq", .en: "Build muscle", .ru: "\u{041D}\u{0430}\u{0431}\u{0440}\u{0430}\u{0442}\u{044C} \u{043C}\u{0430}\u{0441}\u{0441}\u{0443}"],
        "edit_goal_healthy": [.az: "Sa\u{011F}lam qalmaq", .en: "Stay healthy", .ru: "\u{0417}\u{0434}\u{043E}\u{0440}\u{043E}\u{0432}\u{044C}\u{0435}"],
        "edit_specialty": [.az: "\u{0130}xtisas", .en: "Specialty", .ru: "\u{0421}\u{043F}\u{0435}\u{0446}\u{0438}\u{0430}\u{043B}\u{0438}\u{0437}\u{0430}\u{0446}\u{0438}\u{044F}"],
        "edit_experience": [.az: "T\u{0259}cr\u{00FC}b\u{0259} (il)", .en: "Experience (years)", .ru: "\u{041E}\u{043F}\u{044B}\u{0442} (\u{043B}\u{0435}\u{0442})"],
        "edit_bio": [.az: "Haqq\u{0131}mda", .en: "About me", .ru: "\u{041E}\u{0431}\u{043E} \u{043C}\u{043D}\u{0435}"],
        "edit_bio_placeholder": [.az: "\u{00D6}z\u{00FC}n\u{00FC}z haqq\u{0131}nda q\u{0131}sa m\u{0259}lumat yaz\u{0131}n...", .en: "Write a short bio...", .ru: "\u{041A}\u{0440}\u{0430}\u{0442}\u{043A}\u{043E} \u{043E} \u{0441}\u{0435}\u{0431}\u{0435}..."],
        "edit_profile_title": [.az: "Profili Redakt\u{0259} Et", .en: "Edit Profile", .ru: "\u{0420}\u{0435}\u{0434}\u{0430}\u{043A}\u{0442}\u{0438}\u{0440}\u{043E}\u{0432}\u{0430}\u{0442}\u{044C} \u{043F}\u{0440}\u{043E}\u{0444}\u{0438}\u{043B}\u{044C}"],

        // ============================================================
        // MARK: - Teachers
        // ============================================================
        "teacher_title": [.az: "M\u{00FC}\u{0259}lliml\u{0259}r", .en: "Teachers", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}\u{044B}"],
        "teacher_search": [.az: "M\u{00FC}\u{0259}llim axtar...", .en: "Search teacher...", .ru: "\u{041F}\u{043E}\u{0438}\u{0441}\u{043A} \u{0442}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}\u{0430}..."],
        "teacher_not_found": [.az: "M\u{00FC}\u{0259}llim tap\u{0131}lmad\u{0131}", .en: "No teacher found", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440} \u{043D}\u{0435} \u{043D}\u{0430}\u{0439}\u{0434}\u{0435}\u{043D}"],
        "teacher_change_criteria": [.az: "Axtar\u{0131}\u{015F} kriteriyalar\u{0131}n\u{0131} d\u{0259}yi\u{015F}in", .en: "Change search criteria", .ru: "\u{0418}\u{0437}\u{043C}\u{0435}\u{043D}\u{0438}\u{0442}\u{0435} \u{043A}\u{0440}\u{0438}\u{0442}\u{0435}\u{0440}\u{0438}\u{0438}"],
        "teacher_profile": [.az: "M\u{00FC}\u{0259}llim Profili", .en: "Teacher Profile", .ru: "\u{041F}\u{0440}\u{043E}\u{0444}\u{0438}\u{043B}\u{044C} \u{0442}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}\u{0430}"],
        "teacher_about": [.az: "Haqq\u{0131}nda", .en: "About", .ru: "\u{041E} \u{0442}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}\u{0435}"],
        "teacher_contact": [.az: "M\u{00FC}\u{0259}lliml\u{0259} \u{018F}laq\u{0259}", .en: "Contact Teacher", .ru: "\u{0421}\u{0432}\u{044F}\u{0437}\u{0430}\u{0442}\u{044C}\u{0441}\u{044F}"],
        "teacher_view_program": [.az: "Proqrama Bax", .en: "View Program", .ru: "\u{041F}\u{0440}\u{043E}\u{0433}\u{0440}\u{0430}\u{043C}\u{043C}\u{0430}"],
        "teacher_avg_rating": [.az: "Orta Reytinq", .en: "Avg. Rating", .ru: "\u{0421}\u{0440}. \u{0440}\u{0435}\u{0439}\u{0442}\u{0438}\u{043D}\u{0433}"],
        "teacher_cat_all": [.az: "Ham\u{0131}s\u{0131}", .en: "All", .ru: "\u{0412}\u{0441}\u{0435}"],
        "teacher_cat_fitness": [.az: "Fitness", .en: "Fitness", .ru: "\u{0424}\u{0438}\u{0442}\u{043D}\u{0435}\u{0441}"],
        "teacher_cat_strength": [.az: "G\u{00FC}c", .en: "Strength", .ru: "\u{0421}\u{0438}\u{043B}\u{0430}"],
        "teacher_cat_cardio": [.az: "Kardio", .en: "Cardio", .ru: "\u{041A}\u{0430}\u{0440}\u{0434}\u{0438}\u{043E}"],
        "teacher_cat_yoga": [.az: "Yoga", .en: "Yoga", .ru: "\u{0419}\u{043E}\u{0433}\u{0430}"],
        "teacher_cat_nutrition": [.az: "Qidalanma", .en: "Nutrition", .ru: "Питание"],
        "teacher_experience": [.az: "Təcrübə", .en: "Experience", .ru: "Опыт"],
        "teacher_student_label": [.az: "Tələbə", .en: "Student", .ru: "Студент"],
        "teacher_rating": [.az: "Reytinq", .en: "Rating", .ru: "Рейтинг"],
        "teacher_students_count": [.az: "tələbə", .en: "students", .ru: "студентов"],

        // ============================================================
        // MARK: - Settings
        // ============================================================
        "settings_notifications": [.az: "Bildiri\u{015F}l\u{0259}r", .en: "Notifications", .ru: "\u{0423}\u{0432}\u{0435}\u{0434}\u{043E}\u{043C}\u{043B}\u{0435}\u{043D}\u{0438}\u{044F}"],
        "settings_security": [.az: "T\u{0259}hl\u{00FC}k\u{0259}sizlik", .en: "Security", .ru: "\u{0411}\u{0435}\u{0437}\u{043E}\u{043F}\u{0430}\u{0441}\u{043D}\u{043E}\u{0441}\u{0442}\u{044C}"],
        "settings_premium": [.az: "Premium", .en: "Premium", .ru: "Premium"],
        "settings_about": [.az: "Haqq\u{0131}nda", .en: "About", .ru: "\u{041E} \u{043F}\u{0440}\u{0438}\u{043B}\u{043E}\u{0436}\u{0435}\u{043D}\u{0438}\u{0438}"],
        "settings_general": [.az: "\u{00DC}mumi", .en: "General", .ru: "\u{041E}\u{0431}\u{0449}\u{0438}\u{0435}"],
        "settings_reminders": [.az: "Xat\u{0131}rlatmalar", .en: "Reminders", .ru: "\u{041D}\u{0430}\u{043F}\u{043E}\u{043C}\u{0438}\u{043D}\u{0430}\u{043D}\u{0438}\u{044F}"],
        "settings_workout_reminders": [.az: "M\u{0259}\u{015F}q xat\u{0131}rlatmalar\u{0131}", .en: "Workout reminders", .ru: "\u{041D}\u{0430}\u{043F}\u{043E}\u{043C}. \u{043E} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0430}\u{0445}"],
        "settings_meal_reminders": [.az: "Qida xat\u{0131}rlatmalar\u{0131}", .en: "Meal reminders", .ru: "\u{041D}\u{0430}\u{043F}\u{043E}\u{043C}. \u{043E} \u{043F}\u{0438}\u{0442}\u{0430}\u{043D}\u{0438}\u{0438}"],
        "settings_weekly_report": [.az: "H\u{0259}ft\u{0259}lik hesabat", .en: "Weekly report", .ru: "\u{041D}\u{0435}\u{0434}\u{0435}\u{043B}\u{044C}\u{043D}\u{044B}\u{0439} \u{043E}\u{0442}\u{0447}\u{0451}\u{0442}"],
        "settings_reminder_desc": [.az: "M\u{0259}\u{015F}q v\u{0259} qida qeydl\u{0259}riniz \u{00FC}\u{00E7}\u{00FC}n xat\u{0131}rlatmalar al\u{0131}n", .en: "Get reminders for workouts and meals", .ru: "\u{041F}\u{043E}\u{043B}\u{0443}\u{0447}\u{0430}\u{0439}\u{0442}\u{0435} \u{043D}\u{0430}\u{043F}\u{043E}\u{043C}\u{0438}\u{043D}\u{0430}\u{043D}\u{0438}\u{044F}"],
        "settings_biometric": [.az: "Biometrik", .en: "Biometric", .ru: "\u{0411}\u{0438}\u{043E}\u{043C}\u{0435}\u{0442}\u{0440}\u{0438}\u{044F}"],
        "settings_quick_login": [.az: "Tez giri\u{015F} \u{00FC}\u{00E7}\u{00FC}n", .en: "For quick login", .ru: "\u{0414}\u{043B}\u{044F} \u{0431}\u{044B}\u{0441}\u{0442}\u{0440}\u{043E}\u{0433}\u{043E} \u{0432}\u{0445}\u{043E}\u{0434}\u{0430}"],
        "settings_biometric_desc": [.az: "T\u{0259}tbiq\u{0259} %@ il\u{0259} daxil olun", .en: "Login with %@", .ru: "\u{0412}\u{043E}\u{0439}\u{0434}\u{0438}\u{0442}\u{0435} \u{0441} \u{043F}\u{043E}\u{043C}\u{043E}\u{0449}\u{044C}\u{044E} %@"],
        "settings_change_password": [.az: "\u{015E}ifr\u{0259}ni D\u{0259}yi\u{015F}", .en: "Change Password", .ru: "\u{0421}\u{043C}\u{0435}\u{043D}\u{0438}\u{0442}\u{044C} \u{043F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}"],
        "settings_remove_password": [.az: "\u{015E}ifr\u{0259}ni Sil", .en: "Remove Password", .ru: "\u{0423}\u{0434}\u{0430}\u{043B}\u{0438}\u{0442}\u{044C} \u{043F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}"],
        "settings_set_password": [.az: "\u{015E}ifr\u{0259} T\u{0259}yin Et", .en: "Set Password", .ru: "\u{0423}\u{0441}\u{0442}\u{0430}\u{043D}\u{043E}\u{0432}\u{0438}\u{0442}\u{044C} \u{043F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}"],
        "settings_password_section": [.az: "\u{015E}ifr\u{0259}", .en: "Password", .ru: "\u{041F}\u{0430}\u{0440}\u{043E}\u{043B}\u{044C}"],
        "settings_4digit": [.az: "4 r\u{0259}q\u{0259}mli \u{015F}ifr\u{0259} daxil edin", .en: "Enter 4-digit PIN", .ru: "\u{0412}\u{0432}\u{0435}\u{0434}\u{0438}\u{0442}\u{0435} 4-\u{0437}\u{043D}\u{0430}\u{0447}\u{043D}\u{044B}\u{0439} PIN"],
        "settings_4digit_desc": [.az: "T\u{0259}tbiq \u{00FC}\u{00E7}\u{00FC}n 4 r\u{0259}q\u{0259}mli \u{015F}ifr\u{0259} t\u{0259}yin edin", .en: "Set a 4-digit PIN for the app", .ru: "\u{0423}\u{0441}\u{0442}\u{0430}\u{043D}\u{043E}\u{0432}\u{0438}\u{0442}\u{0435} 4-\u{0437}\u{043D}\u{0430}\u{0447}\u{043D}\u{044B}\u{0439} PIN"],
        "settings_password_repeat": [.az: "\u{015E}ifr\u{0259} t\u{0259}krar\u{0131}", .en: "Confirm PIN", .ru: "\u{041F}\u{043E}\u{0434}\u{0442}\u{0432}\u{0435}\u{0440}\u{0434}\u{0438}\u{0442}\u{0435} PIN"],
        "settings_passwords_mismatch": [.az: "\u{015E}ifr\u{0259}l\u{0259}r uy\u{011F}un g\u{0259}lmir", .en: "PINs don't match", .ru: "PIN \u{043D}\u{0435} \u{0441}\u{043E}\u{0432}\u{043F}\u{0430}\u{0434}\u{0430}\u{044E}\u{0442}"],
        "settings_password_4digits": [.az: "\u{015E}ifr\u{0259} 4 r\u{0259}q\u{0259}m olmal\u{0131}d\u{0131}r", .en: "PIN must be 4 digits", .ru: "PIN \u{0434}\u{043E}\u{043B}\u{0436}\u{0435}\u{043D} \u{0431}\u{044B}\u{0442}\u{044C} 4 \u{0446}\u{0438}\u{0444}\u{0440}\u{044B}"],
        "settings_remove_password_confirm": [.az: "T\u{0259}tbiq \u{015F}ifr\u{0259}sini silm\u{0259}k ist\u{0259}diyiniz\u{0259} \u{0259}minsiniz?", .en: "Are you sure you want to remove the PIN?", .ru: "\u{0423}\u{0434}\u{0430}\u{043B}\u{0438}\u{0442}\u{044C} PIN?"],
        "settings_2fa": [.az: "\u{0130}ki faktorlu autentifikasiya", .en: "Two-factor authentication", .ru: "\u{0414}\u{0432}\u{0443}\u{0445}\u{0444}\u{0430}\u{043A}\u{0442}\u{043E}\u{0440}\u{043D}\u{0430}\u{044F}"],
        "settings_extra_security": [.az: "\u{018F}lav\u{0259} T\u{0259}hl\u{00FC}k\u{0259}sizlik", .en: "Additional Security", .ru: "\u{0414}\u{043E}\u{043F}. \u{0431}\u{0435}\u{0437}\u{043E}\u{043F}\u{0430}\u{0441}\u{043D}\u{043E}\u{0441}\u{0442}\u{044C}"],
        "settings_coming_soon": [.az: "Tezlikl\u{0259}", .en: "Coming soon", .ru: "\u{0421}\u{043A}\u{043E}\u{0440}\u{043E}"],
        "settings_permission_required": [.az: "\u{0130}caz\u{0259} T\u{0259}l\u{0259}b Olunur", .en: "Permission Required", .ru: "\u{0422}\u{0440}\u{0435}\u{0431}\u{0443}\u{0435}\u{0442}\u{0441}\u{044F} \u{0440}\u{0430}\u{0437}\u{0440}\u{0435}\u{0448}\u{0435}\u{043D}\u{0438}\u{0435}"],
        "settings_permission_desc": [.az: "Bildiri\u{015F}l\u{0259}r \u{00FC}\u{00E7}\u{00FC}n icaz\u{0259} verin", .en: "Allow notifications", .ru: "\u{0420}\u{0430}\u{0437}\u{0440}\u{0435}\u{0448}\u{0438}\u{0442}\u{0435} \u{0443}\u{0432}\u{0435}\u{0434}\u{043E}\u{043C}\u{043B}\u{0435}\u{043D}\u{0438}\u{044F}"],
        "settings_open_settings": [.az: "T\u{0259}nziml\u{0259}m\u{0259}l\u{0259}r", .en: "Settings", .ru: "\u{041D}\u{0430}\u{0441}\u{0442}\u{0440}\u{043E}\u{0439}\u{043A}\u{0438}"],

        // ============================================================
        // MARK: - About
        // ============================================================
        "about_title": [.az: "Haqq\u{0131}nda", .en: "About", .ru: "\u{041E} \u{043F}\u{0440}\u{0438}\u{043B}\u{043E}\u{0436}\u{0435}\u{043D}\u{0438}\u{0438}"],
        "about_slogan": [.az: "G\u{00FC}c\u{0259} Ged\u{0259}n Yol", .en: "Path to Power", .ru: "\u{041F}\u{0443}\u{0442}\u{044C} \u{043A} \u{0441}\u{0438}\u{043B}\u{0435}"],
        "about_version": [.az: "Versiya 1.0.0", .en: "Version 1.0.0", .ru: "\u{0412}\u{0435}\u{0440}\u{0441}\u{0438}\u{044F} 1.0.0"],
        "about_description": [.az: "CoreVia fitness v\u{0259} qidalanma tracking t\u{0259}tbiqi", .en: "CoreVia fitness and nutrition tracking app", .ru: "\u{041F}\u{0440}\u{0438}\u{043B}\u{043E}\u{0436}\u{0435}\u{043D}\u{0438}\u{0435} CoreVia \u{0434}\u{043B}\u{044F} \u{0444}\u{0438}\u{0442}\u{043D}\u{0435}\u{0441}\u{0430}"],
        "about_features": [.az: "X\u{00FC}susiyy\u{0259}tl\u{0259}r", .en: "Features", .ru: "\u{0424}\u{0443}\u{043D}\u{043A}\u{0446}\u{0438}\u{0438}"],
        "about_workout_tracking": [.az: "M\u{0259}\u{015F}q Tracking", .en: "Workout Tracking", .ru: "\u{041E}\u{0442}\u{0441}\u{043B}\u{0435}\u{0436}\u{0438}\u{0432}\u{0430}\u{043D}\u{0438}\u{0435} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043E}\u{043A}"],
        "about_food_tracking": [.az: "Qida Tracking", .en: "Food Tracking", .ru: "\u{041E}\u{0442}\u{0441}\u{043B}\u{0435}\u{0436}\u{0438}\u{0432}\u{0430}\u{043D}\u{0438}\u{0435} \u{043F}\u{0438}\u{0442}\u{0430}\u{043D}\u{0438}\u{044F}"],
        "about_teacher_system": [.az: "M\u{00FC}\u{0259}llim Sistemi", .en: "Teacher System", .ru: "\u{0421}\u{0438}\u{0441}\u{0442}\u{0435}\u{043C}\u{0430} \u{0442}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}\u{043E}\u{0432}"],
        "about_statistics": [.az: "Statistika", .en: "Statistics", .ru: "\u{0421}\u{0442}\u{0430}\u{0442}\u{0438}\u{0441}\u{0442}\u{0438}\u{043A}\u{0430}"],
        "about_reminders": [.az: "Xat\u{0131}rlatmalar", .en: "Reminders", .ru: "\u{041D}\u{0430}\u{043F}\u{043E}\u{043C}\u{0438}\u{043D}\u{0430}\u{043D}\u{0438}\u{044F}"],
        "about_website": [.az: "Veb Sayt", .en: "Website", .ru: "\u{0412}\u{0435}\u{0431}-\u{0441}\u{0430}\u{0439}\u{0442}"],
        "about_contact": [.az: "\u{018F}laq\u{0259}", .en: "Contact", .ru: "\u{041A}\u{043E}\u{043D}\u{0442}\u{0430}\u{043A}\u{0442}\u{044B}"],
        "about_terms": [.az: "\u{0130}stifad\u{0259} \u{015E}\u{0259}rtl\u{0259}ri", .en: "Terms of Use", .ru: "\u{0423}\u{0441}\u{043B}\u{043E}\u{0432}\u{0438}\u{044F}"],
        "about_privacy": [.az: "M\u{0259}xfilik Siyas\u{0259}ti", .en: "Privacy Policy", .ru: "\u{041F}\u{043E}\u{043B}\u{0438}\u{0442}\u{0438}\u{043A}\u{0430} \u{043A}\u{043E}\u{043D}\u{0444}\u{0438}\u{0434}."],

        // ============================================================
        // MARK: - Premium
        // ============================================================
        "premium_title": [.az: "PREMIUM", .en: "PREMIUM", .ru: "PREMIUM"],
        "premium_subtitle": [.az: "B\u{00FC}t\u{00FC}n funksiyalara tam giri\u{015F}", .en: "Full access to all features", .ru: "\u{041F}\u{043E}\u{043B}\u{043D}\u{044B}\u{0439} \u{0434}\u{043E}\u{0441}\u{0442}\u{0443}\u{043F}"],
        "premium_unlimited": [.az: "Limitsiz M\u{0259}\u{015F}q", .en: "Unlimited Workouts", .ru: "\u{0411}\u{0435}\u{0437}\u{043B}\u{0438}\u{043C}\u{0438}\u{0442}\u{043D}\u{044B}\u{0435}"],
        "premium_unlimited_desc": [.az: "S\u{0131}n\u{0131}rs\u{0131}z m\u{0259}\u{015F}q qeydl\u{0259}ri yarat", .en: "Create unlimited workout logs", .ru: "\u{0421}\u{043E}\u{0437}\u{0434}\u{0430}\u{0432}\u{0430}\u{0439}\u{0442}\u{0435} \u{0431}\u{0435}\u{0437}\u{043B}\u{0438}\u{043C}\u{0438}\u{0442}\u{043D}\u{043E}"],
        "premium_stats": [.az: "\u{018F}trafl\u{0131} Statistika", .en: "Detailed Statistics", .ru: "\u{0414}\u{0435}\u{0442}\u{0430}\u{043B}\u{044C}\u{043D}\u{0430}\u{044F} \u{0441}\u{0442}\u{0430}\u{0442}\u{0438}\u{0441}\u{0442}\u{0438}\u{043A}\u{0430}"],
        "premium_stats_desc": [.az: "D\u{0259}rin analitika v\u{0259} t\u{0259}r\u{0259}qqi", .en: "Deep analytics and progress", .ru: "\u{0413}\u{043B}\u{0443}\u{0431}\u{043E}\u{043A}\u{0430}\u{044F} \u{0430}\u{043D}\u{0430}\u{043B}\u{0438}\u{0442}\u{0438}\u{043A}\u{0430}"],
        "premium_notifications": [.az: "Smart Bildiri\u{015F}l\u{0259}r", .en: "Smart Notifications", .ru: "\u{0423}\u{043C}\u{043D}\u{044B}\u{0435} \u{0443}\u{0432}\u{0435}\u{0434}\u{043E}\u{043C}\u{043B}\u{0435}\u{043D}\u{0438}\u{044F}"],
        "premium_notifications_desc": [.az: "A\u{011F}\u{0131}ll\u{0131} xat\u{0131}rlatma sistemi", .en: "Smart reminder system", .ru: "\u{0423}\u{043C}\u{043D}\u{0430}\u{044F} \u{0441}\u{0438}\u{0441}\u{0442}\u{0435}\u{043C}\u{0430}"],
        "premium_teachers": [.az: "Premium M\u{00FC}\u{0259}lliml\u{0259}r", .en: "Premium Teachers", .ru: "\u{041F}\u{0440}\u{0435}\u{043C}\u{0438}\u{0443}\u{043C} \u{0442}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}\u{044B}"],
        "premium_teachers_desc": [.az: "\u{018F}n yax\u{015F}\u{0131} m\u{00FC}\u{0259}lliml\u{0259}rl\u{0259} \u{0259}laq\u{0259}", .en: "Access to best teachers", .ru: "\u{0414}\u{043E}\u{0441}\u{0442}\u{0443}\u{043F} \u{043A} \u{043B}\u{0443}\u{0447}\u{0448}\u{0438}\u{043C}"],
        "premium_ai": [.az: "AI T\u{00F6}vsiy\u{0259}l\u{0259}ri", .en: "AI Recommendations", .ru: "AI \u{0440}\u{0435}\u{043A}\u{043E}\u{043C}\u{0435}\u{043D}\u{0434}\u{0430}\u{0446}\u{0438}\u{0438}"],
        "premium_ai_desc": [.az: "S\u{00FC}ni intellekt \u{0259}sasl\u{0131} planlar", .en: "AI-based plans", .ru: "\u{041F}\u{043B}\u{0430}\u{043D}\u{044B} \u{043D}\u{0430} \u{043E}\u{0441}\u{043D}\u{043E}\u{0432}\u{0435} AI"],
        "premium_cloud": [.az: "Cloud Sync", .en: "Cloud Sync", .ru: "Cloud Sync"],
        "premium_cloud_desc": [.az: "B\u{00FC}t\u{00FC}n cihazlarda sinxronizasiya", .en: "Sync across all devices", .ru: "\u{0421}\u{0438}\u{043D}\u{0445}\u{0440}\u{043E}\u{043D}\u{0438}\u{0437}\u{0430}\u{0446}\u{0438}\u{044F}"],
        "premium_monthly": [.az: "Ayl\u{0131}q", .en: "Monthly", .ru: "\u{041C}\u{0435}\u{0441}\u{044F}\u{0447}\u{043D}\u{044B}\u{0439}"],
        "premium_yearly": [.az: "\u{0130}llik", .en: "Yearly", .ru: "\u{0413}\u{043E}\u{0434}\u{043E}\u{0432}\u{043E}\u{0439}"],
        "premium_month": [.az: "ay", .en: "mo", .ru: "\u{043C}\u{0435}\u{0441}"],
        "premium_year": [.az: "il", .en: "yr", .ru: "\u{0433}\u{043E}\u{0434}"],
        "premium_most_popular": [.az: "\u{018F}N POPULYAR", .en: "MOST POPULAR", .ru: "\u{041F}\u{041E}\u{041F}\u{0423}\u{041B}\u{042F}\u{0420}\u{041D}\u{042B}\u{0419}"],
        "premium_save_20": [.az: "20% Q\u{018F}NA\u{018F}T", .en: "SAVE 20%", .ru: "\u{042D}\u{041A}\u{041E}\u{041D}\u{041E}\u{041C}\u{0418}\u{042F} 20%"],
        "premium_activate": [.az: "Premium Aktivl\u{0259}\u{015F}dir", .en: "Activate Premium", .ru: "\u{0410}\u{043A}\u{0442}\u{0438}\u{0432}\u{0438}\u{0440}\u{043E}\u{0432}\u{0430}\u{0442}\u{044C} Premium"],
        "premium_terms": [.az: "\u{00D6}d\u{0259}ni\u{015F} Apple ID hesab\u{0131}n\u{0131}zdan \u{00E7}\u{0131}x\u{0131}lacaq.", .en: "Payment will be charged to your Apple ID.", .ru: "\u{041E}\u{043F}\u{043B}\u{0430}\u{0442}\u{0430} \u{0441} Apple ID."],
        "premium_terms2": [.az: "\u{0130}stifad\u{0259} \u{015F}\u{0259}rtl\u{0259}ri v\u{0259} m\u{0259}xfilik siyas\u{0259}ti t\u{0259}tbiq olunur.", .en: "Terms of use and privacy policy apply.", .ru: "\u{041F}\u{0440}\u{0438}\u{043C}\u{0435}\u{043D}\u{044F}\u{044E}\u{0442}\u{0441}\u{044F} \u{0443}\u{0441}\u{043B}\u{043E}\u{0432}\u{0438}\u{044F}."],

        // Premium View — yeni açarlar
        "premium_active": [.az: "Premium Aktiv", .en: "Premium Active", .ru: "Премиум активен"],
        "premium_all_unlocked": [.az: "B\u{00FC}t\u{00FC}n imkanlar\u{0131} a\u{00E7}\u{0131}n, limitl\u{0259}r olmadan", .en: "Unlock all features, no limits", .ru: "Откройте все функции без ограничений"],
        "premium_features_title": [.az: "Premium X\u{00FC}susiyy\u{0259}tl\u{0259}r", .en: "Premium Features", .ru: "Премиум функции"],
        "premium_go_premium": [.az: "Premium-a ke\u{00E7}", .en: "Go Premium", .ru: "Стать Премиум"],
        "premium_cancel": [.az: "Premium-i l\u{0259}\u{011F}v et", .en: "Cancel Premium", .ru: "Отменить Премиум"],
        "premium_cancel_title": [.az: "Premium-i l\u{0259}\u{011F}v et", .en: "Cancel Premium", .ru: "Отмена Премиум"],
        "premium_cancel_message": [.az: "Premium abun\u{0259}liyinizi l\u{0259}\u{011F}v etm\u{0259}k ist\u{0259}yirsiniz? B\u{00FC}t\u{00FC}n premium x\u{00FC}susiyy\u{0259}tl\u{0259}r\u{0259} giri\u{015F}iniz bit\u{0259}c\u{0259}k.", .en: "Do you want to cancel your premium subscription? You will lose access to all premium features.", .ru: "Вы хотите отменить подписку? Вы потеряете доступ ко всем премиум функциям."],
        "premium_cancel_yes": [.az: "B\u{0259}li, l\u{0259}\u{011F}v et", .en: "Yes, cancel", .ru: "Да, отменить"],
        "premium_cancel_no": [.az: "Xeyr", .en: "No", .ru: "Нет"],
        "premium_user": [.az: "Premium \u{0130}stifad\u{0259}\u{00E7}i", .en: "Premium User", .ru: "Премиум пользователь"],
        "premium_all_active": [.az: "B\u{00FC}t\u{00FC}n x\u{00FC}susiyy\u{0259}tl\u{0259}r aktivdir", .en: "All features are active", .ru: "Все функции активны"],
        "premium_can_cancel": [.az: "\u{0130}st\u{0259}diyiniz vaxt l\u{0259}\u{011F}v ed\u{0259} bil\u{0259}rsiniz", .en: "You can cancel anytime", .ru: "Вы можете отменить в любое время"],
        "premium_appstore_payment": [.az: "\u{00D6}d\u{0259}ni\u{015F} App Store hesab\u{0131}n\u{0131}z \u{00FC}z\u{0259}rind\u{0259}n al\u{0131}n\u{0131}r", .en: "Payment is charged through your App Store account", .ru: "Оплата списывается через App Store"],
        "premium_save_33": [.az: "33% q\u{0259}na\u{0259}t", .en: "Save 33%", .ru: "Экономия 33%"],
        "premium_error": [.az: "X\u{0259}ta ba\u{015F} verdi", .en: "An error occurred", .ru: "Произошла ошибка"],
        "premium_badge": [.az: "Premium", .en: "Premium", .ru: "Премиум"],
        "premium_go_banner": [.az: "Premium-a ke\u{00E7}in", .en: "Go Premium", .ru: "Стать Премиум"],
        "premium_go_banner_desc": [.az: "AI analiz, detall\u{0131} statistika v\u{0259} daha \u{00E7}ox", .en: "AI analysis, detailed statistics and more", .ru: "AI анализ, детальная статистика и многое другое"],

        // Profil səhifəsi əlavə açarlar
        "profile_new_workout": [.az: "Yeni \u{0130}dman", .en: "New Workout", .ru: "Новая тренировка"],
        "profile_start_activity": [.az: "H\u{0259}r\u{0259}k\u{0259}t\u{0259} Ba\u{015F}la", .en: "Start Activity", .ru: "Начать активность"],
        "profile_gps_desc": [.az: "GPS il\u{0259} qa\u{00E7}\u{0131}\u{015F}, gezinti izl\u{0259}", .en: "Track running, walking with GPS", .ru: "Отслеживайте бег и ходьбу с GPS"],
        "profile_calorie": [.az: "Kalori", .en: "Calorie", .ru: "Калории"],
        "profile_my_teachers": [.az: "M\u{00FC}\u{0259}lliml\u{0259}rim", .en: "My Teachers", .ru: "Мои тренеры"],
        "profile_change_teacher": [.az: "M\u{00FC}\u{0259}llimi D\u{0259}yi\u{015F}", .en: "Change Teacher", .ru: "Сменить тренера"],
        "profile_select_teacher": [.az: "M\u{00FC}\u{0259}llim Se\u{00E7}", .en: "Select Teacher", .ru: "Выбрать тренера"],
        "profile_view_teachers": [.az: "Professional m\u{00FC}\u{0259}lliml\u{0259}r\u{0259} bax\u{0131}n", .en: "View professional teachers", .ru: "Посмотреть профессиональных тренеров"],
        "profile_quick_actions": [.az: "S\u{00FC}r\u{0259}tli \u{018F}m\u{0259}liyyatlar", .en: "Quick Actions", .ru: "Быстрые действия"],
        "profile_add_food": [.az: "Qida \u{018F}lav\u{0259} Et", .en: "Add Food", .ru: "Добавить еду"],
        "profile_today_highlights": [.az: "Bug\u{00FC}n\u{00FC}n N\u{0259}tic\u{0259}l\u{0259}ri", .en: "Today's Highlights", .ru: "Результаты дня"],
        "premium_active_badge": [.az: "Aktiv", .en: "Active", .ru: "Активен"],
        "premium_active_desc": [.az: "Bütün premium funksiyalara tam giriş", .en: "Full access to all premium features", .ru: "Полный доступ ко всем премиум функциям"],
        "premium_plan": [.az: "Plan", .en: "Plan", .ru: "План"],
        "premium_price": [.az: "Qiymət", .en: "Price", .ru: "Цена"],
        "premium_cancel_button": [.az: "Premium-i ləğv et", .en: "Cancel Premium", .ru: "Отменить Премиум"],
        "premium_unlock": [.az: "Premium ilə Açın", .en: "Unlock with Premium", .ru: "Откройте с Премиум"],
        "premium_unlock_desc": [.az: "Bütün funksiyalara giriş əldə edin", .en: "Get access to all features", .ru: "Получите доступ ко всем функциям"],
        "premium_trial_info": [.az: "İstədiyiniz vaxt ləğv edə bilərsiniz", .en: "Cancel anytime", .ru: "Отмена в любое время"],
        "premium_activate_dev": [.az: "Aktivləşdir (Test)", .en: "Activate (Test)", .ru: "Активировать (Тест)"],
        "premium_coming_soon": [.az: "App Store ilə ödəniş tezliklə əlavə olunacaq", .en: "App Store payment coming soon", .ru: "Оплата через App Store скоро"],
        "premium_feature_activities": [.az: "GPS Marşrut İzləmə", .en: "GPS Route Tracking", .ru: "GPS трекинг маршрутов"],
        "premium_feature_activities_desc": [.az: "Qaçış, gəzinti və velosiped izləməsi", .en: "Running, walking and cycling tracking", .ru: "Отслеживание бега, ходьбы и велосипеда"],
        "premium_feature_chat": [.az: "AI Trainer Chat", .en: "AI Trainer Chat", .ru: "AI чат с тренером"],
        "premium_feature_chat_desc": [.az: "Süni intellekt trenerinizlə söhbət edin", .en: "Chat with your AI trainer", .ru: "Общайтесь с AI тренером"],
        "premium_feature_food": [.az: "Şəkillə Qida Analizi", .en: "Photo Food Analysis", .ru: "Анализ еды по фото"],
        "premium_feature_food_desc": [.az: "Şəkil çəkin, kalori avtomatik hesablansın", .en: "Take a photo, get automatic calorie count", .ru: "Сфотографируйте, получите автоматический подсчет калорий"],
        "premium_feature_trainer": [.az: "Professional Trainerlər", .en: "Professional Trainers", .ru: "Профессиональные тренеры"],
        "premium_feature_trainer_desc": [.az: "Yaxşı trainerlərlə işləyin", .en: "Work with the best trainers", .ru: "Работайте с лучшими тренерами"],
        "premium_feature_stats": [.az: "Detallı Statistika", .en: "Detailed Statistics", .ru: "Детальная статистика"],
        "premium_feature_stats_desc": [.az: "Haftalıq və aylıq inkişaf hesabatları", .en: "Weekly and monthly progress reports", .ru: "Еженедельные и ежемесячные отчеты"],
        "premium_feature_ai": [.az: "AI Tövsiyələri", .en: "AI Recommendations", .ru: "AI рекомендации"],
        "premium_feature_ai_desc": [.az: "Süni intellekt əsaslı fərdi planlar", .en: "AI-based personalized plans", .ru: "Персонализированные планы на основе AI"],
        "premium_required": [.az: "Premium Lazımdır", .en: "Premium Required", .ru: "Требуется Премиум"],
        "common_unknown_error": [.az: "Naməlum xəta", .en: "Unknown error", .ru: "Неизвестная ошибка"],

        // Premium Feature satırları
        "premium_feat_ai_calorie": [.az: "AI Kalori Analizi", .en: "AI Calorie Analysis", .ru: "AI анализ калорий"],
        "premium_feat_ai_calorie_desc": [.az: "\u{015E}\u{0259}kil \u{00E7}\u{0259}kin, kalori avtomatik hesablans\u{0131}n", .en: "Take a photo, calories calculated automatically", .ru: "Сфотографируйте, калории рассчитаются автоматически"],
        "premium_feat_food_photo": [.az: "\u{015E}\u{0259}kil il\u{0259} qida analizi", .en: "Photo food analysis", .ru: "Анализ еды по фото"],
        "premium_feat_food_photo_desc": [.az: "AI il\u{0259} qida tan\u{0131}mas\u{0131} v\u{0259} besin d\u{0259}y\u{0259}rl\u{0259}ri", .en: "AI food recognition and nutritional values", .ru: "Распознавание еды и пищевая ценность"],
        "premium_feat_gps": [.az: "GPS H\u{0259}r\u{0259}k\u{0259}t \u{0130}zl\u{0259}m\u{0259}", .en: "GPS Activity Tracking", .ru: "GPS трекинг активности"],
        "premium_feat_gps_desc": [.az: "Qa\u{00E7}\u{0131}\u{015F}, gezinti v\u{0259} velosiped izl\u{0259}m\u{0259}", .en: "Running, walking and cycling tracking", .ru: "Отслеживание бега, ходьбы и велосипеда"],
        "premium_feat_teachers": [.az: "M\u{00FC}\u{0259}llim sistemi", .en: "Teacher system", .ru: "Система тренеров"],
        "premium_feat_teachers_desc": [.az: "Professional m\u{00FC}\u{0259}lliml\u{0259}r\u{0259} qo\u{015F}ulun", .en: "Connect with professional teachers", .ru: "Подключитесь к профессиональным тренерам"],
        "premium_feat_stats": [.az: "Detall\u{0131} statistika", .en: "Detailed statistics", .ru: "Детальная статистика"],
        "premium_feat_stats_desc": [.az: "H\u{0259}ft\u{0259}lik v\u{0259} ayl\u{0131}q inki\u{015F}af hesabatlar\u{0131}", .en: "Weekly and monthly progress reports", .ru: "Еженедельные и ежемесячные отчёты"],
        "premium_feat_notifications": [.az: "A\u{011F}\u{0131}ll\u{0131} bildiri\u{015F}l\u{0259}r", .en: "Smart notifications", .ru: "Умные уведомления"],
        "premium_feat_notifications_desc": [.az: "Yem\u{0259}k v\u{0259} idman xat\u{0131}rlatmalar\u{0131}", .en: "Meal and workout reminders", .ru: "Напоминания о еде и тренировках"],

        // Premium status satırları
        "premium_status_ai": [.az: "AI Kalori Analizi", .en: "AI Calorie Analysis", .ru: "AI анализ калорий"],
        "premium_status_gps": [.az: "GPS \u{0130}zl\u{0259}m\u{0259}", .en: "GPS Tracking", .ru: "GPS трекинг"],
        "premium_status_teachers": [.az: "M\u{00FC}\u{0259}llim Sistemi", .en: "Teacher System", .ru: "Система тренеров"],
        "premium_status_stats": [.az: "Detall\u{0131} Statistika", .en: "Detailed Statistics", .ru: "Детальная статистика"],

        // Vahidlər və About
        "unit_kcal": [.az: "kkal", .en: "kcal", .ru: "ккал"],
        "unit_kg": [.az: "kq", .en: "kg", .ru: "кг"],
        "unit_cm": [.az: "sm", .en: "cm", .ru: "см"],
        "about_made_with_love": [.az: "Azərbaycanda ❤️ ilə hazırlanıb", .en: "Made with ❤️ in Azerbaijan", .ru: "Сделано с ❤️ в Азербайджане"],
        "premium_currency": [.az: "₼", .en: "₼", .ru: "₼"],

        // ============================================================
        // MARK: - Trainer Dashboard
        // ============================================================
        "dashboard_total_subscribers": [.az: "Ümumi Abunəçilər", .en: "Total Subscribers", .ru: "Всего подписчиков"],
        "dashboard_active_students": [.az: "Aktiv Tələbələr", .en: "Active Students", .ru: "Активные студенты"],
        "dashboard_monthly_earnings": [.az: "Aylıq Gəlir", .en: "Monthly Earnings", .ru: "Ежемесячный доход"],
        "dashboard_total_plans": [.az: "Ümumi Planlar", .en: "Total Plans", .ru: "Всего планов"],
        "dashboard_student_progress": [.az: "Tələbə İnkişafı", .en: "Student Progress", .ru: "Прогресс студентов"],
        "dashboard_this_week": [.az: "Bu həftə", .en: "This week", .ru: "На этой неделе"],
        "dashboard_workouts": [.az: "idman", .en: "workouts", .ru: "тренировок"],
        "dashboard_avg_workouts": [.az: "Orta həftəlik idman", .en: "Avg weekly workouts", .ru: "Средн. тренировок/нед"],
        "dashboard_total_workouts": [.az: "Ümumi idmanlar", .en: "Total workouts", .ru: "Всего тренировок"],
        "dashboard_avg_weight": [.az: "Orta çəki", .en: "Avg weight", .ru: "Средний вес"],
        "dashboard_no_students": [.az: "Hələ tələbəniz yoxdur", .en: "No students yet", .ru: "Пока нет студентов"],
        "dashboard_no_students_desc": [.az: "Tələbələr Premium-a keçib sizə qoşulduqda burada görsənəcək", .en: "Students will appear here when they subscribe to Premium and join you", .ru: "Студенты появятся здесь, когда подпишутся на Премиум и присоединятся к вам"],
        "dashboard_stats_summary": [.az: "Statistika", .en: "Statistics", .ru: "Статистика"],
        "dashboard_training_plans": [.az: "İdman Planları", .en: "Training Plans", .ru: "Планы тренировок"],
        "dashboard_meal_plans": [.az: "Qida Planları", .en: "Meal Plans", .ru: "Планы питания"],
        "dashboard_weight": [.az: "Çəki", .en: "Weight", .ru: "Вес"],
        "dashboard_goal": [.az: "Məqsəd", .en: "Goal", .ru: "Цель"],
        "dashboard_plans": [.az: "plan", .en: "plans", .ru: "планов"],

        // ============================================================
        // MARK: - Activities (Hərəkətlər)
        // ============================================================
        "activities_title": [.az: "Hərəkətlər", .en: "Activities", .ru: "Активности"],
        "activities_subtitle": [.az: "Gəzintilərinizi və qaçışlarınızı izləyin", .en: "Track your walks and runs", .ru: "Отслеживайте прогулки и пробежки"],
        "activities_this_week": [.az: "Bu həftə", .en: "This week", .ru: "На этой неделе"],
        "activities_distance": [.az: "Məsafə", .en: "Distance", .ru: "Расстояние"],
        "activities_duration": [.az: "Müddət", .en: "Duration", .ru: "Длительность"],
        "activities_calorie": [.az: "Kalori", .en: "Calorie", .ru: "Калории"],
        "activities_active": [.az: "Aktiv", .en: "Active", .ru: "Активно"],
        "activities_time": [.az: "Vaxt", .en: "Time", .ru: "Время"],
        "activities_pace": [.az: "Temp", .en: "Pace", .ru: "Темп"],
        "activities_stop": [.az: "Dayandır", .en: "Stop", .ru: "Стоп"],
        "activities_history": [.az: "Tarixçə", .en: "History", .ru: "История"],
        "activities_assigned_plans": [.az: "Tapşırıqlar", .en: "Assigned Plans", .ru: "Назначенные планы"],
        "activities_all": [.az: "Hamısı", .en: "All", .ru: "Все"],
        "activities_not_found": [.az: "Hərəkət tapılmadı", .en: "No activity found", .ru: "Активностей не найдено"],
        "activities_start_hint": [.az: "Aşağıdakı + düyməyə basıb yeni hərəkət başlayın", .en: "Tap the + button below to start a new activity", .ru: "Нажмите + ниже, чтобы начать новую активность"],
        "activities_start": [.az: "Hərəkətə başla", .en: "Start Activity", .ru: "Начать активность"],
        "activities_begin": [.az: "BAŞLA", .en: "START", .ru: "СТАРТ"],
        "activities_walking": [.az: "Gəzinti", .en: "Walking", .ru: "Ходьба"],
        "activities_running": [.az: "Qaçış", .en: "Running", .ru: "Бег"],
        "activities_cycling": [.az: "Velosiped", .en: "Cycling", .ru: "Велосипед"],
        "activities_gps_tracking": [.az: "GPS Hərəkət İzləmə", .en: "GPS Activity Tracking", .ru: "GPS трекинг активности"],
        "activities_gps_desc": [.az: "Qaçış, gəzinti və velosiped marşrutlarınızı izləyin", .en: "Track your running, walking and cycling routes", .ru: "Отслеживайте маршруты бега, ходьбы и велосипеда"],
        "activities_premium_go": [.az: "Premium-a keç", .en: "Go Premium", .ru: "Стать Премиум"],
        "activities_hours_short": [.az: "s", .en: "h", .ru: "ч"],
        "activities_mins_short": [.az: "d", .en: "m", .ru: "м"],
        "activities_mins": [.az: "dəq", .en: "min", .ru: "мин"],

        // ============================================================
        // MARK: - Teachers Detail (Müəllim detalları)
        // ============================================================
        "teacher_join": [.az: "Müəllimlə Qoşul", .en: "Join Teacher", .ru: "Присоединиться"],
        "teacher_join_button": [.az: "Müəllimə Qoşul", .en: "Join Teacher", .ru: "Присоединиться к тренеру"],
        "teacher_already_joined": [.az: "Bu müəllimə qoşulmusunuz", .en: "You are already joined", .ru: "Вы уже присоединились"],
        "teacher_leave_button": [.az: "Ayrıl", .en: "Leave", .ru: "Покинуть"],
        "teacher_send_message": [.az: "Mesaj Göndər", .en: "Send Message", .ru: "Отправить сообщение"],
        "my_trainer": [.az: "Mənim Müəllimim", .en: "My Trainer", .ru: "Мой Тренер"],
        "trainer_personal_trainer": [.az: "Şəxsi Məşqçi", .en: "Personal Trainer", .ru: "Персональный тренер"],
        "teacher_assign_success_title": [.az: "Uğurlu!", .en: "Success!", .ru: "Успешно!"],
        "teacher_assign_success_msg": [.az: "müəllim olaraq təyin olundu!", .en: "assigned as your teacher!", .ru: "назначен(а) вашим тренером!"],
        "teacher_ok": [.az: "Tamam", .en: "OK", .ru: "ОК"],
        "teacher_error": [.az: "Xəta", .en: "Error", .ru: "Ошибка"],
        "teacher_unknown_error": [.az: "Bilinməyən xəta", .en: "Unknown error", .ru: "Неизвестная ошибка"],
        "teacher_premium_required": [.az: "Premium abunəlik lazımdır", .en: "Premium subscription required", .ru: "Требуется Премиум подписка"],
        "teacher_premium_feature": [.az: "Müəllim seçimi Premium funksiyasıdır", .en: "Teacher selection is a Premium feature", .ru: "Выбор тренера — Премиум функция"],

        // ============================================================
        // MARK: - Trainer Verification
        // ============================================================
        "verification_title": [.az: "Verifikasiya", .en: "Verification", .ru: "Верификация"],
        "verification_subtitle": [.az: "Müəllim profilinizi tamamlayın", .en: "Complete your teacher profile", .ru: "Заполните профиль тренера"],
        "verification_step_register": [.az: "Qeydiyyat", .en: "Registration", .ru: "Регистрация"],
        "verification_step_verify": [.az: "Verifikasiya", .en: "Verification", .ru: "Верификация"],
        "verification_photo_hint": [.az: "Bədən formanızı göstərən bir şəkil yükləyin. AI şəkilinizi analiz edəcək.", .en: "Upload a photo showing your body form. AI will analyze your photo.", .ru: "Загрузите фото, показывающее вашу форму. ИИ проанализирует фото."],
        "verification_select_photo": [.az: "Şəkil Seç", .en: "Select Photo", .ru: "Выбрать фото"],
        "verification_bio_placeholder": [.az: "Özünüz haqqında qısa məlumat yazın...", .en: "Write a short bio about yourself...", .ru: "Напишите кратко о себе..."],
        "verification_submit": [.az: "Verifikasiya üçün Göndər", .en: "Submit for Verification", .ru: "Отправить на верификацию"],
        "verification_select_photo_error": [.az: "Zəhmət olmasa şəkil seçin", .en: "Please select a photo", .ru: "Пожалуйста, выберите фото"],
        "verification_ai_score": [.az: "AI Skoru", .en: "AI Score", .ru: "Оценка ИИ"],
        "verification_continue": [.az: "Davam et", .en: "Continue", .ru: "Продолжить"],
        "verification_waiting": [.az: "Gözləyirəm", .en: "Waiting", .ru: "Ожидание"],
        "verification_retry": [.az: "Yenidən cəhd et", .en: "Try again", .ru: "Попробовать снова"],
        "verification_logout": [.az: "Çıxış", .en: "Logout", .ru: "Выйти"],

        // ============================================================
        // MARK: - Teacher Profile View
        // ============================================================
        "teacher_verified": [.az: "Doğrulanmış Müəllim", .en: "Verified Teacher", .ru: "Верифицированный тренер"],
        "teacher_pending": [.az: "Gözdən keçirilir", .en: "Under review", .ru: "На рассмотрении"],
        "teacher_rejected": [.az: "Rədd edildi", .en: "Rejected", .ru: "Отклонено"],
        "teacher_my_plans": [.az: "Planlarım", .en: "My Plans", .ru: "Мои планы"],
        "teacher_workout_plan": [.az: "İdman Planı", .en: "Workout Plan", .ru: "План тренировок"],
        "teacher_meal_plan": [.az: "Yemək Planı", .en: "Meal Plan", .ru: "План питания"],

        // Əlavə səhifə yazıları
        "route_no_map": [.az: "Xəritə məlumatı yoxdur", .en: "No map data available", .ru: "Нет данных карты"],
        "route_details": [.az: "Detallar", .en: "Details", .ru: "Детали"],
        "food_ai_calorie_analysis": [.az: "AI Kalori Analizi", .en: "AI Calorie Analysis", .ru: "AI анализ калорий"],
        "food_unlock_premium": [.az: "Premium ilə açın", .en: "Unlock with Premium", .ru: "Откройте с Премиум"],
        "food_go_premium": [.az: "Premium-a keç", .en: "Go Premium", .ru: "Стать Премиум"],

        // ============================================================
        // MARK: - Trainer (Müəllim xüsusi)
        // ============================================================
        "trainer_my_students": [.az: "T\u{0259}l\u{0259}b\u{0259}l\u{0259}rim", .en: "My Students", .ru: "\u{041C}\u{043E}\u{0438} \u{0441}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}\u{044B}"],
        "trainer_dashboard": [.az: "T\u{0259}limci Paneli", .en: "Trainer Dashboard", .ru: "\u{041F}\u{0430}\u{043D}\u{0435}\u{043B}\u{044C} \u{0442}\u{0440}\u{0435}\u{043D}\u{0435}\u{0440}\u{0430}"],
        "trainer_training_plans": [.az: "\u{0130}dman Planlar\u{0131}", .en: "Training Plans", .ru: "\u{041F}\u{043B}\u{0430}\u{043D}\u{044B} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043E}\u{043A}"],
        "trainer_meal_plans": [.az: "Qida Planlar\u{0131}", .en: "Meal Plans", .ru: "\u{041F}\u{043B}\u{0430}\u{043D}\u{044B} \u{043F}\u{0438}\u{0442}\u{0430}\u{043D}\u{0438}\u{044F}"],
        "trainer_create_training": [.az: "\u{0130}dman Plan\u{0131} Yarat", .en: "Create Training Plan", .ru: "\u{0421}\u{043E}\u{0437}\u{0434}\u{0430}\u{0442}\u{044C} \u{043F}\u{043B}\u{0430}\u{043D} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043E}\u{043A}"],
        "trainer_create_meal": [.az: "Qida Plan\u{0131} Yarat", .en: "Create Meal Plan", .ru: "\u{0421}\u{043E}\u{0437}\u{0434}\u{0430}\u{0442}\u{044C} \u{043F}\u{043B}\u{0430}\u{043D} \u{043F}\u{0438}\u{0442}\u{0430}\u{043D}\u{0438}\u{044F}"],
        "trainer_plan_type": [.az: "Plan N\u{00F6}v\u{00FC}", .en: "Plan Type", .ru: "\u{0422}\u{0438}\u{043F} \u{043F}\u{043B}\u{0430}\u{043D}\u{0430}"],
        "trainer_assign_student": [.az: "T\u{0259}l\u{0259}b\u{0259}y\u{0259} T\u{0259}yin Et", .en: "Assign to Student", .ru: "\u{041D}\u{0430}\u{0437}\u{043D}\u{0430}\u{0447}\u{0438}\u{0442}\u{044C} \u{0441}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}\u{0443}"],
        "trainer_select_student": [.az: "T\u{0259}l\u{0259}b\u{0259} Se\u{00E7}in", .en: "Select Student", .ru: "\u{0412}\u{044B}\u{0431}\u{0435}\u{0440}\u{0438}\u{0442}\u{0435} \u{0441}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}\u{0430}"],
        "trainer_plan_title": [.az: "Plan Ad\u{0131}", .en: "Plan Title", .ru: "\u{041D}\u{0430}\u{0437}\u{0432}\u{0430}\u{043D}\u{0438}\u{0435} \u{043F}\u{043B}\u{0430}\u{043D}\u{0430}"],
        "trainer_plan_title_placeholder": [.az: "m\u{0259}s: 4 H\u{0259}ft\u{0259}lik Ar\u{0131}qlama", .en: "e.g: 4-Week Weight Loss", .ru: "\u{043D}\u{0430}\u{043F}\u{0440}.: 4-\u{043D}\u{0435}\u{0434}. \u{043F}\u{043E}\u{0445}\u{0443}\u{0434}\u{0435}\u{043D}\u{0438}\u{0435}"],
        "trainer_add_workout": [.az: "M\u{0259}\u{015F}q \u{018F}lav\u{0259} Et", .en: "Add Workout", .ru: "\u{0414}\u{043E}\u{0431}\u{0430}\u{0432}\u{0438}\u{0442}\u{044C} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0443}"],
        "trainer_add_meal": [.az: "Yem\u{0259}k \u{018F}lav\u{0259} Et", .en: "Add Meal", .ru: "\u{0414}\u{043E}\u{0431}\u{0430}\u{0432}\u{0438}\u{0442}\u{044C} \u{0435}\u{0434}\u{0443}"],
        "trainer_daily_calorie": [.az: "G\u{00FC}nl\u{00FC}k Kalori H\u{0259}d\u{0259}fi", .en: "Daily Calorie Target", .ru: "\u{0414}\u{043D}\u{0435}\u{0432}\u{043D}\u{0430}\u{044F} \u{0446}\u{0435}\u{043B}\u{044C} \u{043A}\u{0430}\u{043B}\u{043E}\u{0440}\u{0438}\u{0439}"],
        "trainer_no_plans": [.az: "H\u{0259}l\u{0259} plan yoxdur", .en: "No plans yet", .ru: "\u{041F}\u{043E}\u{043A}\u{0430} \u{043D}\u{0435}\u{0442} \u{043F}\u{043B}\u{0430}\u{043D}\u{043E}\u{0432}"],
        "trainer_no_plans_desc": [.az: "\u{0130}lk plan\u{0131}n\u{0131}z\u{0131} yarad\u{0131}n!", .en: "Create your first plan!", .ru: "\u{0421}\u{043E}\u{0437}\u{0434}\u{0430}\u{0439}\u{0442}\u{0435} \u{043F}\u{0435}\u{0440}\u{0432}\u{044B}\u{0439} \u{043F}\u{043B}\u{0430}\u{043D}!"],
        "trainer_workouts_in_plan": [.az: "Plandak\u{0131} M\u{0259}\u{015F}ql\u{0259}r", .en: "Workouts in Plan", .ru: "\u{0422}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0438} \u{0432} \u{043F}\u{043B}\u{0430}\u{043D}\u{0435}"],
        "trainer_meals_in_plan": [.az: "Plandak\u{0131} Yem\u{0259}kl\u{0259}r", .en: "Meals in Plan", .ru: "\u{0415}\u{0434}\u{0430} \u{0432} \u{043F}\u{043B}\u{0430}\u{043D}\u{0435}"],
        "trainer_plan_saved": [.az: "Plan u\u{011F}urla yarad\u{0131}ld\u{0131}!", .en: "Plan created successfully!", .ru: "\u{041F}\u{043B}\u{0430}\u{043D} \u{0441}\u{043E}\u{0437}\u{0434}\u{0430}\u{043D}!"],
        "trainer_student_overview": [.az: "T\u{0259}l\u{0259}b\u{0259} \u{0130}cmal\u{0131}", .en: "Student Overview", .ru: "\u{041E}\u{0431}\u{0437}\u{043E}\u{0440} \u{0441}\u{0442}\u{0443}\u{0434}\u{0435}\u{043D}\u{0442}\u{043E}\u{0432}"],
        "trainer_total_plans": [.az: "Toplam Plan", .en: "Total Plans", .ru: "Всего планов"],
        "trainer_hello": [.az: "Salam", .en: "Hello", .ru: "Привет"],
        "trainer_dashboard_subtitle": [.az: "Tələbələrinizi və planlarınızı idarə edin", .en: "Manage your students and plans", .ru: "Управляйте студентами и планами"],
        "trainer_students": [.az: "Tələbələr", .en: "Students", .ru: "Студенты"],
        "trainer_quick_actions": [.az: "Tez Əməliyyatlar", .en: "Quick Actions", .ru: "Быстрые действия"],
        "trainer_new_training": [.az: "Yeni İdman Planı", .en: "New Training Plan", .ru: "Новый план тренировок"],
        "trainer_new_meal": [.az: "Yeni Qida Planı", .en: "New Meal Plan", .ru: "Новый план питания"],
        "trainer_recent_plans": [.az: "Son Planlar", .en: "Recent Plans", .ru: "Последние планы"],
        "trainer_training_subtitle": [.az: "Tələbələr üçün idman planları yaradın", .en: "Create training plans for students", .ru: "Создавайте планы тренировок"],
        "trainer_meal_subtitle": [.az: "Tələbələr üçün qida planları yaradın", .en: "Create meal plans for students", .ru: "Создавайте планы питания"],
        "trainer_no_training_plans": [.az: "İdman planı yoxdur", .en: "No training plans", .ru: "Нет планов тренировок"],
        "trainer_add_first_plan": [.az: "İlk idman planınızı yaradın!", .en: "Create your first training plan!", .ru: "Создайте первый план тренировок!"],
        "trainer_no_meal_plans": [.az: "Qida planı yoxdur", .en: "No meal plans", .ru: "Нет планов питания"],
        "trainer_add_first_meal_plan": [.az: "İlk qida planınızı yaradın!", .en: "Create your first meal plan!", .ru: "Создайте первый план питания!"],
        "trainer_exercises": [.az: "Məşqlər", .en: "Exercises", .ru: "Упражнения"],
        "trainer_add_exercise": [.az: "Məşq Əlavə Et", .en: "Add Exercise", .ru: "Добавить упражнение"],
        "trainer_no_exercises": [.az: "Hələ məşq əlavə edilməyib", .en: "No exercises added yet", .ru: "Упражнения не добавлены"],
        "trainer_notes": [.az: "Qeydlər", .en: "Notes", .ru: "Заметки"],
        "trainer_exercise_name": [.az: "Məşq Adı", .en: "Exercise Name", .ru: "Название упражнения"],
        "trainer_exercise_name_placeholder": [.az: "məs: Bench Press", .en: "e.g: Bench Press", .ru: "напр.: Жим лёжа"],
        "trainer_sets": [.az: "Set", .en: "Sets", .ru: "Подходы"],
        "trainer_reps": [.az: "Təkrar", .en: "Reps", .ru: "Повторы"],
        "trainer_daily": [.az: "gündə", .en: "daily", .ru: "в день"],
        "trainer_meals_count": [.az: "yemək", .en: "meals", .ru: "блюд"],
        "trainer_meal_plan_title_placeholder": [.az: "məs: Sağlam Qidalanma Planı", .en: "e.g: Healthy Eating Plan", .ru: "напр.: План здорового питания"],
        "trainer_meals": [.az: "Yeməklər", .en: "Meals", .ru: "Блюда"],
        "trainer_no_meals": [.az: "Hələ yemək əlavə edilməyib", .en: "No meals added yet", .ru: "Блюда не добавлены"],
        "trainer_total_calories": [.az: "Toplam kalori:", .en: "Total calories:", .ru: "Всего калорий:"],
        "trainer_meal_name": [.az: "Yemək Adı", .en: "Meal Name", .ru: "Название блюда"],
        "trainer_meal_name_placeholder": [.az: "məs: Toyuq filesi", .en: "e.g: Chicken breast", .ru: "напр.: Куриная грудка"],
        "trainer_meal_type": [.az: "Yemək Növü", .en: "Meal Type", .ru: "Тип приёма пищи"],
        "common_all": [.az: "Hamısı", .en: "All", .ru: "Все"],

        // ============================================================
        // MARK: - Plan Types
        // ============================================================
        "plan_completed": [.az: "Tamamlandı", .en: "Completed", .ru: "Завершено"],
        "plan_mark_done": [.az: "İcra etdim", .en: "Mark as Done", .ru: "Отметить как выполнено"],
        "plan_confirm_complete": [.az: "Bu planı tamamlandı kimi işarələmək istəyirsiniz?", .en: "Do you want to mark this plan as completed?", .ru: "Вы хотите отметить этот план как выполненный?"],
        "plan_status_pending": [.az: "Gözləyir", .en: "Pending", .ru: "Ожидает"],
        "plan_type_weight_loss": [.az: "Ar\u{0131}qlama", .en: "Weight Loss", .ru: "\u{041F}\u{043E}\u{0445}\u{0443}\u{0434}\u{0435}\u{043D}\u{0438}\u{0435}"],
        "plan_type_weight_gain": [.az: "K\u{00F6}k\u{0259}lm\u{0259}", .en: "Weight Gain", .ru: "\u{041D}\u{0430}\u{0431}\u{043E}\u{0440} \u{043C}\u{0430}\u{0441}\u{0441}\u{044B}"],
        "plan_type_strength": [.az: "A\u{011F}\u{0131}rl\u{0131}q m\u{0259}\u{015F}ql\u{0259}ri", .en: "Strength Training", .ru: "\u{0421}\u{0438}\u{043B}\u{043E}\u{0432}\u{044B}\u{0435} \u{0442}\u{0440}\u{0435}\u{043D}\u{0438}\u{0440}\u{043E}\u{0432}\u{043A}\u{0438}"],

        // ============================================================
        // MARK: - Biometric
        // ============================================================
        "biometric_faceid": [.az: "Face ID", .en: "Face ID", .ru: "Face ID"],
        "biometric_touchid": [.az: "Touch ID", .en: "Touch ID", .ru: "Touch ID"],
        "biometric_opticid": [.az: "Optic ID", .en: "Optic ID", .ru: "Optic ID"],
        "biometric_unavailable": [.az: "M\u{00F6}vcud deyil", .en: "Unavailable", .ru: "\u{041D}\u{0435}\u{0434}\u{043E}\u{0441}\u{0442}\u{0443}\u{043F}\u{043D}\u{043E}"],
        "biometric_generic": [.az: "Biometrik", .en: "Biometric", .ru: "\u{0411}\u{0438}\u{043E}\u{043C}\u{0435}\u{0442}\u{0440}\u{0438}\u{044F}"],
        "biometric_reason": [.az: "CoreVia t\u{0259}tbiqin\u{0259} daxil olmaq \u{00FC}\u{00E7}\u{00FC}n", .en: "To access CoreVia app", .ru: "\u{0414}\u{043B}\u{044F} \u{0434}\u{043E}\u{0441}\u{0442}\u{0443}\u{043F}\u{0430} \u{0432} CoreVia"],

        // ============================================================
        // MARK: - Additional Missing Keys
        // ============================================================
        "common_back": [.az: "Geri", .en: "Back", .ru: "Назад"],
        "common_active": [.az: "Aktiv", .en: "Active", .ru: "Активно"],
        "food_time": [.az: "Vaxt", .en: "Time", .ru: "Время"],
        "home_workout_completed": [.az: "məşq tamamlandı", .en: "workout completed", .ru: "тренировка завершена"],
        "register_password_hint": [.az: "Şifrə (ən az 6 simvol)", .en: "Password (min 6 characters)", .ru: "Пароль (мин. 6 символов)"],
        "register_passwords_match": [.az: "Şifrələr uyğundur", .en: "Passwords match", .ru: "Пароли совпадают"],
        "register_passwords_mismatch": [.az: "Şifrələr uyğun deyil", .en: "Passwords don't match", .ru: "Пароли не совпадают"],
        "register_fill_all": [.az: "Bütün sahələri düzgün doldurun", .en: "Fill in all fields correctly", .ru: "Заполните все поля правильно"],
        "register_weak_password": [.az: "Zəif şifrə", .en: "Weak password", .ru: "Слабый пароль"],
        "register_medium_password": [.az: "Orta güclü", .en: "Medium strength", .ru: "Средний"],
        "register_strong_password": [.az: "Güclü şifrə", .en: "Strong password", .ru: "Надёжный пароль"],
        "home_no_workouts_today": [.az: "Bugün məşq yoxdur", .en: "No workouts today", .ru: "Нет тренировок сегодня"],

        // ============================================================
        // MARK: - Default Profile
        // ============================================================
        "default_student_name": [.az: "Tələbə İstifadəçi", .en: "Student User", .ru: "Пользователь-студент"],
        "default_trainer_name": [.az: "Müəllim İstifadəçi", .en: "Trainer User", .ru: "Пользователь-тренер"],
        "default_trainer_bio": [.az: "Peşəkar fitness müəllimi", .en: "Professional fitness trainer", .ru: "Профессиональный фитнес-тренер"],

        // ============================================================
        // MARK: - Tab (Additional)
        // ============================================================
        "tab_students": [.az: "Tələbələr", .en: "Students", .ru: "Студенты"],

        // ============================================================
        // MARK: - Demo Student Goals
        // ============================================================
        "demo_goal_gain": [.az: "Kökəlmək", .en: "Gain weight", .ru: "Набрать массу"],
        "demo_goal_strength": [.az: "Güc artırmaq", .en: "Build strength", .ru: "Увеличить силу"],

        // ============================================================
        // MARK: - Food Names (Mock & Quick Add)
        // ============================================================
        "food_mock_pilaf": [.az: "Toyuq plovu", .en: "Chicken pilaf", .ru: "Плов с курицей"],
        "food_mock_dovga": [.az: "Dovğa", .en: "Yogurt soup", .ru: "Довга"],
        "food_mock_wrap": [.az: "Lavaş dürüm", .en: "Lavash wrap", .ru: "Лаваш ролл"],
        "food_mock_salad": [.az: "Salat (qarışıq)", .en: "Mixed salad", .ru: "Салат (микс)"],
        "food_mock_kebab": [.az: "Şiş kabab", .en: "Shish kebab", .ru: "Шашлык"],
        "food_mock_omelette": [.az: "Pendir omlet", .en: "Cheese omelette", .ru: "Омлет с сыром"],
        "food_mock_soup": [.az: "Mercimek şorbası", .en: "Lentil soup", .ru: "Чечевичный суп"],
        "food_mock_rice": [.az: "Düyü pilavı", .en: "Rice pilaf", .ru: "Рисовый плов"],
        "food_mock_steak": [.az: "Biftek", .en: "Steak", .ru: "Стейк"],
        "food_mock_pasta": [.az: "Makaron", .en: "Pasta", .ru: "Паста"],
        "food_quick_egg": [.az: "Yumurta (1 ədəd)", .en: "Egg (1 pc)", .ru: "Яйцо (1 шт)"],
        "food_quick_banana": [.az: "Banan", .en: "Banana", .ru: "Банан"],
        "food_quick_chicken": [.az: "Toyuq filesi (100q)", .en: "Chicken breast (100g)", .ru: "Куриная грудка (100г)"],
        "food_quick_apple": [.az: "Alma", .en: "Apple", .ru: "Яблоко"],
        "food_quick_oatmeal": [.az: "Oatmeal (100q)", .en: "Oatmeal (100g)", .ru: "Овсянка (100г)"],
        "food_quick_juice": [.az: "Alma şirəsi (200ml)", .en: "Apple juice (200ml)", .ru: "Яблочный сок (200мл)"],

        // ============================================================
        // MARK: - My Students View
        // ============================================================
        "my_students_title": [.az: "Tələbələrim", .en: "My Students", .ru: "Мои студенты"],
        "my_students_total": [.az: "Ümumi tələbə", .en: "Total students", .ru: "Всего студентов"],
        "my_students_avg_progress": [.az: "Orta irəliləyiş", .en: "Avg. progress", .ru: "Ср. прогресс"],
        "my_students_search": [.az: "Tələbə axtar...", .en: "Search students...", .ru: "Поиск студентов..."],
        "my_students_no_results": [.az: "Tələbə tapılmadı", .en: "No students found", .ru: "Студенты не найдены"],
        "my_students_change_search": [.az: "Axtarış meyarlarını dəyişin", .en: "Try a different search", .ru: "Измените критерии поиска"],
        "my_students_age": [.az: "Yaş", .en: "Age", .ru: "Возраст"],
        "my_students_goal": [.az: "Hədəf", .en: "Goal", .ru: "Цель"],
        "my_students_progress": [.az: "İrəliləyiş", .en: "Progress", .ru: "Прогресс"],

        // ============================================================
        // MARK: - Student Detail View
        // ============================================================
        "student_detail_title": [.az: "Tələbə Profili", .en: "Student Profile", .ru: "Профиль студента"],
        "student_detail_progress_overview": [.az: "İrəliləyiş İcmalı", .en: "Progress Overview", .ru: "Обзор прогресса"],
        "student_detail_training_stats": [.az: "Məşq Statistikası", .en: "Training Statistics", .ru: "Статистика тренировок"],
        "student_detail_workouts_week": [.az: "Bu həftə məşqlər", .en: "Workouts this week", .ru: "Тренировки на этой неделе"],
        "student_detail_total_workouts": [.az: "Ümumi məşqlər", .en: "Total workouts", .ru: "Всего тренировок"],
        "student_detail_calories_burned": [.az: "Yandırılmış kalori", .en: "Calories burned", .ru: "Сожжённые калории"],
        "student_detail_assigned_plans": [.az: "Təyin Edilmiş Planlar", .en: "Assigned Plans", .ru: "Назначенные планы"],
        "student_detail_no_plans": [.az: "Hələ plan təyin edilməyib", .en: "No plans assigned yet", .ru: "Планы пока не назначены"],
        "student_detail_create_training": [.az: "İdman Planı Yarat", .en: "Create Training Plan", .ru: "Создать план тренировок"],
        "student_detail_create_meal": [.az: "Qida Planı Yarat", .en: "Create Meal Plan", .ru: "Создать план питания"],

        // ============================================================
        // MARK: - Trainer Profile Detail
        // ============================================================
        "trainer_subscribe": [.az: "Abunə Ol", .en: "Subscribe", .ru: "Подписаться"],
        "trainer_subscribed": [.az: "Abunə olunub", .en: "Subscribed", .ru: "Подписан(а)"],
        "trainer_view_profile": [.az: "Profilə Bax", .en: "View Profile", .ru: "Просмотр профиля"],
        "trainer_price_per_session": [.az: "Qiymət / seans", .en: "Price / session", .ru: "Цена / сеанс"],
        "trainer_specialties": [.az: "İxtisaslar", .en: "Specialties", .ru: "Специализации"],
        "trainer_years_short": [.az: "il", .en: "yrs", .ru: "лет"],
        "trainer_session_short": [.az: "seans", .en: "session", .ru: "сеанс"],
        "trainer_no_bio": [.az: "Bio əlavə edilməyib", .en: "No bio added", .ru: "Био не добавлено"],
        "trainer_instagram": [.az: "Instagram", .en: "Instagram", .ru: "Instagram"],

        // Specialty Tags (localized)
        "specialty_fitness": [.az: "Fitness", .en: "Fitness", .ru: "Фитнес"],
        "specialty_strength": [.az: "Güc məşqi", .en: "Strength", .ru: "Силовые"],
        "specialty_cardio": [.az: "Kardio", .en: "Cardio", .ru: "Кардио"],
        "specialty_yoga": [.az: "Yoga", .en: "Yoga", .ru: "Йога"],
        "specialty_nutrition": [.az: "Qidalanma", .en: "Nutrition", .ru: "Питание"],
        "specialty_bodybuilding": [.az: "Bədən qurma", .en: "Bodybuilding", .ru: "Бодибилдинг"],
        "specialty_pilates": [.az: "Pilates", .en: "Pilates", .ru: "Пилатес"],
        "specialty_crossfit": [.az: "CrossFit", .en: "CrossFit", .ru: "Кроссфит"],
        "specialty_boxing": [.az: "Boks", .en: "Boxing", .ru: "Бокс"],
        "specialty_stretching": [.az: "Esnəmə", .en: "Stretching", .ru: "Растяжка"],
        "specialty_rehabilitation": [.az: "Reabilitasiya", .en: "Rehabilitation", .ru: "Реабилитация"],
        "specialty_functional": [.az: "Funksional", .en: "Functional", .ru: "Функциональный"],

        // ============================================================
        // MARK: - Reviews (Rəylər)
        // ============================================================
        "review_title": [.az: "Rəylər", .en: "Reviews", .ru: "Отзывы"],
        "review_write": [.az: "Rəy yaz", .en: "Write Review", .ru: "Написать отзыв"],
        "review_empty": [.az: "Hələ rəy yoxdur", .en: "No reviews yet", .ru: "Пока нет отзывов"],
        "review_submit": [.az: "Göndər", .en: "Submit", .ru: "Отправить"],
        "review_comment": [.az: "Şərh", .en: "Comment", .ru: "Комментарий"],
        "review_rate_trainer": [.az: "Müəllimi qiymətləndirin", .en: "Rate the trainer", .ru: "Оцените тренера"],
        "review_success_msg": [.az: "Rəyiniz uğurla göndərildi!", .en: "Your review was submitted successfully!", .ru: "Ваш отзыв успешно отправлен!"],
        "review_rating_1": [.az: "Çox pis", .en: "Very bad", .ru: "Очень плохо"],
        "review_rating_2": [.az: "Pis", .en: "Bad", .ru: "Плохо"],
        "review_rating_3": [.az: "Orta", .en: "Average", .ru: "Средне"],
        "review_rating_4": [.az: "Yaxşı", .en: "Good", .ru: "Хорошо"],
        "review_rating_5": [.az: "Əla", .en: "Excellent", .ru: "Отлично"],

        // ============================================================
        // MARK: - Chat (Söhbət)
        // ============================================================
        "chat_title": [.az: "Mesajlar", .en: "Messages", .ru: "Сообщения"],
        "chat_empty": [.az: "Mesaj yoxdur", .en: "No messages", .ru: "Нет сообщений"],
        "chat_empty_desc": [.az: "Müəlliminizlə söhbət başlayın", .en: "Start chatting with your trainer", .ru: "Начните общение с тренером"],
        "chat_no_messages": [.az: "Hələ mesaj yoxdur", .en: "No messages yet", .ru: "Пока нет сообщений"],
        "chat_start_conversation": [.az: "İlk mesajı göndərin", .en: "Send the first message", .ru: "Отправьте первое сообщение"],
        "chat_type_message": [.az: "Mesaj yazın...", .en: "Type a message...", .ru: "Напишите сообщение..."],
        "chat_remaining": [.az: "Qalan mesaj", .en: "Messages left", .ru: "Осталось сообщений"],
        "chat_premium_required": [.az: "Premium lazımdır", .en: "Premium Required", .ru: "Требуется Премиум"],
        "chat_premium_desc": [.az: "Mesajlaşma funksiyası yalnız Premium istifadəçilər üçündür", .en: "Messaging is only available for Premium users", .ru: "Обмен сообщениями доступен только для Премиум"],
        "chat_limit_reached": [.az: "Günlük mesaj limitinə çatdınız", .en: "Daily message limit reached", .ru: "Дневной лимит сообщений исчерпан"],
        "message_sent_success": [.az: "Mesaj göndərildi", .en: "Message sent", .ru: "Сообщение отправлено"],

        // ============================================================
        // MARK: - Content (Məzmun)
        // ============================================================
        "content_title": [.az: "Məzmun", .en: "Content", .ru: "Контент"],
        "content_subtitle": [.az: "Tələbələriniz üçün məzmun yaradın", .en: "Create content for your students", .ru: "Создавайте контент для студентов"],
        "content_empty": [.az: "Hələ məzmun yoxdur", .en: "No content yet", .ru: "Пока нет контента"],
        "content_empty_desc": [.az: "İlk məzmununuzu yaradın!", .en: "Create your first content!", .ru: "Создайте свой первый контент!"],
        "content_create": [.az: "Məzmun Yarat", .en: "Create Content", .ru: "Создать контент"],
        "content_field_title": [.az: "Başlıq", .en: "Title", .ru: "Заголовок"],
        "content_title_placeholder": [.az: "məs: Düzgün qidalanma məsləhətləri", .en: "e.g: Proper nutrition tips", .ru: "напр.: Советы по правильному питанию"],
        "content_field_body": [.az: "Mətn", .en: "Body", .ru: "Текст"],
        "content_premium_only": [.az: "Yalnız abunəçilər görsün", .en: "Subscribers only", .ru: "Только для подписчиков"],
        "content_trainer_posts": [.az: "Müəllim Paylaşımları", .en: "Trainer Posts", .ru: "Посты тренера"],
        "content_no_posts": [.az: "Hələ paylaşım yoxdur", .en: "No posts yet", .ru: "Пока нет постов"],

        // ============================================================
        // MARK: - Onboarding
        // ============================================================
        "onboarding_next": [.az: "Davam et", .en: "Continue", .ru: "Продолжить"],
        "onboarding_finish": [.az: "Başla!", .en: "Get Started!", .ru: "Начать!"],
        "onboarding_goal_title": [.az: "Məqsədiniz nədir?", .en: "What's your goal?", .ru: "Какова ваша цель?"],
        "onboarding_goal_subtitle": [.az: "Sizə uyğun plan hazırlayaq", .en: "Let's prepare a plan for you", .ru: "Подготовим план для вас"],
        "onboarding_level_title": [.az: "Fitness səviyyəniz?", .en: "Your fitness level?", .ru: "Ваш уровень фитнеса?"],
        "onboarding_level_subtitle": [.az: "Təcrübənizə uyğun başlayaq", .en: "Let's start at your level", .ru: "Начнём с вашего уровня"],
        "onboarding_trainer_title": [.az: "Hansı tip müəllim?", .en: "Preferred trainer type?", .ru: "Какой тип тренера?"],
        "onboarding_trainer_subtitle": [.az: "Sizə uyğun müəllim tapaq", .en: "Let's find the right trainer", .ru: "Найдём подходящего тренера"],
        "onboarding_skip": [.az: "Keç", .en: "Skip", .ru: "Пропустить"],

        // ============================================================
        // MARK: - Profile Enhancement (Real/Functional)
        // ============================================================
        "profile_member_since": [.az: "Üzvlük tarixi", .en: "Member since", .ru: "Дата регистрации"],
        "profile_joined_date": [.az: "Qoşulma tarixi", .en: "Joined date", .ru: "Дата присоединения"],
        "profile_completion": [.az: "Profil tamamlanması", .en: "Profile completion", .ru: "Заполнение профиля"],
        "profile_complete_profile": [.az: "Profili tamamla", .en: "Complete your profile", .ru: "Заполните профиль"],
        "profile_complete_desc": [.az: "Profilinizi dolduraraq daha yaxşı təcrübə əldə edin", .en: "Fill out your profile for a better experience", .ru: "Заполните профиль для лучшего опыта"],
        "profile_message_trainer": [.az: "Müəllimə mesaj yaz", .en: "Message trainer", .ru: "Написать тренеру"],
        "profile_subscribers": [.az: "Abunəçilər", .en: "Subscribers", .ru: "Подписчики"],
        "profile_earnings": [.az: "Gəlir", .en: "Earnings", .ru: "Доход"],
        "profile_monthly_earnings": [.az: "Aylıq gəlir", .en: "Monthly earnings", .ru: "Месячный доход"],
        "profile_total_subscribers": [.az: "Ümumi abunəçi", .en: "Total subscribers", .ru: "Всего подписчиков"],
        "profile_avg_workouts_week": [.az: "Ort. həftəlik məşq", .en: "Avg. workouts/week", .ru: "Ср. тренировок/нед."],
        "profile_total_workouts": [.az: "Ümumi məşqlər", .en: "Total workouts", .ru: "Всего тренировок"],
        "profile_no_students_yet": [.az: "Hələ tələbə yoxdur", .en: "No students yet", .ru: "Пока нет студентов"],
        "profile_no_students_desc": [.az: "Tələbələr sizə abunə olduqda burada görünəcək", .en: "Students will appear here when they subscribe", .ru: "Студенты появятся здесь после подписки"],
        "profile_workouts_this_week": [.az: "Bu həftə məşqlər", .en: "Workouts this week", .ru: "Тренировок на этой неделе"],
        "profile_active_label": [.az: "Aktiv", .en: "Active", .ru: "Активные"],

        // ============================================================
        // MARK: - Social Features
        // ============================================================
        "social_feed": [.az: "Lenta", .en: "Feed", .ru: "Лента"],
        "social_create_post": [.az: "Post Yarat", .en: "Create Post", .ru: "Создать пост"],
        "social_post": [.az: "Paylaş", .en: "Post", .ru: "Опубликовать"],
        "social_post_type": [.az: "Post növü", .en: "Post type", .ru: "Тип поста"],
        "social_post_content": [.az: "Məzmun", .en: "Content", .ru: "Содержание"],
        "social_add_image": [.az: "Şəkil əlavə et", .en: "Add image", .ru: "Добавить фото"],
        "social_select_image": [.az: "Şəkil seç", .en: "Select image", .ru: "Выбрать фото"],
        "social_public_post": [.az: "İctimai post", .en: "Public post", .ru: "Публичный пост"],
        "social_general": [.az: "Ümumi", .en: "General", .ru: "Общее"],
        "social_workout": [.az: "Məşq", .en: "Workout", .ru: "Тренировка"],
        "social_meal": [.az: "Yemək", .en: "Meal", .ru: "Еда"],
        "social_progress": [.az: "Tərəqqi", .en: "Progress", .ru: "Прогресс"],
        "social_achievement": [.az: "Nailiyyət", .en: "Achievement", .ru: "Достижение"],
        "social_likes": [.az: "bəyənmə", .en: "likes", .ru: "лайков"],
        "social_comments": [.az: "Şərhlər", .en: "Comments", .ru: "Комментарии"],
        "social_write_comment": [.az: "Şərh yaz...", .en: "Write a comment...", .ru: "Написать комментарий..."],
        "social_no_comments": [.az: "Hələ şərh yoxdur", .en: "No comments yet", .ru: "Пока нет комментариев"],
        "social_be_first_comment": [.az: "İlk şərh edən siz olun", .en: "Be the first to comment", .ru: "Будьте первым, кто оставит комментарий"],
        "social_delete_comment": [.az: "Şərhi sil", .en: "Delete comment", .ru: "Удалить комментарий"],
        "social_delete_comment_confirm": [.az: "Bu şərhi silmək istədiyinizə əminsiniz?", .en: "Are you sure you want to delete this comment?", .ru: "Вы уверены, что хотите удалить этот комментарий?"],
        "social_delete_post": [.az: "Postu sil", .en: "Delete post", .ru: "Удалить пост"],
        "social_delete_post_confirm": [.az: "Bu postu silmək istədiyinizə əminsiniz?", .en: "Are you sure you want to delete this post?", .ru: "Вы уверены, что хотите удалить этот пост?"],
        "social_no_posts": [.az: "Hələ post yoxdur", .en: "No posts yet", .ru: "Пока нет постов"],
        "social_start_sharing": [.az: "Paylaşmağa başlayın", .en: "Start sharing", .ru: "Начните делиться"],

        // ============================================================
        // MARK: - Social & Community
        // ============================================================
        "social_title": [.az: "Sosial", .en: "Social", .ru: "Социальная"],

        // ============================================================
        // MARK: - Marketplace
        // ============================================================
        "marketplace_title": [.az: "Mağaza", .en: "Marketplace", .ru: "Магазин"],
        "marketplace_all": [.az: "Hamısı", .en: "All", .ru: "Все"],
        "marketplace_workout_plan": [.az: "Məşq Planı", .en: "Workout Plan", .ru: "План тренировок"],
        "marketplace_meal_plan": [.az: "Qida Planı", .en: "Meal Plan", .ru: "План питания"],
        "marketplace_ebook": [.az: "E-Kitab", .en: "E-Book", .ru: "Электронная книга"],
        "marketplace_consultation": [.az: "Məsləhət", .en: "Consultation", .ru: "Консультация"],
        "marketplace_no_products": [.az: "Məhsul tapılmadı", .en: "No products found", .ru: "Товары не найдены"],
        "marketplace_no_products_desc": [.az: "Bu kateqoriyada hələ məhsul yoxdur", .en: "No products in this category yet", .ru: "В этой категории пока нет товаров"],
        "marketplace_description": [.az: "Təsvir", .en: "Description", .ru: "Описание"],
        "marketplace_sold_by": [.az: "Satıcı", .en: "Sold by", .ru: "Продавец"],
        "marketplace_reviews": [.az: "Rəylər", .en: "Reviews", .ru: "Отзывы"],
        "marketplace_no_reviews": [.az: "Hələ rəy yoxdur", .en: "No reviews yet", .ru: "Пока нет отзывов"],
        "marketplace_write_review": [.az: "Rəy yaz", .en: "Write Review", .ru: "Написать отзыв"],
        "marketplace_see_all_reviews": [.az: "Bütün rəylərə bax", .en: "See all reviews", .ru: "Все отзывы"],
        "marketplace_price": [.az: "Qiymət", .en: "Price", .ru: "Цена"],
        "marketplace_buy_now": [.az: "İndi Al", .en: "Buy Now", .ru: "Купить сейчас"],
        "marketplace_purchased": [.az: "Alınıb", .en: "Purchased", .ru: "Куплено"],
        "marketplace_confirm_purchase": [.az: "Alışı təsdiqləyin", .en: "Confirm Purchase", .ru: "Подтвердите покупку"],
        "marketplace_total": [.az: "Cəmi", .en: "Total", .ru: "Итого"],
        "marketplace_your_rating": [.az: "Reytinqiniz", .en: "Your Rating", .ru: "Ваш рейтинг"],
        "marketplace_your_review": [.az: "Rəyiniz", .en: "Your Review", .ru: "Ваш отзыв"],
        "marketplace_optional": [.az: "İstəyə bağlı", .en: "Optional", .ru: "Необязательно"],
        "marketplace_submit": [.az: "Göndər", .en: "Submit", .ru: "Отправить"],

        // ============================================================
        // MARK: - Analytics
        // ============================================================
        "analytics_title": [.az: "Analitika", .en: "Analytics", .ru: "Аналитика"],
        "analytics_this_week": [.az: "Bu Həftə", .en: "This Week", .ru: "Эта неделя"],
        "analytics_workouts": [.az: "Məşqlər", .en: "Workouts", .ru: "Тренировки"],
        "analytics_minutes": [.az: "Dəqiqə", .en: "Minutes", .ru: "Минуты"],
        "analytics_calories_burned": [.az: "Yandırılan Kalori", .en: "Calories Burned", .ru: "Сожжено калорий"],
        "analytics_consistency": [.az: "Ardıcıllıq", .en: "Consistency", .ru: "Постоянство"],
        "analytics_weight_trend": [.az: "Çəki Tendensiyası", .en: "Weight Trend", .ru: "Тренд веса"],
        "analytics_workout_trend": [.az: "Məşq Tendensiyası", .en: "Workout Trend", .ru: "Тренд тренировок"],
        "analytics_nutrition_trend": [.az: "Qidalanma Tendensiyası", .en: "Nutrition Trend", .ru: "Тренд питания"],
        "analytics_last_30_days": [.az: "Son 30 Gün", .en: "Last 30 Days", .ru: "Последние 30 дней"],
        "analytics_total_workouts": [.az: "Ümumi Məşqlər", .en: "Total Workouts", .ru: "Всего тренировок"],
        "analytics_total_minutes": [.az: "Ümumi Dəqiqə", .en: "Total Minutes", .ru: "Всего минут"],
        "analytics_workout_streak": [.az: "Məşq Seriyası", .en: "Workout Streak", .ru: "Серия тренировок"],
        "analytics_no_data": [.az: "Məlumat yoxdur", .en: "No data available", .ru: "Нет данных"],
        "analytics_no_data_desc": [.az: "Məşqlər və qida qeydləri əlavə edin", .en: "Add workouts and food entries", .ru: "Добавьте тренировки и записи питания"],

        // ============================================================
        // MARK: - Live Sessions
        // ============================================================
        "live_sessions_title": [.az: "Canlı Sessiyalar", .en: "Live Sessions", .ru: "Живые сессии"],
        "live_sessions_all": [.az: "Hamısı", .en: "All", .ru: "Все"],
        "live_sessions_upcoming": [.az: "Gələcək", .en: "Upcoming", .ru: "Предстоящие"],
        "live_sessions_live": [.az: "Canlı", .en: "Live", .ru: "Прямой эфир"],
        "live_sessions_completed": [.az: "Tamamlanmış", .en: "Completed", .ru: "Завершённые"],
        "live_sessions_no_sessions": [.az: "Sessiya yoxdur", .en: "No sessions", .ru: "Нет сессий"],
        "live_sessions_no_sessions_desc": [.az: "Hələ canlı sessiya planlaşdırılmayıb", .en: "No live sessions scheduled yet", .ru: "Пока нет запланированных сессий"],
        "live_sessions_join": [.az: "Qoşul", .en: "Join", .ru: "Присоединиться"],
        "live_sessions_participants": [.az: "İştirakçılar", .en: "Participants", .ru: "Участники"],
        "live_sessions_start": [.az: "Başlat", .en: "Start", .ru: "Начать"],
        "live_sessions_end": [.az: "Bitir", .en: "End", .ru: "Завершить"],
        "common_free": [.az: "Pulsuz", .en: "Free", .ru: "Бесплатно"],

        // ============================================================
        // MARK: - Time Ago
        // ============================================================
        "time_just_now": [.az: "İndicə", .en: "Just now", .ru: "Только что"],
        "time_second_ago": [.az: "saniyə əvvəl", .en: "second ago", .ru: "секунду назад"],
        "time_seconds_ago": [.az: "saniyə əvvəl", .en: "seconds ago", .ru: "секунд назад"],
        "time_minute_ago": [.az: "dəqiqə əvvəl", .en: "minute ago", .ru: "минуту назад"],
        "time_minutes_ago": [.az: "dəqiqə əvvəl", .en: "minutes ago", .ru: "минут назад"],
        "time_hour_ago": [.az: "saat əvvəl", .en: "hour ago", .ru: "час назад"],
        "time_hours_ago": [.az: "saat əvvəl", .en: "hours ago", .ru: "часов назад"],
        "time_day_ago": [.az: "gün əvvəl", .en: "day ago", .ru: "день назад"],
        "time_days_ago": [.az: "gün əvvəl", .en: "days ago", .ru: "дней назад"],
        "time_week_ago": [.az: "həftə əvvəl", .en: "week ago", .ru: "неделю назад"],
        "time_weeks_ago": [.az: "həftə əvvəl", .en: "weeks ago", .ru: "недель назад"],
        "time_month_ago": [.az: "ay əvvəl", .en: "month ago", .ru: "месяц назад"],
        "time_months_ago": [.az: "ay əvvəl", .en: "months ago", .ru: "месяцев назад"],
        "time_year_ago": [.az: "il əvvəl", .en: "year ago", .ru: "год назад"],
        "time_years_ago": [.az: "il əvvəl", .en: "years ago", .ru: "лет назад"],
    ]
}
