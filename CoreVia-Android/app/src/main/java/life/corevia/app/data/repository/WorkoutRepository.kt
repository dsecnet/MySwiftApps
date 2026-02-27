package life.corevia.app.data.repository

import life.corevia.app.data.model.Workout
import life.corevia.app.data.model.WorkoutCreateRequest
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WorkoutRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getWorkouts(): NetworkResult<List<Workout>> {
        return try {
            val response = apiService.getWorkouts()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Məşqlər yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun createWorkout(request: WorkoutCreateRequest): NetworkResult<Workout> {
        return try {
            val response = apiService.createWorkout(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Məşq əlavə edilə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun toggleWorkout(id: String): NetworkResult<Workout> {
        return try {
            val response = apiService.toggleWorkout(id)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Status dəyişdirilə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun deleteWorkout(id: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deleteWorkout(id)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Məşq silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
