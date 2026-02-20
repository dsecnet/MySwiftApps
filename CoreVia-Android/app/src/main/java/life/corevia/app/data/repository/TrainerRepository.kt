package life.corevia.app.data.repository

import android.content.Context
import android.util.Log
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

/**
 * iOS TrainerManager + ReviewManager-in Android Repository ekvivalenti.
 * Trainer siyahısı, detalları, assign/unassign, reviews.
 */
class TrainerRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    // ─── Trainers ───────────────────────────────────────────────────────────────

    suspend fun getTrainers(): Result<List<UserResponse>> {
        return try {
            Result.success(api.getTrainers())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getTrainer(trainerId: String): Result<UserResponse> {
        return try {
            Result.success(api.getTrainer(trainerId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun assignTrainer(trainerId: String): Result<Unit> {
        return try {
            api.assignTrainer(trainerId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun unassignTrainer(): Result<Unit> {
        return try {
            api.unassignTrainer()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // ─── Reviews ────────────────────────────────────────────────────────────────

    suspend fun getReviews(trainerId: String): Result<List<TrainerReview>> {
        return try {
            Result.success(api.getTrainerReviews(trainerId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getReviewSummary(trainerId: String): Result<ReviewSummary> {
        return try {
            Result.success(api.getReviewSummary(trainerId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createReview(trainerId: String, request: CreateReviewRequest): Result<TrainerReview> {
        return try {
            Result.success(api.createReview(trainerId, request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteReview(trainerId: String): Result<Unit> {
        return try {
            api.deleteReview(trainerId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // ─── Trainer Stats ──────────────────────────────────────────────────────────

    suspend fun getTrainerStats(): Result<TrainerStatsResponse> {
        return try {
            val response = api.getTrainerStats()
            Log.d("TrainerRepo", "Stats OK: subscribers=${response.totalSubscribers}, active=${response.activeStudents}, students=${response.students.size}, summary=${response.statsSummary}")
            if (response.students.isNotEmpty()) {
                response.students.forEachIndexed { i, s ->
                    Log.d("TrainerRepo", "Student[$i]: id=${s.id}, name=${s.name}, workouts=${s.thisWeekWorkouts}")
                }
            }
            Result.success(response)
        } catch (e: Exception) {
            Log.e("TrainerRepo", "Stats ERROR: ${e.javaClass.simpleName}: ${e.message}", e)
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: TrainerRepository? = null
        fun getInstance(context: Context): TrainerRepository =
            instance ?: synchronized(this) {
                instance ?: TrainerRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
