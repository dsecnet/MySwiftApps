package life.corevia.app.ui.food

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
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
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import life.corevia.app.data.model.FoodEntry
import life.corevia.app.data.model.MealType
import life.corevia.app.ui.theme.*
import androidx.compose.foundation.Canvas
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Size

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FoodScreen(
    onNavigateToMealPlans: () -> Unit = {},
    onNavigateToAICalorie: () -> Unit = {},
    onNavigateToAddFood: () -> Unit = {},
    viewModel: FoodViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    PullToRefreshBox(
        isRefreshing = uiState.isLoading,
        onRefresh = { viewModel.loadData() }
    ) {
        if (uiState.error != null && uiState.entries.isEmpty() && !uiState.isLoading) {
            // Error state when no cached data
            FoodErrorState(
                errorMessage = uiState.error ?: "",
                onRetry = { viewModel.loadData() }
            )
        } else {
            FoodScreenContent(
                uiState = uiState,
                onAddWater = viewModel::addWater,
                onRemoveWater = viewModel::removeWater,
                onAddClick = viewModel::toggleAddSheet,
                onEditGoal = viewModel::toggleEditGoal,
                onDeleteEntry = viewModel::deleteEntry,
                onAddFood = viewModel::addFood,
                onUpdateGoal = viewModel::updateCalorieGoal,
                onDismissAdd = viewModel::toggleAddSheet,
                onDismissGoal = viewModel::toggleEditGoal,
                onNavigateToMealPlans = onNavigateToMealPlans,
                onNavigateToAICalorie = onNavigateToAICalorie
            )
        }
    }
}

@Composable
private fun FoodErrorState(
    errorMessage: String,
    onRetry: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            Icons.Filled.WifiOff,
            contentDescription = "Bağlantı xətası",
            modifier = Modifier.size(64.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = errorMessage,
            fontSize = 16.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onBackground,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(24.dp))
        Button(
            onClick = onRetry,
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
        ) {
            Icon(Icons.Filled.Refresh, contentDescription = null, modifier = Modifier.size(18.dp))
            Spacer(modifier = Modifier.width(8.dp))
            Text("Yenidən cəhd et", fontWeight = FontWeight.SemiBold)
        }
    }
}

@Composable
private fun FoodScreenContent(
    uiState: FoodUiState,
    onAddWater: () -> Unit,
    onRemoveWater: () -> Unit,
    onAddClick: () -> Unit,
    onEditGoal: () -> Unit,
    onDeleteEntry: (String) -> Unit,
    onAddFood: (String, Int, Double?, Double?, Double?, MealType, String?) -> Unit,
    onUpdateGoal: (Int) -> Unit,
    onDismissAdd: () -> Unit,
    onDismissGoal: () -> Unit,
    onNavigateToMealPlans: () -> Unit,
    onNavigateToAICalorie: () -> Unit
) {
    Box(modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 100.dp)
        ) {
            Column(
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                Spacer(modifier = Modifier.height(40.dp))

                // ─── Header Section (iOS: headerSection) ────────────────
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Qida Tracking",
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = "Bugünkü qidalanmanızı izləyin",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                // ─── Daily Progress Section (iOS: dailyProgressSection - horizontal) ──
                DailyProgressSection(
                    consumed = uiState.todayCalories,
                    goal = uiState.calorieGoal,
                    remaining = uiState.remainingCalories,
                    progress = uiState.calorieProgress,
                    onEditGoal = onEditGoal
                )

                // ─── Water Tracking (iOS: waterTrackingSection) ──────────
                WaterTrackingSection(
                    glasses = uiState.waterGlasses,
                    onAdd = onAddWater,
                    onRemove = onRemoveWater
                )

                // ─── Macro Breakdown (iOS: macroBreakdownSection) ────────
                MacroBreakdownSection(
                    protein = uiState.todayProtein,
                    carbs = uiState.todayCarbs,
                    fats = uiState.todayFats
                )

                // ─── Meal Sections (iOS: mealSection) ───────────────────
                MealType.entries.forEach { mealType ->
                    MealSection(
                        mealType = mealType,
                        entries = uiState.entriesForMeal(mealType),
                        onDeleteEntry = onDeleteEntry,
                        onAddClick = onAddClick
                    )
                }

                // ─── Add Button (iOS: addButton) ────────────────────────
                AddFoodButton(onClick = onAddClick)
            }
        }
    }

    // Add Food Sheet
    if (uiState.showAddSheet) {
        AddFoodSheet(
            onDismiss = onDismissAdd,
            onAdd = onAddFood,
            onNavigateToAICalorie = onNavigateToAICalorie
        )
    }

    // Edit Goal Dialog
    if (uiState.showEditGoal) {
        EditGoalDialog(
            currentGoal = uiState.calorieGoal,
            onDismiss = onDismissGoal,
            onUpdate = onUpdateGoal
        )
    }
}

