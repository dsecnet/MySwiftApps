package life.corevia.app.data.repository

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import life.corevia.app.util.Constants
import life.corevia.app.util.NetworkResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.ByteArrayOutputStream
import java.util.concurrent.ConcurrentHashMap
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS FoodImageManager.swift equivalent
 * Qida şəkillərini backend-ə upload / download / cache etmə
 */
@Singleton
class FoodImageRepository @Inject constructor(
    private val okHttpClient: OkHttpClient
) {

    // ── In-memory image cache ────────────────────────────────────────
    private val imageCache = ConcurrentHashMap<String, Bitmap>()

    // ─── Save (Upload) Image to Backend ──────────────────────────────

    suspend fun saveImage(bitmap: Bitmap, entryId: String): NetworkResult<String> {
        return withContext(Dispatchers.IO) {
            try {
                // Resize to max 500x500
                val resized = resizeImage(bitmap, targetSize = 500)
                val imageBytes = compressImage(resized, quality = 70)

                // Cache locally
                imageCache[entryId] = resized

                val requestBody = MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart(
                        "file",
                        "food_$entryId.jpg",
                        imageBytes.toRequestBody("image/jpeg".toMediaTypeOrNull())
                    )
                    .build()

                val request = Request.Builder()
                    .url("${Constants.BASE_URL}/api/v1/food/$entryId/image")
                    .post(requestBody)
                    .build()

                val response = okHttpClient.newCall(request).execute()
                val body = response.body?.string() ?: ""

                if (response.isSuccessful) {
                    NetworkResult.Success(body)
                } else {
                    NetworkResult.Error("Şəkil yüklənə bilmədi: ${response.code}")
                }
            } catch (e: Exception) {
                NetworkResult.Error("Şəkil yüklənə bilmədi: ${e.localizedMessage}")
            }
        }
    }

    // ─── Load Image from Cache ───────────────────────────────────────

    fun loadImage(entryId: String): Bitmap? {
        return imageCache[entryId]
    }

    // ─── Load Image from URL ─────────────────────────────────────────

    suspend fun loadImageFromUrl(urlString: String, entryId: String): NetworkResult<Bitmap> {
        // Return cached if available
        imageCache[entryId]?.let {
            return NetworkResult.Success(it)
        }

        return withContext(Dispatchers.IO) {
            try {
                val fullUrl = if (urlString.startsWith("http")) {
                    urlString
                } else {
                    "${Constants.BASE_URL}$urlString"
                }

                val request = Request.Builder()
                    .url(fullUrl)
                    .get()
                    .build()

                val response = okHttpClient.newCall(request).execute()
                val bytes = response.body?.bytes()

                if (response.isSuccessful && bytes != null) {
                    val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                    if (bitmap != null) {
                        imageCache[entryId] = bitmap
                        NetworkResult.Success(bitmap)
                    } else {
                        NetworkResult.Error("Şəkil decode edilə bilmədi")
                    }
                } else {
                    NetworkResult.Error("Download xətası: ${response.code}")
                }
            } catch (e: Exception) {
                NetworkResult.Error("Download xətası: ${e.localizedMessage}")
            }
        }
    }

    // ─── Delete Image from Cache ─────────────────────────────────────

    fun deleteImage(entryId: String) {
        imageCache.remove(entryId)
    }

    // ─── Clear All Cache ─────────────────────────────────────────────

    fun clearCache() {
        imageCache.clear()
    }

    // ─── Helper: Resize Image ────────────────────────────────────────

    fun resizeImage(bitmap: Bitmap, targetSize: Int = 500): Bitmap {
        val width = bitmap.width
        val height = bitmap.height

        val widthRatio = targetSize.toFloat() / width
        val heightRatio = targetSize.toFloat() / height
        val scaleFactor = minOf(widthRatio, heightRatio)

        if (scaleFactor >= 1.0f) return bitmap

        val newWidth = (width * scaleFactor).toInt()
        val newHeight = (height * scaleFactor).toInt()

        return Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true)
    }

    // ─── Helper: Compress to JPEG bytes ──────────────────────────────

    fun compressImage(bitmap: Bitmap, quality: Int = 70): ByteArray {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        return stream.toByteArray()
    }
}
