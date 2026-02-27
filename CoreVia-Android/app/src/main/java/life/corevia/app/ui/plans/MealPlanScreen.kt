package life.corevia.app.ui.plans

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.MealPlan
import life.corevia.app.data.model.PlanType
import life.corevia.app.ui.theme.*

@Composable
fun MealPlanScreen(
    onNavigateToAddPlan: () -> Unit,
    onBack: () -> Unit,
    viewModel: MealPlanViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Box(modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 100.dp)
        ) {
            Column(
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Spacer(modifier = Modifier.height(48.dp))

                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CircleShape)
                                .background(MaterialTheme.colorScheme.surfaceVariant)
                                .clickable(onClick = onBack),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                Icons.Filled.ArrowBack, null,
                                modifier = Modifier.size(18.dp),
                                tint = MaterialTheme.colorScheme.onSurface
                            )
                        }
                        Column {
                            Text(
                                text = "Yemək Planları",
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onBackground
                            )
                            Text(
                                text = "Qidalanma planlarınızı idarə edin",
                                fontSize = 13.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }

                // Stats Row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    MiniStatCard(
                        modifier = Modifier.weight(1f),
                        label = "Cəmi",
                        value = "${uiState.totalPlans}",
                        icon = Icons.Filled.MenuBook,
                        color = CoreViaPrimary
                    )
                    MiniStatCard(
                        modifier = Modifier.weight(1f),
                        label = "Aktiv",
                        value = "${uiState.activePlans}",
                        icon = Icons.Filled.CheckCircle,
                        color = CoreViaSuccess
                    )
                    MiniStatCard(
                        modifier = Modifier.weight(1f),
                        label = "Yeməklər",
                        value = "${uiState.totalMeals}",
                        icon = Icons.Filled.Restaurant,
                        color = Color(0xFFFF9800)
                    )
                    MiniStatCard(
                        modifier = Modifier.weight(1f),
                        label = "Ort. kcal",
                        value = "${uiState.avgCalories}",
                        icon = Icons.Filled.LocalFireDepartment,
                        color = Color(0xFF2196F3)
                    )
                }

                // Filter Chips
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    FilterChipItem(
                        label = "Hamısı",
                        isSelected = uiState.selectedFilter == "all",
                        onClick = { viewModel.setFilter("all") }
                    )
                    PlanType.entries.forEach { type ->
                        FilterChipItem(
                            label = type.displayName,
                            isSelected = uiState.selectedFilter == type.value,
                            onClick = { viewModel.setFilter(type.value) }
                        )
                    }
                }

                // Loading
                if (uiState.isLoading) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 40.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(
                            color = CoreViaPrimary,
                            modifier = Modifier.size(36.dp)
                        )
                    }
                }

                // Plans List
                if (!uiState.isLoading && uiState.filteredPlans.isEmpty()) {
                    EmptyMealPlanView()
                } else {
                    uiState.filteredPlans.forEach { plan ->
                        MealPlanCard(
                            plan = plan,
                            onDelete = { viewModel.deleteMealPlan(plan.id) }
                        )
                    }
                }
            }
        }

        // FAB
        Box(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 20.dp, bottom = 20.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(CoreViaPrimary)
                    .clickable(onClick = onNavigateToAddPlan),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.Add, null,
                    modifier = Modifier.size(24.dp),
                    tint = Color.White
                )
            }
        }
    }
}

@Composable
private fun MiniStatCard(
    modifier: Modifier = Modifier,
    label: String,
    value: String,
    icon: ImageVector,
    color: Color
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(10.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(10.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Icon(
            icon, null,
            modifier = Modifier.size(16.dp),
            tint = color
        )
        Text(
            text = value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = label,
            fontSize = 10.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun FilterChipItem(
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(
                if (isSelected) CoreViaPrimary else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp)
    ) {
        Text(
            text = label,
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold,
            color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun MealPlanCard(
    plan: MealPlan,
    onDelete: () -> Unit
) {
    val planType = PlanType.fromValue(plan.planType)
    val planColor = when (planType) {
        PlanType.WEIGHT_LOSS -> PlanWeightLoss
        PlanType.WEIGHT_GAIN -> PlanWeightGain
        PlanType.MUSCLE_BUILDING -> PlanStrength
        PlanType.MAINTENANCE -> Color(0xFFFF9800)
        PlanType.CUSTOM -> CoreViaPrimary
    }
    val planIcon = when (planType) {
        PlanType.WEIGHT_LOSS -> Icons.Filled.TrendingDown
        PlanType.WEIGHT_GAIN -> Icons.Filled.TrendingUp
        PlanType.MUSCLE_BUILDING -> Icons.Filled.FitnessCenter
        PlanType.MAINTENANCE -> Icons.Filled.Balance
        PlanType.CUSTOM -> Icons.Filled.Edit
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(planColor.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        planIcon, null,
                        modifier = Modifier.size(20.dp),
                        tint = planColor
                    )
                }
                Column {
                    Text(
                        text = plan.name,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onBackground,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = planType.displayName,
                        fontSize = 11.sp,
                        color = planColor,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
            Icon(
                Icons.Filled.Delete, null,
                modifier = Modifier
                    .size(18.dp)
                    .clickable(onClick = onDelete),
                tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
            )
        }

        plan.description?.let { desc ->
            if (desc.isNotBlank()) {
                Text(
                    text = desc,
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        // Stats row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.Restaurant, null,
                    modifier = Modifier.size(12.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "${plan.meals.size} yemək",
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.LocalFireDepartment, null,
                    modifier = Modifier.size(12.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "${plan.totalCalories} kcal",
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            if (plan.studentName != null) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Person, null,
                        modifier = Modifier.size(12.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = plan.studentName,
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }

        // Status badge
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.End
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(
                        if (plan.isActive) CoreViaSuccess.copy(alpha = 0.12f)
                        else MaterialTheme.colorScheme.surfaceVariant
                    )
                    .padding(horizontal = 10.dp, vertical = 4.dp)
            ) {
                Text(
                    text = if (plan.isActive) "Aktiv" else "Deaktiv",
                    fontSize = 10.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = if (plan.isActive) CoreViaSuccess else MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun EmptyMealPlanView() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Box(
            modifier = Modifier
                .size(64.dp)
                .clip(CircleShape)
                .background(CoreViaPrimary.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.MenuBook, null,
                modifier = Modifier.size(32.dp),
                tint = CoreViaPrimary
            )
        }
        Text(
            text = "Hələ yemək planı yoxdur",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = "Yeni yemək planı yaradaraq qidalanmanızı planlaşdırın",
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
