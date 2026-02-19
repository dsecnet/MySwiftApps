package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.MealPlan
import life.corevia.app.data.models.MealPlanCreateRequest

/**
 * iOS MealPlanManager.swift-in Android Repository ekvivalenti.
 */
class MealPlanRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    // iOS: MealPlanManager.loadPlans()
    suspend fun getMealPlans(): Result<List<MealPlan>> {
        return try {
            Result.success(api.getMealPlans())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: MealPlanManager.createPlan(_:)
    suspend fun createMealPlan(request: MealPlanCreateRequest): Result<MealPlan> {
        return try {
            Result.success(api.createMealPlan(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: MealPlanManager.completePlan(_:)
    suspend fun completeMealPlan(planId: String): Result<MealPlan> {
        return try {
            Result.success(api.completeMealPlan(planId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: MealPlanManager.deletePlan(_:)
    suspend fun deleteMealPlan(planId: String): Result<Unit> {
        return try {
            api.deleteMealPlan(planId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: MealPlanRepository? = null
        fun getInstance(context: Context): MealPlanRepository =
            instance ?: synchronized(this) {
                instance ?: MealPlanRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
