package life.corevia.app.ui.analytics

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.BodyMeasurement
import life.corevia.app.data.models.DailyStats

/**
 * iOS: AnalyticsView.swift — streak, bugünkü stats, həftəlik chart, bədən ölçüləri
 */
@Composable
fun AnalyticsScreen(
    viewModel: AnalyticsViewModel,
    onBack: () -> Unit
) {
    val dashboard by viewModel.dashboard.collectAsState()
    val weeklyStats by viewModel.weeklyStats.collectAsState()
    val measurements by viewModel.measurements.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val showAddMeasurement by viewModel.showAddMeasurement.collectAsState()

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
                                    AppTheme.Colors.accent.copy(alpha = 0.15f),
                                    Color.Transparent
                                )
                            )
                        )
                        .padding(horizontal = 16.dp)
                        .padding(top = 50.dp, bottom = 16.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        IconButton(onClick = onBack) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = "Geri",
                                tint = AppTheme.Colors.accent
                            )
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        Icon(
                            imageVector = Icons.Filled.Star,
                            contentDescription = null,
                            tint = AppTheme.Colors.accent,
                            modifier = Modifier.size(28.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Analitika",
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Bold,
                            color = AppTheme.Colors.primaryText
                        )
                    }
                }
            }

            // ── Loading ─────────────────────────────────────────────────────────
            if (isLoading && dashboard == null) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(200.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
            } else {

                // ── Streak Card ─────────────────────────────────────────────────
                item {
                    StreakCard(
                        streakDays = dashboard?.streakDays ?: 0,
                        totalWorkouts = dashboard?.totalWorkoutsAllTime ?: 0,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                }

                // ── Today Stats ─────────────────────────────────────────────────
                item {
                    SectionTitle("Bugünkü Statistika", Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
                }
                item {
                    TodayStatsRow(
                        today = dashboard?.today,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                }

                // ── Weekly Bar Chart ────────────────────────────────────────────
                item {
                    SectionTitle("Həftəlik İcmal", Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
                }
                item {
                    WeeklyChartCard(
                        dailyStats = weeklyStats?.dailyStats ?: emptyList(),
                        totalWorkouts = weeklyStats?.totalWorkouts ?: 0,
                        totalCalories = weeklyStats?.totalCaloriesBurned ?: 0,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                }

                // ── Body Measurements ───────────────────────────────────────────
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Bədən Ölçüləri",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = AppTheme.Colors.primaryText,
                            modifier = Modifier.weight(1f)
                        )
                        Button(
                            onClick = { viewModel.setShowAddMeasurement(true) },
                            colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                            shape = RoundedCornerShape(12.dp),
                            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Filled.Add,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Ölçü əlavə et", fontSize = 13.sp)
                        }
                    }
                }

                if (measurements.isEmpty()) {
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
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text("📏", fontSize = 40.sp)
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = "Hələ ölçü əlavə edilməyib",
                                    color = AppTheme.Colors.secondaryText,
                                    fontSize = 14.sp
                                )
                            }
                        }
                    }
                } else {
                    items(measurements.take(5), key = { it.id }) { measurement ->
                        MeasurementCard(
                            measurement = measurement,
                            onDelete = { viewModel.deleteMeasurement(measurement.id) },
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                        )
                    }
                }
            }
        }

        // ── Add Measurement Sheet ───────────────────────────────────────────────
        if (showAddMeasurement) {
            AddMeasurementSheet(
                onDismiss = { viewModel.setShowAddMeasurement(false) },
                onSave = { request -> viewModel.createMeasurement(request) },
                isLoading = isLoading
            )
        }

        // ── Snackbars ───────────────────────────────────────────────────────────
        successMessage?.let { msg ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp)
                    .padding(bottom = 60.dp),
                containerColor = AppTheme.Colors.success
            ) {
                Text(msg, color = Color.White)
            }
            LaunchedEffect(msg) {
                kotlinx.coroutines.delay(2000)
                viewModel.clearSuccess()
            }
        }
        errorMessage?.let { error ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp)
                    .padding(bottom = 60.dp),
                containerColor = AppTheme.Colors.error,
                action = {
                    TextButton(onClick = { viewModel.clearError() }) {
                        Text("Bağla", color = Color.White)
                    }
                }
            ) {
                Text(error, color = Color.White)
            }
        }
    }
}

