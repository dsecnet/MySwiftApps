package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

/**
 * iOS SocialManager.swift-in Android Repository ekvivalenti.
 */
class SocialRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getFeed(): Result<List<SocialPost>> {
        return try {
            Result.success(api.getSocialFeed())
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

    companion object {
        @Volatile private var instance: SocialRepository? = null
        fun getInstance(context: Context): SocialRepository =
            instance ?: synchronized(this) {
                instance ?: SocialRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
