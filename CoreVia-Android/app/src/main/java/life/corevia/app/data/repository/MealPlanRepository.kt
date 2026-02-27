package life.corevia.app.data.repository

import life.corevia.app.data.model.MealPlan
import life.corevia.app.data.model.MealPlanCreateRequest
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MealPlanRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getMealPlans(): NetworkResult<List<MealPlan>> {
        return try {
            val response = apiService.getMealPlans()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Yemək planları yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getMealPlan(id: String): NetworkResult<MealPlan> {
        return try {
            val response = apiService.getMealPlan(id)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Yemək planı yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun createMealPlan(request: MealPlanCreateRequest): NetworkResult<MealPlan> {
        return try {
            val response = apiService.createMealPlan(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Yemək planı yaradıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun updateMealPlan(id: String, request: MealPlanCreateRequest): NetworkResult<MealPlan> {
        return try {
            val response = apiService.updateMealPlan(id, request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Yemək planı yenilənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun deleteMealPlan(id: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deleteMealPlan(id)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Yemək planı silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
