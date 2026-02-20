package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

/**
 * iOS PremiumManager.swift-in Android Repository ekvivalenti.
 */
class PremiumRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getStatus(): Result<PremiumStatus> {
        return try {
            Result.success(api.getPremiumStatus())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPlans(): Result<List<PremiumPlan>> {
        return try {
            Result.success(api.getPremiumPlans())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun subscribe(request: SubscribeRequest): Result<Unit> {
        return try {
            api.subscribe(request)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: POST /api/v1/premium/activate (body yoxdur)
    suspend fun activate(): Result<Unit> {
        return try {
            api.activatePremium()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun cancel(): Result<Unit> {
        return try {
            api.cancelSubscription()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun restore(): Result<Unit> {
        return try {
            api.restoreSubscription()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getHistory(): Result<List<SubscriptionHistory>> {
        return try {
            Result.success(api.getSubscriptionHistory())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: PremiumRepository? = null
        fun getInstance(context: Context): PremiumRepository =
            instance ?: synchronized(this) {
                instance ?: PremiumRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
