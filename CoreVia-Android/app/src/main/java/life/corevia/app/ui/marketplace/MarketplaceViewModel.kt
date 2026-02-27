package life.corevia.app.ui.marketplace

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.MarketplaceProduct
import life.corevia.app.data.model.MarketplaceProductType
import life.corevia.app.data.repository.MarketplaceRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class MarketplaceUiState(
    val isLoading: Boolean = false,
    val products: List<MarketplaceProduct> = emptyList(),
    val selectedFilter: String = "all",
    val error: String? = null
) {
    val filteredProducts: List<MarketplaceProduct>
        get() = if (selectedFilter == "all") products
        else products.filter { it.productType == selectedFilter }
}

@HiltViewModel
class MarketplaceViewModel @Inject constructor(
    private val marketplaceRepository: MarketplaceRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(MarketplaceUiState())
    val uiState: StateFlow<MarketplaceUiState> = _uiState.asStateFlow()

    init {
        loadProducts()
    }

    fun loadProducts() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            when (val result = marketplaceRepository.getProducts()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        products = result.data.products
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

    fun setFilter(filter: String) {
        _uiState.value = _uiState.value.copy(selectedFilter = filter)
    }
}
