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
    ]
}
