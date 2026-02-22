package life.corevia.app.ui.mealplan

import life.corevia.app.ui.theme.AppTheme
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
import life.corevia.app.ui.theme.CoreViaAnimatedBackground

/**
 * Edit Meal Plan Screen - pre-fills data from an existing MealPlan
 * Similar to AddMealPlanScreen but for editing
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditMealPlanScreen(
    plan: MealPlan,
    onBack: () -> Unit,
    onSave: (String, MealPlanCreateRequest) -> Unit,
    students: List<UserResponse> = emptyList()
) {
    var title by remember { mutableStateOf(plan.title) }
    var selectedPlanType by remember { mutableStateOf(plan.planType) }
    var dailyCalorieTarget by remember { mutableStateOf(plan.dailyCalorieTarget.toString()) }
    var selectedStudentId by remember { mutableStateOf(plan.assignedStudentId) }
    var notes by remember { mutableStateOf(plan.notes ?: "") }
    var items by remember {
        mutableStateOf(
            plan.items.map { item ->
                MealPlanItemCreateRequest(
                    name = item.name,
                    calories = item.calories,
                    protein = item.protein,
                    carbs = item.carbs,
                    fats = item.fats,
                    mealType = item.mealType
                )
            }
        )
    }
    var showAddItem by remember { mutableStateOf(false) }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Column(
        modifier = Modifier
            .fillMaxSize()
    ) {
        // Header
        Spacer(modifier = Modifier.height(56.dp))
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.AutoMirrored.Outlined.ArrowBack, "Geri", tint = AppTheme.Colors.primaryText)
            }
            Text(
                text = "Qida Plan\u0131 Redakt\u0259",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText,
                modifier = Modifier.weight(1f)
            )
            TextButton(
                onClick = {
                    if (title.isNotBlank()) {
                        onSave(
                            plan.id,
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
            // Title
            item {
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("Plan ad\u0131 *", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.success,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText,
                        cursorColor = AppTheme.Colors.success
                    ),
                    singleLine = true
                )
            }

            // Plan Type
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
                                        PlanType.WEIGHT_LOSS -> "\u00c7\u0259ki itkisi"
                                        PlanType.WEIGHT_GAIN -> "\u00c7\u0259ki art\u0131m\u0131"
                                        PlanType.STRENGTH_TRAINING -> "G\u00fcc"
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

            // Daily Calorie Target
            item {
                OutlinedTextField(
                    value = dailyCalorieTarget,
                    onValueChange = { dailyCalorieTarget = it.filter { c -> c.isDigit() } },
                    label = { Text("G\u00fcnd\u0259lik kalori h\u0259d\u0259fi", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.success,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText,
                        cursorColor = AppTheme.Colors.success
                    ),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
            }

            // Student Selection
            if (students.isNotEmpty()) {
                item {
                    Text("Student se\u00e7 (ixtiyari)", color = AppTheme.Colors.secondaryText, fontSize = 13.sp)
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
                            Text("He\u00e7 kim", color = AppTheme.Colors.primaryText, fontSize = 14.sp, modifier = Modifier.padding(start = 8.dp))
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
                                Text(student.name, color = AppTheme.Colors.primaryText, fontSize = 14.sp, modifier = Modifier.padding(start = 8.dp))
                            }
                        }
                    }
                }
            }

            // Meal Items
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Yem\u0259kl\u0259r (${items.size})", color = AppTheme.Colors.primaryText, fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                    TextButton(onClick = { showAddItem = true }) {
                        Icon(Icons.Outlined.Add, null, tint = AppTheme.Colors.success, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("\u018flav\u0259 et", color = AppTheme.Colors.success)
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
                            Text(item.name, color = AppTheme.Colors.primaryText, fontWeight = FontWeight.Medium, fontSize = 14.sp)
                            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                Text(
                                    when (item.mealType) {
                                        "breakfast" -> "\uD83C\uDF05 S\u0259h\u0259r"
                                        "lunch" -> "\u2600\uFE0F Nahar"
                                        "dinner" -> "\uD83C\uDF19 Ax\u015fam"
                                        "snack" -> "\uD83C\uDF7F Ara \u00f6\u011f\u00fcn"
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

            // Notes
            item {
                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Qeydl\u0259r (ixtiyari)", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.success,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText,
                        cursorColor = AppTheme.Colors.success
                    ),
                    minLines = 3,
                    maxLines = 5
                )
            }

            item { Spacer(modifier = Modifier.height(80.dp)) }
        }
    }
    } // CoreViaAnimatedBackground

    // Add Meal Item Sheet (reuses AddMealItemSheet from AddMealPlanScreen)
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
