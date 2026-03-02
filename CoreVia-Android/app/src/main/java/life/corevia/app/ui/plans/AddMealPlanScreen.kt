package life.corevia.app.ui.plans

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
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
import life.corevia.app.data.model.MealPlanItemRequest
import life.corevia.app.data.model.MealType
import life.corevia.app.data.model.PlanType
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMealPlanScreen(
    onBack: () -> Unit,
    viewModel: MealPlanViewModel = hiltViewModel()
) {
    val addState by viewModel.addState.collectAsState()

    LaunchedEffect(addState.isSaved) {
        if (addState.isSaved) {
            viewModel.resetAddState()
            onBack()
        }
    }

    var showAddMealItem by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 100.dp)
        ) {
            Column(
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Spacer(modifier = Modifier.height(48.dp))

                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CircleShape)
                                .background(MaterialTheme.colorScheme.surfaceVariant)
                                .clickable(onClick = onBack),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                Icons.AutoMirrored.Filled.ArrowBack, null,
                                modifier = Modifier.size(18.dp),
                                tint = MaterialTheme.colorScheme.onSurface
                            )
                        }
                        Column {
                            Text(
                                text = "Yeni Yemək Planı",
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onBackground
                            )
                            Text(
                                text = "Qidalanma planı yaradın",
                                fontSize = 13.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }

                // Plan Name
                OutlinedTextField(
                    value = addState.name,
                    onValueChange = viewModel::updateName,
                    label = { Text("Plan adı") },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    singleLine = true,
                    leadingIcon = {
                        Icon(Icons.Filled.MenuBook, null, modifier = Modifier.size(18.dp))
                    }
                )

                // Description
                OutlinedTextField(
                    value = addState.description,
                    onValueChange = viewModel::updateDescription,
                    label = { Text("Təsvir (ixtiyari)") },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    maxLines = 3,
                    leadingIcon = {
                        Icon(Icons.Filled.Description, null, modifier = Modifier.size(18.dp))
                    }
                )

                // Plan Type Selector
                Text(
                    text = "Plan növü",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        PlanType.entries.take(3).forEach { type ->
                            PlanTypeChip(
                                modifier = Modifier.weight(1f),
                                type = type,
                                isSelected = addState.selectedPlanType == type,
                                onClick = { viewModel.updatePlanType(type) }
                            )
                        }
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        PlanType.entries.drop(3).forEach { type ->
                            PlanTypeChip(
                                modifier = Modifier.weight(1f),
                                type = type,
                                isSelected = addState.selectedPlanType == type,
                                onClick = { viewModel.updatePlanType(type) }
                            )
                        }
                        if (PlanType.entries.drop(3).size < 3) {
                            repeat(3 - PlanType.entries.drop(3).size) {
                                Spacer(modifier = Modifier.weight(1f))
                            }
                        }
                    }
                }

                // Meal Items Section
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "Yeməklər",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        if (addState.meals.isNotEmpty()) {
                            Text(
                                text = "Cəmi: ${addState.totalCalories} kcal",
                                fontSize = 11.sp,
                                color = CoreViaPrimary,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(10.dp))
                            .background(CoreViaPrimary.copy(alpha = 0.1f))
                            .clickable { showAddMealItem = true }
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(4.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Filled.Add, null,
                                modifier = Modifier.size(14.dp),
                                tint = CoreViaPrimary
                            )
                            Text(
                                text = "Əlavə et",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = CoreViaPrimary
                            )
                        }
                    }
                }

                if (addState.meals.isEmpty()) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            Icons.Filled.Restaurant, null,
                            modifier = Modifier.size(32.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                        )
                        Text(
                            text = "Hələ yemək əlavə edilməyib",
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f)
                        )
                    }
                } else {
                    addState.meals.forEachIndexed { index, item ->
                        MealItemRow(
                            item = item,
                            onRemove = { viewModel.removeMealItem(index) }
                        )
                    }
                }

                // Error
                addState.error?.let {
                    Text(
                        text = it,
                        fontSize = 12.sp,
                        color = CoreViaError
                    )
                }
            }
        }

        // Save Button
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Button(
                onClick = viewModel::saveMealPlan,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary),
                enabled = addState.isValid && !addState.isLoading
            ) {
                if (addState.isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(20.dp),
                        color = Color.White,
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(Icons.Filled.Save, null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Planı saxla", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    }

    // Add Meal Item Sheet
    if (showAddMealItem) {
        AddMealItemSheet(
            onDismiss = { showAddMealItem = false },
            onAdd = { item ->
                viewModel.addMealItem(item)
                showAddMealItem = false
            }
        )
    }
}

@Composable
private fun PlanTypeChip(
    modifier: Modifier = Modifier,
    type: PlanType,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val color = when (type) {
        PlanType.WEIGHT_LOSS -> PlanWeightLoss
        PlanType.WEIGHT_GAIN -> PlanWeightGain
        PlanType.MUSCLE_BUILDING -> PlanStrength
        PlanType.MAINTENANCE -> Color(0xFFFF9800)
        PlanType.CUSTOM -> CoreViaPrimary
    }
    val icon = when (type) {
        PlanType.WEIGHT_LOSS -> Icons.Filled.TrendingDown
        PlanType.WEIGHT_GAIN -> Icons.Filled.TrendingUp
        PlanType.MUSCLE_BUILDING -> Icons.Filled.FitnessCenter
        PlanType.MAINTENANCE -> Icons.Filled.Balance
        PlanType.CUSTOM -> Icons.Filled.Edit
    }

    Column(
        modifier = modifier
            .clip(RoundedCornerShape(10.dp))
            .background(
                if (isSelected) color.copy(alpha = 0.2f)
                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
            )
            .clickable(onClick = onClick)
            .padding(vertical = 10.dp, horizontal = 6.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Icon(
            icon, null,
            modifier = Modifier.size(16.dp),
            tint = if (isSelected) color else MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = type.displayName,
            fontSize = 10.sp,
            fontWeight = FontWeight.SemiBold,
            color = if (isSelected) color else MaterialTheme.colorScheme.onSurfaceVariant,
            maxLines = 1
        )
    }
}

@Composable
private fun MealItemRow(
    item: MealPlanItemRequest,
    onRemove: () -> Unit
) {
    val mealType = MealType.fromValue(item.mealType)
    val mealColor = when (mealType) {
        MealType.BREAKFAST -> Color(0xFFFF9800)
        MealType.LUNCH -> CoreViaPrimary
        MealType.DINNER -> Color(0xFF9C27B0)
        MealType.SNACK -> CoreViaSuccess
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(10.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(mealColor.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.Restaurant, null,
                modifier = Modifier.size(16.dp),
                tint = mealColor
            )
        }
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                text = item.name,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onBackground
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "${item.calories} kcal",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = mealColor
                )
                Text(
                    text = mealType.displayName,
                    fontSize = 10.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                item.protein?.let {
                    Text("P:${it.toInt()}g", fontSize = 10.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
        Icon(
            Icons.Filled.Close, null,
            modifier = Modifier
                .size(16.dp)
                .clickable(onClick = onRemove),
            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddMealItemSheet(
    onDismiss: () -> Unit,
    onAdd: (MealPlanItemRequest) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var calories by remember { mutableStateOf("") }
    var protein by remember { mutableStateOf("") }
    var carbs by remember { mutableStateOf("") }
    var fats by remember { mutableStateOf("") }
    var selectedMealType by remember { mutableStateOf(MealType.BREAKFAST) }

    val isValid = name.isNotBlank() && calories.isNotBlank() && (calories.toIntOrNull() ?: 0) > 0

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Text(
                text = "Yemək əlavə et",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface
            )

            // Quick add
            Text(
                text = "Tez seç",
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                data class QuickMeal(val emoji: String, val label: String, val cal: Int, val p: Double, val c: Double, val f: Double)
                val quickMeals = listOf(
                    QuickMeal("\uD83E\uDD5A", "Yumurta", 155, 13.0, 1.0, 11.0),
                    QuickMeal("\uD83C\uDF57", "Toyuq", 239, 27.0, 0.0, 14.0),
                    QuickMeal("\uD83E\uDD57", "Salat", 150, 5.0, 20.0, 7.0),
                    QuickMeal("\uD83C\uDF5A", "Düyü", 206, 4.3, 45.0, 0.4)
                )
                quickMeals.forEach { qm ->
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(10.dp))
                            .background(CoreViaPrimary.copy(alpha = 0.08f))
                            .clickable {
                                name = qm.label
                                calories = qm.cal.toString()
                                protein = qm.p.toString()
                                carbs = qm.c.toString()
                                fats = qm.f.toString()
                            }
                            .padding(vertical = 8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(text = qm.emoji, fontSize = 18.sp)
                            Text(
                                text = qm.label,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Medium,
                                color = CoreViaPrimary
                            )
                        }
                    }
                }
            }

            // Meal type
            Text(
                text = "Yemək növü",
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                MealType.entries.forEach { type ->
                    val isSelected = selectedMealType == type
                    val mealColor = when (type) {
                        MealType.BREAKFAST -> Color(0xFFFF9800)
                        MealType.LUNCH -> CoreViaPrimary
                        MealType.DINNER -> Color(0xFF9C27B0)
                        MealType.SNACK -> CoreViaSuccess
                    }
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(10.dp))
                            .background(
                                if (isSelected) mealColor.copy(alpha = 0.2f)
                                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                            )
                            .clickable { selectedMealType = type }
                            .padding(vertical = 8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = type.displayName,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = if (isSelected) mealColor else MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1
                        )
                    }
                }
            }

            // Input fields
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Ad") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true
            )
            OutlinedTextField(
                value = calories,
                onValueChange = { calories = it.filter { c -> c.isDigit() } },
                label = { Text("Kalori (kcal)") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true
            )
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = protein,
                    onValueChange = { protein = it },
                    label = { Text("Protein") },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
                OutlinedTextField(
                    value = carbs,
                    onValueChange = { carbs = it },
                    label = { Text("Karb") },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
                OutlinedTextField(
                    value = fats,
                    onValueChange = { fats = it },
                    label = { Text("Yağ") },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
            }

            Button(
                onClick = {
                    onAdd(
                        MealPlanItemRequest(
                            name = name,
                            calories = calories.toIntOrNull() ?: 0,
                            protein = protein.toDoubleOrNull(),
                            carbs = carbs.toDoubleOrNull(),
                            fats = fats.toDoubleOrNull(),
                            mealType = selectedMealType.value
                        )
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary),
                enabled = isValid
            ) {
                Icon(Icons.Filled.Add, null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Əlavə et", fontSize = 16.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}
