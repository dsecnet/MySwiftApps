package life.corevia.app.ui.food

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.FoodEntry
import life.corevia.app.data.models.MealType

/**
 * iOS EatingView.swift-in Android ekvivalenti.
 *
 * Qayda: UI dəyişsə yalnız bu fayl dəyişir.
 * Kalori hesabı, list, delete — FoodViewModel-dədir.
 */
@Composable
fun FoodScreen(
    viewModel: FoodViewModel = viewModel()
) {
    val foodEntries by viewModel.foodEntries.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val showAddFood by viewModel.showAddFood.collectAsState()
    val calorieGoal by viewModel.calorieGoal.collectAsState()

    // Computed (iOS: @Published var-dan hesablanır)
    val todayEntries = viewModel.todayEntries
    val totalCalories = viewModel.totalCaloriesToday
    val progress = viewModel.calorieProgress
    val totalProtein = viewModel.totalProtein
    val totalCarbs = viewModel.totalCarbs
    val totalFats = viewModel.totalFats

    var showEditGoal by remember { mutableStateOf(false) }

    Scaffold(
        containerColor = AppTheme.Colors.background,
        floatingActionButton = {
            FloatingActionButton(
                onClick = { viewModel.setShowAddFood(true) },
                containerColor = AppTheme.Colors.success,
                shape = CircleShape
            ) {
                Icon(Icons.Default.Add, contentDescription = "Qida əlavə et", tint = Color.White)
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(horizontal = 20.dp, vertical = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ─── Başlıq ───────────────────────────────────────────────────────
            item {
                Text(
                    text = "Qida İzləmə",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }

            // ─── Dairəvi kalori proqresi ──────────────────────────────────────
            // iOS: circular progress with CalorieStat
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(20.dp),
                    colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        // Dairəvi progress
                        Box(contentAlignment = Alignment.Center) {
                            CircularProgressIndicator(
                                progress = { progress },
                                modifier = Modifier.size(140.dp),
                                color = when {
                                    progress >= 1f -> AppTheme.Colors.error
                                    progress >= 0.8f -> Color(0xFFFFCC00)
                                    else -> AppTheme.Colors.success
                                },
                                strokeWidth = 12.dp,
                                trackColor = AppTheme.Colors.separator,
                                strokeCap = StrokeCap.Round
                            )
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(
                                    text = "$totalCalories",
                                    fontSize = 28.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.White
                                )
                                Text(
                                    text = "/ $calorieGoal kal",
                                    fontSize = 13.sp,
                                    color = AppTheme.Colors.secondaryText
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        // iOS: CalorieStat row
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            CalorieStat(label = "Protein", value = "${totalProtein.toInt()}g", color = AppTheme.Colors.accent)
                            CalorieStat(label = "Karbohidrat", value = "${totalCarbs.toInt()}g", color = AppTheme.Colors.warning)
                            CalorieStat(label = "Yağ", value = "${totalFats.toInt()}g", color = AppTheme.Colors.error)
                        }

                        Spacer(modifier = Modifier.height(8.dp))
                        TextButton(onClick = { showEditGoal = true }) {
                            Text(
                                text = "Hədəfi dəyiş (${calorieGoal} kal)",
                                color = AppTheme.Colors.secondaryText,
                                fontSize = 12.sp
                            )
                        }
                    }
                }
            }

            // ─── Bu günün yeməkləri ───────────────────────────────────────────
            item {
                Text(
                    text = "Bu Günün Yeməkləri",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.White
                )
            }

            if (isLoading && foodEntries.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier.fillMaxWidth().padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = AppTheme.Colors.success)
                    }
                }
            } else if (todayEntries.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(16.dp))
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(text = "🍎", fontSize = 36.sp)
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "Bu gün qida daxil edilməyib",
                                color = AppTheme.Colors.secondaryText,
                                fontSize = 14.sp
                            )
                        }
                    }
                }
            } else {
                // Öğünlərə görə qruplaşdır (iOS: MealType-a görə section)
                MealType.entries.forEach { mealType ->
                    val mealEntries = todayEntries.filter { it.mealType == mealType.value }
                    if (mealEntries.isNotEmpty()) {
                        item {
                            Text(
                                text = when (mealType) {
                                    MealType.BREAKFAST -> "🌅 Səhər yeməyi"
                                    MealType.LUNCH     -> "☀️ Nahar"
                                    MealType.DINNER    -> "🌙 Axşam yeməyi"
                                    MealType.SNACK     -> "🍿 Ara öğün"
                                },
                                color = AppTheme.Colors.secondaryText,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Medium
                            )
                        }
                        items(mealEntries, key = { it.id }) { entry ->
                            FoodEntryRow(
                                entry = entry,
                                onDelete = { viewModel.deleteFoodEntry(entry.id) }
                            )
                        }
                    }
                }
            }

            item { Spacer(modifier = Modifier.height(80.dp)) }
        }
    }

    // ─── Add Food Bottom Sheet ────────────────────────────────────────────────
    if (showAddFood) {
        AddFoodSheet(
            onDismiss = { viewModel.setShowAddFood(false) },
            onSave = { name, calories, protein, carbs, fats, mealType, notes ->
                viewModel.addFoodEntry(name, calories, protein, carbs, fats, mealType, notes)
            }
        )
    }

    // ─── Hədəf edit dialog ────────────────────────────────────────────────────
    if (showEditGoal) {
        EditGoalDialog(
            currentGoal = calorieGoal,
            onDismiss = { showEditGoal = false },
            onSave = { newGoal ->
                viewModel.setCalorieGoal(newGoal)
                showEditGoal = false
            }
        )
    }
}

