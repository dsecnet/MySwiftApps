package life.corevia.app.ui.food

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.model.AICalorieResult
import life.corevia.app.data.model.DetectedFood
import life.corevia.app.ui.theme.*

/**
 * AICalorieResultScreen — standalone result display screen
 * Receives AI analysis result and shows detailed nutritional breakdown.
 * Can be navigated to from the main AI Calorie screen or food diary.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AICalorieResultScreen(
    result: AICalorieResult? = null,
    onBack: () -> Unit = {},
    onSave: (DetectedFood) -> Unit = {},
    onSaveAll: () -> Unit = {},
    isSaving: Boolean = false
) {
    // Use provided result or show placeholder
    val displayResult = result ?: sampleAIResult()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "AI Nəticəsi",
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Total Calories Card ──
            TotalCaloriesCard(displayResult)

            // ── Macros Breakdown ──
            MacrosBreakdownCard(displayResult)

            // ── Confidence Score ──
            ConfidenceCard(displayResult.confidence)

            // ── Detected Foods ──
            if (displayResult.foods.isNotEmpty()) {
                Text(
                    text = "Aşkar edilən yeməklər",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )

                displayResult.foods.forEach { food ->
                    DetectedFoodCard(
                        food = food,
                        onSave = { onSave(food) }
                    )
                }
            }

            // ── Save All Button ──
            if (displayResult.foods.size > 1) {
                Button(
                    onClick = onSaveAll,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(14.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = CoreViaSuccess),
                    enabled = !isSaving
                ) {
                    if (isSaving) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(Icons.Filled.SaveAlt, null, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            "Hamısını Saxla",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            } else if (displayResult.foods.size == 1) {
                Button(
                    onClick = { onSave(displayResult.foods.first()) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(14.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary),
                    enabled = !isSaving
                ) {
                    if (isSaving) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(Icons.Filled.Add, null, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            "Saxla",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

// ─── Total Calories Card ────────────────────────────────────────────

@Composable
private fun TotalCaloriesCard(result: AICalorieResult) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.05f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(
            Icons.Filled.AutoAwesome, null,
            modifier = Modifier.size(32.dp),
            tint = CoreViaPrimary
        )

        Text(
            text = "Ümumi Kalori",
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Row(
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = "${result.totalCalories.toInt()}",
                fontSize = 48.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
            Text(
                text = "kcal",
                fontSize = 18.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(bottom = 8.dp)
            )
        }

        if (result.foods.size > 1) {
            Text(
                text = "${result.foods.size} yemək aşkar edildi",
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ─── Macros Breakdown ───────────────────────────────────────────────

@Composable
private fun MacrosBreakdownCard(result: AICalorieResult) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.05f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(20.dp),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        MacroColumn(
            label = "Protein",
            value = "${result.totalProtein.toInt()}g",
            color = AccentBlue
        )
        MacroColumn(
            label = "Karbohidrat",
            value = "${result.totalCarbs.toInt()}g",
            color = AccentOrange
        )
        MacroColumn(
            label = "Yağ",
            value = "${result.totalFat.toInt()}g",
            color = AccentPurple
        )
    }
}

@Composable
private fun MacroColumn(label: String, value: String, color: Color) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Box(
            modifier = Modifier
                .size(52.dp)
                .clip(CircleShape)
                .background(color.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = value,
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
                color = color
            )
        }
        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ─── Confidence Card ────────────────────────────────────────────────

@Composable
private fun ConfidenceCard(confidence: Double) {
    val percent = (confidence * 100).toInt()
    val confidenceColor = when {
        percent >= 80 -> CoreViaSuccess
        percent >= 50 -> CoreViaWarning
        else -> CoreViaError
    }
    val confidenceLabel = when {
        percent >= 80 -> "Yüksək dəqiqlik"
        percent >= 50 -> "Orta dəqiqlik"
        else -> "Aşağı dəqiqlik"
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(confidenceColor.copy(alpha = 0.08f))
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(confidenceColor.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.Verified, null,
                modifier = Modifier.size(20.dp),
                tint = confidenceColor
            )
        }
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = confidenceLabel,
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = "AI dəqiqliyi: $percent%",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Text(
            text = "$percent%",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = confidenceColor
        )
    }
}

// ─── Detected Food Card ─────────────────────────────────────────────

@Composable
private fun DetectedFoodCard(food: DetectedFood, onSave: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 2.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.03f),
                spotColor = Color.Black.copy(alpha = 0.03f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Header: icon + name + calories
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(CoreViaPrimary.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.Restaurant, null,
                        modifier = Modifier.size(18.dp),
                        tint = CoreViaPrimary
                    )
                }
                Column {
                    Text(
                        text = food.name,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = "${food.portionGrams.toInt()}g porsiya",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Text(
                text = "${food.calories.toInt()} kcal",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
        }

        // Macros row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            MacroChip("P", "${food.protein.toInt()}g", AccentBlue)
            MacroChip("K", "${food.carbs.toInt()}g", AccentOrange)
            MacroChip("Y", "${food.fat.toInt()}g", AccentPurple)
        }

        // Save button
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(10.dp))
                .background(CoreViaSuccess.copy(alpha = 0.1f))
                .clickable(onClick = onSave)
                .padding(vertical = 10.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.Add, null,
                    modifier = Modifier.size(16.dp),
                    tint = CoreViaSuccess
                )
                Text(
                    text = "Qida siyahısına əlavə et",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = CoreViaSuccess
                )
            }
        }
    }
}

@Composable
private fun MacroChip(label: String, value: String, color: Color) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(color.copy(alpha = 0.08f))
            .padding(horizontal = 14.dp, vertical = 6.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            text = value,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
            color = color
        )
    }
}

// ─── Sample Data ────────────────────────────────────────────────────

private fun sampleAIResult(): AICalorieResult {
    return AICalorieResult(
        foods = listOf(
            DetectedFood(
                id = "1",
                name = "Toyuq döşü",
                calories = 165.0,
                protein = 31.0,
                carbs = 0.0,
                fat = 3.6,
                portionGrams = 100.0,
                confidence = 0.92
            ),
            DetectedFood(
                id = "2",
                name = "Düyü pilavı",
                calories = 206.0,
                protein = 4.3,
                carbs = 44.5,
                fat = 0.4,
                portionGrams = 158.0,
                confidence = 0.87
            )
        ),
        totalCalories = 371.0,
        totalProtein = 35.3,
        totalCarbs = 44.5,
        totalFat = 4.0,
        confidence = 0.89
    )
}
