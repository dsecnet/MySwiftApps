package life.corevia.app.ui.food

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaIconBadge
import life.corevia.app.ui.theme.CoreViaSectionHeader
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import life.corevia.app.ui.theme.coreViaCard
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.FoodEntry
import life.corevia.app.data.models.MealType

/**
 * iOS EatingView.swift — Android 1-ə-1 port
 *
 * Bölmələr (iOS ilə eyni sıra):
 *  1. Header: title (32sp bold) + subtitle
 *  2. Daily Progress: circular gradient progress + CalorieStat x3 + Edit Goal
 *  3. Macro Breakdown: 3 MacroCard with emoji + border
 *  4. Meal Sections: forEach MealType — header with icon + entries or add button
 *  5. Add Button: accent gradient inline (no FAB)
 */
@Composable
fun FoodScreen(
    viewModel: FoodViewModel = viewModel(),
    isPremium: Boolean = false
) {
    val foodEntries by viewModel.foodEntries.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val showAddFood by viewModel.showAddFood.collectAsState()
    val calorieGoal by viewModel.calorieGoal.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()

    // AI Analysis states
    val analysisResult by viewModel.analysisResult.collectAsState()
    val isAnalyzing by viewModel.isAnalyzing.collectAsState()
    val showAnalysisResult by viewModel.showAnalysisResult.collectAsState()

    // Computed
    val todayEntries   = viewModel.todayEntries
    val totalCalories  = viewModel.totalCaloriesToday
    val progress       = viewModel.calorieProgress
    val totalProtein   = viewModel.totalProtein
    val totalCarbs     = viewModel.totalCarbs
    val totalFats      = viewModel.totalFats
    val remaining      = (calorieGoal - totalCalories).coerceAtLeast(0)

    var showEditGoal   by remember { mutableStateOf(false) }
    var editingEntry   by remember { mutableStateOf<FoodEntry?>(null) }
    var deletingEntryId by remember { mutableStateOf<String?>(null) }

    val scrollState = rememberScrollState()

    // Delete confirmation dialog
    if (deletingEntryId != null) {
        AlertDialog(
            onDismissRequest = { deletingEntryId = null },
            containerColor   = AppTheme.Colors.secondaryBackground,
            title            = { Text("Qidanı sil?", color = AppTheme.Colors.primaryText) },
            text             = { Text("Bu qida girişini silmək istədiyinizdən əminsiniz?", color = AppTheme.Colors.secondaryText) },
            confirmButton    = {
                TextButton(onClick = {
                    deletingEntryId?.let { viewModel.deleteFoodEntry(it) }
                    deletingEntryId = null
                }) { Text("Sil", color = AppTheme.Colors.error) }
            },
            dismissButton    = {
                TextButton(onClick = { deletingEntryId = null }) {
                    Text("Ləğv et", color = AppTheme.Colors.secondaryText)
                }
            }
        )
    }

    // Auto-dismiss messages
    LaunchedEffect(successMessage) {
        if (successMessage != null) { kotlinx.coroutines.delay(2000); viewModel.clearSuccess() }
    }
    LaunchedEffect(errorMessage) {
        if (errorMessage != null) { kotlinx.coroutines.delay(3000); viewModel.clearError() }
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.warning) {
        // iOS: ScrollView { VStack(spacing: 24) { ... } .padding() .padding(.bottom, 100) }
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(scrollState)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            // ── 1. Header (iOS: title 32sp bold + subtitle 14sp) ─────────────────
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text       = "Qida İzləmə",
                    fontSize   = 32.sp,
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.primaryText
                )
                Text(
                    text     = "Qidalanmanızı izləyin və sağlam qalın",
                    fontSize = 14.sp,
                    color    = AppTheme.Colors.secondaryText
                )
            }

            // ── Success/Error messages ───────────────────────────────────────────
            successMessage?.let { msg ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppTheme.Colors.success.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
                        .padding(12.dp)
                ) {
                    Text(text = msg, color = AppTheme.Colors.success, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                }
            }
            errorMessage?.let { msg ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppTheme.Colors.error.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(text = msg, color = AppTheme.Colors.error, fontSize = 14.sp, modifier = Modifier.weight(1f))
                    Text(text = "✕", color = AppTheme.Colors.error, modifier = Modifier.clickable { viewModel.clearError() })
                }
            }

            // ── 2. Daily Progress (iOS: circular gradient + CalorieStat x3 + Edit Goal) ──
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .coreViaCard(cornerRadius = 16.dp)
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // iOS: ZStack { Circle stroke + Circle gradient trim + VStack(calories) }
                Box(
                    contentAlignment = Alignment.Center,
                    modifier         = Modifier.padding(vertical = 20.dp)
                ) {
                    CircularProgressIndicator(
                        progress  = { progress.coerceIn(0f, 1f) },
                        modifier  = Modifier.size(180.dp),
                        color     = AppTheme.Colors.accent,
                        strokeWidth = 20.dp,
                        trackColor  = AppTheme.Colors.separator,
                        strokeCap   = StrokeCap.Round
                    )
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text       = "$totalCalories",
                            fontSize   = 40.sp,
                            fontWeight = FontWeight.Bold,
                            color      = AppTheme.Colors.primaryText
                        )
                        Text(
                            text     = "/ $calorieGoal",
                            fontSize = 16.sp,
                            color    = AppTheme.Colors.secondaryText
                        )
                        Text(
                            text     = "kcal",
                            fontSize = 14.sp,
                            color    = AppTheme.Colors.tertiaryText
                        )
                    }
                }

                // iOS: HStack(spacing: 20) { CalorieStat x3 — remaining, %, meals }
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    FoodCalorieStat(
                        icon  = Icons.Outlined.LocalFireDepartment,
                        value = "$remaining",
                        label = "Qalan",
                        color = AppTheme.Colors.accent
                    )
                    FoodCalorieStat(
                        icon  = Icons.Outlined.GpsFixed,
                        value = "${(progress * 100).toInt()}%",
                        label = "Tamamlandı",
                        color = AppTheme.Colors.accent
                    )
                    FoodCalorieStat(
                        icon  = Icons.Outlined.Restaurant,
                        value = "${todayEntries.size}",
                        label = "Yemək",
                        color = AppTheme.Colors.accent
                    )
                }

                // iOS: Edit Goal button with pencil icon
                Box(
                    modifier = Modifier
                        .background(AppTheme.Colors.accent.copy(alpha = 0.1f), RoundedCornerShape(20.dp))
                        .clip(RoundedCornerShape(20.dp))
                        .clickable { showEditGoal = true }
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                ) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        verticalAlignment     = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector        = Icons.Outlined.Edit,
                            contentDescription = null,
                            modifier           = Modifier.size(14.dp),
                            tint               = AppTheme.Colors.accent
                        )
                        Text(
                            text       = "Hədəfi dəyiş",
                            fontSize   = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            color      = AppTheme.Colors.accent
                        )
                    }
                }
            }

            // ── 3. Macro Breakdown (iOS: 3 MacroCard with emoji + border) ────────
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                CoreViaSectionHeader(title = "Makro Bölgüsü", subtitle = "Günlük makro xülasəsi")

                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    FoodMacroCard(
                        modifier = Modifier.weight(1f),
                        icon     = Icons.Outlined.FitnessCenter,
                        value    = "${totalProtein.toInt()}q",
                        label    = "Protein",
                        color    = AppTheme.Colors.accent
                    )
                    FoodMacroCard(
                        modifier = Modifier.weight(1f),
                        icon     = Icons.Outlined.Grain,
                        value    = "${totalCarbs.toInt()}q",
                        label    = "Karbohidrat",
                        color    = AppTheme.Colors.accentDark
                    )
                    FoodMacroCard(
                        modifier = Modifier.weight(1f),
                        icon     = Icons.Outlined.WaterDrop,
                        value    = "${totalFats.toInt()}q",
                        label    = "Yağ",
                        color    = AppTheme.Colors.accent
                    )
                }
            }

            // ── 4. Meal Sections (iOS: ForEach MealType.allCases) ────────────────
            if (isLoading && foodEntries.isEmpty()) {
                Box(
                    modifier         = Modifier.fillMaxWidth().padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = AppTheme.Colors.accent)
                }
            } else {
                MealType.entries.forEach { mealType ->
                    val mealEntries = todayEntries.filter { it.mealType == mealType.value }
                    val mealCalories = mealEntries.sumOf { it.calories }

                    // iOS: meal section with icon + title + total calories
                    FoodMealSection(
                        mealType     = mealType,
                        entries      = mealEntries,
                        totalCalories = mealCalories,
                        onAddFood    = { viewModel.setShowAddFood(true) },
                        onEditEntry  = { editingEntry = it },
                        onDeleteEntry = { deletingEntryId = it.id }
                    )
                }
            }

            // ── 5. Add Button (iOS: accent gradient inline) ──────────────────────
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(8.dp, RoundedCornerShape(12.dp), spotColor = AppTheme.Colors.accent.copy(alpha = 0.3f))
                    .background(
                        brush = Brush.horizontalGradient(
                            colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.8f))
                        ),
                        shape = RoundedCornerShape(12.dp)
                    )
                    .clip(RoundedCornerShape(12.dp))
                    .clickable { viewModel.setShowAddFood(true) }
                    .padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment     = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector        = Icons.Outlined.AddCircle,
                        contentDescription = null,
                        modifier           = Modifier.size(20.dp),
                        tint               = Color.White
                    )
                    Text(
                        text       = "Qida Əlavə Et",
                        fontSize   = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color      = Color.White
                    )
                }
            }

            Spacer(modifier = Modifier.height(100.dp)) // Tab bar üçün yer
        }
    }

    // ─── Add Food Bottom Sheet ───────────────────────────────────────────────
    if (showAddFood) {
        AddFoodSheet(
            onDismiss = { viewModel.setShowAddFood(false) },
            isPremium = true, // AI analiz herkese aciq
            onSave = { name, calories, protein, carbs, fats, mealType, notes ->
                viewModel.addFoodEntry(name, calories, protein, carbs, fats, mealType, notes)
            },
            onAnalyzeImage = { imageFile ->
                viewModel.analyzeFoodImage(imageFile)
            },
            isAnalyzing = isAnalyzing
        )
    }

    // ─── AI Analysis Result Sheet ─────────────────────────────────────────────
    if (showAnalysisResult && analysisResult != null) {
        FoodAnalysisSheet(
            result = analysisResult!!,
            isLoading = isLoading,
            onDismiss = { viewModel.dismissAnalysisResult() },
            onAddAsFood = { result ->
                viewModel.addFoodFromAnalysis(result, "lunch")
            }
        )
    }

    // ─── Edit Food Bottom Sheet ──────────────────────────────────────────────
    editingEntry?.let { entry ->
        EditFoodSheet(
            entry     = entry,
            onDismiss = { editingEntry = null },
            onSave    = { name, calories, protein, carbs, fats, mealType, notes ->
                viewModel.updateFoodEntry(entry.id, name, calories, protein, carbs, fats, mealType, notes)
                editingEntry = null
            }
        )
    }

    // ─── Edit Goal Dialog ────────────────────────────────────────────────────
    if (showEditGoal) {
        EditGoalDialog(
            currentGoal = calorieGoal,
            onDismiss   = { showEditGoal = false },
            onSave      = { newGoal ->
                viewModel.setCalorieGoal(newGoal)
                showEditGoal = false
            }
        )
    }
}

