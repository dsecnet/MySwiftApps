package life.corevia.app.ui.workout

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import life.corevia.app.data.model.Workout
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WorkoutScreen(
    viewModel: WorkoutViewModel = hiltViewModel(),
    onNavigateToGPS: () -> Unit = {},
    onNavigateToAddWorkout: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    // Reload data every time screen appears (e.g. returning from GPS)
    val lifecycleOwner = androidx.compose.ui.platform.LocalLifecycleOwner.current
    androidx.compose.runtime.DisposableEffect(lifecycleOwner) {
        val observer = androidx.lifecycle.LifecycleEventObserver { _, event ->
            if (event == androidx.lifecycle.Lifecycle.Event.ON_RESUME) {
                viewModel.loadWorkouts()
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    PullToRefreshBox(
        isRefreshing = uiState.isLoading,
        onRefresh = { viewModel.loadWorkouts() }
    ) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 160.dp)
        ) {
            Column(
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Spacer(modifier = Modifier.height(48.dp))

                // Header
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        text = "Məşq İzləmə",
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = "Həftəlik Xülasə",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                // Weekly Summary Stats (2x2 grid)
                WeeklySummarySection(
                    workoutCount = uiState.weekWorkoutCount,
                    completedCount = uiState.weekCompletedCount,
                    totalMinutes = uiState.weekTotalMinutes,
                    totalCalories = uiState.weekTotalCalories
                )

                // Daily Goal Progress
                DailyGoalSection(
                    progress = uiState.todayProgress,
                    calories = uiState.todayTotalCalories,
                    minutes = uiState.todayTotalMinutes
                )

                // Today's Workouts
                if (uiState.todayWorkouts.isNotEmpty()) {
                    WorkoutsSection(
                        title = "Bugünkü Məşqlər",
                        workouts = uiState.todayWorkouts,
                        onToggle = viewModel::toggleCompletion,
                        onDelete = viewModel::deleteWorkout
                    )
                }

                // Completed
                if (uiState.completedWorkouts.isNotEmpty()) {
                    WorkoutsSection(
                        title = "Tamamlanan",
                        workouts = uiState.completedWorkouts,
                        onToggle = viewModel::toggleCompletion,
                        onDelete = viewModel::deleteWorkout
                    )
                }

                // Error state
                if (!uiState.isLoading && uiState.error != null && uiState.workouts.isEmpty()) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 40.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Icon(
                            Icons.Filled.WifiOff,
                            contentDescription = "Bağlantı xətası",
                            modifier = Modifier.size(48.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                        )
                        Text(
                            text = uiState.error ?: "",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Medium,
                            color = MaterialTheme.colorScheme.onBackground,
                            textAlign = TextAlign.Center
                        )
                        Button(
                            onClick = { viewModel.loadWorkouts() },
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
                        ) {
                            Icon(Icons.Filled.Refresh, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("Yenidən cəhd et", fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                        }
                    }
                }

                // Empty state
                if (!uiState.isLoading && uiState.error == null && uiState.workouts.isEmpty()) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 40.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Icon(
                            Icons.Filled.FitnessCenter, null,
                            modifier = Modifier.size(48.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                        )
                        Text(
                            text = "Hələ məşq yoxdur",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        Text(
                            text = "Məşq əlavə edərək başlayın",
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
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
                        CircularProgressIndicator(color = CoreViaPrimary, modifier = Modifier.size(32.dp))
                    }
                }
            }
        }

        // Bottom Bar — GPS + Add Workout
        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.background)
                .padding(horizontal = 16.dp, vertical = 12.dp)
                .padding(bottom = 68.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // GPS Button
            Button(
                onClick = onNavigateToGPS,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaSuccess)
            ) {
                Icon(Icons.Filled.MyLocation, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("GPS ilə Qaçış/Gəzinti", fontSize = 15.sp, fontWeight = FontWeight.Bold)
            }

            // Add Workout Button
            Button(
                onClick = onNavigateToAddWorkout,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
            ) {
                Icon(Icons.Filled.Add, null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Məşq Əlavə Et", fontSize = 15.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
    } // PullToRefreshBox

    // Add Workout Sheet
    if (uiState.showAddWorkout) {
        AddWorkoutSheet(
            onDismiss = viewModel::toggleAddSheet,
            onAdd = viewModel::addWorkout
        )
    }
}

// ─── Weekly Summary ─────────────────────────────────────────────────

@Composable
private fun WeeklySummarySection(
    workoutCount: Int,
    completedCount: Int,
    totalMinutes: Int,
    totalCalories: Int
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            WeekStatCard(Modifier.weight(1f), "$workoutCount", "Məşq", CoreViaPrimary)
            WeekStatCard(Modifier.weight(1f), "$completedCount", "Tamamlandı", CoreViaSuccess)
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            WeekStatCard(Modifier.weight(1f), "$totalMinutes dəq", "Müddət", CoreViaPrimary)
            WeekStatCard(Modifier.weight(1f), "$totalCalories", "Kalori", Color(0xFFFF9800))
        }
    }
}

@Composable
private fun WeekStatCard(modifier: Modifier, value: String, label: String, color: Color) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(text = value, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = color)
        Text(text = label, fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

// ─── Daily Goal ─────────────────────────────────────────────────────

@Composable
private fun DailyGoalSection(progress: Float, calories: Int, minutes: Int) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("Günlük Hədəf", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.onBackground)
            Text("${(progress * 100).toInt()}%", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = CoreViaPrimary)
        }
        LinearProgressIndicator(
            progress = { progress },
            modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
            color = CoreViaPrimary,
            trackColor = CoreViaPrimary.copy(alpha = 0.12f)
        )
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.LocalFireDepartment, null, modifier = Modifier.size(12.dp), tint = Color(0xFFFF9800))
                Text("$calories kcal", fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Schedule, null, modifier = Modifier.size(12.dp), tint = CoreViaPrimary)
                Text("$minutes dəq", fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}

// ─── Workout Cards ──────────────────────────────────────────────────

@Composable
private fun WorkoutsSection(
    title: String,
    workouts: List<Workout>,
    onToggle: (Workout) -> Unit,
    onDelete: (String) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(title, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.onBackground)
        workouts.forEach { workout ->
            WorkoutCard(workout = workout, onToggle = { onToggle(workout) }, onDelete = { onDelete(workout.id) })
        }
    }
}