// ─── Daily Progress Section (iOS-style: horizontal layout) ──────────

@Composable
private fun DailyProgressSection(
    consumed: Int,
    goal: Int,
    remaining: Int,
    progress: Float,
    onEditGoal: () -> Unit
) {
    val animatedProgress by animateFloatAsState(
        targetValue = progress.coerceIn(0f, 1f),
        animationSpec = spring(),
        label = "progress"
    )
    val percentage = (progress * 100).toInt().coerceIn(0, 999)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Compact circular progress on the LEFT (iOS: 90pt)
        Box(contentAlignment = Alignment.Center) {
            CircularProgressIndicator(
                progress = { animatedProgress },
                modifier = Modifier.size(90.dp),
                strokeWidth = 10.dp,
                color = CoreViaPrimary,
                trackColor = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
                strokeCap = StrokeCap.Round
            )
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "$consumed",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "kcal",
                    fontSize = 10.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        // Stats on the RIGHT (iOS style - vertical list)
        Column(
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Target
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.GpsFixed, null,
                    modifier = Modifier.size(12.dp),
                    tint = CoreViaPrimary
                )
                Text(
                    text = "$goal kcal",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "hədəf",
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Remaining
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.LocalFireDepartment, null,
                    modifier = Modifier.size(12.dp),
                    tint = CoreViaPrimary
                )
                Text(
                    text = "$remaining",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "qalıb",
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Percentage
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.BarChart, null,
                    modifier = Modifier.size(12.dp),
                    tint = CoreViaPrimary
                )
                Text(
                    text = "$percentage%",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "tamamlandı",
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Edit goal button (iOS style pill)
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(14.dp))
                    .background(CoreViaPrimary.copy(alpha = 0.1f))
                    .clickable(onClick = onEditGoal)
                    .padding(horizontal = 10.dp, vertical = 5.dp)
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Edit, null,
                        modifier = Modifier.size(12.dp),
                        tint = CoreViaPrimary
                    )
                    Text(
                        text = "Hədəfi Dəyiş",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = CoreViaPrimary
                    )
                }
            }
        }
    }
}

// ─── Water Tracking (iOS-style: tappable drops) ─────────────────────

@Composable
private fun WaterTrackingSection(glasses: Int, onAdd: () -> Unit, onRemove: () -> Unit) {
    val waterGoal = 8
    val waterProgress = glasses / waterGoal.toFloat()
    val mlConsumed = glasses * 250

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Header
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.WaterDrop, null,
                    modifier = Modifier.size(18.dp),
                    tint = Color(0xFF2196F3)
                )
                Text(
                    text = "Su İzləmə",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }
            Text(
                text = "$glasses/$waterGoal",
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF2196F3)
            )
        }

        // Tappable water drop icons (iOS style)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            (1..waterGoal).forEach { index ->
                Icon(
                    Icons.Filled.WaterDrop, null,
                    modifier = Modifier
                        .size(28.dp)
                        .clickable {
                            // iOS behavior: tap to toggle
                            if (glasses == index) {
                                // tapping the last filled one removes it
                                onRemove()
                            } else if (index > glasses) {
                                // fill up to this one
                                repeat(index - glasses) { onAdd() }
                            }
                        },
                    tint = if (index <= glasses) Color(0xFF2196F3)
                    else MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.4f)
                )
            }
        }

        // Progress bar
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp))
                .background(MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f))
        ) {
            val animatedWater by animateFloatAsState(
                targetValue = waterProgress.coerceIn(0f, 1f),
                animationSpec = spring(),
                label = "water"
            )
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(animatedWater)
                    .clip(RoundedCornerShape(3.dp))
                    .background(Color(0xFF2196F3))
            )
        }

        // Minus / ml / Plus row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Minus button
            Icon(
                Icons.Filled.RemoveCircle, null,
                modifier = Modifier
                    .size(28.dp)
                    .clickable(enabled = glasses > 0, onClick = onRemove),
                tint = if (glasses > 0) Color(0xFF2196F3)
                else MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f)
            )

            Text(
                text = "$mlConsumed ml",
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            // Plus button
            Icon(
                Icons.Filled.AddCircle, null,
                modifier = Modifier
                    .size(28.dp)
                    .clickable(enabled = glasses < waterGoal, onClick = onAdd),
                tint = if (glasses < waterGoal) Color(0xFF2196F3)
                else MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f)
            )
        }
    }
}