// ─── iOS: CalorieStat (icon + value + label) ─────────────────────────────────
@Composable
private fun FoodCalorieStat(
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        CoreViaIconBadge(icon = icon, tintColor = color, size = 32.dp, iconSize = 16.dp)
        Text(
            text       = value,
            fontSize   = 18.sp,
            fontWeight = FontWeight.Bold,
            color      = AppTheme.Colors.primaryText
        )
        Text(
            text     = label,
            fontSize = 12.sp,
            color    = AppTheme.Colors.secondaryText
        )
    }
}

// ─── iOS: MacroCard (emoji + value + label, with border) ─────────────────────
@Composable
private fun FoodMacroCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .coreViaCard(accentColor = color, cornerRadius = 12.dp)
            .border(1.dp, color.copy(alpha = 0.2f), RoundedCornerShape(12.dp))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        CoreViaIconBadge(icon = icon, tintColor = color, size = 40.dp, iconSize = 20.dp)
        Text(
            text       = value,
            fontSize   = 16.sp,
            fontWeight = FontWeight.Bold,
            color      = AppTheme.Colors.primaryText
        )
        Text(
            text     = label,
            fontSize = 12.sp,
            color    = AppTheme.Colors.secondaryText
        )
    }
}

// ─── iOS: Meal Section ───────────────────────────────────────────────────────
@Composable
private fun FoodMealSection(
    mealType: MealType,
    entries: List<FoodEntry>,
    totalCalories: Int,
    onAddFood: () -> Unit,
    onEditEntry: (FoodEntry) -> Unit,
    onDeleteEntry: (FoodEntry) -> Unit
) {
    val mealColor = when (mealType) {
        MealType.BREAKFAST -> AppTheme.Colors.mealBreakfast
        MealType.LUNCH     -> AppTheme.Colors.mealLunch
        MealType.DINNER    -> AppTheme.Colors.mealDinner
        MealType.SNACK     -> AppTheme.Colors.mealSnack
    }
    val mealIcon = when (mealType) {
        MealType.BREAKFAST -> Icons.Outlined.WbSunny
        MealType.LUNCH     -> Icons.Outlined.LightMode
        MealType.DINNER    -> Icons.Outlined.NightsStay
        MealType.SNACK     -> Icons.Outlined.Cookie
    }
    val mealLabel = when (mealType) {
        MealType.BREAKFAST -> "Səhər yeməyi"
        MealType.LUNCH     -> "Nahar"
        MealType.DINNER    -> "Axşam yeməyi"
        MealType.SNACK     -> "Ara öyün"
    }

    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        // iOS: HStack { icon + title + Spacer + total calories }
        Row(
            modifier              = Modifier.fillMaxWidth(),
            verticalAlignment     = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Icon(
                imageVector        = mealIcon,
                contentDescription = null,
                modifier           = Modifier.size(20.dp),
                tint               = mealColor
            )
            Text(
                text       = mealLabel,
                fontSize   = 18.sp,
                fontWeight = FontWeight.Bold,
                color      = AppTheme.Colors.primaryText
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text       = "$totalCalories kcal",
                fontSize   = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color      = mealColor
            )
        }

        if (entries.isEmpty()) {
            // iOS: Add button with border
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                    .border(1.dp, mealColor.copy(alpha = 0.3f), RoundedCornerShape(12.dp))
                    .clip(RoundedCornerShape(12.dp))
                    .clickable { onAddFood() }
                    .padding(16.dp),
                verticalAlignment     = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    imageVector        = Icons.Outlined.AddCircle,
                    contentDescription = null,
                    modifier           = Modifier.size(18.dp),
                    tint               = mealColor
                )
                Text(
                    text  = "Əlavə et",
                    color = AppTheme.Colors.primaryText
                )
            }
        } else {
            // iOS: VStack(spacing: 8) { ForEach FoodEntryRow }
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                entries.forEach { entry ->
                    FoodEntryRowIos(
                        entry    = entry,
                        mealColor = mealColor,
                        mealIcon  = mealIcon,
                        onEdit   = { onEditEntry(entry) },
                        onDelete = { onDeleteEntry(entry) }
                    )
                }
            }
        }
    }
}

