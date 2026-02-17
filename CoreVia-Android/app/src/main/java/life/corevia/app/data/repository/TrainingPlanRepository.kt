package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.TrainingPlan

/**
 * iOS TrainingPlanManager.swift-in Android Repository ekvivalenti.
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
    suspend fun createTrainingPlan(plan: TrainingPlan): Result<TrainingPlan> {
        return try {
            Result.success(api.createTrainingPlan(plan))
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
    }
}
