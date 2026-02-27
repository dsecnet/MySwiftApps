package life.corevia.app.ui.plans

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.TrainingPlanType
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddTrainingPlanScreen(
    onBack: () -> Unit,
    viewModel: TrainingPlanViewModel = hiltViewModel()
) {
    val state by viewModel.addState.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.resetAddState()
        viewModel.loadStudents()
    }

    LaunchedEffect(state.isSaved) {
        if (state.isSaved) onBack()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Yeni Mesq Plani", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Filled.Close, contentDescription = "Bagla")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // ── Title ──
            Text("Plan adi", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            OutlinedTextField(
                value = state.title,
                onValueChange = viewModel::updateTitle,
                placeholder = { Text("mes: Haftelik guc proqrami", color = TextHint) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
            )

            // ── Plan Type ──
            Text("Plan novu", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                TrainingPlanType.entries.forEach { type ->
                    val selected = state.selectedPlanType == type
                    val color = when (type) {
                        TrainingPlanType.WEIGHT_LOSS -> PlanWeightLoss
                        TrainingPlanType.WEIGHT_GAIN -> PlanWeightGain
                        TrainingPlanType.STRENGTH_TRAINING -> PlanStrength
                    }
                    val icon = when (type) {
                        TrainingPlanType.WEIGHT_LOSS -> Icons.Filled.TrendingDown
                        TrainingPlanType.WEIGHT_GAIN -> Icons.Filled.TrendingUp
                        TrainingPlanType.STRENGTH_TRAINING -> Icons.Filled.FitnessCenter
                    }

                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (selected) color.copy(alpha = 0.15f) else CoreViaSurface)
                            .border(
                                width = if (selected) 2.dp else 1.dp,
                                color = if (selected) color else TextSeparator,
                                shape = RoundedCornerShape(12.dp)
                            )
                            .clickable { viewModel.updatePlanType(type) }
                            .padding(vertical = 14.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(icon, contentDescription = null, tint = if (selected) color else TextSecondary, modifier = Modifier.size(24.dp))
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(type.displayName, fontSize = 11.sp, color = if (selected) color else TextSecondary, fontWeight = FontWeight.Medium)
                    }
                }
            }

            // ── Student Assignment ──
            if (state.students.isNotEmpty()) {
                Text("Telebeye teyin et", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
                var expanded by remember { mutableStateOf(false) }
                ExposedDropdownMenuBox(expanded = expanded, onExpandedChange = { expanded = !expanded }) {
                    OutlinedTextField(
                        value = state.students.find { it.first == state.assignedStudentId }?.second ?: "Secilmeyib",
                        onValueChange = {},
                        readOnly = true,
                        modifier = Modifier.fillMaxWidth().menuAnchor(),
                        shape = RoundedCornerShape(12.dp),
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded) },
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
                    )
                    ExposedDropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                        DropdownMenuItem(text = { Text("Secilmeyib") }, onClick = { viewModel.updateAssignedStudent(null); expanded = false })
                        state.students.forEach { (id, name) ->
                            DropdownMenuItem(text = { Text(name) }, onClick = { viewModel.updateAssignedStudent(id); expanded = false })
                        }
                    }
                }
            }

            // ── Exercises ──
            Text("Mesqler (${state.workouts.size})", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = TextPrimary)

            // Existing exercises list
            state.workouts.forEachIndexed { index, exercise ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = CoreViaSurface)
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(exercise.name, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = TextPrimary)
                            Text(
                                "${exercise.sets} set x ${exercise.reps} tekrar" +
                                        (exercise.duration?.let { " / $it deq" } ?: ""),
                                fontSize = 12.sp, color = TextSecondary
                            )
                        }
                        IconButton(onClick = { viewModel.removeExercise(index) }) {
                            Icon(Icons.Filled.RemoveCircle, contentDescription = "Sil", tint = CoreViaError, modifier = Modifier.size(22.dp))
                        }
                    }
                }
            }

            // ── Add Exercise Form ──
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = CoreViaPrimary.copy(alpha = 0.05f))
            ) {
                Column(
                    modifier = Modifier.padding(14.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Text("Yeni mesq elave et", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = CoreViaPrimary)
                    OutlinedTextField(
                        value = state.exerciseName,
                        onValueChange = viewModel::updateExerciseName,
                        placeholder = { Text("Mesq adi", color = TextHint) },
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp),
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
                    )
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        OutlinedTextField(
                            value = state.exerciseSets.toString(),
                            onValueChange = { viewModel.updateExerciseSets(it.filter { c -> c.isDigit() }.toIntOrNull() ?: 3) },
                            label = { Text("Set") },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(10.dp),
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
                        )
                        OutlinedTextField(
                            value = state.exerciseReps.toString(),
                            onValueChange = { viewModel.updateExerciseReps(it.filter { c -> c.isDigit() }.toIntOrNull() ?: 10) },
                            label = { Text("Tekrar") },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(10.dp),
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
                        )
                        OutlinedTextField(
                            value = if (state.exerciseDuration > 0) state.exerciseDuration.toString() else "",
                            onValueChange = { viewModel.updateExerciseDuration(it.filter { c -> c.isDigit() }.toIntOrNull() ?: 0) },
                            label = { Text("Deq") },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(10.dp),
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
                        )
                    }
                    Button(
                        onClick = { viewModel.addExercise() },
                        enabled = state.exerciseName.trim().isNotEmpty(),
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary.copy(alpha = 0.8f))
                    ) {
                        Icon(Icons.Filled.Add, contentDescription = null, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Elave et")
                    }
                }
            }

            // ── Notes ──
            Text("Qeydler", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            OutlinedTextField(
                value = state.notes,
                onValueChange = viewModel::updateNotes,
                placeholder = { Text("Elave qeydler...", color = TextHint) },
                modifier = Modifier.fillMaxWidth().height(80.dp),
                shape = RoundedCornerShape(12.dp),
                maxLines = 3,
                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
            )

            // ── Error ──
            state.errorMessage?.let { Text(it, color = CoreViaError, fontSize = 13.sp) }

            // ── Save ──
            Button(
                onClick = { viewModel.savePlan() },
                enabled = state.isFormValid && !state.isLoading,
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary, disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f))
            ) {
                if (state.isLoading) {
                    CircularProgressIndicator(modifier = Modifier.size(22.dp), color = Color.White, strokeWidth = 2.dp)
                } else {
                    Icon(Icons.Filled.Check, contentDescription = null, tint = Color.White)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Plani yadda saxla", fontWeight = FontWeight.Bold, color = Color.White)
                }
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}
