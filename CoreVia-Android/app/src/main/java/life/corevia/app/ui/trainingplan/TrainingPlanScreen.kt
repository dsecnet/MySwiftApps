package life.corevia.app.ui.trainingplan

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
import androidx.compose.material.icons.outlined.People
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
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
    isTrainer: Boolean = false,
    onNavigateToAddTrainingPlan: () -> Unit = {},
    onNavigateToAddWorkoutForStudent: () -> Unit = {},
    onDeletePlan: (String) -> Unit = {},
    viewModel: TrainingPlanViewModel = viewModel()
) {
    val plans by viewModel.plans.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val selectedFilter by viewModel.selectedFilter.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val filteredPlans = viewModel.filteredPlans

    var expandedPlanId by remember { mutableStateOf<String?>(null) }
    var deletingPlanId by remember { mutableStateOf<String?>(null) }

    // Delete confirmation dialog
    if (deletingPlanId != null) {
        AlertDialog(
            onDismissRequest = { deletingPlanId = null },
            containerColor = AppTheme.Colors.secondaryBackground,
            title = { Text("Planı sil?", color = Color.White) },
            text = { Text("Bu məşq planını silmək istədiyinizdən əminsiniz?", color = AppTheme.Colors.secondaryText) },
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

    // Success auto-dismiss
    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearSuccess()
        }
    }

    Scaffold(
        containerColor = AppTheme.Colors.background,
        floatingActionButton = {
            if (isTrainer) {
                // iOS: Dual FABs — "Add Plan" + "Add Workout for Student"
                Column(
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    horizontalAlignment = Alignment.End
                ) {
                    // Regular add plan button (iOS: plus icon, accent)
                    FloatingActionButton(
                        onClick = onNavigateToAddTrainingPlan,
                        containerColor = AppTheme.Colors.accent,
                        shape = CircleShape,
                        modifier = Modifier.size(56.dp)
                    ) {
                        Icon(Icons.Outlined.Add, "Məşq planı yarat", tint = Color.White)
                    }

                    // Add workout for student button (iOS: person.2.fill, green)
                    FloatingActionButton(
                        onClick = onNavigateToAddWorkoutForStudent,
                        containerColor = Color(0xFF4CAF50),
                        shape = CircleShape,
                        modifier = Modifier.size(56.dp)
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                Icons.Outlined.People,
                                null,
                                tint = Color.White,
                                modifier = Modifier.size(18.dp)
                            )
                            Text(
                                "Tələbəyə",
                                fontSize = 8.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = Color.White
                            )
                        }
                    }
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // ─── Başlıq (iOS: header with title + subtitle) ────────────────────────
            Column(
                modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(
                    text = "Məşq Planları",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Text(
                    text = "Məşq planlarınızı idarə edin",
                    fontSize = 14.sp,
                    color = AppTheme.Colors.secondaryText
                )
            }

            // ─── Stats Row (iOS: MiniStatCard HStack) ───────────────────────────
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
                    .padding(bottom = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                MiniStatCard(
                    modifier = Modifier.weight(1f),
                    value = "${filteredPlans.size}",
                    label = "Ümumi planlar",
                    color = AppTheme.Colors.accent
                )
                MiniStatCard(
                    modifier = Modifier.weight(1f),
                    value = "${filteredPlans.count { it.planType == PlanType.WEIGHT_LOSS.value }}",
                    label = "Çəki itkisi",
                    color = AppTheme.Colors.accent
                )
                MiniStatCard(
                    modifier = Modifier.weight(1f),
                    value = "${filteredPlans.count { it.planType == PlanType.STRENGTH_TRAINING.value }}",
                    label = "Güc",
                    color = AppTheme.Colors.accent
                )
            }

            // ─── Success message ──────────────────────────────────────────────────
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

            // ─── Filter chips ─────────────────────────────────────────────────────
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

// ─── TrainingPlanCard ─────────────────────────────────────────────────────────
// iOS: TrainingPlanCard view — genişlənə bilən kart
@Composable
fun TrainingPlanCard(
    plan: TrainingPlan,
    isExpanded: Boolean,
    isTrainer: Boolean = false,
    onToggle: () -> Unit,
    onDelete: () -> Unit = {}
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
                            Text(
                                text = "✅ Tamamlandı",
                                color = AppTheme.Colors.success,
                                fontSize = 12.sp
                            )
                        } else {
                            Text(
                                text = "⏱️ Gözləmədə",
                                color = Color(0xFFFFA500),
                                fontSize = 12.sp
                            )
                        }
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

// ─── iOS: MiniStatCard ──────────────────────────────────────────────────────
@Composable
fun MiniStatCard(
    modifier: Modifier = Modifier,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(10.dp))
            .padding(vertical = 12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(
            text = value,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            text = label,
            fontSize = 10.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center,
            maxLines = 2
        )
    }
}
