package life.corevia.app.ui.social

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.SocialPost
import life.corevia.app.data.repository.SocialRepository
import life.corevia.app.util.NetworkResult
import life.corevia.app.util.toUserFriendlyError
import javax.inject.Inject

data class SocialFeedUiState(
    val isLoading: Boolean = false,
    val isLoadingMore: Boolean = false,
    val posts: List<SocialPost> = emptyList(),
    val error: String? = null,
    val hasMore: Boolean = false,
    val currentPage: Int = 1
)

@HiltViewModel
class SocialFeedViewModel @Inject constructor(
    private val socialRepository: SocialRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SocialFeedUiState())
    val uiState: StateFlow<SocialFeedUiState> = _uiState.asStateFlow()

    init {
        loadFeed()
    }

    fun loadFeed() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = socialRepository.getFeed(page = 1)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        posts = result.data.posts,
                        hasMore = result.data.hasMore,
                        currentPage = 1
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.message.toUserFriendlyError()
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun loadMore() {
        if (_uiState.value.isLoading || !_uiState.value.hasMore) return
        val nextPage = _uiState.value.currentPage + 1
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingMore = true)
            when (val result = socialRepository.getFeed(page = nextPage)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoadingMore = false,
                        posts = _uiState.value.posts + result.data.posts,
                        hasMore = result.data.hasMore,
                        currentPage = nextPage
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(isLoadingMore = false)
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun toggleLike(postId: String) {
        viewModelScope.launch {
            // Optimistic update
            val posts = _uiState.value.posts.map { post ->
                if (post.id == postId) {
                    post.copy(
                        isLiked = !post.isLiked,
                        likesCount = if (post.isLiked) post.likesCount - 1 else post.likesCount + 1
                    )
                } else post
            }
            _uiState.value = _uiState.value.copy(posts = posts)

            when (socialRepository.toggleLike(postId)) {
                is NetworkResult.Success -> {} // Already updated optimistically
                is NetworkResult.Error -> loadFeed() // Revert on error
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun deletePost(postId: String) {
        viewModelScope.launch {
            when (socialRepository.deletePost(postId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        posts = _uiState.value.posts.filter { it.id != postId }
                    )
                }
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }
}
