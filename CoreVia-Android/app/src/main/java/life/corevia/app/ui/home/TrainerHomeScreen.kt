package life.corevia.app.ui.home

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.automirrored.filled.TrendingUp
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.DashboardStudentSummary
import life.corevia.app.ui.theme.*

/**
 * iOS TrainerDashboardView equivalent
 * Trainer Ana Ekranı — statistikalar, tələbələr, planlar
 */

@Composable
fun TrainerHomeScreen(
    viewModel: TrainerHomeViewModel = hiltViewModel(),
    onNavigateToStudentDetail: (String) -> Unit = {},
    onNavigateToTrainingPlans: () -> Unit = {},
    onNavigateToMealPlans: () -> Unit = {},
    onNavigateToMessages: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    // Reload data every time screen appears
    @Suppress("DEPRECATION")
    val lifecycleOwner = androidx.compose.ui.platform.LocalLifecycleOwner.current
    DisposableEffect(lifecycleOwner) {
        val observer = androidx.lifecycle.LifecycleEventObserver { _, event ->
            if (event == androidx.lifecycle.Lifecycle.Event.ON_RESUME) {
                viewModel.loadDashboard()
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(bottom = 80.dp)
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Header ──
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Profile avatar with gradient circle
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                colors = listOf(
                                    CoreViaPrimary.copy(alpha = 0.3f),
                                    CoreViaPrimary
                                )
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = uiState.userName.firstOrNull()?.uppercase() ?: "T",
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }

                // Greeting + Name
                Column(
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(
                        text = "Xoş gəldiniz \uD83D\uDC4B",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = uiState.userName,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                }

                Spacer(modifier = Modifier.weight(1f))

                // Refresh button
                IconButton(
                    onClick = { viewModel.loadDashboard() },
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.surfaceVariant)
                ) {
                    Icon(
                        Icons.Filled.Refresh,
                        contentDescription = "Yenilə",
                        modifier = Modifier.size(16.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // ── Loading indicator ──
            if (uiState.isLoading) {
                Box(
                    modifier = Modifier.fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(24.dp),
                        strokeWidth = 2.dp,
                        color = CoreViaPrimary
                    )
                }
            }

            // ── Error message ──
            if (uiState.errorMessage != null) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(10.dp))
                        .background(CoreViaError.copy(alpha = 0.1f))
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.ErrorOutline, null,
                        modifier = Modifier.size(16.dp),
                        tint = CoreViaError
                    )
                    Text(
                        text = uiState.errorMessage ?: "",
                        fontSize = 13.sp,
                        color = CoreViaError
                    )
                }
            }

            // ── Quick Stats Row ──
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                TrainerStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Filled.People,
                    value = "${uiState.activeStudents}",
                    label = "Aktiv Tələbə",
                    color = CoreViaPrimary
                )
                TrainerStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Filled.Groups,
                    value = "${uiState.totalSubscribers}",
                    label = "Abunəçi",
                    color = AccentBlue
                )
            }

            // ── Earnings Card ──
            EarningsCard(
                earnings = uiState.monthlyEarnings,
                currency = uiState.currency
            )

            // ── Plans Overview ──
            PlansOverviewSection(
                trainingPlans = uiState.totalTrainingPlans,
                mealPlans = uiState.totalMealPlans,
                onTrainingPlansClick = onNavigateToTrainingPlans,
                onMealPlansClick = onNavigateToMealPlans
            )

            // ── Quick Actions ──
            Text(
                text = "Tez Əməliyyatlar",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                TrainerQuickAction(
                    modifier = Modifier.weight(1f),
                    title = "Plan Yarat",
                    icon = Icons.Filled.Add,
                    onClick = onNavigateToTrainingPlans
                )
                TrainerQuickAction(
                    modifier = Modifier.weight(1f),
                    title = "Mesaj Göndər",
                    icon = Icons.AutoMirrored.Filled.Send,
                    onClick = onNavigateToMessages
                )
                TrainerQuickAction(
                    modifier = Modifier.weight(1f),
                    title = "Qida Planı",
                    icon = Icons.Filled.Restaurant,
                    onClick = onNavigateToMealPlans
                )
            }

            // ── Students Section ──
            if (uiState.students.isNotEmpty()) {
                StudentsSection(
                    students = uiState.students,
                    onStudentClick = onNavigateToStudentDetail
                )
            }

            // ── Stats Summary ──
            StatsSummarySection(
                avgWorkoutsPerWeek = uiState.avgWorkoutsPerWeek,
                totalWorkouts = uiState.totalWorkoutsAllStudents,
                avgWeight = uiState.avgStudentWeight
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TrainerStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(color.copy(alpha = 0.08f))
            .border(1.dp, color.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(color.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, modifier = Modifier.size(18.dp), tint = color)
        }
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(
                text = value,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = label,
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// EARNINGS CARD
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun EarningsCard(earnings: Double, currency: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                8.dp, RoundedCornerShape(16.dp),
                ambientColor = CoreViaSuccess.copy(alpha = 0.3f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(
                Brush.horizontalGradient(
                    listOf(CoreViaSuccess.copy(alpha = 0.9f), CoreViaSuccess)
                )
            )
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.AutoMirrored.Filled.TrendingUp, null,
                    modifier = Modifier.size(18.dp),
                    tint = Color.White
                )
                Text(
                    text = "Aylıq Gəlir",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.White.copy(alpha = 0.9f)
                )
            }
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .background(Color.White.copy(alpha = 0.2f))
                    .padding(horizontal = 8.dp, vertical = 3.dp)
            ) {
                Text(
                    text = "Bu ay",
                    fontSize = 11.sp,
                    color = Color.White.copy(alpha = 0.9f)
                )
            }
        }

        Text(
            text = "%.2f %s".format(earnings, currency),
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// PLANS OVERVIEW
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun PlansOverviewSection(
    trainingPlans: Int,
    mealPlans: Int,
    onTrainingPlansClick: () -> Unit,
    onMealPlansClick: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Training Plans
        Column(
            modifier = Modifier
                .weight(1f)
                .clip(RoundedCornerShape(14.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                .clickable(onClick = onTrainingPlansClick)
                .padding(14.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(CoreViaPrimary.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.FitnessCenter, null,
                    modifier = Modifier.size(20.dp),
                    tint = CoreViaPrimary
                )
            }
            Text(
                text = "$trainingPlans",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "Məşq Planı",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        // Meal Plans
        Column(
            modifier = Modifier
                .weight(1f)
                .clip(RoundedCornerShape(14.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                .clickable(onClick = onMealPlansClick)
                .padding(14.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(AccentOrange.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.Restaurant, null,
                    modifier = Modifier.size(20.dp),
                    tint = AccentOrange
                )
            }
            Text(
                text = "$mealPlans",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "Qida Planı",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// QUICK ACTIONS
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TrainerQuickAction(
    modifier: Modifier = Modifier,
    title: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(10.dp))
            .background(CoreViaPrimary.copy(alpha = 0.85f))
            .clickable { onClick() }
            .padding(vertical = 12.dp, horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Icon(
            icon, null,
            modifier = Modifier.size(18.dp),
            tint = Color.White
        )
        Text(
            text = title,
            fontSize = 10.sp,
            fontWeight = FontWeight.Medium,
            color = Color.White,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// STUDENTS SECTION
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun StudentsSection(
    students: List<DashboardStudentSummary>,
    onStudentClick: (String) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Tələbələrim",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "${students.size} tələbə",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            contentPadding = PaddingValues(end = 8.dp)
        ) {
            items(students) { student ->
                StudentCard(
                    student = student,
                    onClick = { onStudentClick(student.id) }
                )
            }
        }
    }
}

@Composable
private fun StudentCard(
    student: DashboardStudentSummary,
    onClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .width(150.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .border(
                1.dp,
                MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.1f),
                RoundedCornerShape(14.dp)
            )
            .clickable(onClick = onClick)
            .padding(14.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Avatar
        Box(
            modifier = Modifier
                .size(50.dp)
                .clip(CircleShape)
                .background(student.avatarColor),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = student.initials,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }

        // Name
        Text(
            text = student.name,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.Center
        )

        // Stats row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "${student.thisWeekWorkouts}",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = CoreViaPrimary
                )
                Text(
                    text = "Məşq",
                    fontSize = 9.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "${student.trainingPlansCount}",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = AccentBlue
                )
                Text(
                    text = "Plan",
                    fontSize = 9.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// STATS SUMMARY
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun StatsSummarySection(
    avgWorkoutsPerWeek: Double,
    totalWorkouts: Int,
    avgWeight: Double
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = "Ümumi Statistika",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            SummaryStatRow(
                icon = Icons.Filled.FitnessCenter,
                label = "Həftəlik ort. məşq",
                value = "%.1f".format(avgWorkoutsPerWeek),
                color = CoreViaPrimary
            )
            SummaryStatRow(
                icon = Icons.Filled.EmojiEvents,
                label = "Ümumi məşqlər",
                value = "$totalWorkouts",
                color = AccentOrange
            )
            SummaryStatRow(
                icon = Icons.Filled.MonitorWeight,
                label = "Ort. çəki",
                value = "%.1f kq".format(avgWeight),
                color = AccentBlue
            )
        }
    }
}

@Composable
private fun SummaryStatRow(
    icon: ImageVector,
    label: String,
    value: String,
    color: Color
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(color.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, modifier = Modifier.size(16.dp), tint = color)
        }
        Text(
            text = label,
            modifier = Modifier.weight(1f),
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}