// ─── Section Title ───────────────────────────────────────────────────────────
@Composable
fun SectionTitle(title: String, modifier: Modifier = Modifier) {
    Text(
        text = title,
        fontSize = 20.sp,
        fontWeight = FontWeight.Bold,
        color = AppTheme.Colors.primaryText,
        modifier = modifier
    )
}

// ─── Streak Card ─────────────────────────────────────────────────────────────
@Composable
fun StreakCard(streakDays: Int, totalWorkouts: Int, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(
                Brush.linearGradient(
                    colors = listOf(
                        AppTheme.Colors.accent.copy(alpha = 0.3f),
                        AppTheme.Colors.accentDark.copy(alpha = 0.2f)
                    )
                )
            )
            .padding(20.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            // Streak
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("🔥", fontSize = 32.sp)
                Text(
                    text = "$streakDays",
                    fontSize = 36.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.accent
                )
                Text(
                    text = "Gün ardıcıl",
                    fontSize = 13.sp,
                    color = AppTheme.Colors.secondaryText
                )
            }

            // Divider
            Box(
                modifier = Modifier
                    .width(1.dp)
                    .height(80.dp)
                    .background(AppTheme.Colors.separator)
            )

            // Total workouts
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("💪", fontSize = 32.sp)
                Text(
                    text = "$totalWorkouts",
                    fontSize = 36.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.success
                )
                Text(
                    text = "Toplam məşq",
                    fontSize = 13.sp,
                    color = AppTheme.Colors.secondaryText
                )
            }
        }
    }
}

// ─── Today Stats Row ─────────────────────────────────────────────────────────
@Composable
fun TodayStatsRow(today: DailyStats?, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        StatMiniCard(
            icon = Icons.Filled.Star,
            value = "${today?.totalWorkouts ?: 0}",
            label = "Məşq",
            color = AppTheme.Colors.accent,
            modifier = Modifier.weight(1f)
        )
        StatMiniCard(
            icon = Icons.Filled.PlayArrow,
            value = "${today?.totalDuration ?: 0} dəq",
            label = "Müddət",
            color = AppTheme.Colors.warning,
            modifier = Modifier.weight(1f)
        )
        StatMiniCard(
            icon = Icons.Filled.Favorite,
            value = "${today?.totalCaloriesBurned ?: 0}",
            label = "Kalori",
            color = AppTheme.Colors.error,
            modifier = Modifier.weight(1f)
        )
    }
}

@Composable
fun StatMiniCard(
    icon: ImageVector,
    value: String,
    label: String,
    color: Color,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground)
            .padding(12.dp)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = color,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = value,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )
            Text(
                text = label,
                fontSize = 11.sp,
                color = AppTheme.Colors.secondaryText
            )
        }
    }
}

// ─── Weekly Chart Card ───────────────────────────────────────────────────────
@Composable
fun WeeklyChartCard(
    dailyStats: List<DailyStats>,
    totalWorkouts: Int,
    totalCalories: Int,
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
            // Summary row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "$totalWorkouts məşq",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AppTheme.Colors.primaryText
                )
                Text(
                    text = "$totalCalories kcal",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AppTheme.Colors.accent
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Simple bar chart
            if (dailyStats.isNotEmpty()) {
                val maxCalories = dailyStats.maxOfOrNull { it.totalCaloriesBurned } ?: 1
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(100.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.Bottom
                ) {
                    dailyStats.forEach { stat ->
                        val heightFraction = if (maxCalories > 0)
                            stat.totalCaloriesBurned.toFloat() / maxCalories
                        else 0f

                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Bottom,
                            modifier = Modifier.weight(1f)
                        ) {
                            // Bar
                            Box(
                                modifier = Modifier
                                    .width(20.dp)
                                    .height((heightFraction * 70).dp.coerceAtLeast(4.dp))
                                    .clip(RoundedCornerShape(topStart = 4.dp, topEnd = 4.dp))
                                    .background(
                                        if (heightFraction > 0) AppTheme.Colors.accent
                                        else AppTheme.Colors.separator
                                    )
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            // Day label
                            Text(
                                text = formatDayLabel(stat.date),
                                fontSize = 10.sp,
                                color = AppTheme.Colors.tertiaryText
                            )
                        }
                    }
                }
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(80.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Bu həftə məlumat yoxdur",
                        color = AppTheme.Colors.tertiaryText,
                        fontSize = 13.sp
                    )
                }
            }
        }
    }
}

