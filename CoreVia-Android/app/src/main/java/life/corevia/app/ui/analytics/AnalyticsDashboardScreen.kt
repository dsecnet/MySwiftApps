package life.corevia.app.ui.analytics

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.NutritionTrend
import life.corevia.app.data.model.WorkoutTrend
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AnalyticsDashboardScreen(
    onBack: () -> Unit = {},
    onNavigateToOverallStats: () -> Unit = {},
    viewModel: AnalyticsDashboardViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Analitika",
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
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
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(padding)
        ) {
            when {
                uiState.isLoading -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                    }
                }

                uiState.error != null -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(16.dp),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(
                            Icons.Filled.ErrorOutline, null,
                            modifier = Modifier.size(48.dp),
                            tint = CoreViaError
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = uiState.error ?: "Xəta baş verdi",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            textAlign = TextAlign.Center
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = viewModel::loadDashboard,
                            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
                        ) {
                            Text("Yenidən cəhd edin")
                        }
                    }
                }

                else -> {
                    val hasData = uiState.currentWeek.totalWorkouts > 0 ||
                            uiState.workoutTrend.isNotEmpty() ||
                            uiState.nutritionTrend.isNotEmpty()

                    if (!hasData) {
                        // Empty state
                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.Center,
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                Icons.Filled.BarChart, null,
                                modifier = Modifier.size(70.dp),
                                tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                            )
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(
                                text = "Hələ analitik məlumat yoxdur",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onBackground
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "Məşq edərək statistikalarınızı izləməyə başlayın",
                                fontSize = 14.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                textAlign = TextAlign.Center
                            )
                        }
                    } else {
                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                                .verticalScroll(rememberScrollState())
                                .padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(24.dp)
                        ) {
                            // ── Current Week Summary Card ──
                            CurrentWeekCard(
                                totalWorkouts = uiState.currentWeek.totalWorkouts,
                                totalMinutes = uiState.currentWeek.totalMinutes,
                                totalCalories = uiState.currentWeek.totalCalories,
                                consistencyPercent = uiState.currentWeek.consistencyPercent
                            )

                            // ── Workout Trend Section ──
                            if (uiState.workoutTrend.isNotEmpty()) {
                                WorkoutTrendSection(trends = uiState.workoutTrend)
                            }

                            // ── Nutrition Trend Section ──
                            if (uiState.nutritionTrend.isNotEmpty()) {
                                NutritionTrendSection(trends = uiState.nutritionTrend)
                            }

                            // ── 30-Day Summary Grid ──
                            ThirtyDaySummarySection(
                                totalWorkouts = uiState.thirtyDaySummary.totalWorkouts,
                                totalCaloriesBurned = uiState.thirtyDaySummary.totalCaloriesBurned,
                                totalFoodCalories = uiState.thirtyDaySummary.totalFoodCalories,
                                avgDailyCalories = uiState.thirtyDaySummary.avgDailyCalories,
                                totalDistance = uiState.thirtyDaySummary.totalDistance,
                                avgSleep = uiState.thirtyDaySummary.avgSleep
                            )

                            // ── Overall Stats Navigation ──
                            OverallStatsButton(onClick = onNavigateToOverallStats)

                            Spacer(modifier = Modifier.height(80.dp))
                        }
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// CURRENT WEEK CARD — iOS style: card with shadow, HStack stat items
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun CurrentWeekCard(
    totalWorkouts: Int,
    totalMinutes: Int,
    totalCalories: Int,
    consistencyPercent: Double
) {
    Column(
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
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Bu Həftə",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
        )

        // Row 1: Workouts + Minutes — iOS HStack stat card style
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            AnalyticsStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.FitnessCenter,
                value = "$totalWorkouts",
                label = "Məşq"
            )
            AnalyticsStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Timer,
                value = "$totalMinutes",
                label = "Dəqiqə"
            )
        }

        // Row 2: Calories + Consistency
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            AnalyticsStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.LocalFireDepartment,
                value = "$totalCalories",
                label = "Kalori"
            )
            AnalyticsStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.TrendingUp,
                value = "${consistencyPercent.toInt()}%",
                label = "Ardıcıllıq"
            )
        }
    }
}

/**
 * iOS AnalyticsStatCard equivalent:
 * HStack { Image(40x40, PrimaryColor 0.1 bg, cornerRadius 10) + VStack(value, label) }
 * background: systemGray6, cornerRadius: 12
 */
