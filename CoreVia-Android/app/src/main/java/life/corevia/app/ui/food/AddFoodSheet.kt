package life.corevia.app.ui.food

import life.corevia.app.ui.theme.AppTheme
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.MealType

/**
 * iOS AddFoodView.swift — Android 1-ə-1 port (BottomSheet)
 *
 * Yeni bölmələr:
 *  - Camera section (premium: AI food photo analysis)
 *  - Quick Add: 6 preset foods (egg, banana, chicken, apple, oatmeal, juice)
 *  - Meal type selector
 *  - Food name + calories + macros + notes
 *  - Save button
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddFoodSheet(
    onDismiss: () -> Unit,
    isPremium: Boolean = false,
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
    var name by remember { mutableStateOf("") }
    var caloriesText by remember { mutableStateOf("") }
    var proteinText by remember { mutableStateOf("") }
    var carbsText by remember { mutableStateOf("") }
    var fatsText by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var selectedMealType by remember { mutableStateOf(MealType.LUNCH.value) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppTheme.Colors.background,
        dragHandle = {
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
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Title ──────────────────────────────────────────────────────────
            Text(
                text = "Qida Əlavə Et",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Camera AI Analysis (iOS: cameraSection)
            // ═══════════════════════════════════════════════════════════════════
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = AppTheme.Colors.secondaryBackground
                )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Camera icon circle
                    Box(
                        modifier = Modifier
                            .size(70.dp)
                            .clip(CircleShape)
                            .background(
                                if (isPremium) Brush.linearGradient(
                                    colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.6f))
                                ) else Brush.linearGradient(
                                    colors = listOf(AppTheme.Colors.secondaryText.copy(alpha = 0.3f), AppTheme.Colors.secondaryText.copy(alpha = 0.15f))
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Filled.CameraAlt,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(32.dp)
                        )
                    }

                    Text(
                        text = "AI ilə qida analizi",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = AppTheme.Colors.primaryText
                    )
                    Text(
                        text = "Yeməyin şəklini çəkin, AI kalori və makroları təyin etsin",
                        fontSize = 13.sp,
                        color = AppTheme.Colors.secondaryText,
                        textAlign = TextAlign.Center
                    )

                    if (isPremium) {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .background(AppTheme.Colors.accent)
                                .clickable { /* TODO: Open camera */ }
                                .padding(horizontal = 20.dp, vertical = 10.dp)
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Icon(Icons.Filled.CameraAlt, null, tint = Color.White, modifier = Modifier.size(16.dp))
                                Text("Şəkil çək", color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                            }
                        }
                    } else {
                        // Locked state
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Filled.Lock,
                                contentDescription = null,
                                tint = AppTheme.Colors.secondaryText,
                                modifier = Modifier.size(14.dp)
                            )
                            Text(
                                text = "Premium xüsusiyyəti",
                                fontSize = 13.sp,
                                color = AppTheme.Colors.secondaryText,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Quick Add (iOS: quickAddSection — 6 preset foods)
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Sürətli əlavə",
                    fontSize = 14.sp,
                    color = AppTheme.Colors.secondaryText
                )

                // iOS: 2 rows of 3 QuickAddButton
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "🥚",
                            name = "Yumurta",
                            calories = 78,
                            onClick = {
                                name = "Yumurta"
                                caloriesText = "78"
                                proteinText = "6"
                                carbsText = "0.6"
                                fatsText = "5"
                            }
                        )
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "🍌",
                            name = "Banan",
                            calories = 89,
                            onClick = {
                                name = "Banan"
                                caloriesText = "89"
                                proteinText = "1.1"
                                carbsText = "23"
                                fatsText = "0.3"
                            }
                        )
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "🍗",
                            name = "Toyuq",
                            calories = 239,
                            onClick = {
                                name = "Toyuq döşü"
                                caloriesText = "239"
                                proteinText = "27"
                                carbsText = "0"
                                fatsText = "14"
                            }
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "🍎",
                            name = "Alma",
                            calories = 52,
                            onClick = {
                                name = "Alma"
                                caloriesText = "52"
                                proteinText = "0.3"
                                carbsText = "14"
                                fatsText = "0.2"
                            }
                        )
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "🥣",
                            name = "Yulaf",
                            calories = 154,
                            onClick = {
                                name = "Yulaf ezmesi"
                                caloriesText = "154"
                                proteinText = "5"
                                carbsText = "27"
                                fatsText = "2.6"
                            }
                        )
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "🧃",
                            name = "Şirə",
                            calories = 112,
                            onClick = {
                                name = "Portağal şirəsi"
                                caloriesText = "112"
                                proteinText = "2"
                                carbsText = "26"
                                fatsText = "0.5"
                            }
                        )
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Meal Type Selector (iOS: MealTypeButton row)
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Öğün", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    MealType.entries.forEach { meal ->
                        val emoji = when (meal) {
                            MealType.BREAKFAST -> "🌅"
                            MealType.LUNCH -> "☀️"
                            MealType.DINNER -> "🌙"
                            MealType.SNACK -> "🍿"
                        }
                        val label = when (meal) {
                            MealType.BREAKFAST -> "Səhər"
                            MealType.LUNCH -> "Nahar"
                            MealType.DINNER -> "Axşam"
                            MealType.SNACK -> "Ara"
                        }
                        val isSelected = selectedMealType == meal.value
                        Column(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(12.dp))
                                .background(
                                    if (isSelected) AppTheme.Colors.success
                                    else AppTheme.Colors.secondaryBackground
                                )
                                .border(
                                    width = if (isSelected) 2.dp else 1.dp,
                                    color = if (isSelected) AppTheme.Colors.success else AppTheme.Colors.separator,
                                    shape = RoundedCornerShape(12.dp)
                                )
                                .clickable { selectedMealType = meal.value }
                                .padding(vertical = 10.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(2.dp)
                        ) {
                            Text(emoji, fontSize = 18.sp)
                            Text(
                                text = label,
                                color = if (isSelected) Color.White else AppTheme.Colors.secondaryText,
                                fontSize = 11.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                            )
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Food Name (iOS: FoodInputField)
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Qida adı", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value = name,
                    onValueChange = { if (it.length <= 200) name = it },
                    placeholder = { Text("məs: Toyuq döşü", color = AppTheme.Colors.tertiaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = foodTextFieldColors(),
                    singleLine = true
                )
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Calories (iOS: FoodInputField with NumberPad)
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Kalori *", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value = caloriesText,
                    onValueChange = {
                        val filtered = it.filter { c -> c.isDigit() }
                        if ((filtered.toIntOrNull() ?: 0) <= 10000) caloriesText = filtered
                    },
                    placeholder = { Text("məs: 250", color = AppTheme.Colors.tertiaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = foodTextFieldColors(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Macros (iOS: MacroInputField row — horizontal)
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Makrolar (istəyə bağlı)", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = proteinText,
                        onValueChange = { proteinText = it },
                        label = { Text("Protein", color = AppTheme.Colors.tertiaryText, fontSize = 11.sp) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = foodTextFieldColors(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        singleLine = true,
                        suffix = { Text("g", color = AppTheme.Colors.secondaryText, fontSize = 11.sp) }
                    )
                    OutlinedTextField(
                        value = carbsText,
                        onValueChange = { carbsText = it },
                        label = { Text("Karbo", color = AppTheme.Colors.tertiaryText, fontSize = 11.sp) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = foodTextFieldColors(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        singleLine = true,
                        suffix = { Text("g", color = AppTheme.Colors.secondaryText, fontSize = 11.sp) }
                    )
                    OutlinedTextField(
                        value = fatsText,
                        onValueChange = { fatsText = it },
                        label = { Text("Yağ", color = AppTheme.Colors.tertiaryText, fontSize = 11.sp) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = foodTextFieldColors(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        singleLine = true,
                        suffix = { Text("g", color = AppTheme.Colors.secondaryText, fontSize = 11.sp) }
                    )
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Notes (iOS: TextEditor, max 1000)
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Qeydlər (istəyə bağlı)", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value = notes,
                    onValueChange = { if (it.length <= 1000) notes = it },
                    placeholder = { Text("Əlavə qeydlər...", color = AppTheme.Colors.tertiaryText) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(min = 80.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = foodTextFieldColors(),
                    minLines = 3,
                    maxLines = 5
                )
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Save Button (iOS: gradient + shadow)
            // ═══════════════════════════════════════════════════════════════════
            val isValid = name.isNotBlank() && caloriesText.isNotBlank()
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp)
                    .then(
                        if (isValid) Modifier.shadow(
                            8.dp, RoundedCornerShape(12.dp),
                            spotColor = AppTheme.Colors.success.copy(alpha = 0.4f)
                        ) else Modifier
                    )
                    .background(
                        brush = Brush.horizontalGradient(
                            colors = listOf(AppTheme.Colors.success, AppTheme.Colors.success.copy(alpha = 0.8f))
                        ),
                        shape = RoundedCornerShape(12.dp),
                        alpha = if (isValid) 1f else 0.5f
                    )
                    .clip(RoundedCornerShape(12.dp))
                    .then(
                        if (isValid) Modifier.clickable {
                            val calories = caloriesText.toIntOrNull() ?: return@clickable
                            onSave(
                                name.trim(),
                                calories,
                                proteinText.toDoubleOrNull(),
                                carbsText.toDoubleOrNull(),
                                fatsText.toDoubleOrNull(),
                                selectedMealType,
                                notes.trim().ifEmpty { null }
                            )
                        } else Modifier
                    )
                    .padding(vertical = 14.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Saxla",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }
    }
}

// ── QuickAddButton (iOS: QuickAddButton — emoji + name + calories) ──────────
@Composable
private fun QuickAddButton(
    modifier: Modifier = Modifier,
    emoji: String,
    name: String,
    calories: Int,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(AppTheme.Colors.secondaryBackground)
            .border(1.dp, AppTheme.Colors.separator, RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(vertical = 10.dp, horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(2.dp)
    ) {
        Text(emoji, fontSize = 24.sp)
        Text(
            text = name,
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
            color = AppTheme.Colors.primaryText,
            maxLines = 1
        )
        Text(
            text = "$calories kal",
            fontSize = 10.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}

// ── TextField Colors ────────────────────────────────────────────────────────
@Composable
private fun foodTextFieldColors() = OutlinedTextFieldDefaults.colors(
    focusedBorderColor = AppTheme.Colors.success,
    unfocusedBorderColor = AppTheme.Colors.separator,
    focusedTextColor = Color.White,
    unfocusedTextColor = Color.White,
    cursorColor = AppTheme.Colors.success
)
