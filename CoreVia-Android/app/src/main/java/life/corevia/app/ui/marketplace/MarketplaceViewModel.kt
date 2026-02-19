package life.corevia.app.ui.marketplace

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.MarketplaceRepository

class MarketplaceViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = MarketplaceRepository.getInstance(application)

    private val _products = MutableStateFlow<List<Product>>(emptyList())
    val products: StateFlow<List<Product>> = _products.asStateFlow()

    private val _selectedProduct = MutableStateFlow<Product?>(null)
    val selectedProduct: StateFlow<Product?> = _selectedProduct.asStateFlow()

    private val _orders = MutableStateFlow<List<Order>>(emptyList())
    val orders: StateFlow<List<Order>> = _orders.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _selectedCategory = MutableStateFlow<String?>(null)
    val selectedCategory: StateFlow<String?> = _selectedCategory.asStateFlow()

    init { loadProducts() }

    fun loadProducts() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getProducts().fold(
                onSuccess = { _products.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun selectProduct(product: Product) { _selectedProduct.value = product }
    fun clearSelectedProduct() { _selectedProduct.value = null }

    fun updateSearchQuery(query: String) { _searchQuery.value = query }
    fun selectCategory(category: String?) { _selectedCategory.value = category }

    val filteredProducts: List<Product>
        get() {
            var list = _products.value
            val query = _searchQuery.value
            val category = _selectedCategory.value
            if (query.isNotBlank()) {
                list = list.filter { it.name.contains(query, ignoreCase = true) || (it.description?.contains(query, ignoreCase = true) == true) }
            }
            if (category != null) {
                list = list.filter { it.category == category }
            }
            return list
        }

    fun createOrder(productId: String, quantity: Int = 1) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.createOrder(CreateOrderRequest(productId, quantity)).fold(
                onSuccess = {
                    _successMessage.value = "Sifariş yaradıldı!"
                    loadOrders()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun loadOrders() {
        viewModelScope.launch {
            repository.getOrders().fold(
                onSuccess = { _orders.value = it },
                onFailure = { /* silent */ }
            )
        }
    }

    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
