package life.corevia.app.data.repository

import life.corevia.app.data.model.ContentCreateRequest
import life.corevia.app.data.model.ContentResponse
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.Constants
import life.corevia.app.util.NetworkResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS ContentManager.swift equivalent
 * Content CRUD operations — trainer content management
 */
@Singleton
class ContentRepository @Inject constructor(
    private val apiService: ApiService,
    private val okHttpClient: OkHttpClient
) {

    // ─── Fetch Trainer Content ───────────────────────────────────────

    suspend fun fetchTrainerContent(trainerId: String): NetworkResult<List<ContentResponse>> {
        return try {
            val response = apiService.getTrainerContent(trainerId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Content yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Fetch My Content ────────────────────────────────────────────

    suspend fun fetchMyContent(): NetworkResult<List<ContentResponse>> {
        return try {
            val response = apiService.getMyContent()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Content yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Create Content ──────────────────────────────────────────────

    suspend fun createContent(request: ContentCreateRequest): NetworkResult<ContentResponse> {
        return try {
            val response = apiService.createContent(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Content yaradıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Upload Content Image ────────────────────────────────────────

    suspend fun uploadContentImage(
        contentId: String,
        imageBytes: ByteArray
    ): NetworkResult<String> {
        return withContext(Dispatchers.IO) {
            try {
                val requestBody = MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart(
                        "file",
                        "content_$contentId.jpg",
                        imageBytes.toRequestBody("image/jpeg".toMediaTypeOrNull())
                    )
                    .build()

                val request = Request.Builder()
                    .url("${Constants.BASE_URL}/api/v1/content/$contentId/image")
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

    // ─── Delete Content ──────────────────────────────────────────────

    suspend fun deleteContent(contentId: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deleteContent(contentId)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Content silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
