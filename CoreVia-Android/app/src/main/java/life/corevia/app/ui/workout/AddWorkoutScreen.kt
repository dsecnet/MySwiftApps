package life.corevia.app.ui.workout

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.WorkoutType
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddWorkoutScreen(
    onBack: () -> Unit,
    viewModel: AddWorkoutViewModel = hiltViewModel()
) {
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state.isSaved) {
        if (state.isSaved) onBack()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Yeni Məşq", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Filled.Close, contentDescription = "Bağla")
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
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // ── Title ──
            SectionLabel("Məşq adı")
            OutlinedTextField(
                value = state.title,
                onValueChange = viewModel::updateTitle,
                placeholder = { Text("məs: Biceps Training", color = TextHint) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary,
                    unfocusedBorderColor = TextSeparator
                )
            )

            // ── Category ──
            SectionLabel("Kateqoriya")
            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(WorkoutType.entries.toList()) { category ->
                    WorkoutCategoryCard(
                        type = category,
                        isSelected = state.selectedCategory == category,
                        onClick = { viewModel.updateCategory(category) }
                    )
                }
            }

            // ── Duration ──
            SectionLabel("Müddət")
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(CoreViaSurface)
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = { viewModel.decreaseDuration() }) {
                    Icon(
                        Icons.Filled.RemoveCircle,
                        contentDescription = "Azalt",
                        tint = CoreViaPrimary,
                        modifier = Modifier.size(32.dp)
                    )
                }
                Text(
                    "${state.duration} dəq",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
                IconButton(onClick = { viewModel.increaseDuration() }) {
                    Icon(
                        Icons.Filled.AddCircle,
                        contentDescription = "Artır",
                        tint = if (state.duration >= 1440) TextHint else CoreViaPrimary,
                        modifier = Modifier.size(32.dp)
                    )
                }
            }

            // ── Calories (Optional) ──
            SectionLabel("Kalori (isteğe bağlı)")
            OutlinedTextField(
                value = state.caloriesBurned,
                onValueChange = viewModel::updateCalories,
                placeholder = { Text("məs: 250", color = TextHint) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary,
                    unfocusedBorderColor = TextSeparator
                )
            )

            // ── Notes (Optional) ──
            SectionLabel("Qeydlər")
            OutlinedTextField(
                value = state.notes,
                onValueChange = viewModel::updateNotes,
                placeholder = { Text("Əlavə qeydlər...", color = TextHint) },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp),
                shape = RoundedCornerShape(12.dp),
                maxLines = 5,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary,
                    unfocusedBorderColor = TextSeparator
                )
            )

            // ── Error Message ──
            state.errorMessage?.let { error ->
                Text(
                    text = error,
                    color = CoreViaError,
                    fontSize = 13.sp,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            // ── Save Button ──
            Button(
                onClick = { viewModel.saveWorkout() },
                enabled = state.isFormValid && !state.isLoading,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CoreViaPrimary,
                    disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f)
                )
            ) {
                if (state.isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(22.dp),
                        color = Color.White,
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(Icons.Filled.Check, contentDescription = null, tint = Color.White)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Yadda saxla", fontWeight = FontWeight.Bold, color = Color.White)
                }
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

@Composable
private fun SectionLabel(text: String) {
    Text(
        text = text,
        fontSize = 14.sp,
        fontWeight = FontWeight.Medium,
        color = TextSecondary
    )
}

@Composable
private fun WorkoutCategoryCard(
    type: WorkoutType,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val bgColor by animateColorAsState(
        if (isSelected) CoreViaPrimary else CoreViaSurface, label = "catBg"
    )
    val textColor = if (isSelected) Color.White else TextSecondary

    val icon = when (type) {
        WorkoutType.STRENGTH -> Icons.Filled.FitnessCenter
        WorkoutType.CARDIO -> Icons.Filled.Favorite
        WorkoutType.FLEXIBILITY -> Icons.Filled.SelfImprovement
        WorkoutType.HIIT -> Icons.Filled.FlashOn
        WorkoutType.YOGA -> Icons.Filled.SelfImprovement
        WorkoutType.ENDURANCE -> Icons.Filled.DirectionsRun
    }

    Column(
        modifier = Modifier
            .width(80.dp)
            .height(80.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(bgColor)
            .border(
                width = if (isSelected) 2.dp else 1.dp,
                color = if (isSelected) CoreViaPrimary else TextSeparator,
                shape = RoundedCornerShape(12.dp)
            )
            .clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(icon, contentDescription = type.displayName, tint = textColor, modifier = Modifier.size(28.dp))
        Spacer(modifier = Modifier.height(4.dp))
        Text(type.displayName, fontSize = 11.sp, color = textColor, fontWeight = FontWeight.Medium)
    }
}