// ─── Macro Breakdown (iOS-style: bordered cards with emojis) ────────

@Composable
private fun MacroBreakdownSection(protein: Double, carbs: Double, fats: Double) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Makro Qırılması",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            MacroCard(
                modifier = Modifier.weight(1f),
                emoji = "\uD83D\uDCAA",
                label = "Protein",
                value = "${protein.toInt()}q",
                color = CoreViaPrimary
            )
            MacroCard(
                modifier = Modifier.weight(1f),
                emoji = "\uD83C\uDF5E",
                label = "Karbohidrat",
                value = "${carbs.toInt()}q",
                color = CoreViaPrimary.copy(red = 0.8f)
            )
            MacroCard(
                modifier = Modifier.weight(1f),
                emoji = "\uD83E\uDD51",
                label = "Yağ",
                value = "${fats.toInt()}q",
                color = CoreViaPrimary
            )
        }
    }
}

@Composable
private fun MacroCard(
    modifier: Modifier = Modifier,
    emoji: String,
    label: String,
    value: String,
    color: Color
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .border(2.dp, color.copy(alpha = 0.3f), RoundedCornerShape(12.dp))
            .padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(text = emoji, fontSize = 28.sp)
        Text(
            text = value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            maxLines = 1
        )
    }
}

// ─── Meal Section (iOS-style: icons, bordered empty state) ──────────

@Composable
private fun MealSection(
    mealType: MealType,
    entries: List<FoodEntry>,
    onDeleteEntry: (String) -> Unit,
    onAddClick: () -> Unit
) {
    val mealIcon = when (mealType) {
        MealType.BREAKFAST -> Icons.Filled.WbSunny
        MealType.LUNCH -> Icons.Filled.Restaurant
        MealType.DINNER -> Icons.Filled.DarkMode
        MealType.SNACK -> Icons.Filled.Cookie
    }
    val mealColor = when (mealType) {
        MealType.BREAKFAST -> Color(0xFFFF9800)
        MealType.LUNCH -> CoreViaPrimary
        MealType.DINNER -> Color(0xFF9C27B0)
        MealType.SNACK -> CoreViaSuccess
    }
    val totalCalories = entries.sumOf { it.calories }

    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        // Header
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    mealIcon, null,
                    modifier = Modifier.size(20.dp),
                    tint = mealColor
                )
                Text(
                    text = mealType.displayName,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }
            Text(
                text = "$totalCalories kcal",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = mealColor
            )
        }

        if (entries.isEmpty()) {
            // iOS style: bordered empty card
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                    .border(1.dp, mealColor.copy(alpha = 0.3f), RoundedCornerShape(12.dp))
                    .clickable(onClick = onAddClick)
                    .padding(16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.AddCircle, null,
                    modifier = Modifier.size(20.dp),
                    tint = mealColor
                )
                Text(
                    text = "Qida əlavə et",
                    fontSize = 15.sp,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                entries.forEach { entry ->
                    FoodEntryRow(entry = entry, mealColor = mealColor, onDelete = { onDeleteEntry(entry.id) })
                }
            }
        }
    }
}

// ─── Food Entry Row (iOS-style: icon left, calories right) ──────────

