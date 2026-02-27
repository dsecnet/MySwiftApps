package life.corevia.app.data.repository

import life.corevia.app.data.model.CreateCommentRequest
import life.corevia.app.data.model.CreatePostRequest
import life.corevia.app.data.model.FeedResponse
import life.corevia.app.data.model.PostComment
import life.corevia.app.data.model.SocialPost
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SocialRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getFeed(page: Int = 1, limit: Int = 20): NetworkResult<FeedResponse> {
        return try {
            val response = apiService.getSocialFeed(page = page, limit = limit)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: FeedResponse())
            } else {
                NetworkResult.Error("Feed yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun createPost(request: CreatePostRequest): NetworkResult<SocialPost> {
        return try {
            val response = apiService.createPost(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: SocialPost())
            } else {
                NetworkResult.Error("Post yaradıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun toggleLike(postId: String): NetworkResult<SocialPost> {
        return try {
            val response = apiService.togglePostLike(postId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: SocialPost())
            } else {
                NetworkResult.Error("Like əməliyyatı uğursuz", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun deletePost(postId: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deletePost(postId)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Post silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getComments(postId: String): NetworkResult<List<PostComment>> {
        return try {
            val response = apiService.getPostComments(postId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Şərhlər yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun addComment(postId: String, content: String): NetworkResult<PostComment> {
        return try {
            val response = apiService.addPostComment(postId, CreateCommentRequest(content))
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: PostComment())
            } else {
                NetworkResult.Error("Şərh əlavə edilə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun deleteComment(postId: String, commentId: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deletePostComment(postId, commentId)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Şərh silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
