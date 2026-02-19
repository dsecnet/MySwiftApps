package life.corevia.app.ui.food

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.FoodAnalysisResult

/**
 * iOS: FoodAnalysisSheet — AI nəticəsi göstər + "Qida olaraq əlavə et"
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FoodAnalysisSheet(
    result: FoodAnalysisResult,
    isLoading: Boolean,
    onDismiss: () -> Unit,
    onAddAsFood: (FoodAnalysisResult) -> Unit
) {
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
                .padding(bottom = 40.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Header
            Text(
                text = "🤖 AI Qida Analizi",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText,
                modifier = Modifier.padding(bottom = 20.dp)
            )

            // Result card
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(20.dp))
                    .background(AppTheme.Colors.cardBackground)
                    .padding(20.dp)
            ) {
                Column {
                    // Food name
                    Text(
                        text = result.foodName,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText
                    )

                    // Confidence
                    result.confidence?.let { conf ->
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Dəqiqlik: ${(conf * 100).toInt()}%",
                            fontSize = 13.sp,
                            color = if (conf > 0.7) AppTheme.Colors.success
                            else AppTheme.Colors.warning
                        )
                    }

                    // Portion size
                    result.portionSize?.let { portion ->
                        Text(
                            text = "Porsiya: $portion",
                            fontSize = 13.sp,
                            color = AppTheme.Colors.secondaryText
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Nutrition grid
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        NutritionChip("Kalori", "${result.calories}", "kcal", AppTheme.Colors.accent)
                        NutritionChip("Protein", String.format("%.1f", result.protein), "g", AppTheme.Colors.success)
                        NutritionChip("Karbo", String.format("%.1f", result.carbs), "g", AppTheme.Colors.warning)
                        NutritionChip("Yağ", String.format("%.1f", result.fats), "g", Color(0xFFFF9500))
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Add as food button
            Button(
                onClick = { onAddAsFood(result) },
                enabled = !isLoading,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = AppTheme.Colors.accent,
                    disabledContainerColor = AppTheme.Colors.accent.copy(alpha = 0.3f)
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                Icon(
                    imageVector = Icons.Filled.Add,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Qida olaraq əlavə et",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            TextButton(onClick = onDismiss) {
                Text("Bağla", color = AppTheme.Colors.secondaryText)
            }
        }
    }
}

@Composable
fun NutritionChip(label: String, value: String, unit: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            text = unit,
            fontSize = 10.sp,
            color = AppTheme.Colors.tertiaryText
        )
        Text(
            text = label,
            fontSize = 11.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}