// ─── iOS: FoodEntryRow ───────────────────────────────────────────────────────
@Composable
private fun FoodEntryRowIos(
    entry: FoodEntry,
    mealColor: Color,
    mealIcon: ImageVector,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .coreViaCard(accentColor = mealColor, cornerRadius = 12.dp)
            .clip(RoundedCornerShape(12.dp))
            .clickable { onEdit() }
            .padding(12.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // iOS: Circle icon (40x40) with meal color
        Box(
            modifier = Modifier
                .size(40.dp)
                .background(mealColor.copy(alpha = 0.2f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector        = mealIcon,
                contentDescription = null,
                modifier           = Modifier.size(16.dp),
                tint               = mealColor
            )
        }

        // iOS: VStack { name, macros, time }
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text       = entry.name,
                fontSize   = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color      = AppTheme.Colors.primaryText
            )

            // iOS: P:X C:X F:X
            val macroText = buildString {
                entry.protein?.let { append("P:${it.toInt()} ") }
                entry.carbs?.let { append("K:${it.toInt()} ") }
                entry.fats?.let { append("Y:${it.toInt()}") }
            }
            if (macroText.isNotBlank()) {
                Text(
                    text     = macroText.trim(),
                    fontSize = 12.sp,
                    color    = AppTheme.Colors.secondaryText
                )
            }
        }

        // iOS: Calories badge
        Text(
            text       = "${entry.calories} kcal",
            fontSize   = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color      = mealColor
        )
    }
}

