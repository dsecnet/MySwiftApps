package life.corevia.app.ui.trainerhub

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
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
import life.corevia.app.ui.theme.*
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

// ═══════════════════════════════════════════════════════════════════
// MARK: - UI State
// ═══════════════════════════════════════════════════════════════════

data class TrainerProductsUiState(
    val isLoading: Boolean = false,
    val products: List<MarketplaceProduct> = emptyList(),
    val selectedFilter: String = "all",
    val error: String? = null,
    val isDeleting: Boolean = false
) {
    val filteredProducts: List<MarketplaceProduct>
        get() = if (selectedFilter == "all") products
        else products.filter { it.productType == selectedFilter }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ═══════════════════════════════════════════════════════════════════

@HiltViewModel
class TrainerProductsViewModel @Inject constructor(
    private val marketplaceRepository: MarketplaceRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(TrainerProductsUiState())
    val uiState: StateFlow<TrainerProductsUiState> = _uiState.asStateFlow()

    init {
        loadProducts()
    }

    fun loadProducts() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = marketplaceRepository.getMyProducts()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        products = result.data
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

    fun deleteProduct(productId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isDeleting = true)
            when (marketplaceRepository.deleteProduct(productId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isDeleting = false,
                        products = _uiState.value.products.filter { it.id != productId }
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isDeleting = false,
                        error = "Məhsul silinə bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Screen Composable
// ═══════════════════════════════════════════════════════════════════

/**
 * iOS TrainerMarketplaceView equivalent
 * Məşqçinin öz məhsulları — filter chips + product cards + FAB
 */
@Composable
fun TrainerProductsContent(
    onNavigateToCreateProduct: () -> Unit = {},
    viewModel: TrainerProductsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Box(modifier = Modifier.fillMaxSize()) {
        Column(modifier = Modifier.fillMaxSize()) {
            // ── Filter Chips — iOS horizontal scroll ──
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                ProductFilterChip(
                    label = "Hamısı",
                    isSelected = uiState.selectedFilter == "all",
                    onClick = { viewModel.setFilter("all") }
                )
                MarketplaceProductType.entries.forEach { type ->
                    ProductFilterChip(
                        label = type.displayName,
                        isSelected = uiState.selectedFilter == type.value,
                        onClick = { viewModel.setFilter(type.value) }
                    )
                }
            }

            // ── Content ──
            when {
                uiState.isLoading && uiState.products.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                    }
                }

                !uiState.isLoading && uiState.filteredProducts.isEmpty() -> {
                    // iOS empty state
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(40.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            Icons.Filled.ShoppingBag,
                            contentDescription = null,
                            modifier = Modifier.size(70.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "Hələ məhsulunuz yoxdur",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "Yeni məhsul yaratmaq üçün + düyməsinə basın",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                else -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState())
                            .padding(horizontal = 16.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        uiState.filteredProducts.forEach { product ->
                            TrainerProductCard(
                                product = product,
                                onDelete = { viewModel.deleteProduct(product.id) }
                            )
                        }
                        Spacer(modifier = Modifier.height(80.dp))
                    }
                }
            }
        }

        // ── FAB — create product ──
        FloatingActionButton(
            onClick = onNavigateToCreateProduct,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 20.dp, bottom = 24.dp),
            containerColor = CoreViaPrimary,
            contentColor = Color.White,
            shape = RoundedCornerShape(Layout.cornerRadiusL)
        ) {
            Icon(Icons.Filled.Add, contentDescription = "Yeni Məhsul")
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Filter Chip
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun ProductFilterChip(
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(
                if (isSelected) CoreViaPrimary
                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Text(
            text = label,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
            color = if (isSelected) Color.White
            else MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Product Card
// ═══════════════════════════════════════════════════════════════════

/**
 * iOS product card — shadow card with cornerRadius(16),
 * type icon, title, type badge, price, rating, delete button
 */
@Composable
private fun TrainerProductCard(
    product: MarketplaceProduct,
    onDelete: () -> Unit
) {
    val typeIcon: ImageVector = when (product.productType) {
        "workout_plan" -> Icons.Filled.FitnessCenter
        "meal_plan" -> Icons.Filled.Restaurant
        "training_program" -> Icons.Filled.School
        "ebook" -> Icons.Filled.MenuBook
        "video_course" -> Icons.Filled.PlayCircle
        else -> Icons.Filled.ShoppingBag
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.05f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // LEFT: Type icon placeholder — 80x80
        Box(
            modifier = Modifier
                .size(80.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(CoreViaPrimary.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                typeIcon,
                contentDescription = null,
                modifier = Modifier.size(32.dp),
                tint = CoreViaPrimary
            )
        }

        // RIGHT: Content
        Column(
            modifier = Modifier
                .weight(1f)
                .heightIn(min = 80.dp),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                // Type badge
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(CoreViaPrimary.copy(alpha = 0.1f))
                        .padding(horizontal = 8.dp, vertical = 3.dp)
                ) {
                    Text(
                        text = product.productTypeEnum.displayName,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = CoreViaPrimary
                    )
                }

                // Title
                Text(
                    text = product.title,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurface,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }

            // Price + Rating + Delete
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = product.displayPrice,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = CoreViaPrimary
                )

                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Rating
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(3.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            Icons.Filled.Star,
                            contentDescription = null,
                            modifier = Modifier.size(14.dp),
                            tint = StarFilled
                        )
                        Text(
                            text = "%.1f".format(product.rating),
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    // Delete button
                    IconButton(
                        onClick = onDelete,
                        modifier = Modifier.size(28.dp)
                    ) {
                        Icon(
                            Icons.Filled.Delete,
                            contentDescription = "Sil",
                            tint = CoreViaError,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            }
        }
    }
}
