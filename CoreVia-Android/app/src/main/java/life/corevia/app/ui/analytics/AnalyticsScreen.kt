package life.corevia.app.ui.analytics

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.Canvas
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
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.*
import life.corevia.app.ui.theme.CoreViaAnimatedBackground

/**
 * iOS: AnalyticsView.swift — streak, bugunku stats, hefteli chart, beden olculeri, muqayise
 */
@Composable
fun AnalyticsScreen(
    viewModel: AnalyticsViewModel,
    onBack: () -> Unit
) {
    val dashboard by viewModel.dashboard.collectAsState()
    val weeklyStats by viewModel.weeklyStats.collectAsState()
    val comparison by viewModel.comparison.collectAsState()
    val measurements by viewModel.measurements.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val showAddMeasurement by viewModel.showAddMeasurement.collectAsState()

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(bottom = 100.dp)
        ) {
            // ── Header ────────────────────────────────────────────────────────────
            item {
                Box(
                    modifier = Modifier.fillMaxWidth()
                        .background(Brush.verticalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.15f), Color.Transparent)))
                        .padding(horizontal = 16.dp).padding(top = 50.dp, bottom = 16.dp)
                ) {
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = onBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                        }
                        Spacer(Modifier.width(8.dp))
                        Icon(Icons.Outlined.Analytics, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(28.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Analitika", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                    }
                }
            }

            // ── Loading ───────────────────────────────────────────────────────────
            if (isLoading && dashboard == null) {
                item {
                    Box(Modifier.fillMaxWidth().height(200.dp), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
            } else {

                // ── Streak Card ───────────────────────────────────────────────────
                item {
                    StreakCard(
                        streakDays = dashboard?.workoutStreakDays ?: 0,
                        totalWorkouts = dashboard?.totalWorkouts30d ?: 0,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                }

                // ── Week Comparison ───────────────────────────────────────────────
                comparison?.let { comp ->
                    item {
                        SectionTitle("Həftəlik Müqayisə", Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
                    }
                    item {
                        WeekComparisonSection(comp, Modifier.padding(horizontal = 16.dp))
                    }
                }

                // ── Today Stats ───────────────────────────────────────────────────
                item {
                    SectionTitle("Bu Həftənin Statistikası", Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
                }
                item {
                    TodayStatsRow(
                        week = dashboard?.currentWeek,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                }

                // ── Workout Trend Chart (Canvas) ──────────────────────────────────
                item {
                    SectionTitle("Məşq Trendi (30 gün)", Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
                }
                item {
                    WorkoutTrendChart(
                        trendData = dashboard?.workoutTrend ?: emptyList(),
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                }

                // ── Nutrition Trend Chart (Canvas) ────────────────────────────────
                item {
                    SectionTitle("Qidalanma Trendi (30 gün)", Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
                }
                item {
                    NutritionTrendChart(
                        trendData = dashboard?.nutritionTrend ?: emptyList(),
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                }

                // ── Weekly Bar Chart ──────────────────────────────────────────────
                item {
                    SectionTitle("Həftəlik İcmal", Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
                }
                item {
                    WeeklyChartCard(
                        workoutTrend = dashboard?.workoutTrend?.takeLast(7) ?: emptyList(),
                        totalWorkouts = dashboard?.currentWeek?.workoutsCompleted ?: 0,
                        totalCalories = dashboard?.currentWeek?.caloriesBurned ?: 0,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                }

                // ── Body Measurements ─────────────────────────────────────────────
                item {
                    Row(
                        Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("Bədən Ölçüləri", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText, modifier = Modifier.weight(1f))
                        Button(
                            onClick = { viewModel.setShowAddMeasurement(true) },
                            colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                            shape = RoundedCornerShape(12.dp),
                            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)
                        ) {
                            Icon(Icons.Outlined.Add, null, Modifier.size(16.dp))
                            Spacer(Modifier.width(4.dp))
                            Text("Ölçü əlavə et", fontSize = 13.sp)
                        }
                    }
                }

                if (measurements.isEmpty()) {
                    item {
                        Box(
                            Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                                .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(32.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(Icons.Outlined.Straighten, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(40.dp))
                                Spacer(Modifier.height(8.dp))
                                Text("Hələ ölçü əlavə edilməyib", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                            }
                        }
                    }
                } else {
                    items(measurements.take(5), key = { it.id }) { measurement ->
                        MeasurementCard(measurement, onDelete = { viewModel.deleteMeasurement(measurement.id) }, Modifier.padding(horizontal = 16.dp, vertical = 4.dp))
                    }
                }
            }
        }

        // ── Add Measurement Sheet ─────────────────────────────────────────────
        if (showAddMeasurement) {
            AddMeasurementSheet(
                onDismiss = { viewModel.setShowAddMeasurement(false) },
                onSave = { request -> viewModel.createMeasurement(request) },
                isLoading = isLoading
            )
        }

        // ── Snackbars ─────────────────────────────────────────────────────────
        successMessage?.let { msg ->
            Snackbar(Modifier.align(Alignment.BottomCenter).padding(16.dp).padding(bottom = 60.dp), containerColor = AppTheme.Colors.success) {
                Text(msg, color = Color.White)
            }
            LaunchedEffect(msg) { kotlinx.coroutines.delay(2000); viewModel.clearSuccess() }
        }
        errorMessage?.let { error ->
            Snackbar(
                Modifier.align(Alignment.BottomCenter).padding(16.dp).padding(bottom = 60.dp),
                containerColor = AppTheme.Colors.error,
                action = { TextButton(onClick = { viewModel.clearError() }) { Text("Bağla", color = Color.White) } }
            ) { Text(error, color = Color.White) }
        }
    }
    } // CoreViaAnimatedBackground
}

// ═══════════════════════════════════════════════════════════════════════════════
// Week Comparison Section - trend indicators (up/down arrows with percentage)
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
fun WeekComparisonSection(comparison: ProgressComparison, modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            ComparisonCard(
                label = "Məşqlər",
                currentValue = "${comparison.currentPeriod.workouts}",
                previousValue = "${comparison.previousPeriod.workouts}",
                changePercent = comparison.workoutsChangePercent,
                icon = Icons.Outlined.FitnessCenter,
                modifier = Modifier.weight(1f)
            )
            ComparisonCard(
                label = "Dəqiqə",
                currentValue = "${comparison.currentPeriod.minutes}",
                previousValue = "${comparison.previousPeriod.minutes}",
                changePercent = comparison.minutesChangePercent,
                icon = Icons.Outlined.Schedule,
                modifier = Modifier.weight(1f)
            )
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            ComparisonCard(
                label = "Yandırılan kal.",
                currentValue = "${comparison.currentPeriod.caloriesBurned}",
                previousValue = "${comparison.previousPeriod.caloriesBurned}",
                changePercent = comparison.caloriesBurnedChangePercent,
                icon = Icons.Outlined.LocalFireDepartment,
                modifier = Modifier.weight(1f)
            )
            ComparisonCard(
                label = "Qəbul kal.",
                currentValue = "${comparison.currentPeriod.caloriesConsumed}",
                previousValue = "${comparison.previousPeriod.caloriesConsumed}",
                changePercent = 0.0, // Not calculated by backend
                icon = Icons.Outlined.Restaurant,
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
fun ComparisonCard(
    label: String,
    currentValue: String,
    previousValue: String,
    changePercent: Double,
    icon: ImageVector,
    modifier: Modifier = Modifier
) {
    val isPositive = changePercent > 0
    val isNeutral = changePercent == 0.0
    val trendColor = when {
        isPositive -> AppTheme.Colors.success
        isNeutral -> AppTheme.Colors.tertiaryText
        else -> AppTheme.Colors.error
    }
    val trendIcon = when {
        isPositive -> Icons.Filled.TrendingUp
        isNeutral -> Icons.Filled.TrendingFlat
        else -> Icons.Filled.TrendingDown
    }

    Box(
        modifier = modifier.clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground).padding(14.dp)
    ) {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(icon, null, Modifier.size(18.dp), tint = AppTheme.Colors.accent)
                Spacer(Modifier.width(6.dp))
                Text(label, fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
            }
            Spacer(Modifier.height(8.dp))
            Text(currentValue, fontSize = 24.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
            Spacer(Modifier.height(4.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(trendIcon, null, Modifier.size(16.dp), tint = trendColor)
                Spacer(Modifier.width(4.dp))
                Text(
                    text = if (!isNeutral) "${if (isPositive) "+" else ""}${"%.0f".format(changePercent)}%" else "—",
                    fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = trendColor
                )
                Spacer(Modifier.width(4.dp))
                Text("keçən: $previousValue", fontSize = 10.sp, color = AppTheme.Colors.tertiaryText)
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Workout Trend Chart — Canvas line chart
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
fun WorkoutTrendChart(trendData: List<WorkoutTrendItem>, modifier: Modifier = Modifier) {
    val accentColor = AppTheme.Colors.accent
    val accentLightColor = AppTheme.Colors.accentLight
    val textColor = AppTheme.Colors.tertiaryText

    Box(
        modifier = modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)
    ) {
        if (trendData.isEmpty()) {
            Box(Modifier.fillMaxWidth().height(120.dp), contentAlignment = Alignment.Center) {
                Text("Məlumat yoxdur", color = AppTheme.Colors.tertiaryText, fontSize = 13.sp)
            }
        } else {
            Column {
                val maxCal = trendData.maxOfOrNull { it.calories }?.coerceAtLeast(1) ?: 1
                Canvas(modifier = Modifier.fillMaxWidth().height(120.dp)) {
                    val w = size.width
                    val h = size.height - 16f
                    val stepX = w / (trendData.size - 1).coerceAtLeast(1)

                    // Fill area
                    val fillPath = Path().apply {
                        moveTo(0f, h)
                        trendData.forEachIndexed { i, item ->
                            val x = i * stepX
                            val y = h - (item.calories.toFloat() / maxCal * h)
                            lineTo(x, y)
                        }
                        lineTo(w, h)
                        close()
                    }
                    drawPath(fillPath, Brush.verticalGradient(listOf(accentColor.copy(alpha = 0.25f), Color.Transparent)))

                    // Line
                    val linePath = Path().apply {
                        trendData.forEachIndexed { i, item ->
                            val x = i * stepX
                            val y = h - (item.calories.toFloat() / maxCal * h)
                            if (i == 0) moveTo(x, y) else lineTo(x, y)
                        }
                    }
                    drawPath(linePath, accentColor, style = Stroke(width = 3f, cap = StrokeCap.Round))

                    // Points
                    trendData.forEachIndexed { i, item ->
                        val x = i * stepX
                        val y = h - (item.calories.toFloat() / maxCal * h)
                        drawCircle(accentColor, radius = 3f, center = Offset(x, y))
                    }
                }
                Spacer(Modifier.height(4.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(
                        try { trendData.first().date.takeLast(5) } catch (e: Exception) { "" },
                        fontSize = 10.sp, color = textColor
                    )
                    Text("Kalori (kcal)", fontSize = 10.sp, color = textColor)
                    Text(
                        try { trendData.last().date.takeLast(5) } catch (e: Exception) { "" },
                        fontSize = 10.sp, color = textColor
                    )
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Nutrition Trend Chart — Canvas multi-line (protein, carbs, fats)
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
fun NutritionTrendChart(trendData: List<NutritionTrendItem>, modifier: Modifier = Modifier) {
    val proteinColor = AppTheme.Colors.accent
    val carbsColor = AppTheme.Colors.warning
    val fatsColor = AppTheme.Colors.statDistance
    val textColor = AppTheme.Colors.tertiaryText

    Box(
        modifier = modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)
    ) {
        if (trendData.isEmpty()) {
            Box(Modifier.fillMaxWidth().height(120.dp), contentAlignment = Alignment.Center) {
                Text("Məlumat yoxdur", color = AppTheme.Colors.tertiaryText, fontSize = 13.sp)
            }
        } else {
            Column {
                // Legend
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    LegendDot(proteinColor, "Protein")
                    LegendDot(carbsColor, "Karbohidrat")
                    LegendDot(fatsColor, "Yağ")
                }
                Spacer(Modifier.height(8.dp))

                val maxVal = trendData.maxOfOrNull { maxOf(it.protein, it.carbs, it.fats) }?.coerceAtLeast(1.0) ?: 1.0
                Canvas(modifier = Modifier.fillMaxWidth().height(100.dp)) {
                    val w = size.width
                    val h = size.height
                    val stepX = w / (trendData.size - 1).coerceAtLeast(1)

                    fun drawLine(data: List<Double>, color: Color) {
                        val path = Path().apply {
                            data.forEachIndexed { i, v ->
                                val x = i * stepX
                                val y = h - (v.toFloat() / maxVal.toFloat() * h)
                                if (i == 0) moveTo(x, y) else lineTo(x, y)
                            }
                        }
                        drawPath(path, color, style = Stroke(width = 2.5f, cap = StrokeCap.Round))
                    }

                    drawLine(trendData.map { it.protein }, proteinColor)
                    drawLine(trendData.map { it.carbs }, carbsColor)
                    drawLine(trendData.map { it.fats }, fatsColor)
                }
                Spacer(Modifier.height(4.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(
                        try { trendData.first().date.takeLast(5) } catch (e: Exception) { "" },
                        fontSize = 10.sp, color = textColor
                    )
                    Text("Qram (g)", fontSize = 10.sp, color = textColor)
                    Text(
                        try { trendData.last().date.takeLast(5) } catch (e: Exception) { "" },
                        fontSize = 10.sp, color = textColor
                    )
                }
            }
        }
    }
}

@Composable
fun LegendDot(color: Color, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(8.dp).background(color, CircleShape))
        Spacer(Modifier.width(4.dp))
        Text(label, fontSize = 11.sp, color = AppTheme.Colors.secondaryText)
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Existing components (updated)
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
fun SectionTitle(title: String, modifier: Modifier = Modifier) {
    Text(title, fontSize = 20.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText, modifier = modifier)
}

@Composable
fun StreakCard(streakDays: Int, totalWorkouts: Int, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier.fillMaxWidth().clip(RoundedCornerShape(20.dp))
            .background(Brush.linearGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.3f), AppTheme.Colors.accentDark.copy(alpha = 0.2f))))
            .padding(20.dp)
    ) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Icon(Icons.Outlined.LocalFireDepartment, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(32.dp))
                Text("$streakDays", fontSize = 36.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.accent)
                Text("Gün ardıcıl", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)
            }
            Box(Modifier.width(1.dp).height(80.dp).background(AppTheme.Colors.separator))
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Icon(Icons.Outlined.FitnessCenter, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(32.dp))
                Text("$totalWorkouts", fontSize = 36.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.success)
                Text("Son 30 gün", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)
            }
        }
    }
}

@Composable
fun TodayStatsRow(week: WeeklyStats?, modifier: Modifier = Modifier) {
    Row(modifier = modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        StatMiniCard(Icons.Outlined.FitnessCenter, "${week?.workoutsCompleted ?: 0}", "Məşq", AppTheme.Colors.accent, Modifier.weight(1f))
        StatMiniCard(Icons.Outlined.Schedule, "${week?.totalWorkoutMinutes ?: 0} dəq", "Müddət", AppTheme.Colors.warning, Modifier.weight(1f))
        StatMiniCard(Icons.Outlined.LocalFireDepartment, "${week?.caloriesBurned ?: 0}", "Kalori", AppTheme.Colors.error, Modifier.weight(1f))
    }
}

@Composable
fun StatMiniCard(icon: ImageVector, value: String, label: String, color: Color, modifier: Modifier = Modifier) {
    Box(modifier = modifier.clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(12.dp)) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(icon, null, tint = color, modifier = Modifier.size(24.dp))
            Spacer(Modifier.height(4.dp))
            Text(value, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
            Text(label, fontSize = 11.sp, color = AppTheme.Colors.secondaryText)
        }
    }
}

@Composable
fun WeeklyChartCard(
    workoutTrend: List<WorkoutTrendItem>,
    totalWorkouts: Int,
    totalCalories: Int,
    modifier: Modifier = Modifier
) {
    Box(modifier = modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)) {
        Column {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("$totalWorkouts məşq", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                Text("$totalCalories kcal", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.accent)
            }
            Spacer(Modifier.height(16.dp))
            if (workoutTrend.isNotEmpty()) {
                val maxCal = workoutTrend.maxOfOrNull { it.calories }?.coerceAtLeast(1) ?: 1
                Row(Modifier.fillMaxWidth().height(100.dp), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.Bottom) {
                    workoutTrend.forEach { stat ->
                        val heightFraction = if (maxCal > 0) stat.calories.toFloat() / maxCal else 0f
                        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Bottom, modifier = Modifier.weight(1f)) {
                            Box(
                                Modifier.width(20.dp)
                                    .height((heightFraction * 70).dp.coerceAtLeast(4.dp))
                                    .clip(RoundedCornerShape(topStart = 4.dp, topEnd = 4.dp))
                                    .background(if (heightFraction > 0) AppTheme.Colors.accent else AppTheme.Colors.separator)
                            )
                            Spacer(Modifier.height(4.dp))
                            Text(formatDayLabel(stat.date), fontSize = 10.sp, color = AppTheme.Colors.tertiaryText)
                        }
                    }
                }
            } else {
                Box(Modifier.fillMaxWidth().height(80.dp), contentAlignment = Alignment.Center) {
                    Text("Bu həftə məlumat yoxdur", color = AppTheme.Colors.tertiaryText, fontSize = 13.sp)
                }
            }
        }
    }
}

// ─── Measurement Card ────────────────────────────────────────────────────────
@Composable
fun MeasurementCard(measurement: BodyMeasurement, onDelete: () -> Unit, modifier: Modifier = Modifier) {
    var showDeleteConfirm by remember { mutableStateOf(false) }

    Box(modifier = modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)) {
        Column {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text(formatMeasurementDate(measurement.measuredAt ?: measurement.createdAt ?: ""), fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                IconButton(onClick = { showDeleteConfirm = true }, modifier = Modifier.size(28.dp)) {
                    Icon(Icons.Outlined.Delete, "Sil", tint = AppTheme.Colors.tertiaryText, modifier = Modifier.size(16.dp))
                }
            }
            Spacer(Modifier.height(8.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                measurement.weightKg?.let { MeasurementChip("Çəki", "${it}kg", Modifier.weight(1f)) }
                measurement.bodyFatPercent?.let { MeasurementChip("Yağ", "${it}%", Modifier.weight(1f)) }
                measurement.muscleMassKg?.let { MeasurementChip("Əzələ", "${it}kg", Modifier.weight(1f)) }
            }
            val extras = listOfNotNull(
                measurement.chestCm?.let { "Sinə: ${it}cm" },
                measurement.waistCm?.let { "Bel: ${it}cm" },
                measurement.hipsCm?.let { "Omba: ${it}cm" },
                measurement.armsCm?.let { "Qol: ${it}cm" }
            )
            if (extras.isNotEmpty()) {
                Spacer(Modifier.height(8.dp))
                Text(extras.joinToString("  •  "), fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
            }
            measurement.notes?.let { if (it.isNotBlank()) { Spacer(Modifier.height(4.dp)); Text(it, fontSize = 12.sp, color = AppTheme.Colors.tertiaryText) } }
        }
    }

    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("Ölçünü sil?", color = AppTheme.Colors.primaryText) },
            text = { Text("Bu ölçü silinəcək.", color = AppTheme.Colors.secondaryText) },
            confirmButton = { TextButton(onClick = { showDeleteConfirm = false; onDelete() }) { Text("Sil", color = AppTheme.Colors.error) } },
            dismissButton = { TextButton(onClick = { showDeleteConfirm = false }) { Text("Ləğv et", color = AppTheme.Colors.secondaryText) } },
            containerColor = AppTheme.Colors.secondaryBackground
        )
    }
}

@Composable
fun MeasurementChip(label: String, value: String, modifier: Modifier = Modifier) {
    Box(modifier = modifier.clip(RoundedCornerShape(12.dp)).background(AppTheme.Colors.secondaryBackground).padding(horizontal = 12.dp, vertical = 8.dp), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(value, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.accent)
            Text(label, fontSize = 10.sp, color = AppTheme.Colors.secondaryText)
        }
    }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
private fun formatDayLabel(dateString: String): String {
    return try {
        val date = java.time.LocalDate.parse(dateString.take(10))
        val dayNames = listOf("B.e.", "Ç.a.", "Ç.", "C.a.", "C.", "Ş.", "B.")
        dayNames[date.dayOfWeek.value - 1]
    } catch (e: Exception) { "" }
}

private fun formatMeasurementDate(dateString: String): String {
    return try {
        val parts = dateString.take(10).split("-")
        "${parts[2]}.${parts[1]}.${parts[0]}"
    } catch (e: Exception) { "" }
}