// ─── Edit Goal Dialog ────────────────────────────────────────────────────────
@Composable
fun EditGoalDialog(
    currentGoal: Int,
    onDismiss: () -> Unit,
    onSave: (Int) -> Unit
) {
    var goalText by remember { mutableStateOf(currentGoal.toString()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor   = AppTheme.Colors.secondaryBackground,
        title            = { Text("Günləlik Kalori Hədəfi", color = AppTheme.Colors.primaryText) },
        text = {
            OutlinedTextField(
                value         = goalText,
                onValueChange = { goalText = it.filter { c -> c.isDigit() } },
                label         = { Text("Kalori (kal)", color = AppTheme.Colors.secondaryText) },
                colors        = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor  = AppTheme.Colors.accent,
                    unfocusedBorderColor = AppTheme.Colors.separator,
                    focusedTextColor    = AppTheme.Colors.primaryText,
                    unfocusedTextColor  = AppTheme.Colors.primaryText,
                    cursorColor         = AppTheme.Colors.accent
                ),
                singleLine    = true
            )
        },
        confirmButton = {
            TextButton(onClick = { goalText.toIntOrNull()?.let { onSave(it) } }) {
                Text("Saxla", color = AppTheme.Colors.accent)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Ləğv et", color = AppTheme.Colors.secondaryText)
            }
        }
    )
}
