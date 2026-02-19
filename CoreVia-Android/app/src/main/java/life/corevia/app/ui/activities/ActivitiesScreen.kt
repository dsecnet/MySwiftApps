package life.corevia.app.ui.activities

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsRun
import androidx.compose.material.icons.automirrored.filled.DirectionsBike
import androidx.compose.material.icons.automirrored.filled.DirectionsWalk
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.MealPlan
import life.corevia.app.data.models.PlanType
import life.corevia.app.data.models.TrainingPlan

/**
 * iOS ActivitiesView.swift — Android 1-ə-1 port
 *
 * iOS-da bu ekran 2 halda görünür:
 *  1. Premium: GPS tracking + weekly stats + assigned plans + activity history + filter chips
 *  2. Non-premium: Weekly stats (blurred) + locked overlay with premium gate
 *
 * Android-da eyni strukturu tətbiq edirik.
 */

// ── Activity types (iOS: ActivityType enum) ─────────────────────────────────
enum class ActivityType(
    val value: String,
    val displayName: String,
    val icon: ImageVector,
    val color: Color
) {
    WALKING("walking", "Yürüyüş", Icons.AutoMirrored.Filled.DirectionsWalk, Color(0xFF4CAF50)),
    RUNNING("running", "Qaçış", Icons.AutoMirrored.Filled.DirectionsRun, Color(0xFFFF9800)),
    CYCLING("cycling", "Velosiped", Icons.AutoMirrored.Filled.DirectionsBike, Color(0xFF2196F3))
}

