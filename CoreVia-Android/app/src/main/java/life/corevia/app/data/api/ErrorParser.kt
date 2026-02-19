package life.corevia.app.data.api

import org.json.JSONObject

/**
 * iOS-dakı error parse ilə eyni — backend `{"detail": "..."}` qaytarır.
 * Bütün repository-lərdə istifadə oluna bilər.
 */
object ErrorParser {

    fun parseMessage(e: Exception): String {
        return when (e) {
            is retrofit2.HttpException -> {
                try {
                    val errorBody = e.response()?.errorBody()?.string()
                    if (!errorBody.isNullOrBlank()) {
                        val json = JSONObject(errorBody)
                        json.optString("detail").takeIf { it.isNotBlank() }
                            ?: "Xəta kodu: ${e.code()}"
                    } else {
                        httpCodeMessage(e.code())
                    }
                } catch (_: Exception) {
                    httpCodeMessage(e.code())
                }
            }
            is java.net.UnknownHostException -> "İnternet bağlantısı yoxdur"
            is java.net.SocketTimeoutException -> "Serverlə əlaqə vaxtı bitdi"
            is java.net.ConnectException -> "Serverə qoşulmaq mümkün olmadı"
            else -> e.message ?: "Naməlum xəta"
        }
    }

    private fun httpCodeMessage(code: Int): String {
        return when (code) {
            400 -> "Yanlış sorğu"
            401 -> "Sessiyanız bitib, yenidən giriş edin"
            403 -> "İcazəniz yoxdur"
            404 -> "Tapılmadı"
            409 -> "Artıq mövcuddur"
            422 -> "Məlumatları yoxlayın"
            429 -> "Çox sorğu göndərdiniz, bir az gözləyin"
            500 -> "Server xətası, sonra yenidən cəhd edin"
            else -> "Xəta kodu: $code"
        }
    }
}
