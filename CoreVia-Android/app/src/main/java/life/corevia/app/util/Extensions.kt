package life.corevia.app.util

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

fun Long.toFormattedDate(pattern: String = "dd MMM yyyy"): String {
    val sdf = SimpleDateFormat(pattern, Locale("az"))
    return sdf.format(Date(this))
}

fun Int.toMinuteString(): String {
    val hours = this / 60
    val minutes = this % 60
    return if (hours > 0) "${hours}s ${minutes}d" else "${minutes} dəq"
}

fun Float.toCalorieString(): String {
    return if (this >= 1000) {
        String.format("%.1fk", this / 1000)
    } else {
        String.format("%.0f", this)
    }
}

/**
 * Texniki error mesajlarını istifadəçi-dostu mesajlara çevir
 */
fun String?.toUserFriendlyError(): String {
    if (this == null) return "Bilinməyən xəta baş verdi"
    val lower = this.lowercase()
    return when {
        lower.contains("unable to resolve host") || lower.contains("no address associated") ->
            "İnternet bağlantısı yoxdur. Şəbəkənizi yoxlayın."
        lower.contains("timeout") || lower.contains("timed out") ->
            "Server cavab vermir. Bir az sonra yenidən cəhd edin."
        lower.contains("connect") && lower.contains("fail") ->
            "Serverə qoşulmaq mümkün olmadı. İnternetinizi yoxlayın."
        lower.contains("ssl") || lower.contains("certificate") ->
            "Təhlükəsiz bağlantı qurula bilmədi."
        lower.contains("401") || lower.contains("unauthorized") ->
            "Sessiya bitib. Yenidən daxil olun."
        lower.contains("403") || lower.contains("forbidden") ->
            "Bu əməliyyat üçün icazəniz yoxdur."
        lower.contains("404") || lower.contains("not found") ->
            "Məlumat tapılmadı."
        lower.contains("500") || lower.contains("internal server") ->
            "Server xətası. Bir az sonra yenidən cəhd edin."
        lower.contains("503") || lower.contains("service unavailable") ->
            "Xidmət müvəqqəti olaraq əlçatmazdır."
        lower.contains("şəbəkə") || lower.contains("network") ->
            "Şəbəkə xətası. İnternet bağlantınızı yoxlayın."
        lower.contains("json") || lower.contains("parse") || lower.contains("serial") ->
            "Serverdən gələn cavab emal edilə bilmədi."
        else -> this
    }
}

/**
 * HTTP status kodu əsasında user-friendly mesaj
 */
fun Int.httpCodeToMessage(): String {
    return when (this) {
        400 -> "Yanlış sorğu göndərildi."
        401 -> "Sessiya bitib. Yenidən daxil olun."
        403 -> "Bu əməliyyat üçün icazəniz yoxdur."
        404 -> "Məlumat tapılmadı."
        409 -> "Bu məlumat artıq mövcuddur."
        422 -> "Daxil edilən məlumatlar düzgün deyil."
        429 -> "Çox tez-tez sorğu göndərilir. Bir az gözləyin."
        in 500..599 -> "Server xətası. Bir az sonra yenidən cəhd edin."
        else -> "Xəta baş verdi (kod: $this)"
    }
}