@Composable
private fun WorkoutCard(workout: Workout, onToggle: () -> Unit, onDelete: () -> Unit) {
    val color = workoutCategoryColor(workout.category)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .then(
                if (workout.isCompleted) Modifier.border(1.dp, CoreViaSuccess.copy(alpha = 0.3f), RoundedCornerShape(12.dp))
                else Modifier
            )
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Category icon
        Box(
            modifier = Modifier
                .size(42.dp)
                .clip(CircleShape)
                .background(color.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                workoutCategoryIcon(workout.category), null,
                modifier = Modifier.size(20.dp),
                tint = color
            )
        }

        // Info
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(
                text = workout.title,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("${workout.duration} dəq", fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                if (workout.caloriesBurned > 0) {
                    Text("${workout.caloriesBurned} kcal", fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }

        // Toggle check
        Icon(
            if (workout.isCompleted) Icons.Filled.CheckCircle else Icons.Filled.RadioButtonUnchecked,
            contentDescription = if (workout.isCompleted) "Tamamlanıb - geri al" else "Tamamla",
            modifier = Modifier
                .size(24.dp)
                .clickable(onClick = onToggle),
            tint = if (workout.isCompleted) CoreViaSuccess else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
        )
    }
}

// ─── Add Workout Sheet ──────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddWorkoutSheet(
    onDismiss: () -> Unit,
    onAdd: (String, String, Int, Int, String?) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var duration by remember { mutableStateOf("") }
    var calories by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf("strength") }

    val categories = listOf("strength", "cardio", "flexibility", "hiit", "yoga")
    val isValid = title.isNotBlank() && (duration.toIntOrNull() ?: 0) > 0

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("Məşq əlavə et", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onSurface)

            // Category selector
            Text("Kateqoriya", fontSize = 13.sp, fontWeight = FontWeight.Medium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                categories.forEach { cat ->
                    val isSelected = selectedCategory == cat
                    val catColor = workoutCategoryColor(cat)
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(10.dp))
                            .background(if (isSelected) catColor else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                            .clickable { selectedCategory = cat }
                            .padding(vertical = 8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(
                            workoutCategoryIcon(cat), null,
                            modifier = Modifier.size(18.dp),
                            tint = if (isSelected) Color.White else catColor
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            workoutCategoryName(cat),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            OutlinedTextField(
                value = title, onValueChange = { title = it },
                label = { Text("Məşq adı") },
                modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp), singleLine = true
            )

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = duration, onValueChange = { duration = it.filter { c -> c.isDigit() } },
                    label = { Text("Müddət (dəq)") },
                    modifier = Modifier.weight(1f), shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), singleLine = true
                )
                OutlinedTextField(
                    value = calories, onValueChange = { calories = it.filter { c -> c.isDigit() } },
                    label = { Text("Kalori") },
                    modifier = Modifier.weight(1f), shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), singleLine = true
                )
            }

            OutlinedTextField(
                value = notes, onValueChange = { notes = it },
                label = { Text("Qeydlər (ixtiyari)") },
                modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp), maxLines = 2
            )

            Button(
                onClick = {
                    onAdd(title, selectedCategory, duration.toIntOrNull() ?: 0, calories.toIntOrNull() ?: 0, notes.ifBlank { null })
                },
                modifier = Modifier.fillMaxWidth().height(48.dp),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary),
                enabled = isValid
            ) {
                Icon(Icons.Filled.Add, null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Əlavə et", fontSize = 16.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}
