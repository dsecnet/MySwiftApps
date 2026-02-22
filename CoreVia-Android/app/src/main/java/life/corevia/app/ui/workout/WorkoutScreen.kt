package life.corevia.app.ui.workout

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaGradientProgressBar
import life.corevia.app.ui.theme.CoreViaSectionHeader
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import life.corevia.app.ui.theme.coreViaCard
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.DirectionsRun
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.Workout
import life.corevia.app.data.models.WorkoutUpdateRequest

/**
 * iOS WorkoutView.swift — Android 1-ə-1 port
 *
 * Bölmələr (iOS ilə eyni sıra):
 *  1. Header: title + subtitle
 *  2. Weekly Summary: 2x2 stat grid in card
 *  3. Daily Goal Progress: progress + calories/minutes
 *  4. Today's Workouts: WorkoutCard list
 *  5. Upcoming/Past Workouts: prefix(3)
 *  6. Empty State
 *  7. GPS Tracking Button (premium)
 *  8. Add Workout Button (gradient inline)
 *
 * Faza 2: Workout card tap → WorkoutDetailScreen
 *         Edit button → EditWorkoutSheet
 */
@Composable
fun WorkoutScreen(
    onNavigateToLiveTracking: () -> Unit,
    viewModel: WorkoutViewModel = viewModel()
) {
    val workouts by viewModel.workouts.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val showAddWorkout by viewModel.showAddWorkout.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val selectedWorkout by viewModel.selectedWorkout.collectAsState()

    // Edit sheet state
    var showEditSheet by remember { mutableStateOf(false) }
    var editingWorkout by remember { mutableStateOf<Workout?>(null) }

    // ── Detail Screen (selectedWorkout != null → show detail instead of list) ──
    selectedWorkout?.let { workout ->
        WorkoutDetailScreen(
            workout = workout,
            onBack = { viewModel.clearSelectedWorkout() },
            onToggleComplete = { workoutId ->
                viewModel.toggleComplete(workout)
            },
            onDelete = { workoutId ->
                viewModel.deleteWorkout(workoutId)
                viewModel.clearSelectedWorkout()
            },
            onEdit = {
                editingWorkout = workout
                showEditSheet = true
            }
        )

        // Edit sheet from detail screen
        if (showEditSheet && editingWorkout != null) {
            EditWorkoutSheet(
                workout = editingWorkout!!,
                onDismiss = {
                    showEditSheet = false
                    editingWorkout = null
                },
                onSave = { workoutId, request ->
                    viewModel.updateWorkout(workoutId, request)
                    showEditSheet = false
                    editingWorkout = null
                }
            )
        }
        return
    }

    // iOS: week summary hesablamaları
    val weeklyMinutes  = viewModel.weeklyMinutes
    val weeklyCalories = viewModel.weeklyCaloriesBurned
    val weekCount      = viewModel.weekWorkoutCount
    val todayWorkouts  = viewModel.todayWorkouts
    val completedCount = workouts.count { it.isCompleted }

    // iOS: todayProgress
    val todayCompleted = todayWorkouts.count { it.isCompleted }
    val todayTotal     = todayWorkouts.size
    val todayProgress  = if (todayTotal > 0) todayCompleted.toFloat() / todayTotal else 0f

    // iOS: today calories + minutes
    val todayCalories = todayWorkouts.sumOf { it.caloriesBurned ?: 0 }
    val todayMinutes  = todayWorkouts.sumOf { it.duration }

    // iOS: pending workouts not today (prefix 3)
    val pendingNotToday = workouts.filter { !it.isCompleted && !todayWorkouts.contains(it) }.take(3)

    val scrollState = rememberScrollState()

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.success) {
    Column(
        modifier = Modifier
            .fillMaxSize()
    ) {
        // ── Scrollable content ──────────────────────────────────────────────
        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(scrollState)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            // ── 1. Header (iOS: VStack alignment leading spacing 6) ─────────────
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(
                    text       = "Məşq İzləmə",
                    fontSize   = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.primaryText
                )
                Text(
                    text     = "Məşqlərinizi izləyin və inkişafınızı görün",
                    fontSize = 12.sp,
                    color    = AppTheme.Colors.secondaryText
                )
            }

            // ── Error message ────────────────────────────────────────────────────
            errorMessage?.let { msg ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppTheme.Colors.error.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text     = msg,
                        color    = AppTheme.Colors.error,
                        modifier = Modifier.weight(1f),
                        fontSize = 14.sp
                    )
                    Text(
                        text     = "✕",
                        color    = AppTheme.Colors.error,
                        modifier = Modifier.clickable { viewModel.clearError() }
                    )
                }
            }

            // ── 2. Weekly Summary (iOS: VStack in secondaryBackground, cornerRadius 16) ──
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .coreViaCard(cornerRadius = 16.dp)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(
                    text       = "Həftəlik Xülasə",
                    fontSize   = 17.sp,
                    fontWeight = FontWeight.SemiBold,
                    color      = AppTheme.Colors.primaryText
                )

                // iOS: Row 1 — workouts + completed
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    WorkoutSummaryStatCard(
                        modifier = Modifier.weight(1f),
                        value    = "$weekCount",
                        label    = "Məşqlər",
                        color    = AppTheme.Colors.accent
                    )
                    WorkoutSummaryStatCard(
                        modifier = Modifier.weight(1f),
                        value    = "$completedCount",
                        label    = "Tamamlandı",
                        color    = AppTheme.Colors.success
                    )
                }

                // iOS: Row 2 — minutes + calories
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    WorkoutSummaryStatCard(
                        modifier = Modifier.weight(1f),
                        value    = "$weeklyMinutes",
                        label    = "Dəqiqə",
                        color    = AppTheme.Colors.accent
                    )
                    WorkoutSummaryStatCard(
                        modifier = Modifier.weight(1f),
                        value    = "$weeklyCalories",
                        label    = "Kalori",
                        color    = Color(0xFFFF9500) // iOS: .orange
                    )
                }
            }

            // ── 3. Daily Goal Progress (iOS: VStack, secondaryBackground, cornerRadius 14) ──
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .coreViaCard()
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // iOS: HStack { title + Spacer + percentage }
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment     = Alignment.CenterVertically
                ) {
                    Text(
                        text       = "Günlük Hədəf",
                        fontSize   = 17.sp,
                        fontWeight = FontWeight.SemiBold,
                        color      = AppTheme.Colors.primaryText
                    )
                    Text(
                        text       = "${(todayProgress * 100).toInt()}%",
                        fontSize   = 17.sp,
                        fontWeight = FontWeight.SemiBold,
                        color      = AppTheme.Colors.accent
                    )
                }

                // Gradient progress bar
                CoreViaGradientProgressBar(
                    progress = todayProgress,
                    height = 8.dp
                )

                // iOS: HStack { flame+calories Spacer clock+minutes }
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalAlignment     = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector        = Icons.Outlined.LocalFireDepartment,
                            contentDescription = null,
                            modifier           = Modifier.size(12.dp),
                            tint               = AppTheme.Colors.accent
                        )
                        Text(
                            text     = "$todayCalories kcal",
                            fontSize = 12.sp,
                            color    = AppTheme.Colors.secondaryText
                        )
                    }
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalAlignment     = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector        = Icons.Outlined.Schedule,
                            contentDescription = null,
                            modifier           = Modifier.size(12.dp),
                            tint               = AppTheme.Colors.accent
                        )
                        Text(
                            text     = "$todayMinutes dəq",
                            fontSize = 12.sp,
                            color    = AppTheme.Colors.secondaryText
                        )
                    }
                }
            }

            // ── 4. Today's Workouts (iOS: VStack alignment leading spacing 12) ──
            if (todayWorkouts.isNotEmpty()) {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    CoreViaSectionHeader(title = "Bugünkü Məşqlər")
                    todayWorkouts.forEach { workout ->
                        WorkoutCardIos(
                            workout  = workout,
                            onToggle = { viewModel.toggleComplete(workout) },
                            onClick  = { viewModel.selectWorkout(workout) }
                        )
                    }
                }
            }

            // ── 5. Upcoming/Past Workouts (iOS: prefix 3, non-today pending) ────
            if (pendingNotToday.isNotEmpty()) {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    CoreViaSectionHeader(title = "Gələcək Məşqlər")
                    pendingNotToday.forEach { workout ->
                        WorkoutCardIos(
                            workout  = workout,
                            onToggle = { viewModel.toggleComplete(workout) },
                            onClick  = { viewModel.selectWorkout(workout) }
                        )
                    }
                }
            }

            // ── 6. Empty State ───────────────────────────────────────────────────
            if (workouts.isEmpty() && !isLoading) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 60.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Icon(
                        imageVector        = Icons.Outlined.FitnessCenter,
                        contentDescription = null,
                        modifier           = Modifier.size(60.dp),
                        tint               = AppTheme.Colors.tertiaryText
                    )
                    Text(
                        text       = "Hələ məşq yoxdur",
                        fontSize   = 17.sp,
                        fontWeight = FontWeight.SemiBold,
                        color      = AppTheme.Colors.secondaryText
                    )
                    Text(
                        text     = "İlk məşqinizi əlavə edin",
                        fontSize = 12.sp,
                        color    = AppTheme.Colors.tertiaryText
                    )
                }
            }

            // Loading
            if (isLoading && workouts.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 40.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = AppTheme.Colors.accent)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }

        // ── Fixed bottom buttons (always visible above nav bar) ─────────────
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppTheme.Colors.background)
                .padding(horizontal = 16.dp)
                .padding(bottom = 100.dp), // Tab bar üçün yer
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            // ── 7. GPS Tracking Button (iOS: premium green / locked gray) ────────
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(8.dp, RoundedCornerShape(14.dp), spotColor = AppTheme.Colors.success.copy(alpha = 0.3f))
                    .background(
                        brush = Brush.horizontalGradient(
                            colors = listOf(AppTheme.Colors.success, AppTheme.Colors.success.copy(alpha = 0.8f))
                        ),
                        shape = RoundedCornerShape(14.dp)
                    )
                    .clip(RoundedCornerShape(14.dp))
                    .clickable { onNavigateToLiveTracking() }
                    .padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment     = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector        = Icons.Outlined.LocationOn,
                        contentDescription = null,
                        tint               = Color.White
                    )
                    Text(
                        text       = "GPS ilə Qaçış/Gəzinti",
                        fontWeight = FontWeight.Bold,
                        color      = Color.White
                    )
                }
            }

            // ── 8. Add Workout Button (iOS: accent gradient, inline) ─────────────
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(8.dp, RoundedCornerShape(14.dp), spotColor = AppTheme.Colors.accent.copy(alpha = 0.3f))
                    .background(
                        brush = Brush.horizontalGradient(
                            colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.8f))
                        ),
                        shape = RoundedCornerShape(14.dp)
                    )
                    .clip(RoundedCornerShape(14.dp))
                    .clickable { viewModel.setShowAddWorkout(true) }
                    .padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment     = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector        = Icons.Outlined.AddCircle,
                        contentDescription = null,
                        tint               = Color.White
                    )
                    Text(
                        text       = "Yeni Məşq",
                        fontWeight = FontWeight.Bold,
                        color      = Color.White
                    )
                }
            }
        }
    }
    } // CoreViaAnimatedBackground

    // ─── Add Workout Bottom Sheet ────────────────────────────────────────────
    if (showAddWorkout) {
        AddWorkoutSheet(
            onDismiss = { viewModel.setShowAddWorkout(false) },
            onSave = { title, category, duration, calories, notes ->
                viewModel.addWorkout(title, category, duration, calories, notes)
            }
        )
    }
}