@Composable
private fun FoodEntryRow(entry: FoodEntry, mealColor: Color, onDelete: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Meal type icon circle
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(mealColor.copy(alpha = 0.2f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.Restaurant, null,
                modifier = Modifier.size(16.dp),
                tint = mealColor
            )
        }

        // Name + macros
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = entry.name,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            if (entry.protein != null && entry.carbs != null && entry.fats != null) {
                Text(
                    text = "P:${entry.protein!!.toInt()} C:${entry.carbs!!.toInt()} F:${entry.fats!!.toInt()}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        // Calories on the right (iOS style - prominent)
        Column(
            horizontalAlignment = Alignment.End,
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                text = "${entry.calories}",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = mealColor
            )
            Text(
                text = "kcal",
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ─── Add Food Button (iOS-style: gradient with shadow) ──────────────

@Composable
private fun AddFoodButton(onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .height(52.dp)
            .shadow(8.dp, RoundedCornerShape(12.dp)),
        shape = RoundedCornerShape(12.dp),
        colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
    ) {
        Icon(
            Icons.Filled.AddCircle, null,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = "Qida Əlavə Et",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

// ─── Add Food Bottom Sheet ──────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddFoodSheet(
    onDismiss: () -> Unit,
    onAdd: (String, Int, Double?, Double?, Double?, MealType, String?) -> Unit,
    onNavigateToAICalorie: () -> Unit = {}
) {
    var name by remember { mutableStateOf("") }
    var calories by remember { mutableStateOf("") }
    var protein by remember { mutableStateOf("") }
    var carbs by remember { mutableStateOf("") }
    var fats by remember { mutableStateOf("") }
    var selectedMealType by remember { mutableStateOf(MealType.BREAKFAST) }
    var notes by remember { mutableStateOf("") }

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
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Header: Bağla / Title / Saxla
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Bağla",
                    fontSize = 14.sp,
                    color = CoreViaPrimary,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.clickable(onClick = onDismiss)
                )
                Text(
                    text = "Qida Əlavə Et",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = "Saxla",
                    fontSize = 14.sp,
                    color = if (isValid) CoreViaPrimary else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f),
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.clickable(enabled = isValid) {
                        onAdd(
                            name,
                            calories.toIntOrNull() ?: 0,
                            protein.toDoubleOrNull(),
                            carbs.toDoubleOrNull(),
                            fats.toDoubleOrNull(),
                            selectedMealType,
                            notes.ifBlank { null }
                        )
                    }
                )
            }

            // AI Analiz button inside sheet
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(14.dp))
                    .background(Color(0xFF9C27B0).copy(alpha = 0.08f))
                    .border(1.dp, Color(0xFF9C27B0).copy(alpha = 0.2f), RoundedCornerShape(14.dp))
                    .clickable {
                        onDismiss()
                        onNavigateToAICalorie()
                    }
                    .padding(vertical = 14.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.CameraAlt, null,
                        modifier = Modifier.size(20.dp),
                        tint = Color(0xFF9C27B0)
                    )
                    Column {
                        Text(
                            text = "AI ilə Analiz Et",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF9C27B0)
                        )
                        Text(
                            text = "Şəkil çəkin, kalorini öyrənin",
                            fontSize = 11.sp,
                            color = Color(0xFF9C27B0).copy(alpha = 0.7f)
                        )
                    }
                }
            }

            // Quick add - Horizontal scrollable
            Text(
                text = "Tez Əlavə Et",
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            data class QuickFood(val emoji: String, val name: String, val portion: String, val cal: Int, val p: Double, val c: Double, val f: Double)
            val quickFoods = listOf(
                QuickFood("\uD83E\uDD5A", "Yumurta", "1 ədəd", 78, 6.0, 0.6, 5.0),
                QuickFood("\uD83C\uDF4C", "Banan", "1 ədəd", 105, 1.3, 27.0, 0.4),
                QuickFood("\uD83C\uDF57", "Toyuq filesi", "100g", 165, 31.0, 0.0, 3.6),
                QuickFood("\uD83C\uDF4E", "Alma", "1 ədəd", 95, 0.5, 25.0, 0.3),
                QuickFood("\uD83E\uDD57", "Salat", "1 porsi", 150, 5.0, 20.0, 7.0),
                QuickFood("\uD83C\uDF5E", "Çörək", "1 dilim", 79, 3.0, 15.0, 1.0),
                QuickFood("\uD83C\uDF5A", "Düyü", "100g", 130, 2.7, 28.0, 0.3),
                QuickFood("\uD83E\uDD5B", "Şorba", "1 kasa", 120, 6.0, 18.0, 3.0)
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                quickFoods.forEach { food ->
                    Column(
                        modifier = Modifier
                            .width(80.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(CoreViaPrimary.copy(alpha = 0.06f))
                            .clickable {
                                name = food.name
                                calories = food.cal.toString()
                                protein = food.p.toString()
                                carbs = food.c.toString()
                                fats = food.f.toString()
                            }
                            .padding(vertical = 10.dp, horizontal = 6.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(3.dp)
                    ) {
                        Text(text = food.emoji, fontSize = 24.sp)
                        Text(
                            text = food.name,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium,
                            color = MaterialTheme.colorScheme.onBackground,
                            maxLines = 1,
                            textAlign = TextAlign.Center
                        )
                        Text(
                            text = food.portion,
                            fontSize = 9.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = "${food.cal} kcal",
                            fontSize = 10.sp,
                            color = CoreViaPrimary,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            // Meal type selector - "Öğün Növü"
            Text(
                text = "Öğün Növü",
                fontSize = 13.sp,
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
                    val mealEmoji = when (type) {
                        MealType.BREAKFAST -> "\u2600\uFE0F"
                        MealType.LUNCH -> "\uD83C\uDF5D"
                        MealType.DINNER -> "\uD83C\uDF19"
                        MealType.SNACK -> "\uD83C\uDF6A"
                    }
                    val mealLabel = when (type) {
                        MealType.BREAKFAST -> "Səhər"
                        MealType.LUNCH -> "Günorta"
                        MealType.DINNER -> "Axşam"
                        MealType.SNACK -> "Snack"
                    }
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(10.dp))
                            .background(
                                if (isSelected) mealColor.copy(alpha = 0.2f)
                                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                            )
                            .then(
                                if (isSelected) Modifier.border(1.dp, mealColor, RoundedCornerShape(10.dp))
                                else Modifier
                            )
                            .clickable { selectedMealType = type }
                            .padding(vertical = 8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(2.dp)
                    ) {
                        Text(text = mealEmoji, fontSize = 14.sp)
                        Text(
                            text = mealLabel,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = if (isSelected) mealColor else MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1
                        )
                    }
                }
            }

            // Food name
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Qida Adı") },
                placeholder = { Text("məs: Yumurta omlet", color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                leadingIcon = { Icon(Icons.Filled.Restaurant, null, modifier = Modifier.size(18.dp)) }
            )

            // Calories
            OutlinedTextField(
                value = calories,
                onValueChange = { calories = it.filter { c -> c.isDigit() } },
                label = { Text("Kalori (kcal)") },
                placeholder = { Text("məs: 250", color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true,
                leadingIcon = { Icon(Icons.Filled.LocalFireDepartment, null, modifier = Modifier.size(18.dp)) }
            )

            // Macros with emoji labels
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = "Makrolar (opsional)",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "· qram",
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                )
            }
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = protein,
                    onValueChange = { protein = it },
                    label = { Text("\uD83D\uDCAA Protein") },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
                OutlinedTextField(
                    value = carbs,
                    onValueChange = { carbs = it },
                    label = { Text("\uD83C\uDF5E Karb") },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
                OutlinedTextField(
                    value = fats,
                    onValueChange = { fats = it },
                    label = { Text("\uD83E\uDD51 Yağ") },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    singleLine = true
                )
            }

            // Notes
            Text(
                text = "Qeydlər (opsional)",
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            OutlinedTextField(
                value = notes,
                onValueChange = { notes = it },
                placeholder = { Text("Əlavə məlumat yazın...", color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)) },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(90.dp),
                shape = RoundedCornerShape(12.dp),
                maxLines = 4
            )

            // Save button
            Button(
                onClick = {
                    onAdd(
                        name,
                        calories.toIntOrNull() ?: 0,
                        protein.toDoubleOrNull(),
                        carbs.toDoubleOrNull(),
                        fats.toDoubleOrNull(),
                        selectedMealType,
                        notes.ifBlank { null }
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .shadow(8.dp, RoundedCornerShape(12.dp)),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary),
                enabled = isValid
            ) {
                Icon(Icons.Filled.AddCircle, null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Saxla", fontSize = 16.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}

// ─── Edit Goal Dialog ───────────────────────────────────────────────

@Composable
private fun EditGoalDialog(currentGoal: Int, onDismiss: () -> Unit, onUpdate: (Int) -> Unit) {
    var goalText by remember { mutableStateOf(currentGoal.toString()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Kalori hədəfi", fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value = goalText,
                    onValueChange = { goalText = it.filter { c -> c.isDigit() } },
                    label = { Text("Gündəlik hədəf (kcal)") },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )

                Text(
                    text = "Tez seçim",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    listOf(1500, 2000, 2500, 3000).forEach { goal ->
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(8.dp))
                                .background(
                                    if (goalText == goal.toString()) CoreViaPrimary
                                    else CoreViaPrimary.copy(alpha = 0.1f)
                                )
                                .clickable { goalText = goal.toString() }
                                .padding(horizontal = 16.dp, vertical = 8.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "$goal",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = if (goalText == goal.toString()) Color.White else CoreViaPrimary
                            )
                        }
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = {
                goalText.toIntOrNull()?.let { onUpdate(it) }
            }) {
                Text("Saxla", color = CoreViaPrimary, fontWeight = FontWeight.SemiBold)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Ləğv et") }
        }
    )
}
