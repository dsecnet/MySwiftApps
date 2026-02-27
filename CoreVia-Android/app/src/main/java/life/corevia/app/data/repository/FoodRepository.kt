package life.corevia.app.data.repository

import life.corevia.app.data.model.DailyFoodStats
import life.corevia.app.data.model.FoodCreateRequest
import life.corevia.app.data.model.FoodEntry
import life.corevia.app.data.model.FoodUpdateRequest
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS FoodManager.swift CRUD equivalent
 * Qida data management — Backend API ilə
 */
@Singleton
class FoodRepository @Inject constructor(
    private val apiService: ApiService
) {

    // ─── Get All Food Entries ────────────────────────────────────────

    suspend fun getFoodEntries(): NetworkResult<List<FoodEntry>> {
        return try {
            val response = apiService.getFoodEntries()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Qida məlumatları yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Get Daily Stats ─────────────────────────────────────────────

    suspend fun getDailyStats(): NetworkResult<DailyFoodStats> {
        return try {
            val response = apiService.getDailyFoodStats()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: DailyFoodStats())
            } else {
                NetworkResult.Error("Statistika yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Add Food Entry ──────────────────────────────────────────────

    suspend fun addEntry(request: FoodCreateRequest): NetworkResult<FoodEntry> {
        return try {
            val response = apiService.addFoodEntry(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Qida əlavə edilə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Update Food Entry ───────────────────────────────────────────

    suspend fun updateEntry(id: String, request: FoodUpdateRequest): NetworkResult<FoodEntry> {
        return try {
            val createReq = FoodCreateRequest(
                name = request.name ?: "",
                calories = request.calories ?: 0,
                protein = request.protein,
                carbs = request.carbs,
                fats = request.fats,
                mealType = request.mealType ?: "breakfast",
                notes = request.notes
            )
            val response = apiService.updateFoodEntry(id, createReq)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Qida yenilənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Delete Food Entry ───────────────────────────────────────────

    suspend fun deleteEntry(id: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deleteFoodEntry(id)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Qida silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
