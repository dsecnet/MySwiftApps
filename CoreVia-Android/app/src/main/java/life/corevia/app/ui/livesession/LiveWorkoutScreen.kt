package life.corevia.app.ui.livesession

import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import life.corevia.app.ui.theme.*

/**
 * iOS LiveWorkoutView equivalent (simplified, no camera)
 * Canlı məşq ekranı — session info, timer, exercise list, end button
 * Placeholder for future WebSocket integration
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LiveWorkoutScreen(
    sessionId: String = "",
    sessionTitle: String = "Canlı Məşq",
    onBack: () -> Unit = {},
    onEndWorkout: () -> Unit = {}
) {
    val isDark = isSystemInDarkTheme()

    // ── Timer State ──
    var elapsedSeconds by remember { mutableIntStateOf(0) }
    var isRunning by remember { mutableStateOf(true) }
    var showEndDialog by remember { mutableStateOf(false) }

    // Timer tick
    LaunchedEffect(isRunning) {
        while (isRunning) {
            delay(1000L)
            elapsedSeconds++
        }
    }

    // End workout confirmation dialog
    if (showEndDialog) {
        AlertDialog(
            onDismissRequest = { showEndDialog = false },
            title = {
                Text(
                    "Məşqi bitir?",
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Text("Canlı məşqi bitirmək istəyirsiniz? Bu əməliyyat geri alına bilməz.")
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showEndDialog = false
                        isRunning = false
                        onEndWorkout()
                    }
                ) {
                    Text(
                        "Bitir",
                        color = CoreViaError,
                        fontWeight = FontWeight.Bold
                    )
                }
            },
            dismissButton = {
                TextButton(onClick = { showEndDialog = false }) {
                    Text("Ləğv et", color = TextSecondary)
                }
            }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Canlı Məşq",
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { showEndDialog = true }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                actions = {
                    // Live indicator
                    Box(
                        modifier = Modifier
                            .padding(end = 16.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(CoreViaError.copy(alpha = 0.15f))
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(8.dp)
                                    .clip(CircleShape)
                                    .background(CoreViaError)
                            )
                            Text(
                                text = "CANLI",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                color = CoreViaError
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(padding)
        ) {
            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // ── Session Info Card ──
                SessionInfoCard(
                    title = sessionTitle,
                    isDark = isDark
                )

                // ── Timer Display ──
                TimerCard(
                    elapsedSeconds = elapsedSeconds,
                    isRunning = isRunning,
                    onToggle = { isRunning = !isRunning },
                    isDark = isDark
                )

                // ── Exercise List ──
                ExerciseListCard(isDark = isDark)

                // ── WebSocket Status Placeholder ──
                ConnectionStatusCard(isDark = isDark)

                Spacer(modifier = Modifier.height(8.dp))
            }

            // ── End Button ──
            EndWorkoutButton(onClick = { showEndDialog = true })
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Session Info Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionInfoCard(title: String, isDark: Boolean) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.08f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(if (isDark) CoreViaSurfaceNight else CoreViaSurface)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Session icon
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(CoreViaPrimary.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.FitnessCenter,
                contentDescription = null,
                modifier = Modifier.size(24.dp),
                tint = CoreViaPrimary
            )
        }

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = "Canlı sessiya davam edir",
                fontSize = 13.sp,
                color = CoreViaSuccess
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Timer Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun TimerCard(
    elapsedSeconds: Int,
    isRunning: Boolean,
    onToggle: () -> Unit,
    isDark: Boolean
) {
    val hours = elapsedSeconds / 3600
    val minutes = (elapsedSeconds % 3600) / 60
    val seconds = elapsedSeconds % 60
    val timeString = if (hours > 0)
        "%02d:%02d:%02d".format(hours, minutes, seconds)
    else
        "%02d:%02d".format(minutes, seconds)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.08f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(if (isDark) CoreViaSurfaceNight else CoreViaSurface)
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Keçən vaxt",
            fontSize = 14.sp,
            color = TextSecondary
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Large timer display
        Text(
            text = timeString,
            fontSize = 56.sp,
            fontWeight = FontWeight.Bold,
            color = CoreViaPrimary,
            textAlign = TextAlign.Center,
            letterSpacing = 2.sp
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Pause/Resume button
        FilledTonalButton(
            onClick = onToggle,
            modifier = Modifier.height(44.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.filledTonalButtonColors(
                containerColor = if (isRunning) AccentOrange.copy(alpha = 0.15f)
                else CoreViaSuccess.copy(alpha = 0.15f)
            )
        ) {
            Icon(
                if (isRunning) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = if (isRunning) AccentOrange else CoreViaSuccess
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = if (isRunning) "Dayandır" else "Davam et",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = if (isRunning) AccentOrange else CoreViaSuccess
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Exercise List Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun ExerciseListCard(isDark: Boolean) {
    // Placeholder exercises — will be replaced by real data from WebSocket
    val exercises = listOf(
        ExercisePlaceholder("Squat", "4 set x 12 təkrar", Icons.Filled.FitnessCenter),
        ExercisePlaceholder("Bench Press", "3 set x 10 təkrar", Icons.Filled.FitnessCenter),
        ExercisePlaceholder("Deadlift", "3 set x 8 təkrar", Icons.Filled.FitnessCenter),
        ExercisePlaceholder("Plank", "3 set x 45 saniyə", Icons.Filled.Timer),
        ExercisePlaceholder("Burpees", "3 set x 15 təkrar", Icons.Filled.DirectionsRun)
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.08f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(if (isDark) CoreViaSurfaceNight else CoreViaSurface)
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(
            text = "Hərəkətlər",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSurface
        )

        Spacer(modifier = Modifier.height(8.dp))

        exercises.forEachIndexed { index, exercise ->
            ExerciseRow(
                index = index + 1,
                exercise = exercise,
                isDark = isDark
            )

            if (index < exercises.lastIndex) {
                HorizontalDivider(
                    modifier = Modifier.padding(vertical = 8.dp),
                    color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
                    thickness = 0.5.dp
                )
            }
        }
    }
}

private data class ExercisePlaceholder(
    val name: String,
    val detail: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector
)

@Composable
private fun ExerciseRow(
    index: Int,
    exercise: ExercisePlaceholder,
    isDark: Boolean
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Number badge
        Box(
            modifier = Modifier
                .size(32.dp)
                .clip(CircleShape)
                .background(CoreViaPrimary.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "$index",
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
        }

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = exercise.name,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = exercise.detail,
                fontSize = 13.sp,
                color = TextSecondary
            )
        }

        Icon(
            exercise.icon,
            contentDescription = null,
            modifier = Modifier.size(20.dp),
            tint = TextSecondary.copy(alpha = 0.5f)
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Connection Status Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun ConnectionStatusCard(isDark: Boolean) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.08f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(if (isDark) CoreViaSurfaceNight else CoreViaSurface)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Box(
            modifier = Modifier
                .size(10.dp)
                .clip(CircleShape)
                .background(CoreViaSuccess)
        )
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = "Bağlantı aktiv",
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = "WebSocket inteqrasiyası tezliklə gələcək",
                fontSize = 12.sp,
                color = TextHint
            )
        }
        Icon(
            Icons.Filled.Wifi,
            contentDescription = null,
            modifier = Modifier.size(20.dp),
            tint = CoreViaSuccess
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - End Workout Button
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun EndWorkoutButton(onClick: () -> Unit) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shadowElevation = 8.dp,
        color = MaterialTheme.colorScheme.surface
    ) {
        Button(
            onClick = onClick,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp)
                .height(52.dp),
            shape = RoundedCornerShape(16.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = CoreViaError,
                contentColor = Color.White
            )
        ) {
            Icon(
                Icons.Filled.Stop,
                contentDescription = null,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "Bitir",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}
