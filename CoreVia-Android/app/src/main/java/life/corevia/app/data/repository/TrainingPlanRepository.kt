package life.corevia.app.data.repository

import life.corevia.app.data.model.TrainingPlan
import life.corevia.app.data.model.TrainingPlanCreateRequest
import life.corevia.app.data.model.TrainingPlanUpdateRequest
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS TrainingPlanManager.swift CRUD equivalent
 * İdman planı idarəsi — Backend API ilə
 */
@Singleton
class TrainingPlanRepository @Inject constructor(
    private val apiService: ApiService
) {

    // ─── Get All Training Plans ──────────────────────────────────────

    suspend fun getTrainingPlans(): NetworkResult<List<TrainingPlan>> {
        return try {
            val response = apiService.getTrainingPlans()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("İdman planları yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Get Training Plan by ID ─────────────────────────────────────

    suspend fun getTrainingPlan(id: String): NetworkResult<TrainingPlan> {
        return try {
            val response = apiService.getTrainingPlan(id)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("İdman planı tapılmadı", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Create Training Plan ────────────────────────────────────────

    suspend fun createTrainingPlan(request: TrainingPlanCreateRequest): NetworkResult<TrainingPlan> {
        return try {
            val response = apiService.createTrainingPlan(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("İdman planı yaradıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Update Training Plan ────────────────────────────────────────

    suspend fun updateTrainingPlan(
        id: String,
        request: TrainingPlanUpdateRequest
    ): NetworkResult<TrainingPlan> {
        return try {
            val response = apiService.updateTrainingPlan(id, request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("İdman planı yenilənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Delete Training Plan ────────────────────────────────────────

    suspend fun deleteTrainingPlan(id: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deleteTrainingPlan(id)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("İdman planı silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Complete Training Plan ──────────────────────────────────────

    suspend fun completeTrainingPlan(id: String): NetworkResult<TrainingPlan> {
        return try {
            val response = apiService.completeTrainingPlan(id)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Plan tamamlana bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
