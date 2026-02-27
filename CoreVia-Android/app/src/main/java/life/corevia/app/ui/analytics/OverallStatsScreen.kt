package life.corevia.app.ui.analytics

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OverallStatsScreen(
    onBack: () -> Unit = {},
    viewModel: AnalyticsDashboardViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Ümumi Statistika",
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent
                )
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(padding)
        ) {
            when {
                uiState.isLoading -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                    }
                }

                uiState.error != null -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(16.dp),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(
                            Icons.Filled.ErrorOutline, null,
                            modifier = Modifier.size(48.dp),
                            tint = CoreViaError
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = uiState.error ?: "Xəta baş verdi",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            textAlign = TextAlign.Center
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = viewModel::loadDashboard,
                            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
                        ) {
                            Text("Yenidən cəhd edin")
                        }
                    }
                }

                else -> {
                    val summary = uiState.thirtyDaySummary

                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState())
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(20.dp)
                    ) {
                        // ── Subtitle ──
                        Text(
                            text = "Son 30 günün nəticələri",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )

                        // ── 2x2 Stats Grid — iOS style with shadow ──
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            OverallStatCard(
                                modifier = Modifier.weight(1f),
                                icon = Icons.Filled.FitnessCenter,
                                value = "${summary.totalWorkouts}",
                                label = "Ümumi Məşq",
                                iconColor = CoreViaPrimary
                            )
                            OverallStatCard(
                                modifier = Modifier.weight(1f),
                                icon = Icons.Filled.LocalFireDepartment,
                                value = formatStatNumber(summary.totalCaloriesBurned),
                                label = "Yandırılan Kalori",
                                iconColor = AccentOrange
                            )
                        }

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            OverallStatCard(
                                modifier = Modifier.weight(1f),
                                icon = Icons.Filled.DirectionsRun,
                                value = String.format("%.1f km", summary.totalDistance),
                                label = "Ümumi Məsafə",
                                iconColor = AccentBlue
                            )
                            OverallStatCard(
                                modifier = Modifier.weight(1f),
                                icon = Icons.Filled.Bedtime,
                                value = String.format("%.1f saat", summary.avgSleep),
                                label = "Ort. Yuxu",
                                iconColor = AccentPurple
                            )
                        }

                        // ── Additional Info Section ──
                        AdditionalInfoSection(
                            totalFoodCalories = summary.totalFoodCalories,
                            avgDailyCalories = summary.avgDailyCalories,
                            consistencyPercent = uiState.currentWeek.consistencyPercent,
                            avgDuration = uiState.currentWeek.avgDuration
                        )

                        Spacer(modifier = Modifier.height(80.dp))
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// STAT CARD — iOS SummaryAnalyticsStatCard style with shadow
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun OverallStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String,
    iconColor: Color
) {
    Column(
        modifier = modifier
            .shadow(
                elevation = 2.dp,
                shape = RoundedCornerShape(12.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.05f)
            )
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Icon with colored background — 40x40, cornerRadius 10
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(iconColor.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                icon, null,
                modifier = Modifier.size(22.dp),
                tint = iconColor
            )
        }

        // Value
        Text(
            text = value,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )

        // Label
        Text(
            text = label,
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// ADDITIONAL INFO — iOS style card with dividers
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun AdditionalInfoSection(
    totalFoodCalories: Int,
    avgDailyCalories: Int,
    consistencyPercent: Double,
    avgDuration: Int
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Əlavə Məlumat",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
        )

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(
                    elevation = 2.dp,
                    shape = RoundedCornerShape(16.dp),
                    ambientColor = Color.Black.copy(alpha = 0.05f),
                    spotColor = Color.Black.copy(alpha = 0.05f)
                )
                .clip(RoundedCornerShape(16.dp))
                .background(MaterialTheme.colorScheme.surface)
                .padding(16.dp)
        ) {
            AdditionalInfoRow(
                icon = Icons.Filled.Restaurant,
                label = "Qida Kalorisi",
                value = formatStatNumber(totalFoodCalories),
                color = CoreViaSuccess
            )

            HorizontalDivider(
                modifier = Modifier.padding(vertical = 12.dp),
                color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f)
            )

            AdditionalInfoRow(
                icon = Icons.Filled.Bolt,
                label = "Gündəlik Ort. Kalori",
                value = formatStatNumber(avgDailyCalories),
                color = AccentOrange
            )

            HorizontalDivider(
                modifier = Modifier.padding(vertical = 12.dp),
                color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f)
            )

            AdditionalInfoRow(
                icon = Icons.Filled.TrendingUp,
                label = "Ardıcıllıq",
                value = "${consistencyPercent.toInt()}%",
                color = CoreViaPrimary
            )

            HorizontalDivider(
                modifier = Modifier.padding(vertical = 12.dp),
                color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f)
            )

            AdditionalInfoRow(
                icon = Icons.Filled.Timer,
                label = "Ort. Məşq Müddəti",
                value = "$avgDuration dəq",
                color = AccentBlue
            )
        }
    }
}

@Composable
private fun AdditionalInfoRow(
    icon: ImageVector,
    label: String,
    value: String,
    color: Color
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(color.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    icon, null,
                    modifier = Modifier.size(16.dp),
                    tint = color
                )
            }
            Text(
                text = label,
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Text(
            text = value,
            fontSize = 15.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════

private fun formatStatNumber(number: Int): String {
    return when {
        number >= 1_000_000 -> String.format("%.1fM", number / 1_000_000.0)
        number >= 1_000 -> String.format("%.1fK", number / 1_000.0)
        else -> "$number"
    }
}
