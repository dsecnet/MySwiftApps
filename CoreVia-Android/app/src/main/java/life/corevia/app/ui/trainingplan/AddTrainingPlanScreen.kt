package life.corevia.app.ui.trainingplan

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.*

/**
 * iOS AddTrainingPlanView.swift — Android full-screen port
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddTrainingPlanScreen(
    onBack: () -> Unit,
    onSave: (TrainingPlanCreateRequest) -> Unit,
    students: List<UserResponse> = emptyList(),
    preSelectedStudentId: String? = null
) {
    var title by remember { mutableStateOf("") }
    var selectedPlanType by remember { mutableStateOf(PlanType.WEIGHT_LOSS.value) }
    var selectedStudentId by remember { mutableStateOf(preSelectedStudentId) }
    var notes by remember { mutableStateOf("") }
    var workouts by remember { mutableStateOf(listOf<PlanWorkoutCreateRequest>()) }
    var showAddExercise by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        // ─── Header ─────────────────────────────────────────────────────────
        Spacer(modifier = Modifier.height(56.dp))
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.AutoMirrored.Outlined.ArrowBack, "Geri", tint = Color.White)
            }
            Text(
                text = "Məşq Planı Yarat",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                modifier = Modifier.weight(1f)
            )
            TextButton(
                onClick = {
                    if (title.isNotBlank()) {
                        onSave(
                            TrainingPlanCreateRequest(
                                title = title.trim(),
                                planType = selectedPlanType,
                                notes = notes.ifBlank { null },
                                assignedStudentId = selectedStudentId,
                                workouts = workouts
                            )
                        )
                    }
                },
                enabled = title.isNotBlank()
            ) {
                Text(
                    "Saxla",
                    color = if (title.isNotBlank()) AppTheme.Colors.accent else AppTheme.Colors.tertiaryText,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }

        LazyColumn(
            contentPadding = PaddingValues(horizontal = 20.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ─── Title ──────────────────────────────────────────────────────
            item {
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("Plan adı *", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.accent
                    ),
                    singleLine = true
                )
            }

            // ─── Plan Type ──────────────────────────────────────────────────
            item {
                Text("Plan tipi", color = AppTheme.Colors.secondaryText, fontSize = 13.sp)
                Spacer(modifier = Modifier.height(8.dp))
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(PlanType.entries) { planType ->
                        FilterChip(
                            selected = selectedPlanType == planType.value,
                            onClick = { selectedPlanType = planType.value },
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
                                selectedContainerColor = AppTheme.Colors.accent,
                                selectedLabelColor = Color.White,
                                containerColor = AppTheme.Colors.secondaryBackground,
                                labelColor = AppTheme.Colors.secondaryText
                            )
                        )
                    }
                }
            }

            // ─── Student Selection ──────────────────────────────────────────
            if (students.isNotEmpty()) {
                item {
                    Text("Student seç (ixtiyari)", color = AppTheme.Colors.secondaryText, fontSize = 13.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    Column {
                        // "Heç kim" option
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { selectedStudentId = null }
                                .padding(vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = selectedStudentId == null,
                                onClick = { selectedStudentId = null },
                                colors = RadioButtonDefaults.colors(
                                    selectedColor = AppTheme.Colors.accent,
                                    unselectedColor = AppTheme.Colors.secondaryText
                                )
                            )
                            Text("Heç kim", color = Color.White, fontSize = 14.sp, modifier = Modifier.padding(start = 8.dp))
                        }
                        students.forEach { student ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { selectedStudentId = student.id }
                                    .padding(vertical = 6.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                RadioButton(
                                    selected = selectedStudentId == student.id,
                                    onClick = { selectedStudentId = student.id },
                                    colors = RadioButtonDefaults.colors(
                                        selectedColor = AppTheme.Colors.accent,
                                        unselectedColor = AppTheme.Colors.secondaryText
                                    )
                                )
                                Text(student.name, color = Color.White, fontSize = 14.sp, modifier = Modifier.padding(start = 8.dp))
                            }
                        }
                    }
                }
            }

            // ─── Workouts List ──────────────────────────────────────────────
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Məşqlər (${workouts.size})", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                    TextButton(onClick = { showAddExercise = true }) {
                        Icon(Icons.Outlined.Add, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Əlavə et", color = AppTheme.Colors.accent)
                    }
                }
            }

            items(workouts.size) { index ->
                val workout = workouts[index]
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(workout.name, color = Color.White, fontWeight = FontWeight.Medium, fontSize = 14.sp)
                            Text(
                                "${workout.sets}x${workout.reps}" + (workout.duration?.let { " • ${it} dəq" } ?: ""),
                                color = AppTheme.Colors.secondaryText,
                                fontSize = 12.sp
                            )
                        }
                        IconButton(onClick = {
                            workouts = workouts.toMutableList().also { it.removeAt(index) }
                        }) {
                            Icon(Icons.Outlined.Delete, null, tint = AppTheme.Colors.error, modifier = Modifier.size(18.dp))
                        }
                    }
                }
            }

            // ─── Notes ──────────────────────────────────────────────────────
            item {
                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Qeydlər (ixtiyari)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.accent
                    ),
                    minLines = 3,
                    maxLines = 5
                )
            }

            item { Spacer(modifier = Modifier.height(80.dp)) }
        }
    }

    // ─── Add Exercise Sheet ─────────────────────────────────────────────────
    if (showAddExercise) {
        AddExerciseSheet(
            onDismiss = { showAddExercise = false },
            onAdd = { exercise ->
                workouts = workouts + exercise
                showAddExercise = false
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddExerciseSheet(
    onDismiss: () -> Unit,
    onAdd: (PlanWorkoutCreateRequest) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var sets by remember { mutableStateOf("3") }
    var reps by remember { mutableStateOf("12") }
    var duration by remember { mutableStateOf("") }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppTheme.Colors.background,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppTheme.Colors.secondaryText) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp)
        ) {
            Text("Məşq Əlavə Et", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White)
            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Məşq adı *", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppTheme.Colors.accent,
                    unfocusedBorderColor = AppTheme.Colors.separator,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    cursorColor = AppTheme.Colors.accent
                ),
                singleLine = true
            )
            Spacer(modifier = Modifier.height(12.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value = sets,
                    onValueChange = { sets = it.filter { c -> c.isDigit() } },
                    label = { Text("Set", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.accent
                    ),
                    singleLine = true
                )
                OutlinedTextField(
                    value = reps,
                    onValueChange = { reps = it.filter { c -> c.isDigit() } },
                    label = { Text("Təkrar", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.accent
                    ),
                    singleLine = true
                )
                OutlinedTextField(
                    value = duration,
                    onValueChange = { duration = it.filter { c -> c.isDigit() } },
                    label = { Text("Dəq", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.accent
                    ),
                    singleLine = true
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            Button(
                onClick = {
                    if (name.isNotBlank()) {
                        onAdd(
                            PlanWorkoutCreateRequest(
                                name = name.trim(),
                                sets = sets.toIntOrNull() ?: 3,
                                reps = reps.toIntOrNull() ?: 12,
                                duration = duration.toIntOrNull()
                            )
                        )
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                shape = RoundedCornerShape(12.dp),
                enabled = name.isNotBlank()
            ) {
                Text("Əlavə et", fontWeight = FontWeight.SemiBold)
            }
        }
    }
}
