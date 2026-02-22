package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

/**
 * iOS WorkoutManager.swift-in Android Repository ekvivalenti.
 *
 * WorkoutViewModel bu class-ı çağırır.
 * Screen WorkoutViewModel-i çağırır.
 * Heç bir Screen birbaşa bu class-a toxunmur.
 */
class WorkoutRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    // iOS: WorkoutManager.loadWorkouts()
    suspend fun getWorkouts(): Result<List<Workout>> {
        return try {
            Result.success(api.getWorkouts())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: WorkoutManager.addWorkout(_ workout:)
    suspend fun createWorkout(request: WorkoutCreateRequest): Result<Workout> {
        return try {
            Result.success(api.createWorkout(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: WorkoutManager.updateWorkout(_ workout:)
    suspend fun updateWorkout(id: String, request: WorkoutUpdateRequest): Result<Workout> {
        return try {
            Result.success(api.updateWorkout(id, request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: WorkoutManager.deleteWorkout(_ workout:)
    suspend fun deleteWorkout(id: String): Result<Unit> {
        return try {
            api.deleteWorkout(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: WorkoutManager.loadStats()
    suspend fun getWorkoutStats(): Result<WorkoutStatsResponse> {
        return try {
            Result.success(api.getWorkoutStats())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: WorkoutRepository? = null
        fun getInstance(context: Context): WorkoutRepository =
            instance ?: synchronized(this) {
                instance ?: WorkoutRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
