package life.corevia.app.ui.workout

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.DirectionsRun
import androidx.compose.material.icons.outlined.*
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
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.Workout
import life.corevia.app.data.models.WorkoutCategory
import life.corevia.app.data.models.WorkoutUpdateRequest

/**
 * iOS EditWorkoutView.swift — Android 1-ə-1 port (BottomSheet)
 *
 * AddWorkoutSheet ilə eyni dizayn, amma mövcud məlumatlarla doldurulur.
 * Dəyişiklikləri WorkoutUpdateRequest olaraq qaytarır.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditWorkoutSheet(
    workout: Workout,
    onDismiss: () -> Unit,
    onSave: (String, WorkoutUpdateRequest) -> Unit
) {
    var title by remember { mutableStateOf(workout.title) }
    var selectedCategory by remember { mutableStateOf(workout.category) }
    var duration by remember { mutableIntStateOf(workout.duration) }
    var caloriesText by remember { mutableStateOf(workout.caloriesBurned?.toString() ?: "") }
    var notes by remember { mutableStateOf(workout.notes ?: "") }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor   = AppTheme.Colors.background,
        dragHandle       = {
            Box(
                modifier = Modifier
                    .padding(vertical = 8.dp)
                    .size(width = 40.dp, height = 4.dp)
                    .background(AppTheme.Colors.separator, RoundedCornerShape(2.dp))
            )
        }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Title ────────────────────────────────────────────────────────────
            Text(
                text       = "Məşqi Redaktə Et",
                fontSize   = 22.sp,
                fontWeight = FontWeight.Bold,
                color      = AppTheme.Colors.primaryText
            )

            // ── Məşq adı ─────────────────────────────────────────────────────────
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Məşq adı", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value         = title,
                    onValueChange = { if (it.length <= 200) title = it },
                    placeholder   = { Text("məs: Biceps Training", color = AppTheme.Colors.tertiaryText) },
                    modifier      = Modifier.fillMaxWidth(),
                    shape         = RoundedCornerShape(12.dp),
                    colors        = editSheetTextFieldColors(),
                    singleLine    = true
                )
            }

            // ── Category ──────────────────────────────────────────────────────────
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Kateqoriya", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    WorkoutCategory.entries.forEach { cat ->
                        EditCategoryButton(
                            modifier   = Modifier.weight(1f),
                            icon       = when (cat) {
                                WorkoutCategory.CARDIO      -> Icons.AutoMirrored.Outlined.DirectionsRun
                                WorkoutCategory.STRENGTH    -> Icons.Outlined.FitnessCenter
                                WorkoutCategory.FLEXIBILITY -> Icons.Outlined.SelfImprovement
                                WorkoutCategory.ENDURANCE   -> Icons.Outlined.Speed
                            },
                            label      = when (cat) {
                                WorkoutCategory.CARDIO      -> "Kardio"
                                WorkoutCategory.STRENGTH    -> "Güc"
                                WorkoutCategory.FLEXIBILITY -> "Elastik"
                                WorkoutCategory.ENDURANCE   -> "Dözüm"
                            },
                            isSelected = selectedCategory == cat.value,
                            onClick    = { selectedCategory = cat.value }
                        )
                    }
                }
            }

            // ── Duration Stepper ──────────────────────────────────────────────────
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Müddət", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                        .padding(16.dp),
                    verticalAlignment     = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Icon(
                        imageVector        = Icons.Outlined.RemoveCircle,
                        contentDescription = "Azalt",
                        modifier = Modifier
                            .size(32.dp)
                            .clickable { if (duration > 5) duration -= 5 },
                        tint = AppTheme.Colors.accent
                    )
                    Text(
                        text       = "$duration dəq",
                        fontSize   = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color      = AppTheme.Colors.primaryText
                    )
                    Icon(
                        imageVector        = Icons.Outlined.AddCircle,
                        contentDescription = "Artır",
                        modifier = Modifier
                            .size(32.dp)
                            .clickable { if (duration < 1440) duration += 5 },
                        tint = if (duration >= 1440) AppTheme.Colors.tertiaryText
                               else AppTheme.Colors.accent
                    )
                }
            }

            // ── Calories ──────────────────────────────────────────────────────────
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Kalori (istəyə bağlı)", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value         = caloriesText,
                    onValueChange = {
                        val filtered = it.filter { c -> c.isDigit() }
                        if ((filtered.toIntOrNull() ?: 0) <= 10000) caloriesText = filtered
                    },
                    placeholder   = { Text("məs: 250", color = AppTheme.Colors.tertiaryText) },
                    modifier      = Modifier.fillMaxWidth(),
                    shape         = RoundedCornerShape(12.dp),
                    colors        = editSheetTextFieldColors(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine    = true
                )
            }

            // ── Notes ─────────────────────────────────────────────────────────────
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Qeydlər (istəyə bağlı)", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value         = notes,
                    onValueChange = { if (it.length <= 1000) notes = it },
                    placeholder   = { Text("Əlavə qeydlər...", color = AppTheme.Colors.tertiaryText) },
                    modifier      = Modifier
                        .fillMaxWidth()
                        .heightIn(min = 80.dp),
                    shape         = RoundedCornerShape(12.dp),
                    colors        = editSheetTextFieldColors(),
                    minLines      = 3,
                    maxLines      = 5
                )
            }

            // ── Save Button ───────────────────────────────────────────────────────
            val isValid = title.isNotBlank() && duration >= 5
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp)
                    .then(
                        if (isValid) Modifier.shadow(
                            8.dp, RoundedCornerShape(12.dp),
                            spotColor = AppTheme.Colors.accent.copy(alpha = 0.4f)
                        ) else Modifier
                    )
                    .background(
                        brush  = Brush.horizontalGradient(
                            colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.8f))
                        ),
                        shape  = RoundedCornerShape(12.dp),
                        alpha  = if (isValid) 1f else 0.5f
                    )
                    .clip(RoundedCornerShape(12.dp))
                    .then(
                        if (isValid) Modifier.clickable {
                            val calories = caloriesText.toIntOrNull()
                            val request = WorkoutUpdateRequest(
                                title          = title.trim(),
                                category       = selectedCategory,
                                duration       = duration,
                                caloriesBurned = calories,
                                notes          = notes.trim().ifEmpty { null },
                                isCompleted    = null // don't change completion status from edit
                            )
                            onSave(workout.id, request)
                        } else Modifier
                    )
                    .padding(vertical = 14.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text       = "Yadda saxla",
                    fontSize   = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color      = Color.White
                )
            }
        }
    }
}

// ─── iOS: CategoryButton (reused style from AddWorkoutSheet) ─────────────────
@Composable
private fun EditCategoryButton(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .aspectRatio(1f)
            .clip(RoundedCornerShape(14.dp))
            .background(
                if (isSelected) Brush.linearGradient(
                    colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.7f))
                ) else Brush.linearGradient(
                    colors = listOf(AppTheme.Colors.secondaryBackground, AppTheme.Colors.secondaryBackground)
                ),
                shape = RoundedCornerShape(14.dp)
            )
            .then(
                if (isSelected) Modifier.border(2.dp, AppTheme.Colors.accent, RoundedCornerShape(14.dp))
                else Modifier.border(1.dp, AppTheme.Colors.separator, RoundedCornerShape(14.dp))
            )
            .clickable { onClick() }
            .padding(8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector        = icon,
            contentDescription = null,
            modifier           = Modifier.size(24.dp),
            tint               = if (isSelected) Color.White else AppTheme.Colors.secondaryText
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text      = label,
            fontSize  = 10.sp,
            color     = if (isSelected) Color.White else AppTheme.Colors.secondaryText,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
            textAlign = TextAlign.Center,
            maxLines  = 1
        )
    }
}

// ─── Shared TextField Colors ─────────────────────────────────────────────────
@Composable
private fun editSheetTextFieldColors() = OutlinedTextFieldDefaults.colors(
    focusedBorderColor   = AppTheme.Colors.accent,
    unfocusedBorderColor = AppTheme.Colors.separator,
    focusedTextColor     = AppTheme.Colors.primaryText,
    unfocusedTextColor   = AppTheme.Colors.primaryText,
    cursorColor          = AppTheme.Colors.accent
)