// ─── Measurement Card ────────────────────────────────────────────────────────
@Composable
fun MeasurementCard(
    measurement: BodyMeasurement,
    onDelete: () -> Unit,
    modifier: Modifier = Modifier
) {
    var showDeleteConfirm by remember { mutableStateOf(false) }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
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
                    text = formatMeasurementDate(measurement.measuredAt ?: measurement.createdAt ?: ""),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AppTheme.Colors.primaryText
                )
                IconButton(
                    onClick = { showDeleteConfirm = true },
                    modifier = Modifier.size(28.dp)
                ) {
                    Icon(
                        imageVector = Icons.Filled.Delete,
                        contentDescription = "Sil",
                        tint = AppTheme.Colors.tertiaryText,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Measurement values in a grid
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                measurement.weight?.let {
                    MeasurementChip("Çəki", "${it}kg", Modifier.weight(1f))
                }
                measurement.height?.let {
                    MeasurementChip("Boy", "${it}cm", Modifier.weight(1f))
                }
                measurement.bodyFat?.let {
                    MeasurementChip("Yağ", "${it}%", Modifier.weight(1f))
                }
            }

            // Additional measurements
            val extras = listOfNotNull(
                measurement.chest?.let { "Sinə: ${it}cm" },
                measurement.waist?.let { "Bel: ${it}cm" },
                measurement.hips?.let { "Omba: ${it}cm" },
                measurement.arms?.let { "Qol: ${it}cm" }
            )
            if (extras.isNotEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = extras.joinToString("  •  "),
                    fontSize = 12.sp,
                    color = AppTheme.Colors.secondaryText
                )
            }

            measurement.notes?.let { notes ->
                if (notes.isNotBlank()) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = notes,
                        fontSize = 12.sp,
                        color = AppTheme.Colors.tertiaryText
                    )
                }
            }
        }
    }

    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("Ölçünü sil?", color = AppTheme.Colors.primaryText) },
            text = { Text("Bu ölçü silinəcək.", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = {
                    showDeleteConfirm = false
                    onDelete()
                }) {
                    Text("Sil", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirm = false }) {
                    Text("Ləğv et", color = AppTheme.Colors.secondaryText)
                }
            },
            containerColor = AppTheme.Colors.secondaryBackground
        )
    }
}

@Composable
fun MeasurementChip(label: String, value: String, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(AppTheme.Colors.secondaryBackground)
            .padding(horizontal = 12.dp, vertical = 8.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = value,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.accent
            )
            Text(
                text = label,
                fontSize = 10.sp,
                color = AppTheme.Colors.secondaryText
            )
        }
    }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
private fun formatDayLabel(dateString: String): String {
    return try {
        val date = java.time.LocalDate.parse(dateString.take(10))
        val dayNames = listOf("B.e.", "Ç.a.", "Ç.", "C.a.", "C.", "Ş.", "B.")
        dayNames[date.dayOfWeek.value - 1]
    } catch (e: Exception) {
        ""
    }
}

private fun formatMeasurementDate(dateString: String): String {
    return try {
        val date = dateString.take(10)
        val parts = date.split("-")
        "${parts[2]}.${parts[1]}.${parts[0]}"
    } catch (e: Exception) {
        ""
    }
}
