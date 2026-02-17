package life.corevia.app.ui.workout

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.Workout
import life.corevia.app.ui.home.StatCard

/**
 * iOS WorkoutView.swift-in Android ekvivalenti.
 *
 * Screen yalnız ViewModel-dən oxuyur.
 * ViewModel dəyişsə bu fayl silinmir — yalnız state adları güncəllənir.
 */
@Composable
fun WorkoutScreen(
    onNavigateToLiveTracking: () -> Unit,
    viewModel: WorkoutViewModel = viewModel()
) {
    val workouts by viewModel.workouts.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val showAddWorkout by viewModel.showAddWorkout.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()

    // iOS: weekSummarySection hesablamaları
    val weeklyMinutes = viewModel.weeklyMinutes
    val weeklyCalories = viewModel.weeklyCaloriesBurned
    val weekCount = viewModel.weekWorkoutCount
    val completedCount = workouts.count { it.isCompleted }

    Scaffold(
        containerColor = AppTheme.Colors.background,
        floatingActionButton = {
            FloatingActionButton(
                onClick = { viewModel.setShowAddWorkout(true) },
                containerColor = AppTheme.Colors.accent,
                shape = CircleShape
            ) {
                Icon(Icons.Default.Add, contentDescription = "Məşq əlavə et", tint = Color.White)
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // ─── Başlıq ───────────────────────────────────────────────────────
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Məşqlər",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                // iOS: GPS tracking button (premium)
                TextButton(onClick = onNavigateToLiveTracking) {
                    Text(text = "📍 GPS", color = AppTheme.Colors.accent)
                }
            }

            // ─── Həftəlik statistika ──────────────────────────────────────────
            // iOS: weekSummarySection
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                StatCard(
                    modifier = Modifier.weight(1f),
                    value = "$weekCount",
                    label = "Bu həftə",
                    color = AppTheme.Colors.accent
                )
                StatCard(
                    modifier = Modifier.weight(1f),
                    value = "$completedCount",
                    label = "Tamamlandı",
                    color = AppTheme.Colors.success
                )
                StatCard(
                    modifier = Modifier.weight(1f),
                    value = "$weeklyMinutes",
                    label = "Dəqiqə",
                    color = AppTheme.Colors.warning
                )
                StatCard(
                    modifier = Modifier.weight(1f),
                    value = "$weeklyCalories",
                    label = "Kalori",
                    color = AppTheme.Colors.error
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // ─── Xəta mesajı ─────────────────────────────────────────────────
            errorMessage?.let { msg ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp),
                    colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.error.copy(alpha = 0.15f))
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(text = msg, color = AppTheme.Colors.error, modifier = Modifier.weight(1f))
                        TextButton(onClick = { viewModel.clearError() }) {
                            Text("X", color = AppTheme.Colors.error)
                        }
                    }
                }
            }

            // ─── Məşq siyahısı ────────────────────────────────────────────────
            if (isLoading && workouts.isEmpty()) {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = AppTheme.Colors.accent)
                }
            } else if (workouts.isEmpty()) {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(text = "🏋️", fontSize = 48.sp)
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = "Hələ məşq yoxdur",
                            color = AppTheme.Colors.secondaryText,
                            fontSize = 16.sp
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "+ düyməsi ilə əlavə edin",
                            color = AppTheme.Colors.accent,
                            fontSize = 14.sp
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(workouts, key = { it.id }) { workout ->
                        WorkoutCard(
                            workout = workout,
                            onToggleComplete = { viewModel.toggleComplete(workout) },
                            onDelete = { viewModel.deleteWorkout(workout.id) }
                        )
                    }
                    item { Spacer(modifier = Modifier.height(80.dp)) }
                }
            }
        }
    }

    // ─── Add Workout Bottom Sheet ─────────────────────────────────────────────
    if (showAddWorkout) {
        AddWorkoutSheet(
            onDismiss = { viewModel.setShowAddWorkout(false) },
            onSave = { title, category, duration, calories, notes ->
                viewModel.addWorkout(title, category, duration, calories, notes)
            }
        )
    }
}

// ─── WorkoutCard ──────────────────────────────────────────────────────────────
// iOS: WorkoutCard view
@Composable
fun WorkoutCard(
    workout: Workout,
    onToggleComplete: () -> Unit,
    onDelete: () -> Unit
) {
    var showDeleteConfirm by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Tamamlandı checkbox
            Checkbox(
                checked = workout.isCompleted,
                onCheckedChange = { onToggleComplete() },
                colors = CheckboxDefaults.colors(
                    checkedColor = AppTheme.Colors.success,
                    uncheckedColor = AppTheme.Colors.tertiaryText
                )
            )

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = workout.title,
                    color = Color.White,
                    fontWeight = FontWeight.Medium,
                    fontSize = 15.sp
                )
                Text(
                    text = "${workout.duration} dəq · ${workout.category}",
                    color = AppTheme.Colors.secondaryText,
                    fontSize = 13.sp
                )
                workout.caloriesBurned?.let {
                    Text(
                        text = "🔥 $it kal",
                        color = AppTheme.Colors.error,
                        fontSize = 12.sp
                    )
                }
            }

            IconButton(onClick = { showDeleteConfirm = true }) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Sil",
                    tint = AppTheme.Colors.tertiaryText
                )
            }
        }
    }

    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            containerColor = AppTheme.Colors.secondaryBackground,
            title = { Text("Silinsin?", color = Color.White) },
            text = { Text("\"${workout.title}\" silinəcək.", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = {
                    onDelete()
                    showDeleteConfirm = false
                }) {
                    Text("Sil", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirm = false }) {
                    Text("Ləğv et", color = AppTheme.Colors.accent)
                }
            }
        )
    }
}
