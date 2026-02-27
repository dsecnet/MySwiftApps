package life.corevia.app.ui.marketplace

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
import life.corevia.app.data.model.MarketplaceProduct
import life.corevia.app.data.model.ProductReview
import life.corevia.app.ui.theme.*

/**
 * ProductDetailScreen — iOS ProductDetailView equivalent
 * Full product detail: image, info, rating, reviews, purchase
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductDetailScreen(
    onBack: () -> Unit = {},
    onNavigateToWriteReview: () -> Unit = {},
    viewModel: ProductDetailViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        uiState.product?.title ?: "Məhsul",
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent
                )
            )
        }
    ) { padding ->
        when {
            // Loading
            uiState.isLoading && uiState.product == null -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = CoreViaPrimary)
                }
            }

            // Error
            uiState.error != null && uiState.product == null -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .padding(40.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(
                        Icons.Filled.Error, null,
                        modifier = Modifier.size(48.dp),
                        tint = CoreViaError.copy(alpha = 0.5f)
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = uiState.error ?: "Xəta baş verdi",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Product loaded
            uiState.product != null -> {
                val product = uiState.product!!

                Box(modifier = Modifier.fillMaxSize()) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(padding)
                            .verticalScroll(rememberScrollState())
                            .padding(bottom = 100.dp)
                    ) {
                        // ── Cover Image Placeholder ──
                        CoverImageSection(product)

                        Column(
                            modifier = Modifier.padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            // ── Product Info ──
                            ProductInfoSection(product)

                            HorizontalDivider(color = TextSeparator.copy(alpha = 0.3f))

                            // ── Seller Info ──
                            SellerInfoSection(product)

                            HorizontalDivider(color = TextSeparator.copy(alpha = 0.3f))

                            // ── Description ──
                            if (product.description.isNotBlank()) {
                                DescriptionSection(product.description)
                                HorizontalDivider(color = TextSeparator.copy(alpha = 0.3f))
                            }

                            // ── Rating Section ──
                            RatingSection(
                                rating = product.rating,
                                reviewsCount = product.reviewsCount,
                                onWriteReview = onNavigateToWriteReview
                            )

                            // ── Reviews List ──
                            if (uiState.reviews.isNotEmpty()) {
                                ReviewsSection(uiState.reviews)
                            }
                        }
                    }

                    // ── Bottom Purchase Bar ──
                    PurchaseBar(
                        product = product,
                        modifier = Modifier.align(Alignment.BottomCenter)
                    )
                }
            }
        }
    }
}

// ─── Cover Image Placeholder ────────────────────────────────────────

@Composable
private fun CoverImageSection(product: MarketplaceProduct) {
    val typeIcon: ImageVector = when (product.productType) {
        "workout_plan" -> Icons.Filled.FitnessCenter
        "meal_plan" -> Icons.Filled.Restaurant
        "training_program" -> Icons.Filled.School
        "ebook" -> Icons.Filled.MenuBook
        "video_course" -> Icons.Filled.PlayCircle
        else -> Icons.Filled.ShoppingBag
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp)
            .background(CoreViaPrimary.copy(alpha = 0.1f)),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Icon(
                typeIcon, null,
                modifier = Modifier.size(56.dp),
                tint = CoreViaPrimary.copy(alpha = 0.6f)
            )
            Text(
                text = product.productTypeEnum.displayName,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = CoreViaPrimary.copy(alpha = 0.6f)
            )
        }
    }
}

// ─── Product Info ───────────────────────────────────────────────────

@Composable
private fun ProductInfoSection(product: MarketplaceProduct) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        // Type badge
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(8.dp))
                .background(CoreViaPrimary.copy(alpha = 0.1f))
                .padding(horizontal = 10.dp, vertical = 5.dp)
        ) {
            Text(
                text = product.productTypeEnum.displayName,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold,
                color = CoreViaPrimary
            )
        }

        // Title
        Text(
            text = product.title,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )

        // Price + rating row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = product.displayPrice,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.Star, null,
                    modifier = Modifier.size(18.dp),
                    tint = StarFilled
                )
                Text(
                    text = "%.1f".format(product.rating),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "(${product.reviewsCount})",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        // Sales count
        if (product.salesCount > 0) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.ShoppingCart, null,
                    modifier = Modifier.size(14.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "${product.salesCount} satış",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

// ─── Seller Info ────────────────────────────────────────────────────

@Composable
private fun SellerInfoSection(product: MarketplaceProduct) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Avatar
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(CoreViaPrimary.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = product.seller.initials,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
        }

        // Info
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(
                text = product.seller.fullName,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurface
            )
            if (product.seller.rating > 0.0) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Star, null,
                        modifier = Modifier.size(12.dp),
                        tint = StarFilled
                    )
                    Text(
                        text = "%.1f".format(product.seller.rating),
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = "trener reytinqi",
                        fontSize = 12.sp,
                        color = TextHint
                    )
                }
            }
        }
    }
}

// ─── Description ────────────────────────────────────────────────────

@Composable
private fun DescriptionSection(description: String) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = "Haqqında",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = description,
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            lineHeight = 22.sp
        )
    }
}

// ─── Rating Section ─────────────────────────────────────────────────

@Composable
private fun RatingSection(
    rating: Double,
    reviewsCount: Int,
    onWriteReview: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Rəylər",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )

            // Write review button
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(10.dp))
                    .background(CoreViaPrimary.copy(alpha = 0.1f))
                    .clickable(onClick = onWriteReview)
                    .padding(horizontal = 14.dp, vertical = 8.dp)
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.RateReview, null,
                        modifier = Modifier.size(16.dp),
                        tint = CoreViaPrimary
                    )
                    Text(
                        text = "Rəy Yaz",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = CoreViaPrimary
                    )
                }
            }
        }

        // Star display row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Big rating number
            Text(
                text = "%.1f".format(rating),
                fontSize = 36.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )

            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                // Stars
                Row(horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                    for (i in 1..5) {
                        val starColor = if (i <= rating.toInt()) StarFilled
                        else if (i.toFloat() - 0.5f <= rating.toFloat()) StarFilled.copy(alpha = 0.5f)
                        else StarEmpty
                        Icon(
                            Icons.Filled.Star, null,
                            modifier = Modifier.size(18.dp),
                            tint = starColor
                        )
                    }
                }
                Text(
                    text = "$reviewsCount rəy əsasında",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

// ─── Reviews List ───────────────────────────────────────────────────

@Composable
private fun ReviewsSection(reviews: List<ProductReview>) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        reviews.forEach { review ->
            ReviewCard(review)
        }
    }
}

@Composable
private fun ReviewCard(review: ProductReview) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 2.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.03f),
                spotColor = Color.Black.copy(alpha = 0.03f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Header: avatar + name + stars
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Avatar
                Box(
                    modifier = Modifier
                        .size(32.dp)
                        .clip(CircleShape)
                        .background(AccentBlue.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = review.author.initials,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = AccentBlue
                    )
                }
                Text(
                    text = review.author.fullName,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurface
                )
            }

            // Stars
            Row(horizontalArrangement = Arrangement.spacedBy(1.dp)) {
                for (i in 1..5) {
                    Icon(
                        Icons.Filled.Star, null,
                        modifier = Modifier.size(14.dp),
                        tint = if (i <= review.rating) StarFilled else StarEmpty
                    )
                }
            }
        }

        // Comment
        if (review.comment.isNotBlank()) {
            Text(
                text = review.comment,
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                lineHeight = 19.sp
            )
        }

        // Date
        if (review.createdAt.isNotBlank()) {
            Text(
                text = formatReviewDate(review.createdAt),
                fontSize = 11.sp,
                color = TextHint
            )
        }
    }
}

// ─── Purchase Bar ───────────────────────────────────────────────────

@Composable
private fun PurchaseBar(
    product: MarketplaceProduct,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface)
            .padding(horizontal = 16.dp, vertical = 12.dp)
            .padding(bottom = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Price
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = "Qiymət",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = product.displayPrice,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
        }

        // Buy button
        Button(
            onClick = { /* Purchase action */ },
            modifier = Modifier
                .weight(2f)
                .height(52.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
        ) {
            Icon(Icons.Filled.ShoppingCart, null, modifier = Modifier.size(18.dp))
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                "Satın Al",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

// ─── Helpers ────────────────────────────────────────────────────────

private fun formatReviewDate(isoDate: String): String {
    return try {
        val parts = isoDate.split("T")
        if (parts.isNotEmpty()) {
            val dateParts = parts[0].split("-")
            if (dateParts.size == 3) {
                "${dateParts[2]}.${dateParts[1]}.${dateParts[0]}"
            } else parts[0]
        } else isoDate
    } catch (_: Exception) {
        isoDate
    }
}
