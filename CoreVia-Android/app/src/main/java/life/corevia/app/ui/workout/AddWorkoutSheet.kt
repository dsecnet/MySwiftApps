package life.corevia.app.ui.workout

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.WorkoutCategory

/**
 * iOS AddWorkoutView.swift-in Android ekvivalenti (BottomSheet kimi).
 *
 * onSave callback ilə WorkoutScreen-ə data ötürür.
 * WorkoutScreen isə ViewModel-ə ötürür.
 * Bu fayl heç bir ViewModel bilmir — tamamilə stateless (yalnız local state).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddWorkoutSheet(
    onDismiss: () -> Unit,
    onSave: (title: String, category: String, duration: Int, calories: Int?, notes: String?) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf(WorkoutCategory.CARDIO.value) }
    var durationText by remember { mutableStateOf("") }
    var caloriesText by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppTheme.Colors.secondaryBackground,
        dragHandle = {
            Box(
                modifier = Modifier
                    .padding(vertical = 8.dp)
                    .size(width = 40.dp, height = 4.dp)
                    .background(AppTheme.Colors.cardBackground, RoundedCornerShape(2.dp))
            )
        }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Məşq Əlavə Et",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )

            // ─── Ad ───────────────────────────────────────────────────────────
            OutlinedTextField(
                value = title,
                onValueChange = { title = it },
                label = { Text("Məşq adı", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = sheetTextFieldColors(),
                singleLine = true
            )

            // ─── Kateqoriya seçimi ────────────────────────────────────────────
            // iOS: CategoryButton row
            Text(text = "Kateqoriya", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                WorkoutCategory.entries.forEach { cat ->
                    CategoryChip(
                        modifier = Modifier.weight(1f),
                        label = when (cat) {
                            WorkoutCategory.CARDIO -> "Kardio"
                            WorkoutCategory.STRENGTH -> "Güc"
                            WorkoutCategory.FLEXIBILITY -> "Elastiklik"
                            WorkoutCategory.ENDURANCE -> "Dözümlülük"
                        },
                        isSelected = selectedCategory == cat.value,
                        onClick = { selectedCategory = cat.value }
                    )
                }
            }

            // ─── Müddət ───────────────────────────────────────────────────────
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedTextField(
                    value = durationText,
                    onValueChange = { durationText = it.filter { c -> c.isDigit() } },
                    label = { Text("Müddət (dəq)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    colors = sheetTextFieldColors(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )
                OutlinedTextField(
                    value = caloriesText,
                    onValueChange = { caloriesText = it.filter { c -> c.isDigit() } },
                    label = { Text("Kalori (kal)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    colors = sheetTextFieldColors(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )
            }

            // ─── Qeydlər ─────────────────────────────────────────────────────
            OutlinedTextField(
                value = notes,
                onValueChange = { notes = it },
                label = { Text("Qeydlər (istəyə bağlı)", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = sheetTextFieldColors(),
                minLines = 2,
                maxLines = 3
            )

            // ─── Saxla düyməsi ────────────────────────────────────────────────
            Button(
                onClick = {
                    val duration = durationText.toIntOrNull() ?: return@Button
                    val calories = caloriesText.toIntOrNull()
                    onSave(
                        title.trim(),
                        selectedCategory,
                        duration,
                        calories,
                        notes.trim().ifEmpty { null }
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                enabled = title.isNotBlank() && durationText.isNotBlank()
            ) {
                Text(
                    text = "Saxla",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

// ─── Köməkçi komponentlər ────────────────────────────────────────────────────

@Composable
private fun CategoryChip(
    modifier: Modifier = Modifier,
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .background(
                if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.secondaryBackground,
                RoundedCornerShape(8.dp)
            )
            .clickable(onClick = onClick)
            .padding(vertical = 8.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            color = if (isSelected) Color.White else AppTheme.Colors.secondaryText,
            fontSize = 11.sp,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
        )
    }
}

@Composable
private fun sheetTextFieldColors() = OutlinedTextFieldDefaults.colors(
    focusedBorderColor = AppTheme.Colors.accent,
    unfocusedBorderColor = AppTheme.Colors.separator,
    focusedTextColor = Color.White,
    unfocusedTextColor = Color.White,
    cursorColor = AppTheme.Colors.accent
)
