package life.corevia.app.ui.food

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
import life.corevia.app.data.models.FoodEntry
import life.corevia.app.data.models.MealType

/**
 * iOS EditFoodView — movcud qida girishini duzeltmek
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditFoodSheet(
    entry: FoodEntry,
    onDismiss: () -> Unit,
    onSave: (
        name: String,
        calories: Int,
        protein: Double?,
        carbs: Double?,
        fats: Double?,
        mealType: String,
        notes: String?
    ) -> Unit
) {
    var name by remember { mutableStateOf(entry.name) }
    var caloriesText by remember { mutableStateOf(entry.calories.toString()) }
    var proteinText by remember { mutableStateOf(entry.protein?.toString() ?: "") }
    var carbsText by remember { mutableStateOf(entry.carbs?.toString() ?: "") }
    var fatsText by remember { mutableStateOf(entry.fats?.toString() ?: "") }
    var notes by remember { mutableStateOf(entry.notes ?: "") }
    var selectedMealType by remember { mutableStateOf(entry.mealType) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
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
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Text(
                text = "Qidani Duzelis Et",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )

            // ─── Ogun tipi ─────────────────────────────────────────────
            Text(text = "Ogun", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                MealType.entries.forEach { meal ->
                    val label = when (meal) {
                        MealType.BREAKFAST -> "🌅 Seher"
                        MealType.LUNCH     -> "☀️ Nahar"
                        MealType.DINNER    -> "🌙 Axsham"
                        MealType.SNACK     -> "🍿 Ara"
                    }
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .background(
                                if (selectedMealType == meal.value) AppTheme.Colors.success
                                else AppTheme.Colors.secondaryBackground,
                                RoundedCornerShape(8.dp)
                            )
                            .clickable { selectedMealType = meal.value }
                            .padding(vertical = 8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = label,
                            color = if (selectedMealType == meal.value) Color.White
                            else AppTheme.Colors.secondaryText,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }

            // ─── Qida adi ────────────────────────────────────────────────
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Qida adi", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = editFoodTextFieldColors(),
                singleLine = true
            )

            // ─── Kalori ───────────────────────────────────────────────────
            OutlinedTextField(
                value = caloriesText,
                onValueChange = { caloriesText = it.filter { c -> c.isDigit() } },
                label = { Text("Kalori (kal) *", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = editFoodTextFieldColors(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true
            )

            // ─── Makro ──────────────────────────────────────────────────
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = proteinText,
                    onValueChange = { proteinText = it },
                    label = { Text("Protein(g)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    colors = editFoodTextFieldColors(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
                OutlinedTextField(
                    value = carbsText,
                    onValueChange = { carbsText = it },
                    label = { Text("Karbo(g)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    colors = editFoodTextFieldColors(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
                OutlinedTextField(
                    value = fatsText,
                    onValueChange = { fatsText = it },
                    label = { Text("Yag(g)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    colors = editFoodTextFieldColors(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
            }

            // ─── Qeyd ─────────────────────────────────────────────────────
            OutlinedTextField(
                value = notes,
                onValueChange = { notes = it },
                label = { Text("Qeyd (ixtiyari)", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = editFoodTextFieldColors(),
                maxLines = 2
            )

            // ─── Saxla ─────────────────────────────────────────────────────
            Button(
                onClick = {
                    val calories = caloriesText.toIntOrNull() ?: return@Button
                    onSave(
                        name.trim(),
                        calories,
                        proteinText.toDoubleOrNull(),
                        carbsText.toDoubleOrNull(),
                        fatsText.toDoubleOrNull(),
                        selectedMealType,
                        notes.trim().ifEmpty { null }
                    )
                },
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                enabled = name.isNotBlank() && caloriesText.isNotBlank()
            ) {
                Text("Yenile", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = Color.White)
            }
        }
    }
}

@Composable
private fun editFoodTextFieldColors() = OutlinedTextFieldDefaults.colors(
    focusedBorderColor = AppTheme.Colors.accent,
    unfocusedBorderColor = AppTheme.Colors.separator,
    focusedTextColor = AppTheme.Colors.primaryText,
    unfocusedTextColor = AppTheme.Colors.primaryText,
    cursorColor = AppTheme.Colors.accent
)
