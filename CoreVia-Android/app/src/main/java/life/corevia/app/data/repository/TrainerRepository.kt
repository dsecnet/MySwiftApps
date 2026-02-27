package life.corevia.app.data.repository

import life.corevia.app.data.model.TrainerResponse
import life.corevia.app.data.model.UserResponse
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

/**
 * iOS TrainerManager.swift equivalent
 * Trainer API inteqrasiyası — fetch, assign, unassign, students
 */
@Singleton
class TrainerRepository @Inject constructor(
    private val apiService: ApiService
) {

    // ─── Bütün Trainerleri Getir ─────────────────────────────────────

    suspend fun fetchTrainers(): NetworkResult<List<TrainerResponse>> {
        return try {
            val response = apiService.getTrainers()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Trenerlər yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Trainer Məlumatı Getir ──────────────────────────────────────

    suspend fun fetchTrainer(trainerId: String): NetworkResult<TrainerResponse> {
        return try {
            val response = apiService.getTrainer(trainerId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Trener tapılmadı", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Trainer-ə Qoşul (Premium lazımdır) ─────────────────────────

    suspend fun assignTrainer(trainerId: String): NetworkResult<UserResponse> {
        return try {
            val response = apiService.assignTrainer(trainerId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Trenerə qoşulmaq mümkün olmadı", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Trainer-dən Ayrıl ───────────────────────────────────────────

    suspend fun unassignTrainer(): NetworkResult<UserResponse> {
        return try {
            val response = apiService.unassignTrainer()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Trenerdən ayrılmaq mümkün olmadı", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    // ─── Bağlı Trainer Məlumatı Getir ────────────────────────────────

    suspend fun fetchAssignedTrainer(trainerId: String): NetworkResult<TrainerResponse> {
        return fetchTrainer(trainerId)
    }

    // ─── Mənim Tələbələrim (Trainer üçün) ────────────────────────────

    suspend fun fetchMyStudents(): NetworkResult<List<UserResponse>> {
        return try {
            val response = apiService.getMyStudents()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Tələbələr yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
