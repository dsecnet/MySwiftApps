package life.corevia.app.ui.marketplace

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
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
import life.corevia.app.data.models.ProductReview

@Composable
fun ProductDetailScreen(
    viewModel: MarketplaceViewModel,
    onBack: () -> Unit
) {
    val product by viewModel.selectedProduct.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val reviews by viewModel.reviews.collectAsState()

    val currentProduct = product ?: return

    var showReviewSheet by remember { mutableStateOf(false) }

    val categoryLabels = mapOf(
        "supplements" to "Əlavələr",
        "equipment" to "Avadanlıq",
        "clothing" to "Geyim",
        "accessories" to "Aksesuar",
        "workout_plan" to "Məşq Planı",
        "meal_plan" to "Qida Planı",
        "training_program" to "Proqram",
        "ebook" to "E-kitab",
        "video_course" to "Video Kurs"
    )

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(modifier = Modifier.fillMaxSize()) {
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
                        Icon(Icons.Outlined.ShoppingBag, null, Modifier.size(72.dp), tint = AppTheme.Colors.accent.copy(alpha = 0.5f))
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
                            Icon(Icons.Filled.Star, null, Modifier.size(20.dp), tint = AppTheme.Colors.starFilled)
                            Spacer(Modifier.height(4.dp))
                            Text("%.1f / 5".format(rating), fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
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
                            .background(AppTheme.Colors.cardBackground).padding(12.dp)
                            .clickable { showReviewSheet = true },
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(Icons.Outlined.RateReview, null, Modifier.size(20.dp), tint = AppTheme.Colors.accent)
                            Spacer(Modifier.height(4.dp))
                            Text("$count rəy", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        }
                    }
                }
            }

            // Seller info
            currentProduct.seller?.let { seller ->
                Spacer(Modifier.height(16.dp))
                Box(
                    Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                        .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            Modifier.size(40.dp).clip(CircleShape).background(AppTheme.Colors.accent.copy(alpha = 0.15f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Outlined.Person, null, Modifier.size(20.dp), tint = AppTheme.Colors.accent)
                        }
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text("Satıcı", fontSize = 11.sp, color = AppTheme.Colors.tertiaryText)
                            Text(seller.name, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        }
                        Spacer(Modifier.weight(1f))
                        seller.rating?.let { r ->
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Filled.Star, null, Modifier.size(14.dp), tint = AppTheme.Colors.starFilled)
                                Spacer(Modifier.width(4.dp))
                                Text("%.1f".format(r), fontSize = 13.sp, color = AppTheme.Colors.secondaryText)
                            }
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

            // ── Reviews Section ─────────────────────────────────────────────────
            Spacer(Modifier.height(16.dp))
            Box(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                    .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)
            ) {
                Column {
                    Row(
                        Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Rəylər", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        TextButton(onClick = { showReviewSheet = true }) {
                            Icon(Icons.Outlined.Edit, null, Modifier.size(16.dp), tint = AppTheme.Colors.accent)
                            Spacer(Modifier.width(4.dp))
                            Text("Rəy yaz", fontSize = 13.sp, color = AppTheme.Colors.accent)
                        }
                    }

                    // Average rating display
                    currentProduct.rating?.let { avgRating ->
                        Spacer(Modifier.height(8.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                "%.1f".format(avgRating), fontSize = 32.sp,
                                fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText
                            )
                            Spacer(Modifier.width(12.dp))
                            Column {
                                // Star row
                                Row {
                                    repeat(5) { index ->
                                        Icon(
                                            if (index < avgRating.toInt()) Icons.Filled.Star
                                            else if (index < avgRating) Icons.Filled.Star
                                            else Icons.Outlined.Star,
                                            null, Modifier.size(18.dp),
                                            tint = if (index < avgRating) AppTheme.Colors.starFilled else AppTheme.Colors.starEmpty
                                        )
                                    }
                                }
                                Text(
                                    "${currentProduct.reviewCount ?: 0} rəy",
                                    fontSize = 12.sp, color = AppTheme.Colors.secondaryText
                                )
                            }
                        }
                        Spacer(Modifier.height(12.dp))
                        HorizontalDivider(color = AppTheme.Colors.separator)
                    }

                    // Review list
                    if (reviews.isEmpty()) {
                        Spacer(Modifier.height(16.dp))
                        Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(Icons.Outlined.RateReview, null, Modifier.size(32.dp), tint = AppTheme.Colors.tertiaryText)
                                Spacer(Modifier.height(8.dp))
                                Text("Hələ rəy yazılmayıb", fontSize = 14.sp, color = AppTheme.Colors.tertiaryText)
                                Text("İlk rəyi siz yazın!", fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
                            }
                        }
                    } else {
                        reviews.take(5).forEach { review ->
                            Spacer(Modifier.height(12.dp))
                            ReviewItem(review)
                        }
                        if (reviews.size > 5) {
                            Spacer(Modifier.height(8.dp))
                            TextButton(
                                onClick = { /* expand reviews */ },
                                modifier = Modifier.align(Alignment.CenterHorizontally)
                            ) {
                                Text("Bütün rəyləri gör (${reviews.size})", fontSize = 13.sp, color = AppTheme.Colors.accent)
                            }
                        }
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

        // ── Review Sheet ────────────────────────────────────────────────────────
        if (showReviewSheet) {
            WriteReviewSheet(
                onDismiss = { showReviewSheet = false },
                onSubmit = { rating, comment ->
                    viewModel.submitReview(currentProduct.id, rating, comment)
                    showReviewSheet = false
                },
                isLoading = isLoading
            )
        }
    }
    } // CoreViaAnimatedBackground
}

