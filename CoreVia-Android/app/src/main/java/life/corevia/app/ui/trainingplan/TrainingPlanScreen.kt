package life.corevia.app.ui.trainingplan

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.PlanType
import life.corevia.app.data.models.TrainingPlan

/**
 * iOS TrainingPlanView.swift-in Android ekvivalenti.
 *
 * Filter, list, plan detail — hamısı ViewModel-dən alır.
 * UI dəyişsə yalnız bu fayl dəyişir.
 */
@Composable
fun TrainingPlanScreen(
    viewModel: TrainingPlanViewModel = viewModel()
) {
    val plans by viewModel.plans.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val selectedFilter by viewModel.selectedFilter.collectAsState()
    val filteredPlans = viewModel.filteredPlans

    var expandedPlanId by remember { mutableStateOf<String?>(null) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        // ─── Başlıq ───────────────────────────────────────────────────────────
        Text(
            text = "Məşq Planları",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp)
        )

        // ─── Filter chips ─────────────────────────────────────────────────────
        // iOS: planType filter buttons
        LazyRow(
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.padding(bottom = 12.dp)
        ) {
            item {
                FilterChip(
                    selected = selectedFilter == null,
                    onClick = { viewModel.setFilter(null) },
                    label = { Text("Hamısı") },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = AppTheme.Colors.warning,
                        selectedLabelColor = Color.Black,
                        containerColor = AppTheme.Colors.secondaryBackground,
                        labelColor = AppTheme.Colors.secondaryText
                    )
                )
            }
            items(PlanType.entries) { planType ->
                FilterChip(
                    selected = selectedFilter == planType.value,
                    onClick = { viewModel.setFilter(planType.value) },
                    label = {
                        Text(when (planType) {
                            PlanType.WEIGHT_LOSS      -> "Çəki itkisi"
                            PlanType.WEIGHT_GAIN      -> "Çəki artımı"
                            PlanType.STRENGTH_TRAINING -> "Güc"
                        })
                    },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = AppTheme.Colors.warning,
                        selectedLabelColor = Color.Black,
                        containerColor = AppTheme.Colors.secondaryBackground,
                        labelColor = AppTheme.Colors.secondaryText
                    )
                )
            }
        }

        // ─── Siyahı ───────────────────────────────────────────────────────────
        if (isLoading && plans.isEmpty()) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = AppTheme.Colors.warning)
            }
        } else if (filteredPlans.isEmpty()) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(text = "📋", fontSize = 48.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "Plan tapılmadı",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 16.sp
                    )
                }
            }
        } else {
            LazyColumn(
                contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(filteredPlans, key = { it.id }) { plan ->
                    TrainingPlanCard(
                        plan = plan,
                        isExpanded = expandedPlanId == plan.id,
                        onToggle = {
                            expandedPlanId = if (expandedPlanId == plan.id) null else plan.id
                        }
                    )
                }
                item { Spacer(modifier = Modifier.height(80.dp)) }
            }
        }
    }
}

// ─── TrainingPlanCard ─────────────────────────────────────────────────────────
// iOS: TrainingPlanCard view — genişlənə bilən kart
@Composable
fun TrainingPlanCard(
    plan: TrainingPlan,
    isExpanded: Boolean,
    onToggle: () -> Unit
) {
    val planTypeLabel = when (plan.planType) {
        PlanType.WEIGHT_LOSS.value      -> "⬇️ Çəki itkisi"
        PlanType.WEIGHT_GAIN.value      -> "⬆️ Çəki artımı"
        PlanType.STRENGTH_TRAINING.value -> "💪 Güc"
        else -> plan.planType
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onToggle),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = plan.title,
                        color = Color.White,
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 16.sp
                    )
                    Text(
                        text = planTypeLabel,
                        color = AppTheme.Colors.warning,
                        fontSize = 13.sp
                    )
                    plan.assignedStudentName?.let {
                        Text(
                            text = "👤 $it",
                            color = AppTheme.Colors.secondaryText,
                            fontSize = 12.sp
                        )
                    }
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "${plan.workouts.size} məşq",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 13.sp
                    )
                    Text(
                        text = if (isExpanded) "▲" else "▼",
                        color = AppTheme.Colors.warning,
                        fontSize = 12.sp
                    )
                }
            }

            // Genişlənmiş: məşq siyahısı
            if (isExpanded && plan.workouts.isNotEmpty()) {
                Spacer(modifier = Modifier.height(12.dp))
                HorizontalDivider(color = AppTheme.Colors.separator)
                Spacer(modifier = Modifier.height(8.dp))
                plan.workouts.forEach { workout ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "• ${workout.name}",
                            color = AppTheme.Colors.primaryText.copy(alpha = 0.87f),
                            fontSize = 14.sp,
                            modifier = Modifier.weight(1f)
                        )
                        Text(
                            text = "${workout.sets}x${workout.reps}",
                            color = AppTheme.Colors.secondaryText,
                            fontSize = 13.sp
                        )
                    }
                }
                plan.notes?.let {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "📝 $it",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 12.sp
                    )
                }
            }
        }
    }
}
