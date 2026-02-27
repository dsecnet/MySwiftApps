package life.corevia.app.ui.home

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.ui.theme.*

@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel(),
    onNavigateToWorkout: () -> Unit = {},
    onNavigateToFood: () -> Unit = {},
    onNavigateToRoute: () -> Unit = {},
    onNavigateToAIAnalysis: () -> Unit = {},
    onNavigateToNotifications: () -> Unit = {},
    onNavigateToSocial: () -> Unit = {},
    onNavigateToMarketplace: () -> Unit = {},
    onNavigateToLiveSession: () -> Unit = {},
    onNavigateToAnalytics: () -> Unit = {},
    onNavigateToSurvey: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    // Reload data every time screen appears
    val lifecycleOwner = androidx.compose.ui.platform.LocalLifecycleOwner.current
    androidx.compose.runtime.DisposableEffect(lifecycleOwner) {
        val observer = androidx.lifecycle.LifecycleEventObserver { _, event ->
            if (event == androidx.lifecycle.Lifecycle.Event.ON_RESUME) {
                viewModel.loadData()
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    HomeScreenContent(
        uiState = uiState,
        onNavigateToWorkout = onNavigateToWorkout,
        onNavigateToFood = onNavigateToFood,
        onNavigateToSocial = onNavigateToSocial,
        onNavigateToMarketplace = onNavigateToMarketplace,
        onNavigateToLiveSession = onNavigateToLiveSession,
        onNavigateToAnalytics = onNavigateToAnalytics,
        onSurveyClick = onNavigateToSurvey
    )
}

@Composable
fun HomeScreenContent(
    uiState: HomeUiState = HomeUiState(),
    onNavigateToWorkout: () -> Unit = {},
    onNavigateToFood: () -> Unit = {},
    onNavigateToSocial: () -> Unit = {},
    onNavigateToMarketplace: () -> Unit = {},
    onNavigateToLiveSession: () -> Unit = {},
    onNavigateToAnalytics: () -> Unit = {},
    onSurveyClick: () -> Unit = {}
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(bottom = 80.dp)
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // MARK: - Header
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    text = "Salam, ${uiState.userName} \uD83D\uDC4B",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "Hədəflərinizə fokuslanın",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // MARK: - Stats (Real Data)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                StatCard(
                    modifier = Modifier.weight(1f),
                    title = "Məşq",
                    value = "${uiState.todayTotalMinutes} dəq",
                    icon = Icons.Filled.LocalFireDepartment,
                    color = CoreViaPrimary
                )
                StatCard(
                    modifier = Modifier.weight(1f),
                    title = "Kalori",
                    value = "${uiState.todayTotalCalories}",
                    icon = Icons.Filled.Bolt,
                    color = CoreViaPrimary
                )
            }

            // MARK: - Daily Survey Prompt
            DailySurveyPrompt(onClick = onSurveyClick)

            // MARK: - Daily Goal
            DailyGoalCard(
                progress = uiState.todayProgress,
                completedCount = uiState.todayCompletedCount,
                totalCount = uiState.todayTotalCount
            )

            // MARK: - Today's Workouts
            if (uiState.todayWorkouts.isNotEmpty()) {
                TodayWorkoutsSection(
                    workouts = uiState.todayWorkouts,
                    onSeeAll = onNavigateToWorkout
                )
            }

            // MARK: - Quick Actions
            Text(
                text = "Tez Əməliyyatlar",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )

            QuickActionsGrid(
                onWorkoutClick = onNavigateToWorkout,
                onFoodClick = onNavigateToFood,
                onSocialClick = onNavigateToSocial,
                onMarketplaceClick = onNavigateToMarketplace,
                onLiveSessionClick = onNavigateToLiveSession,
                onAnalyticsClick = onNavigateToAnalytics
            )

            // MARK: - AI Recommendation
            AIRecommendationCard(recommendation = uiState.aiRecommendation, isLoading = uiState.isLoadingAI)

            // MARK: - Weekly Stats
            WeeklyStatsCard(stats = uiState.weekStats)
        }
    }

}

