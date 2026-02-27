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
