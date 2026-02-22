package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

/**
 * iOS AnalyticsManager.swift-in Android Repository ekvivalenti.
 */
class AnalyticsRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getDailyStats(date: String): Result<DailyStats> {
        return try {
            Result.success(api.getDailyAnalytics(date))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getWeeklyStats(): Result<WeeklyStats> {
        return try {
            Result.success(api.getWeeklyAnalytics())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getDashboard(): Result<AnalyticsDashboard> {
        return try {
            Result.success(api.getAnalyticsDashboard())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getMeasurements(): Result<List<BodyMeasurement>> {
        return try {
            Result.success(api.getMeasurements())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createMeasurement(request: BodyMeasurementCreateRequest): Result<BodyMeasurement> {
        return try {
            Result.success(api.createMeasurement(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteMeasurement(id: String): Result<Unit> {
        return try {
            api.deleteMeasurement(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getComparison(period: String = "week"): Result<ProgressComparison> {
        return try {
            Result.success(api.getProgressComparison(period))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: AnalyticsRepository? = null
        fun getInstance(context: Context): AnalyticsRepository =
            instance ?: synchronized(this) {
                instance ?: AnalyticsRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
