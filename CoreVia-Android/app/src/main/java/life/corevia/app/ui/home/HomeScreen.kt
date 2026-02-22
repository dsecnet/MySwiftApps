package life.corevia.app.ui.home

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaIconBadge
import life.corevia.app.ui.theme.CoreViaGradientProgressBar
import life.corevia.app.ui.theme.CoreViaSectionHeader
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import life.corevia.app.ui.theme.coreViaCard
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.Feed
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.ui.workout.WorkoutViewModel

/**
 * iOS HomeView.swift — Android 1-ə-1 port
 * Pinterest-inspired visual enhancement applied
 *
 * Bölmələr (iOS ilə eyni sıra):
 *  1. Header: "Salam" + "Gün üçün hazır ol"
 *  2. StatCard x2: məşq dəqiqələri + kalori
 *  3. Daily Goal: GradientProgressBar + tamamlanan/ümumi
 *  4. Today's Workouts: CompactWorkoutCard (max 2, "Hamısı" link)
 *  5. Quick Actions: 2x3 grid
 *  6. Weekly Stats: 3 WeekStatItem
 */
@Composable
fun HomeScreen(
    userName: String = "",
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

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(horizontal = 20.dp)
    ) {
        Spacer(modifier = Modifier.height(56.dp))

        // ── 1. Header ───────────────────────────────────────────────────────────
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text       = if (userName.isNotEmpty()) "Salam, $userName" else "Salam",
                fontSize   = 28.sp,
                fontWeight = FontWeight.Bold,
                color      = AppTheme.Colors.primaryText
            )
            Icon(
                imageVector = Icons.Outlined.WavingHand,
                contentDescription = null,
                modifier = Modifier.size(26.dp),
                tint = AppTheme.Colors.accent
            )
        }
        Text(
            text     = "Gün üçün hazır ol",
            fontSize = 16.sp,
            color    = AppTheme.Colors.secondaryText
        )

        Spacer(modifier = Modifier.height(20.dp))

        // ── 2. StatCard x2 (iOS: HStack spacing 12) ────────────────────────────
        Row(
            modifier            = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            HomeStatCard(
                modifier = Modifier.weight(1f),
                icon     = Icons.Outlined.LocalFireDepartment,
                value    = "$weeklyMinutes dəq",
                label    = "Məşq"
            )
            HomeStatCard(
                modifier = Modifier.weight(1f),
                icon     = Icons.Outlined.Bolt,
                value    = "$weeklyCalories",
                label    = "Kalori"
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── 3. Daily Goal ────────────────────────────────────────────────────────
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .coreViaCard()
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
                    color      = AppTheme.Colors.primaryText
                )
                Text(
                    text       = "${(todayProgress * 100).toInt()}%",
                    fontSize   = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.accent
                )
            }
            Spacer(modifier = Modifier.height(10.dp))

            // Gradient progress bar
            CoreViaGradientProgressBar(
                progress = todayProgress,
                height = 8.dp
            )
            Spacer(modifier = Modifier.height(6.dp))

            // iOS: "\(completed)/\(total) tamamlandı"
            Text(
                text     = "$completedCount/$totalCount tamamlandı",
                fontSize = 12.sp,
                color    = AppTheme.Colors.secondaryText
            )
        }

        // ── 4. Today's Workouts ─────────────────────────────────────────────────
        if (todayWorkouts.isNotEmpty()) {
            Spacer(modifier = Modifier.height(16.dp))

            CoreViaSectionHeader(
                title = "Bu Günün Məşqləri",
                trailing = {
                    Text(
                        text     = "Hamısı",
                        fontSize = 13.sp,
                        color    = AppTheme.Colors.accent,
                        modifier = Modifier.clickable { onNavigateToWorkout() }
                    )
                }
            )

            Spacer(modifier = Modifier.height(8.dp))

            // iOS: ForEach todayWorkouts.prefix(2) { CompactWorkoutCard }
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                todayWorkouts.take(2).forEach { workout ->
                    HomeCompactWorkoutCard(workout = workout)
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── 5. Quick Actions (iOS: LazyVGrid 2 columns) ─────────────────────────
        CoreViaSectionHeader(
            title = "Sürətli Əməliyyatlar",
            subtitle = "Tez keçidlər"
        )
        Spacer(modifier = Modifier.height(10.dp))

        // iOS HomeView: 6 QuickActionButton — 2 sütunlu grid
        val quickActions = listOf(
            Triple(Icons.Outlined.Add,          "Məşq əlavə et",   onNavigateToWorkout),
            Triple(Icons.Outlined.Restaurant,   "Qida əlavə et",   onNavigateToFood),
            Triple(Icons.AutoMirrored.Outlined.Feed, "Sosial Axın",     onNavigateToSocial),
            Triple(Icons.Outlined.ShoppingCart,  "Mağaza",          onNavigateToMarketplace),
            Triple(Icons.Outlined.Videocam,     "Canlı Sessiyalar", onNavigateToLiveSessions),
            Triple(Icons.Outlined.BarChart,      "Statistika",       onNavigateToAnalytics)
        )

        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            quickActions.chunked(2).forEach { rowItems ->
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    rowItems.forEach { (icon, label, action) ->
                        HomeQuickActionButton(
                            modifier = Modifier.weight(1f),
                            icon     = icon,
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

        // ── 6. Weekly Stats (iOS: HStack WeekStatItem x3) ───────────────────────
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .coreViaCard()
                .padding(16.dp)
        ) {
            Text(
                text       = "Bu Həftə",
                fontSize   = 17.sp,
                fontWeight = FontWeight.Bold,
                color      = AppTheme.Colors.primaryText
            )
            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier              = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                WeekStatItem(icon = Icons.Outlined.FitnessCenter, value = "$weekCount",        label = "Məşq")
                WeekStatItem(icon = Icons.Outlined.CheckCircle,   value = "$completedCount",    label = "Tamamlandı")
                WeekStatItem(icon = Icons.Outlined.Timer,         value = "$weeklyMinutes",     label = "Dəqiqə")
            }
        }

        Spacer(modifier = Modifier.height(100.dp)) // CustomTabBar üçün yer
    }
    } // CoreViaAnimatedBackground
}