// ─── iOS: WeeklySummary Stat Card (VStack in cardBackground, cornerRadius 12) ──
@Composable
private fun WorkoutSummaryStatCard(
    modifier: Modifier = Modifier,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .coreViaCard(accentColor = color, cornerRadius = 12.dp, backgroundColor = AppTheme.Colors.cardBackground)
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(
            text       = value,
            fontSize   = 22.sp,
            fontWeight = FontWeight.Bold,
            color      = color
        )
        Text(
            text     = label,
            fontSize = 10.sp,
            color    = AppTheme.Colors.secondaryText
        )
    }
}

// ─── iOS: WorkoutCard ─────────────────────────────────────────────────────────
// HStack(spacing: 16) { circle icon + VStack(title, HStack(clock+duration, flame+calories)) + toggle }
// background: secondaryBackground, cornerRadius: 14
// border: success(0.3) when completed
@Composable
fun WorkoutCardIos(
    workout: Workout,
    onToggle: () -> Unit,
    onClick: (() -> Unit)? = null
) {
    // iOS: categoryColor based on workout.category
    val categoryColor = when (workout.category.lowercase()) {
        "strength"   -> AppTheme.Colors.accent
        "cardio"     -> AppTheme.Colors.accentDark
        "flexibility" -> AppTheme.Colors.accent
        "endurance"  -> AppTheme.Colors.accentDark
        else         -> AppTheme.Colors.accent
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .coreViaCard()
            .then(if (onClick != null) Modifier.clickable { onClick() } else Modifier)
            .then(
                if (workout.isCompleted) {
                    Modifier.border(
                        width = 1.dp,
                        color = AppTheme.Colors.success.copy(alpha = 0.3f),
                        shape = RoundedCornerShape(14.dp)
                    )
                } else Modifier
            )
            .padding(16.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // iOS: ZStack { Circle(50) + category icon }
        Box(
            modifier = Modifier
                .size(50.dp)
                .background(categoryColor.copy(alpha = 0.2f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = when (workout.category.lowercase()) {
                    "strength"   -> Icons.Outlined.FitnessCenter
                    "cardio"     -> Icons.AutoMirrored.Outlined.DirectionsRun
                    "flexibility" -> Icons.Outlined.SelfImprovement
                    "endurance"  -> Icons.Outlined.Speed
                    else         -> Icons.Outlined.FitnessCenter
                },
                contentDescription = null,
                modifier = Modifier.size(22.dp),
                tint     = categoryColor
            )
        }

        // iOS: VStack(alignment: .leading, spacing: 4) { title, HStack(clock+dur, flame+cal) }
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text       = workout.title,
                color      = AppTheme.Colors.primaryText,
                fontWeight = FontWeight.Bold,
                fontSize   = 15.sp
            )

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                // iOS: clock.fill + duration
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment     = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector        = Icons.Outlined.Schedule,
                        contentDescription = null,
                        modifier           = Modifier.size(10.dp),
                        tint               = AppTheme.Colors.secondaryText
                    )
                    Text(
                        text     = "${workout.duration} dəq",
                        fontSize = 12.sp,
                        color    = AppTheme.Colors.secondaryText
                    )
                }

                // iOS: flame.fill + calories (if present)
                workout.caloriesBurned?.let { cal ->
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalAlignment     = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector        = Icons.Outlined.LocalFireDepartment,
                            contentDescription = null,
                            modifier           = Modifier.size(10.dp),
                            tint               = AppTheme.Colors.accent
                        )
                        Text(
                            text     = "$cal kcal",
                            fontSize = 12.sp,
                            color    = AppTheme.Colors.accent
                        )
                    }
                }
            }
        }

        // iOS: Button { checkmark.circle.fill or circle }
        Icon(
            imageVector = if (workout.isCompleted) Icons.Outlined.CheckCircle else Icons.Outlined.RadioButtonUnchecked,
            contentDescription = "Tamamla",
            modifier = Modifier
                .size(28.dp)
                .clickable { onToggle() },
            tint = if (workout.isCompleted) AppTheme.Colors.success else AppTheme.Colors.tertiaryText
        )
    }
}