@Composable
fun ActivitiesScreen(
    viewModel: ActivitiesViewModel = viewModel(),
    isPremium: Boolean = false
) {
    val trainingPlans by viewModel.trainingPlans.collectAsState()
    val mealPlans by viewModel.mealPlans.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()

    val assignedTraining = viewModel.assignedTrainingPlans
    val assignedMeals = viewModel.assignedMealPlans

    var showPremiumSheet by remember { mutableStateOf(false) }
    var showStartActivitySheet by remember { mutableStateOf(false) }
    var selectedFilter by remember { mutableStateOf<ActivityType?>(null) }

    // ── GPS tracking state ──────────────────────────────────────────────────
    var isTracking by remember { mutableStateOf(false) }
    var activeType by remember { mutableStateOf(ActivityType.RUNNING) }
    var elapsedSeconds by remember { mutableIntStateOf(0) }

    // Success snackbar
    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearSuccess()
        }
    }

    // Timer for tracking
    LaunchedEffect(isTracking) {
        if (isTracking) {
            while (true) {
                kotlinx.coroutines.delay(1000)
                elapsedSeconds++
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .background(AppTheme.Colors.background),
            contentPadding = PaddingValues(horizontal = 20.dp, vertical = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ─── Header (iOS: headerSection) ──────────────────────────────────
            item {
                Spacer(modifier = Modifier.height(40.dp))
                Text(
                    text = "Hərəkətlər",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
                Text(
                    text = "GPS ilə aktivliklərinizi izləyin",
                    fontSize = 14.sp,
                    color = AppTheme.Colors.secondaryText,
                    modifier = Modifier.padding(top = 6.dp)
                )
            }

            // ─── Success message ──────────────────────────────────────────────
            if (successMessage != null) {
                item {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.success.copy(alpha = 0.15f))
                    ) {
                        Text(
                            text = successMessage ?: "",
                            modifier = Modifier.padding(16.dp),
                            color = AppTheme.Colors.success,
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 14.sp
                        )
                    }
                }
            }

            // ─── Weekly Stats (iOS: weeklyStatsSection) ───────────────────────
            item {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text(
                        text = "Bu həftə",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = AppTheme.Colors.primaryText
                    )

                    val statsModifier = if (!isPremium) Modifier.blur(3.dp) else Modifier
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .then(statsModifier),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        ActivityStatCard(
                            modifier = Modifier.weight(1f),
                            icon = Icons.Filled.LocationOn,
                            value = "0.0 km",
                            label = "Məsafə",
                            color = AppTheme.Colors.accent
                        )
                        ActivityStatCard(
                            modifier = Modifier.weight(1f),
                            icon = Icons.Filled.Schedule,
                            value = "0 dəq",
                            label = "Müddət",
                            color = AppTheme.Colors.accent
                        )
                        ActivityStatCard(
                            modifier = Modifier.weight(1f),
                            icon = Icons.Filled.LocalFireDepartment,
                            value = "0",
                            label = "Kalori",
                            color = AppTheme.Colors.accent
                        )
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // PREMIUM GATE (iOS: lockedActivitiesContent)
            // ═══════════════════════════════════════════════════════════════════
            if (!isPremium) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { showPremiumSheet = true },
                        contentAlignment = Alignment.Center
                    ) {
                        // Blurred placeholder cards
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .blur(2.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            repeat(3) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
                                        .padding(16.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(14.dp)
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .size(48.dp)
                                            .background(Color.Gray.copy(alpha = 0.1f), CircleShape)
                                    )
                                    Column {
                                        Box(
                                            modifier = Modifier
                                                .size(120.dp, 14.dp)
                                                .background(Color.Gray.copy(alpha = 0.15f), RoundedCornerShape(4.dp))
                                        )
                                        Spacer(modifier = Modifier.height(6.dp))
                                        Box(
                                            modifier = Modifier
                                                .size(180.dp, 12.dp)
                                                .background(Color.Gray.copy(alpha = 0.1f), RoundedCornerShape(4.dp))
                                        )
                                    }
                                }
                            }
                        }

                        // Lock overlay (iOS: locked content center)
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(14.dp),
                            modifier = Modifier.padding(vertical = 30.dp)
                        ) {
                            // Lock icon circle
                            Box(
                                modifier = Modifier
                                    .size(60.dp)
                                    .clip(CircleShape)
                                    .background(
                                        Brush.linearGradient(
                                            colors = listOf(AppTheme.Colors.accentDark, AppTheme.Colors.accent)
                                        )
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Filled.Lock,
                                    contentDescription = null,
                                    tint = Color.White,
                                    modifier = Modifier.size(26.dp)
                                )
                            }

                            Text(
                                text = "GPS izləmə",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold,
                                color = AppTheme.Colors.primaryText
                            )
                            Text(
                                text = "Məsafə, müddət və kaloriləri izləyin",
                                fontSize = 13.sp,
                                color = AppTheme.Colors.secondaryText,
                                textAlign = TextAlign.Center
                            )

                            // Premium button
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(14.dp))
                                    .background(
                                        Brush.horizontalGradient(
                                            colors = listOf(AppTheme.Colors.accentDark, AppTheme.Colors.accent)
                                        )
                                    )
                                    .shadow(10.dp, RoundedCornerShape(14.dp), spotColor = AppTheme.Colors.accentDark.copy(alpha = 0.4f))
                                    .padding(horizontal = 24.dp, vertical = 12.dp)
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Filled.AutoAwesome,
                                        contentDescription = null,
                                        tint = Color.White,
                                        modifier = Modifier.size(14.dp)
                                    )
                                    Text(
                                        text = "Premium-a keç",
                                        fontSize = 15.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        color = Color.White
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // PREMIUM CONTENT — only when premium
            // ═══════════════════════════════════════════════════════════════════
            if (isPremium) {
                // ─── Assigned Plans (iOS: assignedPlansSection) ────────────────
                if (assignedTraining.isNotEmpty() || assignedMeals.isNotEmpty()) {
                    item {
                        Text(
                            text = "Tapşırıqlar",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = AppTheme.Colors.primaryText
                        )
                    }
                }

                if (assignedTraining.isNotEmpty()) {
                    item {
                        Text(
                            text = "📋 Məşq Planları",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = Color.White
                        )
                    }
                    items(assignedTraining, key = { "t_${it.id}" }) { plan ->
                        AssignedTrainingPlanCard(
                            plan = plan,
                            onComplete = { viewModel.completeTrainingPlan(plan.id) }
                        )
                    }
                }

                if (assignedMeals.isNotEmpty()) {
                    item {
                        Text(
                            text = "🍽️ Qida Planları",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = Color.White
                        )
                    }
                    items(assignedMeals, key = { "m_${it.id}" }) { plan ->
                        AssignedMealPlanCard(
                            plan = plan,
                            onComplete = { viewModel.completeMealPlan(plan.id) }
                        )
                    }
                }

                // ─── Active Tracking (iOS: activeTrackingSection) ─────────────
                if (isTracking) {
                    item {
                        ActiveTrackingCard(
                            activeType = activeType,
                            elapsedSeconds = elapsedSeconds,
                            onStop = {
                                isTracking = false
                                elapsedSeconds = 0
                            }
                        )
                    }
                }

                // ─── Filter chips (iOS: filterSection) ────────────────────────
                item {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text(
                            text = "Tarixçə",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = AppTheme.Colors.primaryText
                        )
                        Row(
                            modifier = Modifier.horizontalScroll(rememberScrollState()),
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            // All filter
                            FilterChipItem(
                                title = "Hamısı",
                                isSelected = selectedFilter == null,
                                color = AppTheme.Colors.accent,
                                onClick = { selectedFilter = null }
                            )
                            ActivityType.entries.forEach { type ->
                                FilterChipItem(
                                    title = type.displayName,
                                    isSelected = selectedFilter == type,
                                    color = type.color,
                                    onClick = { selectedFilter = type }
                                )
                            }
                        }
                    }
                }

                // ─── Empty state for activity list ────────────────────────────
                item {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 40.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.DirectionsWalk,
                            contentDescription = null,
                            tint = AppTheme.Colors.secondaryText,
                            modifier = Modifier.size(40.dp)
                        )
                        Text(
                            text = "Aktivlik tapılmadı",
                            fontSize = 15.sp,
                            color = AppTheme.Colors.secondaryText
                        )
                        Text(
                            text = "Yeni aktivlik başlatmaq üçün + düyməsinə basın",
                            fontSize = 13.sp,
                            color = AppTheme.Colors.secondaryText.copy(alpha = 0.7f)
                        )
                    }
                }
            }

            // ─── Non-premium assigned plans (still show) ──────────────────────
            if (!isPremium) {
                if (assignedTraining.isNotEmpty()) {
                    item {
                        Text(
                            text = "📋 Məşq Planları",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = Color.White
                        )
                    }
                    items(assignedTraining, key = { "t_${it.id}" }) { plan ->
                        AssignedTrainingPlanCard(
                            plan = plan,
                            onComplete = { viewModel.completeTrainingPlan(plan.id) }
                        )
                    }
                }

                if (assignedMeals.isNotEmpty()) {
                    item {
                        Text(
                            text = "🍽️ Qida Planları",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = Color.White
                        )
                    }
                    items(assignedMeals, key = { "m_${it.id}" }) { plan ->
                        AssignedMealPlanCard(
                            plan = plan,
                            onComplete = { viewModel.completeMealPlan(plan.id) }
                        )
                    }
                }

                // Empty state
                if (assignedTraining.isEmpty() && assignedMeals.isEmpty() && !isLoading) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(32.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(text = "🏃", fontSize = 48.sp)
                                Spacer(modifier = Modifier.height(12.dp))
                                Text(
                                    text = "Hələ tapşırıq yoxdur",
                                    color = AppTheme.Colors.secondaryText,
                                    fontSize = 16.sp
                                )
                                Text(
                                    text = "Müəllim sizə plan təyin etdikdə burada görünəcək",
                                    color = AppTheme.Colors.tertiaryText,
                                    fontSize = 13.sp
                                )
                            }
                        }
                    }
                }
            }

            // ─── Loading ──────────────────────────────────────────────────────
            if (isLoading && trainingPlans.isEmpty() && mealPlans.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
            }

            item { Spacer(modifier = Modifier.height(80.dp)) }
        }

        // ─── FAB: Start Activity (iOS: play.fill circle button) ──────────────
        if (isPremium && !isTracking) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = 20.dp, bottom = 20.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(60.dp)
                        .shadow(12.dp, CircleShape, spotColor = AppTheme.Colors.accent.copy(alpha = 0.4f))
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.7f))
                            )
                        )
                        .clickable { showStartActivitySheet = true },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.PlayArrow,
                        contentDescription = "Başla",
                        tint = Color.White,
                        modifier = Modifier.size(28.dp)
                    )
                }
            }
        }

        // ─── Start Activity Sheet ────────────────────────────────────────────
        if (showStartActivitySheet) {
            StartActivitySheet(
                onDismiss = { showStartActivitySheet = false },
                onStart = { type ->
                    activeType = type
                    isTracking = true
                    elapsedSeconds = 0
                    showStartActivitySheet = false
                }
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// iOS: ActiveTrackingSection — live tracking indicator card (map is in LiveTrackingScreen)
// ═══════════════════════════════════════════════════════════════════════════════
@Composable
private fun ActiveTrackingCard(
    activeType: ActivityType,
    elapsedSeconds: Int,
    onStop: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .border(2.dp, activeType.color.copy(alpha = 0.5f), RoundedCornerShape(16.dp))
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Activity type + live indicator
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .background(activeType.color.copy(alpha = 0.2f), CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = activeType.icon,
                            contentDescription = null,
                            tint = activeType.color,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Text(
                        text = activeType.displayName,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = AppTheme.Colors.primaryText
                    )
                }

                // Live indicator
                Box(
                    modifier = Modifier
                        .background(Color.Red, RoundedCornerShape(20.dp))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .background(Color.White, CircleShape)
                        )
                        Text("CANLI", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }
            }

            // Stats: Time | Distance | Pace
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                TrackingStat(formatElapsedTime(elapsedSeconds), "Vaxt")
                TrackingStat("0.00", "km")
                TrackingStat("--:--", "Temp")
            }

            // Stop button
            Button(
                onClick = onStop,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = activeType.color)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Icon(Icons.Filled.Stop, null, tint = Color.White)
                    Text("Dayandır", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
    }
}

