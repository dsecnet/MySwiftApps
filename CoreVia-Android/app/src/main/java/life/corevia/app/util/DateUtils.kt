package life.corevia.app.util

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

object DateUtils {
    private val azLocale = Locale("az")

    fun getGreeting(): String {
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        return when {
            hour < 6 -> "Gecəniz xeyir"
            hour < 12 -> "Sabahınız xeyir"
            hour < 18 -> "Günortanız xeyir"
            else -> "Axşamınız xeyir"
        }
    }

    fun getTodayFormatted(): String {
        val sdf = SimpleDateFormat("dd MMMM yyyy", azLocale)
        return sdf.format(Date())
    }

    fun getDayOfWeek(): String {
        val sdf = SimpleDateFormat("EEEE", azLocale)
        return sdf.format(Date())
    }
}
