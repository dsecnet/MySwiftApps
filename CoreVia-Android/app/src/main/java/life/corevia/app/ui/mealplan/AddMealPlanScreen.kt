package life.corevia.app.ui.mealplan

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.*

/**
 * iOS AddMealPlanView.swift — Android full-screen port
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMealPlanScreen(
    onBack: () -> Unit,
    onSave: (MealPlanCreateRequest) -> Unit,
    students: List<UserResponse> = emptyList(),
    preSelectedStudentId: String? = null
) {
    var title by remember { mutableStateOf("") }
    var selectedPlanType by remember { mutableStateOf(PlanType.WEIGHT_LOSS.value) }
    var dailyCalorieTarget by remember { mutableStateOf("2000") }
    var selectedStudentId by remember { mutableStateOf(preSelectedStudentId) }
    var notes by remember { mutableStateOf("") }
    var items by remember { mutableStateOf(listOf<MealPlanItemCreateRequest>()) }
    var showAddItem by remember { mutableStateOf(false) }

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
                text = "Qida Planı Yarat",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                modifier = Modifier.weight(1f)
            )
            TextButton(
                onClick = {
                    if (title.isNotBlank()) {
                        onSave(
                            MealPlanCreateRequest(
                                title = title.trim(),
                                planType = selectedPlanType,
                                dailyCalorieTarget = dailyCalorieTarget.toIntOrNull() ?: 2000,
                                notes = notes.ifBlank { null },
                                assignedStudentId = selectedStudentId,
                                items = items
                            )
                        )
                    }
                },
                enabled = title.isNotBlank()
            ) {
                Text(
                    "Saxla",
                    color = if (title.isNotBlank()) AppTheme.Colors.success else AppTheme.Colors.tertiaryText,
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
                        focusedBorderColor = AppTheme.Colors.success,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.success
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
                                selectedContainerColor = AppTheme.Colors.success,
                                selectedLabelColor = Color.White,
                                containerColor = AppTheme.Colors.secondaryBackground,
                                labelColor = AppTheme.Colors.secondaryText
                            )
                        )
                    }
                }
            }

            // ─── Daily Calorie Target ───────────────────────────────────────
            item {
                OutlinedTextField(
                    value = dailyCalorieTarget,
                    onValueChange = { dailyCalorieTarget = it.filter { c -> c.isDigit() } },
                    label = { Text("Gündəlik kalori hədəfi", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.success,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.success
                    ),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
            }

            // ─── Student Selection ──────────────────────────────────────────
            if (students.isNotEmpty()) {
                item {
                    Text("Student seç (ixtiyari)", color = AppTheme.Colors.secondaryText, fontSize = 13.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    Column {
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
                                    selectedColor = AppTheme.Colors.success,
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
                                        selectedColor = AppTheme.Colors.success,
                                        unselectedColor = AppTheme.Colors.secondaryText
                                    )
                                )
                                Text(student.name, color = Color.White, fontSize = 14.sp, modifier = Modifier.padding(start = 8.dp))
                            }
                        }
                    }
                }
            }

            // ─── Meal Items ─────────────────────────────────────────────────
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Yeməklər (${items.size})", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                    TextButton(onClick = { showAddItem = true }) {
                        Icon(Icons.Outlined.Add, null, tint = AppTheme.Colors.success, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Əlavə et", color = AppTheme.Colors.success)
                    }
                }
            }

            items(items.size) { index ->
                val item = items[index]
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
                            Text(item.name, color = Color.White, fontWeight = FontWeight.Medium, fontSize = 14.sp)
                            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                Text(
                                    when (item.mealType) {
                                        "breakfast" -> "🌅 Səhər"
                                        "lunch" -> "☀️ Nahar"
                                        "dinner" -> "🌙 Axşam"
                                        "snack" -> "🍿 Ara öğün"
                                        else -> item.mealType
                                    },
                                    color = AppTheme.Colors.secondaryText,
                                    fontSize = 12.sp
                                )
                                Text("${item.calories} kal", color = AppTheme.Colors.success, fontSize = 12.sp)
                            }
                        }
                        IconButton(onClick = {
                            items = items.toMutableList().also { it.removeAt(index) }
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
                        focusedBorderColor = AppTheme.Colors.success,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.success
                    ),
                    minLines = 3,
                    maxLines = 5
                )
            }

            item { Spacer(modifier = Modifier.height(80.dp)) }
        }
    }

    // ─── Add Meal Item Sheet ────────────────────────────────────────────────
    if (showAddItem) {
        AddMealItemSheet(
            onDismiss = { showAddItem = false },
            onAdd = { item ->
                items = items + item
                showAddItem = false
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMealItemSheet(
    onDismiss: () -> Unit,
    onAdd: (MealPlanItemCreateRequest) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var calories by remember { mutableStateOf("") }
    var protein by remember { mutableStateOf("") }
    var carbs by remember { mutableStateOf("") }
    var fats by remember { mutableStateOf("") }
    var selectedMealType by remember { mutableStateOf("breakfast") }

    val mealTypes = listOf(
        "breakfast" to "🌅 Səhər yeməyi",
        "lunch" to "☀️ Nahar",
        "dinner" to "🌙 Axşam yeməyi",
        "snack" to "🍿 Ara öğün"
    )

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = AppTheme.Colors.background,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppTheme.Colors.secondaryText) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp)
        ) {
            Text("Yemək Əlavə Et", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White)
            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Yemək adı *", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppTheme.Colors.success,
                    unfocusedBorderColor = AppTheme.Colors.separator,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    cursorColor = AppTheme.Colors.success
                ),
                singleLine = true
            )
            Spacer(modifier = Modifier.height(12.dp))

            // Meal type selection
            Text("Yemək növü", color = AppTheme.Colors.secondaryText, fontSize = 13.sp)
            Spacer(modifier = Modifier.height(4.dp))
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(mealTypes) { (value, label) ->
                    FilterChip(
                        selected = selectedMealType == value,
                        onClick = { selectedMealType = value },
                        label = { Text(label, fontSize = 12.sp) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = AppTheme.Colors.success,
                            selectedLabelColor = Color.White,
                            containerColor = AppTheme.Colors.secondaryBackground,
                            labelColor = AppTheme.Colors.secondaryText
                        )
                    )
                }
            }
            Spacer(modifier = Modifier.height(12.dp))

            // Nutrition fields
            OutlinedTextField(
                value = calories,
                onValueChange = { calories = it.filter { c -> c.isDigit() } },
                label = { Text("Kalori *", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppTheme.Colors.success,
                    unfocusedBorderColor = AppTheme.Colors.separator,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    cursorColor = AppTheme.Colors.success
                ),
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
            )
            Spacer(modifier = Modifier.height(8.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = protein,
                    onValueChange = { protein = it.filter { c -> c.isDigit() || c == '.' } },
                    label = { Text("Protein(g)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.accent
                    ),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
                )
                OutlinedTextField(
                    value = carbs,
                    onValueChange = { carbs = it.filter { c -> c.isDigit() || c == '.' } },
                    label = { Text("Karb(g)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.warning,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.warning
                    ),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
                )
                OutlinedTextField(
                    value = fats,
                    onValueChange = { fats = it.filter { c -> c.isDigit() || c == '.' } },
                    label = { Text("Yağ(g)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.weight(1f),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.error,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = AppTheme.Colors.error
                    ),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            Button(
                onClick = {
                    if (name.isNotBlank() && calories.isNotBlank()) {
                        onAdd(
                            MealPlanItemCreateRequest(
                                name = name.trim(),
                                calories = calories.toIntOrNull() ?: 0,
                                protein = protein.toDoubleOrNull(),
                                carbs = carbs.toDoubleOrNull(),
                                fats = fats.toDoubleOrNull(),
                                mealType = selectedMealType
                            )
                        )
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.success),
                shape = RoundedCornerShape(12.dp),
                enabled = name.isNotBlank() && calories.isNotBlank()
            ) {
                Text("Əlavə et", fontWeight = FontWeight.SemiBold)
            }
        }
    }
}