// ─── StatCard — Pinterest-inspired ──────────────────────────────────────────
@Composable
fun HomeStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String
) {
    Column(
        modifier = modifier
            .coreViaCard()
            .padding(16.dp)
    ) {
        CoreViaIconBadge(icon = icon, tintColor = AppTheme.Colors.accent, size = 36.dp, iconSize = 18.dp)
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text       = value,
            fontSize   = 22.sp,
            fontWeight = FontWeight.Bold,
            color      = AppTheme.Colors.primaryText
        )
        Text(
            text     = label,
            fontSize = 12.sp,
            color    = AppTheme.Colors.secondaryText
        )
    }
}

// ─── QuickActionButton — Pinterest-inspired card style ──────────────────────
@Composable
fun HomeQuickActionButton(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    label: String,
    onClick: () -> Unit
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .coreViaCard(cornerRadius = 12.dp)
            .clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 14.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        CoreViaIconBadge(icon = icon, tintColor = AppTheme.Colors.accent, size = 32.dp, iconSize = 16.dp)
        Text(
            text       = label,
            fontSize   = 13.sp,
            color      = AppTheme.Colors.primaryText,
            fontWeight = FontWeight.Medium,
            maxLines   = 1
        )
    }
}

// ─── CompactWorkoutCard — Pinterest-inspired ────────────────────────────────
@Composable
fun HomeCompactWorkoutCard(workout: life.corevia.app.data.models.Workout) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .coreViaCard(cornerRadius = 12.dp)
            .padding(16.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment     = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            CoreViaIconBadge(
                icon = Icons.Outlined.FitnessCenter,
                tintColor = AppTheme.Colors.accent,
                size = 40.dp,
                iconSize = 20.dp
            )
            Column {
                Text(
                    text       = workout.title,
                    color      = AppTheme.Colors.primaryText,
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
        Icon(
            imageVector = if (workout.isCompleted) Icons.Outlined.CheckCircle else Icons.Outlined.RadioButtonUnchecked,
            contentDescription = null,
            modifier = Modifier.size(24.dp),
            tint = if (workout.isCompleted) AppTheme.Colors.success else AppTheme.Colors.tertiaryText
        )
    }
}

// ─── WeekStatItem — Pinterest-inspired ──────────────────────────────────────
@Composable
fun WeekStatItem(
    icon: ImageVector,
    value: String,
    label: String
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        CoreViaIconBadge(icon = icon, tintColor = AppTheme.Colors.accent, size = 36.dp, iconSize = 18.dp)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text       = value,
            fontSize   = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color      = AppTheme.Colors.primaryText
        )
        Text(
            text     = label,
            fontSize = 11.sp,
            color    = AppTheme.Colors.secondaryText
        )
    }
}

// ─── Legacy StatCard / QuickActionButton / CompactWorkoutCard ───────────────
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
            .coreViaCard(accentColor = color, cornerRadius = 16.dp)
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
            .coreViaCard(cornerRadius = 12.dp)
            .padding(16.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column {
            Text(text = workout.title, color = AppTheme.Colors.primaryText, fontWeight = FontWeight.Medium, fontSize = 15.sp)
            Text(text = "${workout.duration} dəq", color = AppTheme.Colors.secondaryText, fontSize = 13.sp)
        }
        if (workout.isCompleted) {
            Icon(
                imageVector = Icons.Outlined.CheckCircle,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = AppTheme.Colors.success
            )
        }
    }
}
