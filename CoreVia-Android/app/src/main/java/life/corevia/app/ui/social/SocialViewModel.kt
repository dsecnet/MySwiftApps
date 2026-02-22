package life.corevia.app.ui.social

import android.app.Application
import android.net.Uri
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.SocialRepository

/**
 * iOS SocialManager.swift-in Android ViewModel ekvivalenti.
 *
 * Feed + post CRUD + like + comments + follow + profile + achievements.
 */
class SocialViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = SocialRepository.getInstance(application)

    // ─── State ──────────────────────────────────────────────────────────────────
    private val _posts = MutableStateFlow<List<SocialPost>>(emptyList())
    val posts: StateFlow<List<SocialPost>> = _posts.asStateFlow()

    private val _comments = MutableStateFlow<List<SocialComment>>(emptyList())
    val comments: StateFlow<List<SocialComment>> = _comments.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    // Sheet states
    private val _showCreatePost = MutableStateFlow(false)
    val showCreatePost: StateFlow<Boolean> = _showCreatePost.asStateFlow()

    private val _showComments = MutableStateFlow(false)
    val showComments: StateFlow<Boolean> = _showComments.asStateFlow()

    private val _selectedPostId = MutableStateFlow<String?>(null)
    val selectedPostId: StateFlow<String?> = _selectedPostId.asStateFlow()

    // User Profile state
    private val _selectedUserProfile = MutableStateFlow<UserProfileSummary?>(null)
    val selectedUserProfile: StateFlow<UserProfileSummary?> = _selectedUserProfile.asStateFlow()

    private val _userPosts = MutableStateFlow<List<SocialPost>>(emptyList())
    val userPosts: StateFlow<List<SocialPost>> = _userPosts.asStateFlow()

    // Achievements state
    private val _achievements = MutableStateFlow<List<Achievement>>(emptyList())
    val achievements: StateFlow<List<Achievement>> = _achievements.asStateFlow()

    init {
        loadFeed()
    }

    // ─── Feed ───────────────────────────────────────────────────────────────────

    fun loadFeed() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getFeed().fold(
                onSuccess = { _posts.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // ─── Post CRUD ──────────────────────────────────────────────────────────────

    fun createPost(content: String, postType: String = "general", imageUri: Uri? = null) {
        if (content.isBlank()) return
        viewModelScope.launch {
            _isLoading.value = true
            repository.createPost(CreatePostRequest(content, postType)).fold(
                onSuccess = { newPost ->
                    // Şəkil varsa yüklə
                    if (imageUri != null) {
                        repository.uploadPostImage(newPost.id, imageUri).fold(
                            onSuccess = { updatedPost ->
                                _posts.value = listOf(updatedPost) + _posts.value
                                _showCreatePost.value = false
                                _successMessage.value = "Post paylaşıldı"
                            },
                            onFailure = {
                                // Post yaradıldı amma şəkil yüklənmədi
                                _posts.value = listOf(newPost) + _posts.value
                                _showCreatePost.value = false
                                _successMessage.value = "Post paylaşıldı (şəkil yüklənmədi)"
                            }
                        )
                    } else {
                        _posts.value = listOf(newPost) + _posts.value
                        _showCreatePost.value = false
                        _successMessage.value = "Post paylaşıldı"
                    }
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun deletePost(postId: String) {
        viewModelScope.launch {
            repository.deletePost(postId).fold(
                onSuccess = {
                    _posts.value = _posts.value.filter { it.id != postId }
                    _successMessage.value = "Post silindi"
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    // ─── Like ───────────────────────────────────────────────────────────────────

    fun toggleLike(postId: String) {
        val post = _posts.value.find { it.id == postId } ?: return
        viewModelScope.launch {
            if (post.isLiked) {
                repository.unlikePost(postId).fold(
                    onSuccess = {
                        _posts.value = _posts.value.map {
                            if (it.id == postId) it.copy(
                                isLiked = false,
                                likeCount = (it.likeCount - 1).coerceAtLeast(0)
                            ) else it
                        }
                    },
                    onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
                )
            } else {
                repository.likePost(postId).fold(
                    onSuccess = {
                        _posts.value = _posts.value.map {
                            if (it.id == postId) it.copy(
                                isLiked = true,
                                likeCount = it.likeCount + 1
                            ) else it
                        }
                    },
                    onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
                )
            }
        }
    }

    // ─── Comments ───────────────────────────────────────────────────────────────

    fun openComments(postId: String) {
        _selectedPostId.value = postId
        _showComments.value = true
        loadComments(postId)
    }

    fun loadComments(postId: String) {
        viewModelScope.launch {
            repository.getComments(postId).fold(
                onSuccess = { _comments.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun createComment(content: String) {
        val postId = _selectedPostId.value ?: return
        if (content.isBlank()) return
        viewModelScope.launch {
            repository.createComment(postId, CreateCommentRequest(content)).fold(
                onSuccess = { newComment ->
                    _comments.value = _comments.value + newComment
                    // Post-un comment count-unu artır
                    _posts.value = _posts.value.map {
                        if (it.id == postId) it.copy(commentCount = it.commentCount + 1)
                        else it
                    }
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun closeComments() {
        _showComments.value = false
        _selectedPostId.value = null
        _comments.value = emptyList()
    }

    // ─── Follow/Unfollow ────────────────────────────────────────────────────────

    fun followUser(userId: String) {
        viewModelScope.launch {
            repository.followUser(userId).fold(
                onSuccess = {
                    _successMessage.value = "İzlənilir"
                    // Profil açıqdırsa yenilə
                    _selectedUserProfile.value?.let { profile ->
                        if (profile.id == userId) {
                            _selectedUserProfile.value = profile.copy(
                                isFollowing = true,
                                followerCount = profile.followerCount + 1
                            )
                        }
                    }
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun unfollowUser(userId: String) {
        viewModelScope.launch {
            repository.unfollowUser(userId).fold(
                onSuccess = {
                    _successMessage.value = "İzləmə dayandırıldı"
                    _selectedUserProfile.value?.let { profile ->
                        if (profile.id == userId) {
                            _selectedUserProfile.value = profile.copy(
                                isFollowing = false,
                                followerCount = (profile.followerCount - 1).coerceAtLeast(0)
                            )
                        }
                    }
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    // ─── User Profile ───────────────────────────────────────────────────────────

    fun loadUserProfile(userId: String) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getUserProfile(userId).fold(
                onSuccess = { _selectedUserProfile.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            repository.getUserPosts(userId).fold(
                onSuccess = { _userPosts.value = it },
                onFailure = { /* sessiz */ }
            )
            _isLoading.value = false
        }
    }

    fun clearUserProfile() {
        _selectedUserProfile.value = null
        _userPosts.value = emptyList()
    }

    // ─── Achievements ───────────────────────────────────────────────────────────

    fun loadAchievements() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getAllAchievements().fold(
                onSuccess = { _achievements.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // ─── Utils ──────────────────────────────────────────────────────────────────
    fun setShowCreatePost(show: Boolean) { _showCreatePost.value = show }
    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