@Composable
private fun TrackingStat(value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// iOS: StartActivitySheet — choose activity type
// ═══════════════════════════════════════════════════════════════════════════════
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun StartActivitySheet(
    onDismiss: () -> Unit,
    onStart: (ActivityType) -> Unit
) {
    var selectedType by remember { mutableStateOf(ActivityType.RUNNING) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppTheme.Colors.background,
        dragHandle = {
            Box(
                modifier = Modifier
                    .padding(vertical = 12.dp)
                    .size(width = 40.dp, height = 5.dp)
                    .background(AppTheme.Colors.secondaryText.copy(alpha = 0.3f), RoundedCornerShape(3.dp))
            )
        }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Aktivlik başlat",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )

            // Activity type selector
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                ActivityType.entries.forEach { type ->
                    val isSelected = selectedType == type
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(14.dp))
                            .background(
                                if (isSelected) type.color.copy(alpha = 0.08f) else Color.Transparent
                            )
                            .border(
                                width = if (isSelected) 2.dp else 0.dp,
                                color = if (isSelected) type.color else Color.Transparent,
                                shape = RoundedCornerShape(14.dp)
                            )
                            .clickable { selectedType = type }
                            .padding(vertical = 12.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(64.dp)
                                .background(
                                    if (isSelected) type.color.copy(alpha = 0.2f)
                                    else AppTheme.Colors.secondaryBackground,
                                    CircleShape
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = type.icon,
                                contentDescription = null,
                                tint = if (isSelected) type.color else AppTheme.Colors.secondaryText,
                                modifier = Modifier.size(28.dp)
                            )
                        }
                        Text(
                            text = type.displayName,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = if (isSelected) AppTheme.Colors.primaryText else AppTheme.Colors.secondaryText
                        )
                    }
                }
            }

            // Start button
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(
                        Brush.horizontalGradient(
                            colors = listOf(selectedType.color, selectedType.color.copy(alpha = 0.7f))
                        )
                    )
                    .shadow(10.dp, RoundedCornerShape(16.dp), spotColor = selectedType.color.copy(alpha = 0.4f))
                    .clickable { onStart(selectedType) }
                    .padding(vertical = 16.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Icon(Icons.Filled.PlayArrow, null, tint = Color.White, modifier = Modifier.size(18.dp))
                    Text("Başla", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// iOS: ActivityStatCard
// ═══════════════════════════════════════════════════════════════════════════════
@Composable
private fun ActivityStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
            .padding(vertical = 14.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = color,
            modifier = Modifier.size(18.dp)
        )
        Text(
            text = value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            maxLines = 1
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// iOS: FilterChip
// ═══════════════════════════════════════════════════════════════════════════════
@Composable
private fun FilterChipItem(
    title: String,
    isSelected: Boolean,
    color: Color,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(if (isSelected) color else AppTheme.Colors.secondaryBackground)
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Text(
            text = title,
            fontSize = 14.sp,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
            color = if (isSelected) Color.White else AppTheme.Colors.secondaryText
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════════
private fun formatElapsedTime(seconds: Int): String {
    val hrs = seconds / 3600
    val mins = (seconds % 3600) / 60
    val secs = seconds % 60
    return if (hrs > 0) {
        String.format("%d:%02d:%02d", hrs, mins, secs)
    } else {
        String.format("%02d:%02d", mins, secs)
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Assigned Plan Cards (same as before, kept for compatibility)
// ═══════════════════════════════════════════════════════════════════════════════
@Composable
fun AssignedTrainingPlanCard(
    plan: TrainingPlan,
    onComplete: () -> Unit
) {
    val planTypeLabel = when (plan.planType) {
        PlanType.WEIGHT_LOSS.value -> "⬇️ Çəki itkisi"
        PlanType.WEIGHT_GAIN.value -> "⬆️ Çəki artımı"
        PlanType.STRENGTH_TRAINING.value -> "💪 Güc"
        else -> plan.planType
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (plan.isCompleted)
                AppTheme.Colors.success.copy(alpha = 0.1f)
            else
                AppTheme.Colors.secondaryBackground
        )
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(plan.title, color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
                    Text(planTypeLabel, color = AppTheme.Colors.warning, fontSize = 13.sp)
                    Text("${plan.workouts.size} məşq", color = AppTheme.Colors.secondaryText, fontSize = 12.sp)
                }
                if (plan.isCompleted) {
                    Text("✅", fontSize = 24.sp)
                }
            }

            if (plan.workouts.isNotEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                plan.workouts.forEach { workout ->
                    Text(
                        text = "• ${workout.name} — ${workout.sets}x${workout.reps}",
                        color = AppTheme.Colors.primaryText.copy(alpha = 0.7f),
                        fontSize = 13.sp,
                        modifier = Modifier.padding(vertical = 2.dp)
                    )
                }
            }

            plan.notes?.let {
                Spacer(modifier = Modifier.height(4.dp))
                Text("📝 $it", color = AppTheme.Colors.secondaryText, fontSize = 12.sp)
            }

            if (!plan.isCompleted) {
                Spacer(modifier = Modifier.height(12.dp))
                Button(
                    onClick = onComplete,
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.success),
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Text("✅ İcra etdim", fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}

@Composable
fun AssignedMealPlanCard(
    plan: MealPlan,
    onComplete: () -> Unit
) {
    val planTypeLabel = when (plan.planType) {
        PlanType.WEIGHT_LOSS.value -> "⬇️ Çəki itkisi"
        PlanType.WEIGHT_GAIN.value -> "⬆️ Çəki artımı"
        PlanType.STRENGTH_TRAINING.value -> "💪 Güc"
        else -> plan.planType
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (plan.isCompleted)
                AppTheme.Colors.success.copy(alpha = 0.1f)
            else
                AppTheme.Colors.secondaryBackground
        )
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(plan.title, color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
                    Text(planTypeLabel, color = AppTheme.Colors.success, fontSize = 13.sp)
                    Text(
                        "🔥 ${plan.dailyCalorieTarget} kal/gün • ${plan.items.size} yemək",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 12.sp
                    )
                }
                if (plan.isCompleted) {
                    Text("✅", fontSize = 24.sp)
                }
            }

            if (plan.items.isNotEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                plan.items.forEach { item ->
                    Text(
                        text = "• ${item.name} — ${item.calories} kal",
                        color = AppTheme.Colors.primaryText.copy(alpha = 0.7f),
                        fontSize = 13.sp,
                        modifier = Modifier.padding(vertical = 2.dp)
                    )
                }
            }

            plan.notes?.let {
                Spacer(modifier = Modifier.height(4.dp))
                Text("📝 $it", color = AppTheme.Colors.secondaryText, fontSize = 12.sp)
            }

            if (!plan.isCompleted) {
                Spacer(modifier = Modifier.height(12.dp))
                Button(
                    onClick = onComplete,
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.success),
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Text("✅ İcra etdim", fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}