// MARK: - StatCard
@Composable
private fun StatCard(
    modifier: Modifier = Modifier,
    title: String,
    value: String,
    icon: ImageVector,
    color: Color
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(10.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(horizontal = 10.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            icon, null,
            modifier = Modifier.size(16.dp),
            tint = color
        )
        Column(verticalArrangement = Arrangement.spacedBy(1.dp)) {
            Text(
                text = value,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = title,
                fontSize = 10.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// MARK: - Daily Survey Prompt
@Composable
private fun DailySurveyPrompt(onClick: () -> Unit = {}) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(
                Brush.linearGradient(
                    listOf(Color(0xFF2196F3).copy(alpha = 0.05f), Color(0xFF2196F3).copy(alpha = 0.1f))
                )
            )
            .border(1.dp, Color(0xFF2196F3).copy(alpha = 0.2f), RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(42.dp)
                .clip(CircleShape)
                .background(Color(0xFF2196F3).copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.Assignment, null,
                modifier = Modifier.size(18.dp),
                tint = Color(0xFF2196F3)
            )
        }
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                text = "Günlük sorğunu doldur",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "Vəziyyətini qiymətləndir",
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Icon(
            Icons.Filled.ChevronRight, null,
            modifier = Modifier.size(14.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// MARK: - Daily Goal
@Composable
private fun DailyGoalCard(progress: Float, completedCount: Int, totalCount: Int) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Günlük Hədəf",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "${(progress * 100).toInt()}%",
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
        }

        LinearProgressIndicator(
            progress = { progress.coerceIn(0f, 1f) },
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp)),
            color = CoreViaPrimary,
            trackColor = CoreViaPrimary.copy(alpha = 0.12f),
        )

        Text(
            text = "$completedCount/$totalCount Tamamlandı",
            fontSize = 10.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// MARK: - Today's Workouts
@Composable
private fun TodayWorkoutsSection(workouts: List<TodayWorkout>, onSeeAll: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Bugünkü Məşqlər",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "Hamısına bax",
                fontSize = 12.sp,
                color = CoreViaPrimary,
                modifier = Modifier.clickable { onSeeAll() }
            )
        }

        workouts.take(2).forEach { workout ->
            CompactWorkoutCard(workout = workout)
        }
    }
}

// MARK: - Compact Workout Card
@Composable
private fun CompactWorkoutCard(workout: TodayWorkout) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            Icons.Filled.FavoriteBorder, null,
            modifier = Modifier.size(24.dp),
            tint = CoreViaPrimary
        )
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                text = workout.title,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "${workout.duration} dəq",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Icon(
            if (workout.isCompleted) Icons.Filled.CheckCircle else Icons.Filled.RadioButtonUnchecked,
            null,
            modifier = Modifier.size(22.dp),
            tint = if (workout.isCompleted) CoreViaSuccess else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
        )
    }
}

// MARK: - Quick Actions Grid (3x2)
@Composable
private fun QuickActionsGrid(
    onWorkoutClick: () -> Unit,
    onFoodClick: () -> Unit,
    onSocialClick: () -> Unit,
    onMarketplaceClick: () -> Unit,
    onLiveSessionClick: () -> Unit,
    onAnalyticsClick: () -> Unit
) {
    // Row 1
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        CompactQuickAction(Modifier.weight(1f), "Məşq Əlavə Et", Icons.Filled.AddCircle, onWorkoutClick)
        CompactQuickAction(Modifier.weight(1f), "Qida Əlavə Et", Icons.Filled.Restaurant, onFoodClick)
        CompactQuickAction(Modifier.weight(1f), "Sosial", Icons.Filled.People, onSocialClick)
    }
    // Row 2
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        CompactQuickAction(Modifier.weight(1f), "Mağaza", Icons.Filled.ShoppingCart, onMarketplaceClick)
        CompactQuickAction(Modifier.weight(1f), "Canlı Sessiyalar", Icons.Filled.Videocam, onLiveSessionClick)
        CompactQuickAction(Modifier.weight(1f), "Statistika", Icons.Filled.BarChart, onAnalyticsClick)
    }
}

