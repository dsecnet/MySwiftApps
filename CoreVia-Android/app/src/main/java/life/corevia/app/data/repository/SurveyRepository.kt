package life.corevia.app.data.repository

import life.corevia.app.data.model.DailySurveyRequest
import life.corevia.app.data.model.DailySurveyResponse
import life.corevia.app.data.model.TodaySurveyStatus
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SurveyRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun submitDailySurvey(request: DailySurveyRequest): NetworkResult<DailySurveyResponse> {
        return try {
            val response = apiService.submitDailySurvey(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Sorğu göndərilə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getTodayStatus(): NetworkResult<TodaySurveyStatus> {
        return try {
            val response = apiService.getTodaySurveyStatus()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Status alına bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
