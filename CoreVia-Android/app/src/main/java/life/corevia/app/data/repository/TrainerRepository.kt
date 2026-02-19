package life.corevia.app.data.repository

import android.content.Context
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
            Result.success(api.getTrainerStats())
        } catch (e: Exception) {
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
