package life.corevia.app.ui.home

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.ui.workout.WorkoutViewModel

/**
 * iOS HomeView.swift — Android 1-ə-1 port
 *
 * Bölmələr (iOS ilə eyni sıra):
 *  1. Header: "Salam 👋" + "Gün üçün hazır ol"
 *  2. StatCard x2: məşq dəqiqələri + kalori
 *  3. Daily Goal: ProgressBar + tamamlanan/ümumi
 *  4. Today's Workouts: CompactWorkoutCard (max 2, "Hamısı" link)
 *  5. Quick Actions: 2x3 grid
 *  6. Weekly Stats: 3 WeekStatItem
 */
@Composable
fun HomeScreen(
    onNavigateToWorkout: () -> Unit,
    onNavigateToFood: () -> Unit,
    onNavigateToTrainingPlan: () -> Unit,
    onNavigateToLiveTracking: () -> Unit,
    onNavigateToProfile: () -> Unit = {},
    onNavigateToActivities: () -> Unit = {},
    // iOS HomeView Quick Actions → feature screens
    onNavigateToSocial: () -> Unit = {},
    onNavigateToMarketplace: () -> Unit = {},
    onNavigateToLiveSessions: () -> Unit = {},
    onNavigateToAnalytics: () -> Unit = {},
    workoutViewModel: WorkoutViewModel = viewModel()
) {
    val workouts by workoutViewModel.workouts.collectAsState()
    val isLoading by workoutViewModel.isLoading.collectAsState()
    val scrollState = rememberScrollState()

    val weeklyMinutes  = workoutViewModel.weeklyMinutes
    val weeklyCalories = workoutViewModel.weeklyCaloriesBurned
    val weekCount      = workoutViewModel.weekWorkoutCount
    val todayWorkouts  = workoutViewModel.todayWorkouts

    // iOS: todayProgress = completed / total
    val completedCount = todayWorkouts.count { it.isCompleted }
    val totalCount     = todayWorkouts.size
    val todayProgress  = if (totalCount > 0) completedCount.toFloat() / totalCount else 0f

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
            .verticalScroll(scrollState)
            .padding(horizontal = 20.dp)
    ) {
        Spacer(modifier = Modifier.height(56.dp))

        // ── 1. Header (iOS: VStack alignment leading) ─────────────────────────
        Text(
            text       = "Salam 👋",
            fontSize   = 28.sp,
            fontWeight = FontWeight.Bold,
            color      = Color.White
        )
        Text(
            text     = "Gün üçün hazır ol",
            fontSize = 16.sp,
            color    = AppTheme.Colors.secondaryText
        )

        Spacer(modifier = Modifier.height(20.dp))

        // ── 2. StatCard x2 (iOS: HStack spacing 12) ──────────────────────────
        Row(
            modifier            = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            HomeStatCard(
                modifier = Modifier.weight(1f),
                icon     = "🔥",
                value    = "$weeklyMinutes dəq",
                label    = "Məşq"
            )
            HomeStatCard(
                modifier = Modifier.weight(1f),
                icon     = "⚡",
                value    = "$weeklyCalories",
                label    = "Kalori"
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── 3. Daily Goal (iOS: VStack padding secondarySystemBackground) ─────
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
                .padding(16.dp)
        ) {
            Row(
                modifier              = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.CenterVertically
            ) {
                Text(
                    text       = "Günlük Hədəf",
                    fontSize   = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color      = Color.White
                )
                Text(
                    text       = "${(todayProgress * 100).toInt()}%",
                    fontSize   = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.accent
                )
            }
            Spacer(modifier = Modifier.height(10.dp))

            // iOS: ProgressView(value: todayProgress).tint(accent)
            LinearProgressIndicator(
                progress          = { todayProgress },
                modifier          = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .clip(RoundedCornerShape(3.dp)),
                color             = AppTheme.Colors.accent,
                trackColor        = AppTheme.Colors.accent.copy(alpha = 0.2f)
            )
            Spacer(modifier = Modifier.height(6.dp))

            // iOS: "\(completed)/\(total) tamamlandı"
            Text(
                text     = "$completedCount/$totalCount tamamlandı",
                fontSize = 12.sp,
                color    = AppTheme.Colors.secondaryText
            )
        }

        // ── 4. Today's Workouts ───────────────────────────────────────────────
        if (todayWorkouts.isNotEmpty()) {
            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier              = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.CenterVertically
            ) {
                Text(
                    text       = "Bu Günün Məşqləri",
                    fontSize   = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color      = Color.White
                )
                // iOS: NavigationLink → WorkoutView
                Text(
                    text     = "Hamısı",
                    fontSize = 13.sp,
                    color    = AppTheme.Colors.accent,
                    modifier = Modifier.clickable { onNavigateToWorkout() }
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // iOS: ForEach todayWorkouts.prefix(2) { CompactWorkoutCard }
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                todayWorkouts.take(2).forEach { workout ->
                    HomeCompactWorkoutCard(workout = workout)
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── 5. Quick Actions (iOS: LazyVGrid 2 columns) ───────────────────────
        Text(
            text       = "Sürətli Əməliyyatlar",
            fontSize   = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color      = Color.White
        )
        Spacer(modifier = Modifier.height(10.dp))

        // iOS HomeView: 6 QuickActionButton — 2 sütunlu grid
        // iOS kimi: Add Workout, Add Food, Social Feed, Marketplace, Live Sessions, Statistics
        val quickActions = listOf(
            Triple("➕", "Məşq əlavə et",   onNavigateToWorkout),
            Triple("🍴", "Qida əlavə et",   onNavigateToFood),
            Triple("📱", "Sosial Axın",     onNavigateToSocial),
            Triple("🛒", "Mağaza",          onNavigateToMarketplace),
            Triple("📹", "Canlı Sessiyalar", onNavigateToLiveSessions),
            Triple("📊", "Statistika",       onNavigateToAnalytics)
        )

        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            quickActions.chunked(2).forEach { rowItems ->
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    rowItems.forEach { (emoji, label, action) ->
                        HomeQuickActionButton(
                            modifier = Modifier.weight(1f),
                            emoji    = emoji,
                            label    = label,
                            onClick  = action
                        )
                    }
                    // Əgər tək element varsa, boş yer doldur
                    if (rowItems.size == 1) {
                        Spacer(modifier = Modifier.weight(1f))
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── 6. Weekly Stats (iOS: HStack WeekStatItem x3) ─────────────────────
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
                .padding(16.dp)
        ) {
            Text(
                text       = "Bu Həftə",
                fontSize   = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color      = Color.White
            )
            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier              = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                WeekStatItem(icon = "🏋️", value = "$weekCount",        label = "Məşq")
                WeekStatItem(icon = "✅", value = "$completedCount",    label = "Tamamlandı")
                WeekStatItem(icon = "⏱️", value = "$weeklyMinutes",     label = "Dəqiqə")
            }
        }

        Spacer(modifier = Modifier.height(100.dp)) // CustomTabBar üçün yer
    }
}

// ─── iOS: StatCard ─────────────────────────────────────────────────────────────
@Composable
fun HomeStatCard(
    modifier: Modifier = Modifier,
    icon: String,
    value: String,
    label: String
) {
    Column(
        modifier = modifier
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
            .padding(16.dp)
    ) {
        Text(text = icon, fontSize = 22.sp)
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text       = value,
            fontSize   = 20.sp,
            fontWeight = FontWeight.Bold,
            color      = Color.White
        )
        Text(
            text     = label,
            fontSize = 12.sp,
            color    = AppTheme.Colors.secondaryText
        )
    }
}

// ─── iOS: QuickActionButton ────────────────────────────────────────────────────
@Composable
fun HomeQuickActionButton(
    modifier: Modifier = Modifier,
    emoji: String,
    label: String,
    onClick: () -> Unit
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(AppTheme.Colors.accent.copy(alpha = 0.85f))
            .clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 14.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(text = emoji, fontSize = 18.sp)
        Text(
            text       = label,
            fontSize   = 13.sp,
            color      = Color.White,
            fontWeight = FontWeight.Medium,
            maxLines   = 1
        )
    }
}

// ─── iOS: CompactWorkoutCard ───────────────────────────────────────────────────
@Composable
fun HomeCompactWorkoutCard(workout: life.corevia.app.data.models.Workout) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
            .padding(16.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment     = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // iOS: Image(systemName: workout.category.icon).foregroundColor(accent)
            Text(text = "💪", fontSize = 20.sp)
            Column {
                Text(
                    text       = workout.title,
                    color      = Color.White,
                    fontWeight = FontWeight.SemiBold,
                    fontSize   = 15.sp
                )
                Text(
                    text     = "${workout.duration} dəq",
                    color    = AppTheme.Colors.secondaryText,
                    fontSize = 12.sp
                )
            }
        }
        // iOS: workout.isCompleted ? checkmark.circle.fill : circle
        Text(
            text = if (workout.isCompleted) "✅" else "⭕",
            fontSize = 20.sp
        )
    }
}

// ─── iOS: WeekStatItem ─────────────────────────────────────────────────────────
@Composable
fun WeekStatItem(
    icon: String,
    value: String,
    label: String
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = icon, fontSize = 22.sp)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text       = value,
            fontSize   = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color      = Color.White
        )
        Text(
            text     = label,
            fontSize = 11.sp,
            color    = AppTheme.Colors.secondaryText
        )
    }
}

// ─── Legacy StatCard / QuickActionButton / CompactWorkoutCard ─────────────────
// Köhnə kod uyğunluğu üçün — silinmir
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
        Text(text = value, fontSize = 22.sp, fontWeight = FontWeight.Bold, color = color)
        Text(text = label, fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
    }
}

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
            text      = label,
            fontSize  = 11.sp,
            color     = color,
            fontWeight = FontWeight.Medium,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
fun CompactWorkoutCard(workout: life.corevia.app.data.models.Workout) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
            .padding(16.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column {
            Text(text = workout.title, color = Color.White, fontWeight = FontWeight.Medium, fontSize = 15.sp)
            Text(text = "${workout.duration} dəq", color = AppTheme.Colors.secondaryText, fontSize = 13.sp)
        }
        if (workout.isCompleted) Text(text = "✅", fontSize = 18.sp)
    }
}