// ─── Review Item ────────────────────────────────────────────────────────────
@Composable
fun ReviewItem(review: ProductReview) {
    Column {
        Row(verticalAlignment = Alignment.CenterVertically) {
            // Author avatar
            Box(
                Modifier.size(32.dp).clip(CircleShape)
                    .background(AppTheme.Colors.accent.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    review.author?.name?.take(1)?.uppercase() ?: "?",
                    fontSize = 14.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.accent
                )
            }
            Spacer(Modifier.width(10.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    review.author?.name ?: "Anonim",
                    fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText
                )
                // Stars
                Row {
                    repeat(5) { index ->
                        Icon(
                            if (index < review.rating) Icons.Filled.Star else Icons.Outlined.Star,
                            null, Modifier.size(14.dp),
                            tint = if (index < review.rating) AppTheme.Colors.starFilled else AppTheme.Colors.starEmpty
                        )
                    }
                }
            }
            // Date
            review.createdAt?.let { date ->
                Text(
                    try { date.take(10) } catch (e: Exception) { "" },
                    fontSize = 11.sp, color = AppTheme.Colors.tertiaryText
                )
            }
        }
        review.comment?.let { comment ->
            if (comment.isNotBlank()) {
                Spacer(Modifier.height(6.dp))
                Text(comment, fontSize = 13.sp, color = AppTheme.Colors.secondaryText, lineHeight = 20.sp)
            }
        }
    }
}

// ─── Write Review Sheet ─────────────────────────────────────────────────────
@Composable
fun WriteReviewSheet(
    onDismiss: () -> Unit,
    onSubmit: (rating: Int, comment: String?) -> Unit,
    isLoading: Boolean
) {
    var selectedRating by remember { mutableIntStateOf(0) }
    var comment by remember { mutableStateOf("") }

    Box(
        modifier = Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.5f)).clickable(onClick = onDismiss),
        contentAlignment = Alignment.BottomCenter
    ) {
        Box(
            modifier = Modifier.fillMaxWidth()
                .clip(RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp))
                .background(AppTheme.Colors.secondaryBackground)
                .clickable(enabled = false) {} // prevent dismiss on sheet click
                .padding(24.dp)
        ) {
            Column {
                // Handle bar
                Box(
                    Modifier.width(40.dp).height(4.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(AppTheme.Colors.separator)
                        .align(Alignment.CenterHorizontally)
                )

                Spacer(Modifier.height(16.dp))

                Text("Rəy Yaz", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)

                Spacer(Modifier.height(16.dp))

                // Star rating selection
                Text("Qiymətləndirin", fontSize = 14.sp, color = AppTheme.Colors.secondaryText)
                Spacer(Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center
                ) {
                    repeat(5) { index ->
                        val starIndex = index + 1
                        IconButton(onClick = { selectedRating = starIndex }) {
                            Icon(
                                if (starIndex <= selectedRating) Icons.Filled.Star else Icons.Outlined.Star,
                                "Ulduz $starIndex",
                                modifier = Modifier.size(40.dp),
                                tint = if (starIndex <= selectedRating) AppTheme.Colors.starFilled else AppTheme.Colors.starEmpty
                            )
                        }
                    }
                }

                Spacer(Modifier.height(16.dp))

                // Comment field
                OutlinedTextField(
                    value = comment,
                    onValueChange = { comment = it },
                    modifier = Modifier.fillMaxWidth().height(120.dp),
                    placeholder = { Text("Rəyinizi yazın (istəyə bağlı)...", color = AppTheme.Colors.tertiaryText) },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedContainerColor = AppTheme.Colors.cardBackground,
                        unfocusedContainerColor = AppTheme.Colors.cardBackground,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText
                    ),
                    shape = RoundedCornerShape(12.dp),
                    maxLines = 5
                )

                Spacer(Modifier.height(20.dp))

                // Submit button
                Button(
                    onClick = { onSubmit(selectedRating, comment.ifBlank { null }) },
                    modifier = Modifier.fillMaxWidth().height(52.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                    shape = RoundedCornerShape(14.dp),
                    enabled = selectedRating > 0 && !isLoading
                ) {
                    if (isLoading) {
                        CircularProgressIndicator(color = Color.White, modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                    } else {
                        Text("Göndər", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Spacer(Modifier.height(16.dp))
            }
        }
    }
}
