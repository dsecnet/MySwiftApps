package life.corevia.app.ui.plans

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.TrainingPlan
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrainingPlanScreen(
    onNavigateToAddPlan: () -> Unit,
    onBack: () -> Unit,
    viewModel: TrainingPlanViewModel = hiltViewModel()
) {
    val state by viewModel.listState.collectAsState()

    LaunchedEffect(Unit) { viewModel.loadPlans() }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Mesq Planlari", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onNavigateToAddPlan,
                containerColor = CoreViaPrimary,
                contentColor = Color.White,
                shape = CircleShape
            ) {
                Icon(Icons.Filled.Add, contentDescription = "Yeni plan")
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(horizontal = 20.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Stats Row ──
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    PlanStatCard("Umumi", "${state.totalPlans}", PlanStrength, Modifier.weight(1f))
                    PlanStatCard("Tamamlanmis", "${state.completedPlans}", CoreViaSuccess, Modifier.weight(1f))
                }
            }

            // ── Filter Chips ──
            item {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    val filters = listOf(
                        "all" to "Hamisi",
                        "weight_loss" to "Ariqla",
                        "weight_gain" to "Kilo al",
                        "strength_training" to "Guc"
                    )
                    items(filters) { (key, label) ->
                        FilterChip(
                            selected = state.selectedFilter == key,
                            onClick = { viewModel.setFilter(key) },
                            label = { Text(label, fontSize = 13.sp) },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = CoreViaPrimary,
                                selectedLabelColor = Color.White
                            )
                        )
                    }
                }
            }

            // ── Loading ──
            if (state.isLoading) {
                item {
                    Box(modifier = Modifier.fillMaxWidth().padding(40.dp), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                    }
                }
            }

            // ── Plan Cards ──
            if (!state.isLoading && state.filteredPlans.isEmpty()) {
                item {
                    Column(
                        modifier = Modifier.fillMaxWidth().padding(60.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(Icons.Filled.FitnessCenter, contentDescription = null, modifier = Modifier.size(48.dp), tint = TextHint)
                        Spacer(modifier = Modifier.height(12.dp))
                        Text("Henuz plan yoxdur", fontSize = 16.sp, color = TextSecondary, textAlign = TextAlign.Center)
                        Spacer(modifier = Modifier.height(4.dp))
                        Text("Yeni mesq plani yaradib baslayin!", fontSize = 13.sp, color = TextHint, textAlign = TextAlign.Center)
                    }
                }
            }

            items(state.filteredPlans) { plan ->
                TrainingPlanCard(
                    plan = plan,
                    onComplete = { viewModel.completePlan(plan.id) },
                    onDelete = { viewModel.deletePlan(plan.id) }
                )
            }

            item { Spacer(modifier = Modifier.height(80.dp)) }
        }
    }
}

@Composable
private fun PlanStatCard(label: String, value: String, color: Color, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = color.copy(alpha = 0.1f))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(value, fontSize = 28.sp, fontWeight = FontWeight.Bold, color = color)
            Text(label, fontSize = 13.sp, color = TextSecondary)
        }
    }
}

@Composable
private fun TrainingPlanCard(
    plan: TrainingPlan,
    onComplete: () -> Unit,
    onDelete: () -> Unit
) {
    val isCompleted = plan.isCompleted == true
    val typeColor = when (plan.planType) {
        "weight_loss" -> PlanWeightLoss
        "weight_gain" -> PlanWeightGain
        else -> PlanStrength
    }
    val typeLabel = when (plan.planType) {
        "weight_loss" -> "Ariqla"
        "weight_gain" -> "Kilo al"
        else -> "Guc"
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Type badge
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(typeColor.copy(alpha = 0.15f))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                ) {
                    Text(typeLabel, fontSize = 11.sp, color = typeColor, fontWeight = FontWeight.SemiBold)
                }

                if (isCompleted) {
                    Icon(Icons.Filled.CheckCircle, contentDescription = "Tamamlanib", tint = CoreViaSuccess, modifier = Modifier.size(20.dp))
                }
            }

            Spacer(modifier = Modifier.height(10.dp))
            Text(plan.title, fontSize = 17.sp, fontWeight = FontWeight.Bold, color = TextPrimary)

            plan.assignedStudentId?.let {
                Text("Telebe: $it", fontSize = 12.sp, color = TextSecondary, modifier = Modifier.padding(top = 4.dp))
            }

            Spacer(modifier = Modifier.height(8.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                Text("${plan.workouts.size} mesq", fontSize = 13.sp, color = TextSecondary)
                plan.formattedDate.let { if (it.isNotEmpty()) Text(it, fontSize = 13.sp, color = TextHint) }
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                if (!isCompleted) {
                    OutlinedButton(
                        onClick = onComplete,
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Tamamla", fontSize = 13.sp)
                    }
                }
                OutlinedButton(
                    onClick = onDelete,
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = CoreViaError)
                ) {
                    Icon(Icons.Filled.Delete, contentDescription = "Sil", modifier = Modifier.size(16.dp))
                }
            }
        }
    }
}
