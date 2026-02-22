package life.corevia.app.data.repository

import android.content.Context
import android.net.Uri
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.toRequestBody

/**
 * iOS SocialManager.swift-in Android Repository ekvivalenti.
 */
class SocialRepository(private val context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getFeed(page: Int = 1): Result<List<SocialPost>> {
        return try {
            val response = api.getSocialFeed(page = page)
            Result.success(response.posts)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createPost(request: CreatePostRequest): Result<SocialPost> {
        return try {
            Result.success(api.createPost(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deletePost(postId: String): Result<Unit> {
        return try {
            api.deletePost(postId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun likePost(postId: String): Result<Unit> {
        return try {
            api.likePost(postId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun unlikePost(postId: String): Result<Unit> {
        return try {
            api.unlikePost(postId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getComments(postId: String): Result<List<SocialComment>> {
        return try {
            Result.success(api.getComments(postId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createComment(postId: String, request: CreateCommentRequest): Result<SocialComment> {
        return try {
            Result.success(api.createComment(postId, request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun followUser(userId: String): Result<Unit> {
        return try {
            api.followUser(userId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun unfollowUser(userId: String): Result<Unit> {
        return try {
            api.unfollowUser(userId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getUserProfile(userId: String): Result<UserProfileSummary> {
        return try {
            Result.success(api.getUserProfile(userId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getAchievements(): Result<List<Achievement>> {
        return try {
            Result.success(api.getAchievements())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getAllAchievements(): Result<List<Achievement>> {
        return try {
            Result.success(api.getAllAchievements())
        } catch (e: Exception) {
            try {
                Result.success(api.getAchievements())
            } catch (e2: Exception) {
                Result.failure(e2)
            }
        }
    }

    suspend fun uploadPostImage(postId: String, imageUri: Uri): Result<SocialPost> {
        return try {
            val inputStream = context.contentResolver.openInputStream(imageUri)
                ?: return Result.failure(Exception("Şəkil oxuna bilmədi"))
            val bytes = inputStream.readBytes()
            inputStream.close()
            val requestBody = bytes.toRequestBody("image/jpeg".toMediaTypeOrNull())
            val part = MultipartBody.Part.createFormData("file", "post_image.jpg", requestBody)
            Result.success(api.uploadPostImage(postId, part))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getUserPosts(userId: String): Result<List<SocialPost>> {
        return try {
            Result.success(api.getUserPosts(userId))
        } catch (e: Exception) {
            // Fallback: feed-dən filtr
            try {
                val response = api.getSocialFeed()
                Result.success(response.posts.filter { it.userId == userId })
            } catch (e2: Exception) {
                Result.failure(e2)
            }
        }
    }

    companion object {
        @Volatile private var instance: SocialRepository? = null
        fun getInstance(context: Context): SocialRepository =
            instance ?: synchronized(this) {
                instance ?: SocialRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
