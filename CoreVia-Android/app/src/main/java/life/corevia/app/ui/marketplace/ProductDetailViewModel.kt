package life.corevia.app.ui.marketplace

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.CreateReviewRequest
import life.corevia.app.data.model.MarketplaceProduct
import life.corevia.app.data.model.ProductReview
import life.corevia.app.data.repository.MarketplaceRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class ProductDetailUiState(
    val isLoading: Boolean = false,
    val product: MarketplaceProduct? = null,
    val reviews: List<ProductReview> = emptyList(),
    val reviewRating: Int = 5,
    val reviewComment: String = "",
    val isSubmitting: Boolean = false,
    val reviewSubmitted: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class ProductDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val marketplaceRepository: MarketplaceRepository
) : ViewModel() {

    private val productId: String = savedStateHandle.get<String>("productId") ?: ""

    private val _uiState = MutableStateFlow(ProductDetailUiState())
    val uiState: StateFlow<ProductDetailUiState> = _uiState.asStateFlow()

    init {
        loadProduct()
        loadReviews()
    }

    private fun loadProduct() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            when (val result = marketplaceRepository.getProduct(productId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        product = result.data
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    private fun loadReviews() {
        viewModelScope.launch {
            when (val result = marketplaceRepository.getProductReviews(productId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(reviews = result.data)
                }
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun updateRating(rating: Int) {
        _uiState.value = _uiState.value.copy(reviewRating = rating)
    }

    fun updateComment(comment: String) {
        _uiState.value = _uiState.value.copy(reviewComment = comment)
    }

    fun submitReview() {
        val state = _uiState.value
        if (state.reviewComment.isBlank()) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmitting = true)
            val request = CreateReviewRequest(
                rating = state.reviewRating,
                comment = state.reviewComment
            )
            when (marketplaceRepository.createReview(productId, request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        reviewSubmitted = true,
                        reviewComment = "",
                        reviewRating = 5
                    )
                    loadReviews()
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        error = "R\u0259y g\u00f6nd\u0259ril\u0259 bilm\u0259di"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}
