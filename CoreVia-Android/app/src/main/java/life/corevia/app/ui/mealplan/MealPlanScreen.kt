package life.corevia.app.ui.mealplan

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.MealPlan
import life.corevia.app.data.models.PlanType

/**
 * iOS MealPlanView.swift — Android 1-ə-1 port
 */
@Composable
fun MealPlanScreen(
    isTrainer: Boolean,
    onNavigateToAddMealPlan: () -> Unit = {},
    onDeletePlan: (String) -> Unit = {},
    viewModel: MealPlanViewModel = viewModel()
) {
    val plans by viewModel.plans.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val selectedFilter by viewModel.selectedFilter.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val filteredPlans = viewModel.filteredPlans

    var expandedPlanId by remember { mutableStateOf<String?>(null) }
    var deletingPlanId by remember { mutableStateOf<String?>(null) }

    // Auto-dismiss messages
    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearSuccess()
        }
    }
    LaunchedEffect(errorMessage) {
        if (errorMessage != null) {
            kotlinx.coroutines.delay(3000)
            viewModel.clearError()
        }
    }

    // Delete confirmation dialog
    if (deletingPlanId != null) {
        AlertDialog(
            onDismissRequest = { deletingPlanId = null },
            containerColor = AppTheme.Colors.secondaryBackground,
            title = { Text("Planı sil?", color = Color.White) },
            text = { Text("Bu qida planını silmək istədiyinizdən əminsiniz?", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = {
                    deletingPlanId?.let { onDeletePlan(it) }
                    deletingPlanId = null
                }) {
                    Text("Sil", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { deletingPlanId = null }) {
                    Text("Ləğv et", color = AppTheme.Colors.secondaryText)
                }
            }
        )
    }

    Scaffold(
        containerColor = AppTheme.Colors.background,
        floatingActionButton = {
            if (isTrainer) {
                FloatingActionButton(
                    onClick = onNavigateToAddMealPlan,
                    containerColor = AppTheme.Colors.success,
                    shape = CircleShape
                ) {
                    Icon(Icons.Outlined.Add, "Qida planı yarat", tint = Color.White)
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // ─── Başlıq ─────────────────────────────────────────────────────
            Text(
                text = "Qida Planları",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp)
            )

            // ─── Success message ────────────────────────────────────────────
            if (successMessage != null) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 4.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.success.copy(alpha = 0.15f))
                ) {
                    Text(
                        text = successMessage ?: "",
                        modifier = Modifier.padding(12.dp),
                        color = AppTheme.Colors.success,
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 14.sp
                    )
                }
            }

            // ─── Error message ──────────────────────────────────────────────
            if (errorMessage != null) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 4.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.error.copy(alpha = 0.15f))
                ) {
                    Text(
                        text = errorMessage ?: "",
                        modifier = Modifier.padding(12.dp),
                        color = AppTheme.Colors.error,
                        fontSize = 14.sp
                    )
                }
            }

            // ─── Filter chips ───────────────────────────────────────────────
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
                            selectedContainerColor = AppTheme.Colors.success,
                            selectedLabelColor = Color.White,
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
                            Text(
                                when (planType) {
                                    PlanType.WEIGHT_LOSS -> "Çəki itkisi"
                                    PlanType.WEIGHT_GAIN -> "Çəki artımı"
                                    PlanType.STRENGTH_TRAINING -> "Güc"
                                }
                            )
                        },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = AppTheme.Colors.success,
                            selectedLabelColor = Color.White,
                            containerColor = AppTheme.Colors.secondaryBackground,
                            labelColor = AppTheme.Colors.secondaryText
                        )
                    )
                }
            }

            // ─── Siyahı ─────────────────────────────────────────────────────
            if (isLoading && plans.isEmpty()) {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = AppTheme.Colors.success)
                }
            } else if (filteredPlans.isEmpty()) {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(text = "🍽️", fontSize = 48.sp)
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = "Qida planı tapılmadı",
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
                        MealPlanCard(
                            plan = plan,
                            isExpanded = expandedPlanId == plan.id,
                            isTrainer = isTrainer,
                            onToggle = {
                                expandedPlanId = if (expandedPlanId == plan.id) null else plan.id
                            },
                            onDelete = { deletingPlanId = plan.id }
                        )
                    }
                    item { Spacer(modifier = Modifier.height(80.dp)) }
                }
            }
        }
    }
}

