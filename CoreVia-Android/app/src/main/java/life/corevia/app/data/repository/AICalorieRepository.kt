package life.corevia.app.data.repository

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import life.corevia.app.data.local.OnDeviceFoodAnalyzer
import life.corevia.app.data.model.AICalorieResult
import life.corevia.app.data.model.BackendFoodAnalysisResponse
import life.corevia.app.data.model.DetectedFood
import life.corevia.app.data.model.FoodCreateRequest
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import life.corevia.app.util.Constants
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import timber.log.Timber
import java.util.Calendar
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

/**
 * AI Kalori Repository — iOS AICalorieService.swift ekvivalenti
 *
 * Strategiya (iOS ilə eyni):
 * 1. Əvvəlcə ON-DEVICE analiz (ML Kit + lokal DB) — offline, sürətli
 * 2. Uğursuz olarsa → BACKEND fallback (/api/v1/food/analyze)
 */
@Singleton
class AICalorieRepository @Inject constructor(
    private val apiService: ApiService,
    private val okHttpClient: OkHttpClient,
    private val json: Json,
    private val onDeviceFoodAnalyzer: OnDeviceFoodAnalyzer
) {
    /**
     * Şəkili analiz edir — əvvəlcə on-device, sonra backend fallback
     * iOS-dakı kimi: on-device first, backend fallback
     */
    suspend fun analyzeFood(imageBytes: ByteArray): NetworkResult<AICalorieResult> {
        return withContext(Dispatchers.IO) {
            // Step 1: On-device analiz (offline, sürətli)
            try {
                Timber.d("🔍 On-device analiz başlayır...")
                val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                if (bitmap != null) {
                    val result = onDeviceFoodAnalyzer.analyzeFood(bitmap)
                    Timber.d("✅ On-device analiz uğurlu: ${result.foods.size} yemək, ${result.totalCalories.toInt()} kcal")
                    return@withContext NetworkResult.Success(result)
                }
            } catch (e: Exception) {
                Timber.w("⚠️ On-device analiz uğursuz: ${e.message}, backend-ə keçilir...")
            }

            // Step 2: Backend fallback (iOS-dakı kimi)
            try {
                Timber.d("🌐 Backend analiz başlayır...")
                val requestBody = MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart(
                        "file",
                        "food_photo.jpg",
                        imageBytes.toRequestBody("image/jpeg".toMediaTypeOrNull())
                    )
                    .build()

                val request = Request.Builder()
                    .url("${Constants.BASE_URL}/api/v1/food/analyze")
                    .post(requestBody)
                    .build()

                val response = okHttpClient.newCall(request).execute()

                if (response.isSuccessful) {
                    val body = response.body?.string() ?: "{}"
                    try {
                        val result = json.decodeFromString<AICalorieResult>(body)
                        Timber.d("✅ Backend analiz uğurlu")
                        NetworkResult.Success(result)
                    } catch (e: Exception) {
                        try {
                            val backendResponse = json.decodeFromString<BackendFoodAnalysisResponse>(body)
                            val mapped = mapBackendResponse(backendResponse)
                            Timber.d("✅ Backend analiz uğurlu (mapped)")
                            NetworkResult.Success(mapped)
                        } catch (e2: Exception) {
                            NetworkResult.Error("Cavab emal edilə bilmədi: ${e2.message}")
                        }
                    }
                } else {
                    NetworkResult.Error("Analiz uğursuz oldu", response.code)
                }
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Şəbəkə xətası")
            }
        }
    }

    /**
     * Yalnız on-device analiz — offline mode üçün
     */
    suspend fun analyzeFoodOffline(bitmap: Bitmap): NetworkResult<AICalorieResult> {
        return withContext(Dispatchers.IO) {
            try {
                val result = onDeviceFoodAnalyzer.analyzeFood(bitmap)
                NetworkResult.Success(result)
            } catch (e: Exception) {
                NetworkResult.Error("Offline analiz uğursuz: ${e.message}")
            }
        }
    }

    private fun mapBackendResponse(response: BackendFoodAnalysisResponse): AICalorieResult {
        val foods = mutableListOf<DetectedFood>()

        if (!response.foodsDetail.isNullOrEmpty()) {
            for (detail in response.foodsDetail) {
                foods.add(
                    DetectedFood(
                        id = UUID.randomUUID().toString(),
                        name = detail.name ?: "Yemək",
                        calories = detail.calories ?: 0.0,
                        protein = detail.protein ?: 0.0,
                        carbs = detail.carbs ?: 0.0,
                        fat = detail.fats ?: 0.0,
                        portionGrams = 200.0,
                        confidence = response.confidence ?: 0.5
                    )
                )
            }
        } else {
            foods.add(
                DetectedFood(
                    id = UUID.randomUUID().toString(),
                    name = response.foodName ?: "Yemək",
                    calories = response.calories ?: 0.0,
                    protein = response.protein ?: 0.0,
                    carbs = response.carbs ?: 0.0,
                    fat = response.fats ?: 0.0,
                    portionGrams = 200.0,
                    confidence = response.confidence ?: 0.5
                )
            )
        }

        val totalCalories = foods.sumOf { it.calories }
        val totalProtein = foods.sumOf { it.protein }
        val totalCarbs = foods.sumOf { it.carbs }
        val totalFat = foods.sumOf { it.fat }

        return AICalorieResult(
            foods = foods,
            totalCalories = totalCalories,
            totalProtein = totalProtein,
            totalCarbs = totalCarbs,
            totalFat = totalFat,
            confidence = response.confidence ?: 0.5,
            imageUrl = null
        )
    }

    // Save AI analysis result as food entry
    suspend fun saveAsFood(food: DetectedFood, mealType: String): NetworkResult<Unit> {
        return try {
            val request = FoodCreateRequest(
                name = food.name,
                calories = food.calories.toInt(),
                protein = food.protein,
                carbs = food.carbs,
                fats = food.fat,
                mealType = mealType
            )
            val response = apiService.addFoodEntry(request)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Qida saxlanıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // Estimate meal type based on current hour
    fun estimateMealType(): String {
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        return when (hour) {
            in 6..10 -> "breakfast"
            in 11..14 -> "lunch"
            in 15..16 -> "snack"
            in 17..21 -> "dinner"
            else -> "snack"
        }
    }
}
