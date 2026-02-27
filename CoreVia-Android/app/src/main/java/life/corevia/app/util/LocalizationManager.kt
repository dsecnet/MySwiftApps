package life.corevia.app.util

/**
 * LocalizationManager — iOS LocalizationManager.swift equivalent.
 *
 * Singleton managing in-app language selection and string localization.
 * Supports three languages: Azərbaycanca (az), English (en), Русский (ru).
 *
 * Usage:
 *   LocalizationManager.currentLanguage = "en"
 *   val text = LocalizationManager.localized("login_title")
 */
object LocalizationManager {

    /** Currently active language code. Defaults to Azerbaijani. */
    var currentLanguage: String = "az"

    /**
     * Returns the localized string for [key] in [currentLanguage].
     * Falls back to Azerbaijani, then returns the key itself if not found.
     */
    fun localized(key: String): String {
        val langMap = translations[key] ?: return key
        return langMap[currentLanguage]
            ?: langMap["az"]
            ?: key
    }

    /**
     * Returns all available language codes.
     */
    fun availableLanguages(): List<String> = listOf("az", "en", "ru")

    /**
     * Returns the display name for a given language code.
     */
    fun languageDisplayName(code: String): String = when (code) {
        "az" -> "Azərbaycanca"
        "en" -> "English"
        "ru" -> "Русский"
        else -> code
    }

    // ═════════════════════════════════════════════════════════════════
    // TRANSLATION MAP
    // Key → { "az" → ..., "en" → ..., "ru" → ... }
    // ═════════════════════════════════════════════════════════════════

