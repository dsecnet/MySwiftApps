package life.corevia.app.ui.marketplace

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.Product

@Composable
fun MarketplaceScreen(
    viewModel: MarketplaceViewModel,
    onBack: () -> Unit,
    onProductSelected: (Product) -> Unit
) {
    val products by viewModel.products.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()
    val selectedCategory by viewModel.selectedCategory.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()

    val filteredProducts = viewModel.filteredProducts
    val categories = listOf("supplements", "equipment", "clothing", "accessories")
    val categoryLabels = mapOf(
        "supplements" to "Əlavələr",
        "equipment" to "Avadanlıq",
        "clothing" to "Geyim",
        "accessories" to "Aksesuar"
    )

    Box(modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background)) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Header
            Box(
                modifier = Modifier.fillMaxWidth()
                    .background(Brush.verticalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.15f), Color.Transparent)))
                    .padding(horizontal = 16.dp).padding(top = 50.dp, bottom = 16.dp)
            ) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = onBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                        }
                        Spacer(Modifier.width(8.dp))
                        Text("Mağaza", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                    }

                    Spacer(Modifier.height(12.dp))

                    // Search
                    OutlinedTextField(
                        value = searchQuery,
                        onValueChange = { viewModel.updateSearchQuery(it) },
                        modifier = Modifier.fillMaxWidth(),
                        placeholder = { Text("Məhsul axtar...", color = AppTheme.Colors.tertiaryText) },
                        leadingIcon = { Icon(Icons.Outlined.Search, null, tint = AppTheme.Colors.tertiaryText) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = AppTheme.Colors.accent,
                            unfocusedBorderColor = AppTheme.Colors.cardBackground,
                            focusedContainerColor = AppTheme.Colors.cardBackground,
                            unfocusedContainerColor = AppTheme.Colors.cardBackground,
                            focusedTextColor = AppTheme.Colors.primaryText,
                            unfocusedTextColor = AppTheme.Colors.primaryText
                        ),
                        shape = RoundedCornerShape(12.dp),
                        singleLine = true
                    )

                    Spacer(Modifier.height(12.dp))

                    // Category filters
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        FilterChip(
                            selected = selectedCategory == null,
                            onClick = { viewModel.selectCategory(null) },
                            label = { Text("Hamısı", fontSize = 12.sp) },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = AppTheme.Colors.accent,
                                selectedLabelColor = Color.White,
                                containerColor = AppTheme.Colors.cardBackground,
                                labelColor = AppTheme.Colors.secondaryText
                            )
                        )
                        categories.forEach { cat ->
                            FilterChip(
                                selected = selectedCategory == cat,
                                onClick = { viewModel.selectCategory(if (selectedCategory == cat) null else cat) },
                                label = { Text(categoryLabels[cat] ?: cat, fontSize = 12.sp) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = AppTheme.Colors.accent,
                                    selectedLabelColor = Color.White,
                                    containerColor = AppTheme.Colors.cardBackground,
                                    labelColor = AppTheme.Colors.secondaryText
                                )
                            )
                        }
                    }
                }
            }

            when {
                isLoading && products.isEmpty() -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
                products.isEmpty() -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("🛍️", fontSize = 64.sp)
                            Spacer(Modifier.height(16.dp))
                            Text("Məhsul tapılmadı", color = AppTheme.Colors.primaryText, fontSize = 18.sp, fontWeight = FontWeight.SemiBold)
                            Text("Yeni məhsullar tezliklə əlavə olunacaq", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                        }
                    }
                }
                else -> {
                    LazyVerticalGrid(
                        columns = GridCells.Fixed(2),
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        items(filteredProducts, key = { it.id }) { product ->
                            ProductCard(product) {
                                viewModel.selectProduct(product)
                                onProductSelected(product)
                            }
                        }
                    }
                }
            }
        }

        successMessage?.let { msg ->
            Snackbar(Modifier.align(Alignment.BottomCenter).padding(16.dp), containerColor = AppTheme.Colors.success) {
                Text(msg, color = Color.White)
            }
            LaunchedEffect(msg) { kotlinx.coroutines.delay(2000); viewModel.clearSuccess() }
        }
    }
}

@Composable
fun ProductCard(product: Product, onClick: () -> Unit) {
    Box(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground).clickable(onClick = onClick)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            // Product image placeholder
            Box(
                modifier = Modifier.fillMaxWidth().height(100.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(AppTheme.Colors.accent.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Text("🏋️", fontSize = 36.sp)
            }

            Spacer(Modifier.height(8.dp))

            Text(
                product.name, fontSize = 14.sp, fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText, maxLines = 2, overflow = TextOverflow.Ellipsis
            )

            Spacer(Modifier.height(4.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "${product.price} ₼", fontSize = 16.sp,
                    fontWeight = FontWeight.Bold, color = AppTheme.Colors.accent
                )
                Spacer(Modifier.weight(1f))
                if (product.rating != null) {
                    Icon(Icons.Outlined.Star, null, Modifier.size(12.dp), tint = AppTheme.Colors.warning)
                    Spacer(Modifier.width(2.dp))
                    Text("${product.rating}", fontSize = 11.sp, color = AppTheme.Colors.secondaryText)
                }
            }

            if (!product.inStock) {
                Spacer(Modifier.height(4.dp))
                Text("Stokda yoxdur", fontSize = 11.sp, color = AppTheme.Colors.error)
            }
        }
    }
}
