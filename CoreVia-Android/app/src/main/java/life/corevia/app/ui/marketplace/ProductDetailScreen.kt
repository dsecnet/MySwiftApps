package life.corevia.app.ui.marketplace

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun ProductDetailScreen(
    viewModel: MarketplaceViewModel,
    onBack: () -> Unit
) {
    val product by viewModel.selectedProduct.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()

    val currentProduct = product ?: return

    val categoryLabels = mapOf(
        "supplements" to "Əlavələr",
        "equipment" to "Avadanlıq",
        "clothing" to "Geyim",
        "accessories" to "Aksesuar"
    )

    Box(modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background)) {
        Column(
            modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())
        ) {
            // Header with product image
            Box(
                modifier = Modifier.fillMaxWidth()
                    .background(Brush.verticalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.2f), Color.Transparent)))
                    .padding(horizontal = 16.dp).padding(top = 50.dp, bottom = 24.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = onBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                        }
                        Spacer(Modifier.weight(1f))
                    }

                    // Product image placeholder
                    Box(
                        modifier = Modifier.size(200.dp).clip(RoundedCornerShape(20.dp))
                            .background(AppTheme.Colors.cardBackground),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("🏋️", fontSize = 72.sp)
                    }

                    Spacer(Modifier.height(16.dp))

                    // Category badge
                    Box(
                        Modifier.clip(RoundedCornerShape(8.dp))
                            .background(AppTheme.Colors.accent.copy(alpha = 0.15f))
                            .padding(horizontal = 12.dp, vertical = 4.dp)
                    ) {
                        Text(
                            categoryLabels[currentProduct.category] ?: currentProduct.category,
                            fontSize = 12.sp, color = AppTheme.Colors.accent, fontWeight = FontWeight.SemiBold
                        )
                    }

                    Spacer(Modifier.height(12.dp))

                    Text(
                        currentProduct.name, fontSize = 24.sp, fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText, textAlign = TextAlign.Center
                    )

                    Spacer(Modifier.height(8.dp))

                    Text(
                        "${currentProduct.price} ₼", fontSize = 28.sp,
                        fontWeight = FontWeight.Bold, color = AppTheme.Colors.accent
                    )
                }
            }

            // Info row
            Row(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Rating
                currentProduct.rating?.let { rating ->
                    Box(
                        Modifier.weight(1f).clip(RoundedCornerShape(12.dp))
                            .background(AppTheme.Colors.cardBackground).padding(12.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(Icons.Outlined.Star, null, Modifier.size(20.dp), tint = AppTheme.Colors.warning)
                            Spacer(Modifier.height(4.dp))
                            Text("$rating / 5", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        }
                    }
                }

                // Stock status
                Box(
                    Modifier.weight(1f).clip(RoundedCornerShape(12.dp))
                        .background(AppTheme.Colors.cardBackground).padding(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            if (currentProduct.inStock) Icons.Filled.Check else Icons.Outlined.Close,
                            null, Modifier.size(20.dp),
                            tint = if (currentProduct.inStock) AppTheme.Colors.success else AppTheme.Colors.error
                        )
                        Spacer(Modifier.height(4.dp))
                        Text(
                            if (currentProduct.inStock) "Stokda var" else "Stokda yoxdur",
                            fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText
                        )
                    }
                }

                // Review count
                currentProduct.reviewCount?.let { count ->
                    Box(
                        Modifier.weight(1f).clip(RoundedCornerShape(12.dp))
                            .background(AppTheme.Colors.cardBackground).padding(12.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("💬", fontSize = 20.sp)
                            Spacer(Modifier.height(4.dp))
                            Text("$count rəy", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        }
                    }
                }
            }

            // Description
            currentProduct.description?.let { desc ->
                Spacer(Modifier.height(16.dp))
                Box(
                    Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                        .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)
                ) {
                    Column {
                        Text("Təsvir", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        Spacer(Modifier.height(8.dp))
                        Text(desc, fontSize = 14.sp, color = AppTheme.Colors.secondaryText, lineHeight = 22.sp)
                    }
                }
            }

            Spacer(Modifier.height(100.dp))
        }

        // Buy button
        Box(
            Modifier.fillMaxWidth().align(Alignment.BottomCenter)
                .background(AppTheme.Colors.background).padding(20.dp)
        ) {
            Button(
                onClick = { viewModel.createOrder(currentProduct.id) },
                modifier = Modifier.fillMaxWidth().height(56.dp),
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                shape = RoundedCornerShape(16.dp),
                enabled = !isLoading && currentProduct.inStock
            ) {
                if (isLoading) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                } else {
                    Icon(Icons.Outlined.ShoppingCart, null, Modifier.size(20.dp))
                    Spacer(Modifier.width(8.dp))
                    Text("Sifariş ver — ${currentProduct.price} ₼", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                }
            }
        }

        successMessage?.let { msg ->
            Snackbar(Modifier.align(Alignment.BottomCenter).padding(16.dp).padding(bottom = 80.dp), containerColor = AppTheme.Colors.success) {
                Text(msg, color = Color.White)
            }
            LaunchedEffect(msg) { kotlinx.coroutines.delay(2000); viewModel.clearSuccess() }
        }
    }
}
