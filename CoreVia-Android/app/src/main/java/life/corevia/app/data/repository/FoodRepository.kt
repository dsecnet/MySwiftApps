package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*
import okhttp3.MultipartBody

/**
 * iOS FoodManager.swift-in Android Repository ekvivalenti.
 */
class FoodRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    // iOS: FoodManager.loadFoodEntries()
    suspend fun getFoodEntries(): Result<List<FoodEntry>> {
        return try {
            Result.success(api.getFoodEntries())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: FoodManager.addFoodEntry(_:)
    suspend fun createFoodEntry(request: FoodEntryCreateRequest): Result<FoodEntry> {
        return try {
            Result.success(api.createFoodEntry(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: FoodManager.updateFoodEntry(_:)
    suspend fun updateFoodEntry(id: String, request: FoodEntryCreateRequest): Result<FoodEntry> {
        return try {
            Result.success(api.updateFoodEntry(id, request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // AI Food Analysis
    suspend fun analyzeFoodImage(filePart: MultipartBody.Part): Result<FoodAnalysisResult> {
        return try {
            Result.success(api.analyzeFoodImage(filePart))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: FoodManager.deleteFoodEntry(_:)
    suspend fun deleteFoodEntry(id: String): Result<Unit> {
        return try {
            api.deleteFoodEntry(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: FoodRepository? = null
        fun getInstance(context: Context): FoodRepository =
            instance ?: synchronized(this) {
                instance ?: FoodRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
