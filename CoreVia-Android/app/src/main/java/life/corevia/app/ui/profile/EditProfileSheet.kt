package life.corevia.app.ui.profile

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.ProfileUpdateRequest
import life.corevia.app.data.models.UserResponse

/**
 * iOS EditProfileView.swift — Android ModalBottomSheet
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileSheet(
    user: UserResponse?,
    onDismiss: () -> Unit,
    onSave: (ProfileUpdateRequest) -> Unit
) {
    var name by remember { mutableStateOf(user?.name ?: "") }
    var age by remember { mutableStateOf(user?.age?.toString() ?: "") }
    var weight by remember { mutableStateOf(user?.weight?.toString() ?: "") }
    var height by remember { mutableStateOf(user?.height?.toString() ?: "") }
    var goal by remember { mutableStateOf(user?.goal ?: "") }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = AppTheme.Colors.background,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppTheme.Colors.secondaryText) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp)
        ) {
            Text(
                text = "Profili Redaktə et",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            Spacer(modifier = Modifier.height(20.dp))

            ProfileTextField(label = "Ad", value = name, onValueChange = { name = it })
            ProfileTextField(
                label = "Yaş",
                value = age,
                onValueChange = { age = it.filter { c -> c.isDigit() } },
                keyboardType = KeyboardType.Number
            )
            ProfileTextField(
                label = "Çəki (kg)",
                value = weight,
                onValueChange = { weight = it.filter { c -> c.isDigit() || c == '.' } },
                keyboardType = KeyboardType.Decimal
            )
            ProfileTextField(
                label = "Boy (cm)",
                value = height,
                onValueChange = { height = it.filter { c -> c.isDigit() || c == '.' } },
                keyboardType = KeyboardType.Decimal
            )

            // Goal seçimi
            Text(
                text = "Məqsəd",
                color = AppTheme.Colors.secondaryText,
                fontSize = 13.sp,
                modifier = Modifier.padding(bottom = 4.dp)
            )
            val goals = listOf("weight_loss", "weight_gain", "muscle_gain", "general_fitness")
            val goalLabels = listOf("Çəki itkisi", "Çəki artımı", "Əzələ artımı", "Ümumi fitness")
            Column {
                goals.forEachIndexed { index, goalValue ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp)
                    ) {
                        RadioButton(
                            selected = goal == goalValue,
                            onClick = { goal = goalValue },
                            colors = RadioButtonDefaults.colors(
                                selectedColor = AppTheme.Colors.accent,
                                unselectedColor = AppTheme.Colors.secondaryText
                            )
                        )
                        Text(
                            text = goalLabels[index],
                            color = Color.White,
                            fontSize = 14.sp,
                            modifier = Modifier.padding(start = 8.dp, top = 12.dp)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            Button(
                onClick = {
                    onSave(
                        ProfileUpdateRequest(
                            name = name.ifBlank { null },
                            age = age.toIntOrNull(),
                            weight = weight.toDoubleOrNull(),
                            height = height.toDoubleOrNull(),
                            goal = goal.ifBlank { null }
                        )
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Saxla", fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

@Composable
fun ProfileTextField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    keyboardType: KeyboardType = KeyboardType.Text
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label, color = AppTheme.Colors.secondaryText) },
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 12.dp),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = AppTheme.Colors.accent,
            unfocusedBorderColor = AppTheme.Colors.separator,
            focusedTextColor = Color.White,
            unfocusedTextColor = Color.White,
            cursorColor = AppTheme.Colors.accent
        ),
        singleLine = true,
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType)
    )
}
