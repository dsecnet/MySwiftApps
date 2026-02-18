package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.ProfileUpdateRequest
import life.corevia.app.data.models.UserResponse

/**
 * iOS: UserService / ProfileView data layer.
 * User profile + trainer students.
 */
class UserRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    // iOS: getMe()
    suspend fun getMe(): Result<UserResponse> {
        return try {
            Result.success(api.getMe())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: updateProfile()
    suspend fun updateProfile(request: ProfileUpdateRequest): Result<UserResponse> {
        return try {
            Result.success(api.updateProfile(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // iOS: getMyStudents() — Trainer only
    suspend fun getMyStudents(): Result<List<UserResponse>> {
        return try {
            Result.success(api.getMyStudents())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: UserRepository? = null
        fun getInstance(context: Context): UserRepository =
            instance ?: synchronized(this) {
                instance ?: UserRepository(context.applicationContext).also { instance = it }
            }
    }
}
