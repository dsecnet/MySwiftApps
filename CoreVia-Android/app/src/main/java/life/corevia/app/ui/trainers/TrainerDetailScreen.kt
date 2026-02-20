package life.corevia.app.ui.trainers

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.TrainerReview

/**
 * iOS: TrainerDetailView.swift — bio, stats, reviews, "Müəllimi seç" button
 */
@Composable
fun TrainerDetailScreen(
    viewModel: TrainersViewModel,
    onBack: () -> Unit
) {
    val trainer by viewModel.selectedTrainer.collectAsState()
    val reviews by viewModel.reviews.collectAsState()
    val reviewSummary by viewModel.reviewSummary.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val showAddReview by viewModel.showAddReview.collectAsState()

    val currentTrainer = trainer ?: return

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(bottom = 100.dp)
        ) {
            // ── Header ──────────────────────────────────────────────────────────
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    AppTheme.Colors.accent.copy(alpha = 0.2f),
                                    Color.Transparent
                                )
                            )
                        )
                        .padding(horizontal = 16.dp)
                        .padding(top = 50.dp, bottom = 24.dp)
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            IconButton(onClick = onBack) {
                                Icon(
                                    imageVector = Icons.AutoMirrored.Outlined.ArrowBack,
                                    contentDescription = "Geri",
                                    tint = AppTheme.Colors.accent
                                )
                            }
                            Spacer(modifier = Modifier.weight(1f))
                        }

                        // Avatar
                        Box(
                            modifier = Modifier
                                .size(90.dp)
                                .background(
                                    brush = Brush.linearGradient(
                                        colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                                    ),
                                    shape = CircleShape
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            val initials = currentTrainer.name
                                .split(" ")
                                .take(2)
                                .mapNotNull { it.firstOrNull()?.uppercaseChar() }
                                .joinToString("")
                            Text(
                                text = initials.ifEmpty { "?" },
                                color = Color.White,
                                fontWeight = FontWeight.Bold,
                                fontSize = 28.sp
                            )
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        Text(
                            text = currentTrainer.name,
                            fontSize = 24.sp,
                            fontWeight = FontWeight.Bold,
                            color = AppTheme.Colors.primaryText
                        )
                        Text(
                            text = currentTrainer.email,
                            fontSize = 14.sp,
                            color = AppTheme.Colors.secondaryText
                        )

                        // Rating
                        reviewSummary?.let { summary ->
                            Spacer(modifier = Modifier.height(8.dp))
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                repeat(5) { index ->
                                    Icon(
                                        imageVector = Icons.Outlined.Star,
                                        contentDescription = null,
                                        tint = if (index < summary.averageRating.toInt())
                                            AppTheme.Colors.starFilled
                                        else AppTheme.Colors.starEmpty,
                                        modifier = Modifier.size(20.dp)
                                    )
                                }
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = String.format("%.1f", summary.averageRating),
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = AppTheme.Colors.accent
                                )
                                Text(
                                    text = " (${summary.totalReviews} rəy)",
                                    fontSize = 13.sp,
                                    color = AppTheme.Colors.secondaryText
                                )
                            }
                        }
                    }
                }
            }

            // ── Action Buttons ──────────────────────────────────────────────────
            item {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Assign/Unassign
                    Button(
                        onClick = { viewModel.assignTrainer(currentTrainer.id) },
                        modifier = Modifier.weight(1f).height(48.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                        shape = RoundedCornerShape(14.dp),
                        enabled = !isLoading
                    ) {
                        Text(
                            text = "Müəllimi seç",
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    }

                    // Add review
                    OutlinedButton(
                        onClick = { viewModel.setShowAddReview(true) },
                        modifier = Modifier.weight(1f).height(48.dp),
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.outlinedButtonColors(
                            contentColor = AppTheme.Colors.accent
                        )
                    ) {
                        Text(
                            text = "Rəy yaz",
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    }
                }
            }

            // ── Reviews Section ─────────────────────────────────────────────────
            item {
                Text(
                    text = "Rəylər",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
                )
            }

            if (reviews.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(AppTheme.Colors.cardBackground)
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "Hələ rəy yazılmayıb",
                            color = AppTheme.Colors.secondaryText,
                            fontSize = 14.sp
                        )
                    }
                }
            } else {
                items(reviews, key = { it.id }) { review ->
                    ReviewCard(
                        review = review,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                    )
                }
            }
        }

        // ── Add Review Sheet ────────────────────────────────────────────────────
        if (showAddReview) {
            AddReviewSheet(
                onDismiss = { viewModel.setShowAddReview(false) },
                onSubmit = { rating, comment -> viewModel.createReview(rating, comment) },
                isLoading = isLoading
            )
        }

        // Snackbars
        successMessage?.let { msg ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp),
                containerColor = AppTheme.Colors.success
            ) { Text(msg, color = Color.White) }
            LaunchedEffect(msg) {
                kotlinx.coroutines.delay(2000)
                viewModel.clearSuccess()
            }
        }
        errorMessage?.let { error ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp),
                containerColor = AppTheme.Colors.error,
                action = {
                    TextButton(onClick = { viewModel.clearError() }) {
                        Text("Bağla", color = Color.White)
                    }
                }
            ) { Text(error, color = Color.White) }
        }
    }
}

@Composable
fun ReviewCard(
    review: TrainerReview,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground)
            .padding(16.dp)
    ) {
        Column {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                // Avatar
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .background(AppTheme.Colors.accent.copy(alpha = 0.2f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = (review.clientName ?: "?").firstOrNull()?.uppercaseChar()?.toString() ?: "?",
                        color = AppTheme.Colors.accent,
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp
                    )
                }

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = review.clientName ?: "İstifadəçi",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = AppTheme.Colors.primaryText
                    )
                    // Stars
                    Row {
                        repeat(5) { index ->
                            Icon(
                                imageVector = Icons.Outlined.Star,
                                contentDescription = null,
                                tint = if (index < review.rating) AppTheme.Colors.starFilled
                                else AppTheme.Colors.starEmpty,
                                modifier = Modifier.size(14.dp)
                            )
                        }
                    }
                }

                Text(
                    text = try { review.createdAt.take(10) } catch (e: Exception) { "" },
                    fontSize = 11.sp,
                    color = AppTheme.Colors.tertiaryText
                )
            }

            review.comment?.let { comment ->
                if (comment.isNotBlank()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = comment,
                        fontSize = 14.sp,
                        color = AppTheme.Colors.secondaryText,
                        lineHeight = 20.sp
                    )
                }
            }
        }
    }
}
