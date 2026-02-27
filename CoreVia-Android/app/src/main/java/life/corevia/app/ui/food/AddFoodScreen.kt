package life.corevia.app.ui.food

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.MealType
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddFoodScreen(
    onBack: () -> Unit,
    viewModel: AddFoodViewModel = hiltViewModel()
) {
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state.isSaved) {
        if (state.isSaved) onBack()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Yeni Qida", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Filled.Close, contentDescription = "Bagla")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // ── Meal Type ──
            Text("Yemek novu", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                MealType.entries.forEach { type ->
                    val selected = state.selectedMealType == type
                    val color = when (type) {
                        MealType.BREAKFAST -> MealBreakfast
                        MealType.LUNCH -> MealLunch
                        MealType.DINNER -> MealDinner
                        MealType.SNACK -> MealSnack
                    }
                    val icon = when (type) {
                        MealType.BREAKFAST -> Icons.Filled.WbSunny
                        MealType.LUNCH -> Icons.Filled.LunchDining
                        MealType.DINNER -> Icons.Filled.DarkMode
                        MealType.SNACK -> Icons.Filled.Cookie
                    }
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (selected) color.copy(alpha = 0.15f) else CoreViaSurface)
                            .border(
                                width = if (selected) 2.dp else 1.dp,
                                color = if (selected) color else TextSeparator,
                                shape = RoundedCornerShape(12.dp)
                            )
                            .clickable { viewModel.updateMealType(type) }
                            .padding(vertical = 12.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(icon, contentDescription = null, tint = if (selected) color else TextSecondary, modifier = Modifier.size(22.dp))
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(type.displayName, fontSize = 10.sp, color = if (selected) color else TextSecondary, fontWeight = FontWeight.Medium)
                    }
                }
            }

            // ── Food Name ──
            Text("Qida adi", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            OutlinedTextField(
                value = state.foodName,
                onValueChange = viewModel::updateFoodName,
                placeholder = { Text("mes: Toyuq salat", color = TextHint) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                leadingIcon = { Icon(Icons.Filled.Restaurant, contentDescription = null, tint = TextSecondary) },
                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
            )

            // ── Calories ──
            Text("Kalori (kcal)", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            OutlinedTextField(
                value = state.calories,
                onValueChange = viewModel::updateCalories,
                placeholder = { Text("mes: 350", color = TextHint) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                leadingIcon = { Icon(Icons.Filled.LocalFireDepartment, contentDescription = null, tint = CoreViaPrimary) },
                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
            )

            // ── Macros ──
            Text("Makrolar (istege bagli)", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                MacroField("Protein", state.protein, viewModel::updateProtein, CoreViaInfo, Modifier.weight(1f))
                MacroField("Karb", state.carbs, viewModel::updateCarbs, CoreViaWarning, Modifier.weight(1f))
                MacroField("Yag", state.fats, viewModel::updateFats, CoreViaError, Modifier.weight(1f))
            }

            // ── Notes ──
            Text("Qeydler", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            OutlinedTextField(
                value = state.notes,
                onValueChange = viewModel::updateNotes,
                placeholder = { Text("Elave qeydler...", color = TextHint) },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(80.dp),
                shape = RoundedCornerShape(12.dp),
                maxLines = 3,
                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = TextSeparator)
            )

            // ── Error ──
            state.errorMessage?.let {
                Text(it, color = CoreViaError, fontSize = 13.sp)
            }

            // ── Save ──
            Button(
                onClick = { viewModel.saveFoodEntry() },
                enabled = state.isFormValid && !state.isLoading,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CoreViaPrimary,
                    disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f)
                )
            ) {
                if (state.isLoading) {
                    CircularProgressIndicator(modifier = Modifier.size(22.dp), color = Color.White, strokeWidth = 2.dp)
                } else {
                    Icon(Icons.Filled.Check, contentDescription = null, tint = Color.White)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Yadda saxla", fontWeight = FontWeight.Bold, color = Color.White)
                }
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

@Composable
private fun MacroField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    accentColor: Color,
    modifier: Modifier = Modifier
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label, fontSize = 11.sp) },
        placeholder = { Text("g", color = TextHint) },
        modifier = modifier,
        shape = RoundedCornerShape(10.dp),
        singleLine = true,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = accentColor,
            focusedLabelColor = accentColor,
            unfocusedBorderColor = TextSeparator
        )
    )
}
