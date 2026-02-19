package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.TrainingPlan
import life.corevia.app.data.models.TrainingPlanCreateRequest

/**
 * iOS TrainingPlanManager.swift-in Android Repository ekvivalenti.
 * FIXED: createTrainingPlan request model düzəldildi + complete/delete əlavə edildi
 */
class TrainingPlanRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    // iOS: TrainingPlanManager.loadPlans()
    suspend fun getTrainingPlans(): Result<List<TrainingPlan>> {
        return try {
            Result.success(api.getTrainingPlans())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: TrainingPlanManager.createPlan(_:)
    suspend fun createTrainingPlan(request: TrainingPlanCreateRequest): Result<TrainingPlan> {
        return try {
            Result.success(api.createTrainingPlan(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: TrainingPlanManager.completePlan(_:)
    suspend fun completeTrainingPlan(planId: String): Result<TrainingPlan> {
        return try {
            Result.success(api.completeTrainingPlan(planId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: TrainingPlanManager.deletePlan(_:)
    suspend fun deleteTrainingPlan(planId: String): Result<Unit> {
        return try {
            api.deleteTrainingPlan(planId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: TrainingPlanRepository? = null
        fun getInstance(context: Context): TrainingPlanRepository =
            instance ?: synchronized(this) {
                instance ?: TrainingPlanRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