// ─── Components ───────────────────────────────────────────────────────────────

// iOS: CalorieStat
@Composable
fun CalorieStat(label: String, value: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = value, color = color, fontWeight = FontWeight.Bold, fontSize = 16.sp)
        Text(text = label, color = AppTheme.Colors.secondaryText, fontSize = 12.sp)
    }
}

// iOS: FoodEntryRow
@Composable
fun FoodEntryRow(entry: FoodEntry, onDelete: () -> Unit) {
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
                Text(
                    text = entry.name,
                    color = Color.White,
                    fontWeight = FontWeight.Medium,
                    fontSize = 14.sp
                )
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    entry.protein?.let {
                        Text(text = "P: ${it.toInt()}g", color = AppTheme.Colors.accent, fontSize = 12.sp)
                    }
                    entry.carbs?.let {
                        Text(text = "K: ${it.toInt()}g", color = AppTheme.Colors.warning, fontSize = 12.sp)
                    }
                    entry.fats?.let {
                        Text(text = "Y: ${it.toInt()}g", color = AppTheme.Colors.error, fontSize = 12.sp)
                    }
                }
            }
            Text(
                text = "${entry.calories} kal",
                color = AppTheme.Colors.success,
                fontWeight = FontWeight.SemiBold,
                fontSize = 14.sp
            )
            IconButton(onClick = onDelete) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Sil",
                    tint = AppTheme.Colors.tertiaryText,
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}

// iOS: EditGoalView
@Composable
fun EditGoalDialog(
    currentGoal: Int,
    onDismiss: () -> Unit,
    onSave: (Int) -> Unit
) {
    var goalText by remember { mutableStateOf(currentGoal.toString()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = AppTheme.Colors.secondaryBackground,
        title = { Text("Gündəlik Kalori Hədəfi", color = Color.White) },
        text = {
            OutlinedTextField(
                value = goalText,
                onValueChange = { goalText = it.filter { c -> c.isDigit() } },
                label = { Text("Kalori (kal)", color = AppTheme.Colors.secondaryText) },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppTheme.Colors.success,
                    unfocusedBorderColor = AppTheme.Colors.separator,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    cursorColor = AppTheme.Colors.success
                ),
                singleLine = true
            )
        },
        confirmButton = {
            TextButton(onClick = {
                goalText.toIntOrNull()?.let { onSave(it) }
            }) {
                Text("Saxla", color = AppTheme.Colors.success)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Ləğv et", color = AppTheme.Colors.secondaryText)
            }
        }
    )
}