    private val translations: Map<String, Map<String, String>> = mapOf(

        // ─── Common ──────────────────────────────────────────────────
        "common_ok" to mapOf(
            "az" to "Tamam",
            "en" to "OK",
            "ru" to "ОК"
        ),
        "common_cancel" to mapOf(
            "az" to "Ləğv et",
            "en" to "Cancel",
            "ru" to "Отмена"
        ),
        "common_save" to mapOf(
            "az" to "Yadda saxla",
            "en" to "Save",
            "ru" to "Сохранить"
        ),
        "common_delete" to mapOf(
            "az" to "Sil",
            "en" to "Delete",
            "ru" to "Удалить"
        ),
        "common_edit" to mapOf(
            "az" to "Redaktə et",
            "en" to "Edit",
            "ru" to "Редактировать"
        ),
        "common_error" to mapOf(
            "az" to "Xəta",
            "en" to "Error",
            "ru" to "Ошибка"
        ),
        "common_loading" to mapOf(
            "az" to "Yüklənir...",
            "en" to "Loading...",
            "ru" to "Загрузка..."
        ),
        "common_retry" to mapOf(
            "az" to "Yenidən cəhd et",
            "en" to "Retry",
            "ru" to "Повторить"
        ),
        "common_close" to mapOf(
            "az" to "Bağla",
            "en" to "Close",
            "ru" to "Закрыть"
        ),
        "common_search" to mapOf(
            "az" to "Axtar",
            "en" to "Search",
            "ru" to "Поиск"
        ),
        "common_next" to mapOf(
            "az" to "Növbəti",
            "en" to "Next",
            "ru" to "Далее"
        ),
        "common_back" to mapOf(
            "az" to "Geri",
            "en" to "Back",
            "ru" to "Назад"
        ),
        "common_done" to mapOf(
            "az" to "Hazır",
            "en" to "Done",
            "ru" to "Готово"
        ),
        "common_yes" to mapOf(
            "az" to "Bəli",
            "en" to "Yes",
            "ru" to "Да"
        ),
        "common_no" to mapOf(
            "az" to "Xeyr",
            "en" to "No",
            "ru" to "Нет"
        ),
        "common_confirm" to mapOf(
            "az" to "Təsdiqlə",
            "en" to "Confirm",
            "ru" to "Подтвердить"
        ),
        "common_add" to mapOf(
            "az" to "Əlavə et",
            "en" to "Add",
            "ru" to "Добавить"
        ),
        "common_update" to mapOf(
            "az" to "Yenilə",
            "en" to "Update",
            "ru" to "Обновить"
        ),
        "common_share" to mapOf(
            "az" to "Paylaş",
            "en" to "Share",
            "ru" to "Поделиться"
        ),
        "common_select" to mapOf(
            "az" to "Seç",
            "en" to "Select",
            "ru" to "Выбрать"
        ),

        // ─── Tab Bar ─────────────────────────────────────────────────
        "tab_home" to mapOf(
            "az" to "Ana Səhifə",
            "en" to "Home",
            "ru" to "Главная"
        ),
        "tab_workouts" to mapOf(
            "az" to "Məşqlər",
            "en" to "Workouts",
            "ru" to "Тренировки"
        ),
        "tab_food" to mapOf(
            "az" to "Qida",
            "en" to "Food",
            "ru" to "Питание"
        ),
        "tab_social" to mapOf(
            "az" to "Sosial",
            "en" to "Social",
            "ru" to "Социальное"
        ),
        "tab_profile" to mapOf(
            "az" to "Profil",
            "en" to "Profile",
            "ru" to "Профиль"
        ),

        // ─── Auth ────────────────────────────────────────────────────
        "login_title" to mapOf(
            "az" to "Daxil ol",
            "en" to "Log In",
            "ru" to "Войти"
        ),
        "register_title" to mapOf(
            "az" to "Qeydiyyat",
            "en" to "Sign Up",
            "ru" to "Регистрация"
        ),
        "forgot_password" to mapOf(
            "az" to "Şifrəni unutdum",
            "en" to "Forgot Password",
            "ru" to "Забыли пароль"
        ),
        "email_label" to mapOf(
            "az" to "E-poçt",
            "en" to "Email",
            "ru" to "Эл. почта"
        ),
        "password_label" to mapOf(
            "az" to "Şifrə",
            "en" to "Password",
            "ru" to "Пароль"
        ),
        "confirm_password_label" to mapOf(
            "az" to "Şifrəni təsdiqlə",
            "en" to "Confirm Password",
            "ru" to "Подтвердите пароль"
        ),
        "name_label" to mapOf(
            "az" to "Ad",
            "en" to "Name",
            "ru" to "Имя"
        ),
        "logout" to mapOf(
            "az" to "Çıxış",
            "en" to "Log Out",
            "ru" to "Выйти"
        ),

        // ─── Settings ───────────────────────────────────────────────
        "settings_title" to mapOf(
            "az" to "Tənzimləmələr",
            "en" to "Settings",
            "ru" to "Настройки"
        ),
        "settings_language" to mapOf(
            "az" to "Dil",
            "en" to "Language",
            "ru" to "Язык"
        ),
        "settings_notifications" to mapOf(
            "az" to "Bildirişlər",
            "en" to "Notifications",
            "ru" to "Уведомления"
        ),
        "settings_privacy" to mapOf(
            "az" to "Məxfilik",
            "en" to "Privacy",
            "ru" to "Конфиденциальность"
        ),
        "settings_about" to mapOf(
            "az" to "Haqqında",
            "en" to "About",
            "ru" to "О приложении"
        ),

        // ─── Workout / Food / Social ────────────────────────────────
        "workout_add" to mapOf(
            "az" to "Məşq əlavə et",
            "en" to "Add Workout",
            "ru" to "Добавить тренировку"
        ),
        "food_add" to mapOf(
            "az" to "Qida əlavə et",
            "en" to "Add Food",
            "ru" to "Добавить еду"
        ),
        "calories_label" to mapOf(
            "az" to "Kalori",
            "en" to "Calories",
            "ru" to "Калории"
        ),
        "protein_label" to mapOf(
            "az" to "Protein",
            "en" to "Protein",
            "ru" to "Белки"
        ),
        "carbs_label" to mapOf(
            "az" to "Karbohidrat",
            "en" to "Carbs",
            "ru" to "Углеводы"
        ),
        "fat_label" to mapOf(
            "az" to "Yağ",
            "en" to "Fat",
            "ru" to "Жиры"
        ),

        // ─── Premium ────────────────────────────────────────────────
        "premium_title" to mapOf(
            "az" to "Premium",
            "en" to "Premium",
            "ru" to "Премиум"
        ),
        "premium_subscribe" to mapOf(
            "az" to "Abunə ol",
            "en" to "Subscribe",
            "ru" to "Подписаться"
        ),

        // ─── Network / Empty States ─────────────────────────────────
        "no_internet" to mapOf(
            "az" to "İnternet bağlantısı yoxdur",
            "en" to "No Internet Connection",
            "ru" to "Нет подключения к интернету"
        ),
        "empty_list" to mapOf(
            "az" to "Məlumat tapılmadı",
            "en" to "No Data Found",
            "ru" to "Данные не найдены"
        ),
        "success_message" to mapOf(
            "az" to "Əməliyyat uğurla tamamlandı",
            "en" to "Operation Completed Successfully",
            "ru" to "Операция успешно завершена"
        )
    )
}
