package life.corevia.app.ui.home

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.ui.workout.WorkoutViewModel

/**
 * iOS HomeView.swift-in Android ekvivalenti.
 *
 * Yalnız ViewModel-dən oxuyur. UI dəyişsə yalnız bu fayl dəyişir.
 * WorkoutViewModel-i parametr kimi alır — həm HomeScreen, həm WorkoutScreen paylaşır.
 */
@Composable
fun HomeScreen(
    onNavigateToWorkout: () -> Unit,
    onNavigateToFood: () -> Unit,
    onNavigateToTrainingPlan: () -> Unit,
    onNavigateToLiveTracking: () -> Unit,
    workoutViewModel: WorkoutViewModel = viewModel()
) {
    val workouts by workoutViewModel.workouts.collectAsState()
    val isLoading by workoutViewModel.isLoading.collectAsState()
    val scrollState = rememberScrollState()

    // Hesablamalar (iOS HomeView-dəki computed props)
    val weeklyMinutes = workoutViewModel.weeklyMinutes
    val weeklyCalories = workoutViewModel.weeklyCaloriesBurned
    val weekCount = workoutViewModel.weekWorkoutCount
    val todayWorkouts = workoutViewModel.todayWorkouts

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
            .verticalScroll(scrollState)
    ) {
        // ─── Header ───────────────────────────────────────────────────────────
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(top = 56.dp, bottom = 8.dp)
        ) {
            Text(
                text = "Salam 👋",
                fontSize = 14.sp,
                color = AppTheme.Colors.secondaryText
            )
            Text(
                text = "CoreVia",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }

        // ─── Həftəlik statistika kartları ─────────────────────────────────────
        // iOS: WeekStatItem — horizontal scroll row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            StatCard(
                modifier = Modifier.weight(1f),
                value = "$weekCount",
                label = "Məşq",
                color = AppTheme.Colors.accent
            )
            StatCard(
                modifier = Modifier.weight(1f),
                value = "$weeklyMinutes",
                label = "Dəqiqə",
                color = AppTheme.Colors.success
            )
            StatCard(
                modifier = Modifier.weight(1f),
                value = "$weeklyCalories",
                label = "Kalori",
                color = AppTheme.Colors.error
            )
        }

        // ─── Sürətli əməliyyatlar ─────────────────────────────────────────────
        // iOS: QuickActionButton row
        Text(
            text = "Sürətli Əməliyyatlar",
            fontSize = 18.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color.White,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 8.dp)
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            QuickActionButton(
                modifier = Modifier.weight(1f),
                emoji = "🏋️",
                label = "Məşq\nƏlavə Et",
                color = AppTheme.Colors.accent,
                onClick = onNavigateToWorkout
            )
            QuickActionButton(
                modifier = Modifier.weight(1f),
                emoji = "🍎",
                label = "Qida\nƏlavə Et",
                color = AppTheme.Colors.success,
                onClick = onNavigateToFood
            )
            QuickActionButton(
                modifier = Modifier.weight(1f),
                emoji = "📍",
                label = "GPS\nMəşq",
                color = AppTheme.Colors.error,
                onClick = onNavigateToLiveTracking
            )
            QuickActionButton(
                modifier = Modifier.weight(1f),
                emoji = "📋",
                label = "Plan",
                color = AppTheme.Colors.warning,
                onClick = onNavigateToTrainingPlan
            )
        }

        // ─── Bu günün məşqləri ────────────────────────────────────────────────
        // iOS: CompactWorkoutCard list
        Spacer(modifier = Modifier.height(20.dp))
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Bu Günün Məşqləri",
                fontSize = 18.sp,
                fontWeight = FontWeight.SemiBold,
                color = Color.White
            )
            TextButton(onClick = onNavigateToWorkout) {
                Text(text = "Hamısı", color = AppTheme.Colors.accent, fontSize = 14.sp)
            }
        }

        if (isLoading && workouts.isEmpty()) {
            CircularProgressIndicator(
                modifier = Modifier
                    .padding(32.dp)
                    .align(Alignment.CenterHorizontally),
                color = AppTheme.Colors.accent
            )
        } else if (todayWorkouts.isEmpty()) {
            // iOS: EmptyStateCard
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 8.dp)
                    .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(16.dp))
                    .padding(32.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(text = "🏃", fontSize = 32.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "Bu gün məşq yoxdur",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 14.sp
                    )
                }
            }
        } else {
            Column(
                modifier = Modifier.padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                todayWorkouts.take(3).forEach { workout ->
                    CompactWorkoutCard(workout = workout)
                }
            }
        }

        Spacer(modifier = Modifier.height(100.dp)) // bottom nav üçün boşluq
    }
}

// ─── Reusable Components ──────────────────────────────────────────────────────

// iOS: StatCard
@Composable
fun StatCard(
    modifier: Modifier = Modifier,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(16.dp))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = value,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}

// iOS: QuickActionButton
@Composable
fun QuickActionButton(
    modifier: Modifier = Modifier,
    emoji: String,
    label: String,
    color: Color,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(color.copy(alpha = 0.15f))
            .clickable(onClick = onClick)
            .padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(text = emoji, fontSize = 24.sp)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            fontSize = 11.sp,
            color = color,
            fontWeight = FontWeight.Medium,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
    }
}

// iOS: CompactWorkoutCard
@Composable
fun CompactWorkoutCard(workout: life.corevia.app.data.models.Workout) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column {
            Text(
                text = workout.title,
                color = Color.White,
                fontWeight = FontWeight.Medium,
                fontSize = 15.sp
            )
            Text(
                text = "${workout.duration} dəq · ${workout.category}",
                color = AppTheme.Colors.secondaryText,
                fontSize = 13.sp
            )
        }
        if (workout.isCompleted) {
            Text(text = "✅", fontSize = 18.sp)
        }
    }
}