@Composable
fun MealPlanCard(
    plan: MealPlan,
    isExpanded: Boolean,
    isTrainer: Boolean = false,
    onToggle: () -> Unit,
    onDelete: () -> Unit = {}
) {
    val planTypeLabel = when (plan.planType) {
        PlanType.WEIGHT_LOSS.value -> "⬇️ Çəki itkisi"
        PlanType.WEIGHT_GAIN.value -> "⬆️ Çəki artımı"
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
                    Text(text = planTypeLabel, color = AppTheme.Colors.success, fontSize = 13.sp)
                    Text(
                        text = "🔥 ${plan.dailyCalorieTarget} kal/gün",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 12.sp
                    )
                    // iOS: assigned student name display
                    if (plan.assignedStudentId != null) {
                        Text(
                            text = "👤 ${plan.assignedStudentName ?: "Tələbəyə təyin olunub"}",
                            color = AppTheme.Colors.accent,
                            fontSize = 12.sp
                        )
                    }
                    // iOS: completion status (only show if assigned to student)
                    if (plan.assignedStudentId != null) {
                        if (plan.isCompleted) {
                            Text(text = "✅ Tamamlandı", color = AppTheme.Colors.success, fontSize = 12.sp)
                        } else {
                            Text(text = "⏱️ Gözləmədə", color = Color(0xFFFFA500), fontSize = 12.sp)
                        }
                    }
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "${plan.items.size} yemək",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 13.sp
                    )
                    Text(
                        text = if (isExpanded) "▲" else "▼",
                        color = AppTheme.Colors.success,
                        fontSize = 12.sp
                    )
                }
            }

            // Genişlənmiş: yemək siyahısı
            if (isExpanded && plan.items.isNotEmpty()) {
                Spacer(modifier = Modifier.height(12.dp))
                HorizontalDivider(color = AppTheme.Colors.separator)
                Spacer(modifier = Modifier.height(8.dp))
                plan.items.forEach { item ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "• ${item.name}",
                                color = AppTheme.Colors.primaryText.copy(alpha = 0.87f),
                                fontSize = 14.sp
                            )
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                item.protein?.let {
                                    Text("P:${it.toInt()}g", color = AppTheme.Colors.accent, fontSize = 11.sp)
                                }
                                item.carbs?.let {
                                    Text("K:${it.toInt()}g", color = AppTheme.Colors.warning, fontSize = 11.sp)
                                }
                                item.fats?.let {
                                    Text("Y:${it.toInt()}g", color = AppTheme.Colors.error, fontSize = 11.sp)
                                }
                            }
                        }
                        Text(
                            text = "${item.calories} kal",
                            color = AppTheme.Colors.success,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
                plan.notes?.let {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("📝 $it", color = AppTheme.Colors.secondaryText, fontSize = 12.sp)
                }

                // Delete button (trainer only)
                if (isTrainer) {
                    Spacer(modifier = Modifier.height(12.dp))
                    OutlinedButton(
                        onClick = onDelete,
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = AppTheme.Colors.error),
                        border = ButtonDefaults.outlinedButtonBorder(enabled = true).copy(
                            brush = androidx.compose.ui.graphics.SolidColor(AppTheme.Colors.error.copy(alpha = 0.5f))
                        )
                    ) {
                        Text("🗑️ Sil", fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.error)
                    }
                }
            }
        }
    }
}
