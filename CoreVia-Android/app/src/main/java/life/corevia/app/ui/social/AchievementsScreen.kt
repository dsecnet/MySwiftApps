package life.corevia.app.ui.social

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import life.corevia.app.ui.theme.CoreViaGradientProgressBar
import life.corevia.app.ui.theme.coreViaCard
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.Achievement

/**
 * Nailiyyetler sehifesi — achievement badge grid + progress bar
 */
@Composable
fun AchievementsScreen(
    viewModel: SocialViewModel,
    onBack: () -> Unit
) {
    val achievements by viewModel.achievements.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.loadAchievements()
    }

    val unlockedCount = achievements.count { it.isUnlocked }
    val totalCount = achievements.size

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Column(
        modifier = Modifier.fillMaxSize()
    ) {
        // ── Header ──────────────────────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            AppTheme.Colors.accent.copy(alpha = 0.15f),
                            Color.Transparent
                        )
                    )
                )
                .padding(horizontal = 16.dp)
                .padding(top = 50.dp, bottom = 16.dp)
        ) {
            Column {
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
                    Spacer(modifier = Modifier.width(8.dp))
                    Icon(
                        imageVector = Icons.Outlined.EmojiEvents,
                        contentDescription = null,
                        tint = AppTheme.Colors.accent,
                        modifier = Modifier.size(28.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Nailiyyetler",
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText
                    )
                }

                // Progress summary
                if (totalCount > 0) {
                    Spacer(modifier = Modifier.height(12.dp))
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(14.dp))
                            .background(AppTheme.Colors.cardBackground)
                            .padding(16.dp)
                    ) {
                        Column {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = "Umumi irəlilayis",
                                    fontSize = 14.sp,
                                    color = AppTheme.Colors.secondaryText
                                )
                                Text(
                                    text = "$unlockedCount / $totalCount",
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = AppTheme.Colors.accent
                                )
                            }
                            Spacer(modifier = Modifier.height(8.dp))
                            CoreViaGradientProgressBar(
                                progress = if (totalCount > 0) unlockedCount.toFloat() / totalCount.toFloat() else 0f,
                                modifier = Modifier.fillMaxWidth(),
                                height = 10.dp
                            )
                        }
                    }
                }
            }
        }

        // ── Content ─────────────────────────────────────────────────────────
        when {
            isLoading && achievements.isEmpty() -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = AppTheme.Colors.accent)
                }
            }
            achievements.isEmpty() -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Outlined.EmojiEvents,
                            null,
                            tint = AppTheme.Colors.tertiaryText,
                            modifier = Modifier.size(64.dp)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "Hele nailiyyet yoxdur",
                            color = AppTheme.Colors.primaryText,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                        Text(
                            text = "Mesq edin ve nailiyyetler qazanin!",
                            color = AppTheme.Colors.secondaryText,
                            fontSize = 14.sp
                        )
                    }
                }
            }
            else -> {
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(achievements, key = { it.id }) { achievement ->
                        AchievementCard(achievement)
                    }
                    // Bottom padding
                    item { Spacer(modifier = Modifier.height(100.dp)) }
                    item { Spacer(modifier = Modifier.height(100.dp)) }
                }
            }
        }
    }
    } // CoreViaAnimatedBackground
}

@Composable
private fun AchievementCard(achievement: Achievement) {
    val isUnlocked = achievement.isUnlocked
    val progress = achievement.progress.toFloat().coerceIn(0f, 1f)

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(
                if (isUnlocked) AppTheme.Colors.cardBackground
                else AppTheme.Colors.cardBackground.copy(alpha = 0.6f)
            )
            .padding(16.dp)
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Icon circle
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .background(
                        brush = if (isUnlocked) {
                            Brush.linearGradient(
                                colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                            )
                        } else {
                            Brush.linearGradient(
                                colors = listOf(
                                    AppTheme.Colors.tertiaryText.copy(alpha = 0.3f),
                                    AppTheme.Colors.tertiaryText.copy(alpha = 0.2f)
                                )
                            )
                        },
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = mapAchievementIcon(achievement.icon),
                    contentDescription = null,
                    tint = if (isUnlocked) Color.White else AppTheme.Colors.tertiaryText,
                    modifier = Modifier.size(28.dp)
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Title
            Text(
                text = achievement.title,
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = if (isUnlocked) AppTheme.Colors.primaryText
                       else AppTheme.Colors.tertiaryText,
                textAlign = TextAlign.Center,
                maxLines = 2
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Description
            Text(
                text = achievement.description,
                fontSize = 11.sp,
                color = AppTheme.Colors.secondaryText,
                textAlign = TextAlign.Center,
                maxLines = 2
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Progress bar (for in-progress achievements)
            if (!isUnlocked && progress > 0f) {
                CoreViaGradientProgressBar(
                    progress = progress,
                    modifier = Modifier.fillMaxWidth(),
                    height = 6.dp,
                    gradientColors = listOf(
                        AppTheme.Colors.accent.copy(alpha = 0.5f),
                        AppTheme.Colors.accent
                    )
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "${achievement.current}/${achievement.target}",
                    fontSize = 11.sp,
                    color = AppTheme.Colors.tertiaryText
                )
            } else if (isUnlocked) {
                // Unlocked badge
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(AppTheme.Colors.success.copy(alpha = 0.15f))
                        .padding(horizontal = 10.dp, vertical = 3.dp)
                ) {
                    Text(
                        text = "Qazanildi",
                        fontSize = 11.sp,
                        color = AppTheme.Colors.success,
                        fontWeight = FontWeight.Medium
                    )
                }
            } else {
                // Locked
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(AppTheme.Colors.tertiaryText.copy(alpha = 0.15f))
                        .padding(horizontal = 10.dp, vertical = 3.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.Lock,
                            contentDescription = null,
                            tint = AppTheme.Colors.tertiaryText,
                            modifier = Modifier.size(12.dp)
                        )
                        Text(
                            text = "Kilidli",
                            fontSize = 11.sp,
                            color = AppTheme.Colors.tertiaryText
                        )
                    }
                }
            }
        }
    }
}

private fun mapAchievementIcon(iconName: String?): ImageVector {
    return when (iconName) {
        "fitness_center" -> Icons.Outlined.FitnessCenter
        "local_fire_department" -> Icons.Filled.LocalFireDepartment
        "emoji_events" -> Icons.Outlined.EmojiEvents
        "military_tech" -> Icons.Outlined.Star
        "forum" -> Icons.Outlined.Forum
        "share" -> Icons.Outlined.Share
        "people" -> Icons.Outlined.People
        "calendar_month" -> Icons.Outlined.CalendarMonth
        else -> Icons.Outlined.Star
    }
}
