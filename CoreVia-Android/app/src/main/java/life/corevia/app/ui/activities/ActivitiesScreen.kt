package life.corevia.app.ui.activities

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.DirectionsRun
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
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
import life.corevia.app.ui.theme.coreViaCard
import life.corevia.app.data.models.MealPlan
import life.corevia.app.data.models.PlanType
import life.corevia.app.data.models.TrainingPlan

/**
 * iOS ActivitiesView.swift — Android port
 *
 * Premium: Weekly stats + assigned plans
 * Non-premium: Weekly stats (blurred) + locked overlay with premium gate
 * GPS tracking bölmələri silindi — yalnız trainerin tapşırıqları göstərilir.
 */

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

    // Success snackbar
    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearSuccess()
        }
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize(),
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
                    text = "Müəlliminizin təyin etdiyi planlar",
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
                            icon = Icons.Outlined.LocationOn,
                            value = "0.0 km",
                            label = "Məsafə",
                            color = AppTheme.Colors.accent
                        )
                        ActivityStatCard(
                            modifier = Modifier.weight(1f),
                            icon = Icons.Outlined.Schedule,
                            value = "0 dəq",
                            label = "Müddət",
                            color = AppTheme.Colors.accent
                        )
                        ActivityStatCard(
                            modifier = Modifier.weight(1f),
                            icon = Icons.Outlined.LocalFireDepartment,
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
                                    imageVector = Icons.Outlined.Lock,
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
                                        imageVector = Icons.Outlined.AutoAwesome,
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
                            color = AppTheme.Colors.primaryText
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
                            color = AppTheme.Colors.primaryText
                        )
                    }
                    items(assignedMeals, key = { "m_${it.id}" }) { plan ->
                        AssignedMealPlanCard(
                            plan = plan,
                            onComplete = { viewModel.completeMealPlan(plan.id) }
                        )
                    }
                }

                // Empty state — premium amma hələ tapşırıq yoxdur
                if (assignedTraining.isEmpty() && assignedMeals.isEmpty() && !isLoading) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(32.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(
                                    imageVector = Icons.AutoMirrored.Outlined.DirectionsRun,
                                    contentDescription = null,
                                    modifier = Modifier.size(48.dp),
                                    tint = AppTheme.Colors.tertiaryText
                                )
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
    }
    } // CoreViaAnimatedBackground
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
// Assigned Plan Cards
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
                    Text(plan.title, color = AppTheme.Colors.primaryText, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
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
                    Text(plan.title, color = AppTheme.Colors.primaryText, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
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