@Composable
private fun AnalyticsStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f))
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 40x40 icon container with PrimaryColor 0.1 bg, cornerRadius 10
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(CoreViaPrimary.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                icon, null,
                modifier = Modifier.size(22.dp),
                tint = CoreViaPrimary
            )
        }

        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(
                text = value,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = label,
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// WORKOUT TREND SECTION — iOS style card with shadow
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun WorkoutTrendSection(trends: List<WorkoutTrend>) {
    Column(
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
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(
            text = "Məşq Trendi",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
        )

        val maxCount = trends.maxOfOrNull { it.count } ?: 1

        trends.forEach { trend ->
            WorkoutTrendBar(
                date = formatTrendDate(trend.date),
                count = trend.count,
                maxCount = maxCount
            )
        }
    }
}

@Composable
private fun WorkoutTrendBar(
    date: String,
    count: Int,
    maxCount: Int
) {
    val fraction = if (maxCount > 0) count.toFloat() / maxCount.toFloat() else 0f

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Text(
            text = date,
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.width(36.dp)
        )

        Box(
            modifier = Modifier
                .weight(1f)
                .height(24.dp)
                .clip(RoundedCornerShape(6.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f))
        ) {
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(fraction.coerceAtLeast(0.02f))
                    .clip(RoundedCornerShape(6.dp))
                    .background(CoreViaPrimary)
            )
        }

        Text(
            text = "$count",
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface,
            modifier = Modifier.width(24.dp),
            textAlign = TextAlign.End
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// NUTRITION TREND SECTION — iOS style card with shadow
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun NutritionTrendSection(trends: List<NutritionTrend>) {
    Column(
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
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Text(
            text = "Qidalanma Trendi",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
        )

        trends.forEach { trend ->
            NutritionTrendItem(trend = trend)
        }
    }
}

@Composable
private fun NutritionTrendItem(trend: NutritionTrend) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = formatTrendDate(trend.date),
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = "${trend.calories} kcal",
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            MacroPill(label = "P", value = "${trend.protein.toInt()}g", color = AccentBlue)
            MacroPill(label = "K", value = "${trend.carbs.toInt()}g", color = AccentOrange)
            MacroPill(label = "Y", value = "${trend.fats.toInt()}g", color = AccentPurple)
        }
    }
}

@Composable
private fun MacroPill(label: String, value: String, color: Color) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(color.copy(alpha = 0.12f))
            .padding(horizontal = 10.dp, vertical = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(label, fontSize = 11.sp, fontWeight = FontWeight.Bold, color = color)
        Text(value, fontSize = 11.sp, fontWeight = FontWeight.Medium, color = MaterialTheme.colorScheme.onSurface)
    }
}

// ═══════════════════════════════════════════════════════════════════
// 30-DAY SUMMARY GRID — iOS SummaryAnalyticsStatCard style
// VStack centered: icon + value + label, with shadow
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun ThirtyDaySummarySection(
    totalWorkouts: Int,
    totalCaloriesBurned: Int,
    totalFoodCalories: Int,
    avgDailyCalories: Int,
    totalDistance: Double,
    avgSleep: Double
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "30 Günlük Xülasə",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
        )

        // 2-column grid like iOS LazyVGrid
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            SummaryStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.FitnessCenter,
                value = "$totalWorkouts",
                label = "Ümumi Məşq"
            )
            SummaryStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.LocalFireDepartment,
                value = formatNumber(totalCaloriesBurned),
                label = "Yandırılan Kalori"
            )
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            SummaryStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Restaurant,
                value = formatNumber(totalFoodCalories),
                label = "Qida Kalorisi"
            )
            SummaryStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Bolt,
                value = formatNumber(avgDailyCalories),
                label = "Gündəlik Ort."
            )
        }
    }
}

/**
 * iOS SummaryAnalyticsStatCard equivalent:
 * VStack centered { icon (title) + value (title2 bold) + label (caption gray) }
 * background: systemBackground, cornerRadius: 12, shadow(0.05, radius 5, y: 2)
 */
@Composable
private fun SummaryStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String
) {
    Column(
        modifier = modifier
            .shadow(
                elevation = 2.dp,
                shape = RoundedCornerShape(12.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.05f)
            )
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Icon(
            icon, null,
            modifier = Modifier.size(28.dp),
            tint = CoreViaPrimary
        )
        Text(
            text = value,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// OVERALL STATS BUTTON
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun OverallStatsButton(onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 2.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.05f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(CoreViaPrimary.copy(alpha = 0.1f))
            .clickable { onClick() }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(CoreViaPrimary.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.Insights, null,
                    modifier = Modifier.size(22.dp),
                    tint = CoreViaPrimary
                )
            }
            Column {
                Text(
                    text = "Ümumi Statistika",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = "Bütün məlumatlarınıza baxın",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
        Icon(
            Icons.Filled.ChevronRight, null,
            modifier = Modifier.size(20.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════

private fun formatTrendDate(dateStr: String): String {
    return try {
        val parts = dateStr.split("-")
        if (parts.size >= 3) "${parts[2]}/${parts[1]}" else dateStr
    } catch (_: Exception) {
        dateStr
    }
}

private fun formatNumber(number: Int): String {
    return when {
        number >= 1_000_000 -> String.format("%.1fM", number / 1_000_000.0)
        number >= 1_000 -> String.format("%.1fK", number / 1_000.0)
        else -> "$number"
    }
}
