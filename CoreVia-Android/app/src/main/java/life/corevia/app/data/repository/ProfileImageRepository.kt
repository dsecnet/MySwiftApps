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
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS ProfileImageManager.swift equivalent
 * Profil şəkillərini backend-ə upload / download / delete etmə
 */
@Singleton
class ProfileImageRepository @Inject constructor(
    private val okHttpClient: OkHttpClient
) {

    // ─── Upload Image ───────────────────────────────────────────────

    suspend fun uploadProfileImage(imageBytes: ByteArray): NetworkResult<String> {
        return withContext(Dispatchers.IO) {
            try {
                val requestBody = MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart(
                        "file",
                        "profile.jpg",
                        imageBytes.toRequestBody("image/jpeg".toMediaTypeOrNull())
                    )
                    .build()

                val request = Request.Builder()
                    .url("${Constants.BASE_URL}/api/v1/uploads/profile-image")
                    .post(requestBody)
                    .build()

                val response = okHttpClient.newCall(request).execute()
                val body = response.body?.string() ?: ""

                if (response.isSuccessful) {
                    NetworkResult.Success(body)
                } else {
                    NetworkResult.Error("Upload xətası: ${response.code}")
                }
            } catch (e: Exception) {
                NetworkResult.Error("Upload xətası: ${e.localizedMessage}")
            }
        }
    }

    // ─── Download Image ─────────────────────────────────────────────

    suspend fun downloadProfileImage(imageUrl: String): NetworkResult<Bitmap> {
        return withContext(Dispatchers.IO) {
            try {
                val fullUrl = if (imageUrl.startsWith("http")) {
                    imageUrl
                } else {
                    "${Constants.BASE_URL}$imageUrl"
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

    // ─── Delete Image ───────────────────────────────────────────────

    suspend fun deleteProfileImage(): NetworkResult<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                val request = Request.Builder()
                    .url("${Constants.BASE_URL}/api/v1/uploads/profile-image")
                    .delete()
                    .build()

                val response = okHttpClient.newCall(request).execute()

                if (response.isSuccessful) {
                    NetworkResult.Success(Unit)
                } else {
                    NetworkResult.Error("Silmə xətası: ${response.code}")
                }
            } catch (e: Exception) {
                NetworkResult.Error("Silmə xətası: ${e.localizedMessage}")
            }
        }
    }

    // ─── Resize Image (iOS: resizeImage helper) ─────────────────────

    fun resizeImage(bitmap: Bitmap, maxSize: Int = 300): Bitmap {
        val width = bitmap.width
        val height = bitmap.height

        if (width <= maxSize && height <= maxSize) return bitmap

        val ratio = minOf(maxSize.toFloat() / width, maxSize.toFloat() / height)
        val newWidth = (width * ratio).toInt()
        val newHeight = (height * ratio).toInt()

        return Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true)
    }

    // ─── Bitmap → compressed JPEG bytes ─────────────────────────────

    fun compressImage(bitmap: Bitmap, quality: Int = 80): ByteArray {
        val resized = resizeImage(bitmap)
        val stream = ByteArrayOutputStream()
        resized.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        return stream.toByteArray()
    }
}