@Composable
private fun CompactQuickAction(
    modifier: Modifier = Modifier,
    title: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(10.dp))
            .background(CoreViaPrimary.copy(alpha = 0.85f))
            .clickable { onClick() }
            .padding(vertical = 12.dp, horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Icon(
            icon, null,
            modifier = Modifier.size(18.dp),
            tint = Color.White
        )
        Text(
            text = title,
            fontSize = 10.sp,
            fontWeight = FontWeight.Medium,
            color = Color.White,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

// MARK: - AI Recommendation Card (purple themed)
@Composable
private fun AIRecommendationCard(recommendation: AIRecommendation, isLoading: Boolean) {
    val purple = Color(0xFF9C27B0)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(
                Brush.linearGradient(
                    listOf(purple.copy(alpha = 0.05f), purple.copy(alpha = 0.1f))
                )
            )
            .border(1.dp, purple.copy(alpha = 0.2f), RoundedCornerShape(14.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                Icons.Filled.Psychology, null,
                modifier = Modifier.size(18.dp),
                tint = purple
            )
            Text(
                text = "AI Tövsiyə",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Spacer(Modifier.weight(1f))
            if (isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(14.dp),
                    strokeWidth = 2.dp,
                    color = purple
                )
            } else {
                Icon(
                    Icons.Filled.AutoAwesome, null,
                    modifier = Modifier.size(16.dp),
                    tint = purple
                )
            }
        }

        Text(
            text = recommendation.title,
            fontSize = 15.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Text(
            text = recommendation.description,
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            lineHeight = 18.sp,
            maxLines = 3
        )

        // Category tag
        val tagColor = when (recommendation.type) {
            "workout" -> CoreViaPrimary
            "meal" -> Color(0xFFFF9800)
            "hydration" -> Color(0xFF2196F3)
            "sleep" -> purple
            "rest" -> CoreViaSuccess
            else -> CoreViaPrimary
        }
        val tagIcon = when (recommendation.type) {
            "workout" -> Icons.Filled.DirectionsRun
            "meal" -> Icons.Filled.Restaurant
            "hydration" -> Icons.Filled.WaterDrop
            "sleep" -> Icons.Filled.DarkMode
            "rest" -> Icons.Filled.Spa
            else -> Icons.Filled.EmojiEvents
        }

        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(8.dp))
                .background(tagColor.copy(alpha = 0.1f))
                .padding(horizontal = 10.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                tagIcon, null,
                modifier = Modifier.size(12.dp),
                tint = tagColor
            )
            Text(
                text = recommendation.category,
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                color = tagColor
            )
        }
    }
}

// MARK: - Weekly Stats
@Composable
private fun WeeklyStatsCard(stats: WeekStats) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            text = "Bu Həftə",
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Row(modifier = Modifier.fillMaxWidth()) {
            WeekStatItem(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.FitnessCenter,
                value = "${stats.workoutCount}",
                label = "Məşq"
            )
            WeekStatItem(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.CheckCircle,
                value = "${stats.completedCount}",
                label = "Tamamlandı"
            )
            WeekStatItem(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Schedule,
                value = "${stats.totalMinutes}",
                label = "Dəqiqə"
            )
        }
    }
}

@Composable
private fun WeekStatItem(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Icon(
            icon, null,
            modifier = Modifier.size(16.dp),
            tint = CoreViaPrimary
        )
        Text(
            text = value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = label,
            fontSize = 10.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun HomeScreenPreview() {
    CoreViaTheme {
        HomeScreenContent()
    }
}
