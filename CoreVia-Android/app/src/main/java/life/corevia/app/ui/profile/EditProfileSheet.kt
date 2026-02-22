package life.corevia.app.ui.profile

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
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
 *
 * Pre-fills all fields from current user data.
 * Supports both client (name, age, weight, height, goal) and
 * trainer (+ bio, specialization, experience, pricePerSession) fields.
 * Shows loading state during save and dismisses on success.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileSheet(
    user: UserResponse?,
    isLoading: Boolean = false,
    onDismiss: () -> Unit,
    onSave: (ProfileUpdateRequest) -> Unit
) {
    var name by remember { mutableStateOf(user?.name ?: "") }
    var age by remember { mutableStateOf(user?.age?.toString() ?: "") }
    var weight by remember { mutableStateOf(user?.weight?.toString() ?: "") }
    var height by remember { mutableStateOf(user?.height?.toString() ?: "") }
    var goal by remember { mutableStateOf(user?.goal ?: "") }
    var bio by remember { mutableStateOf(user?.bio ?: "") }
    var specialization by remember { mutableStateOf(user?.specialization ?: "") }
    var experience by remember { mutableStateOf(user?.experience?.toString() ?: "") }
    var pricePerSession by remember { mutableStateOf(user?.pricePerSession?.toString() ?: "") }

    val isTrainer = user?.userType == "trainer"

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
                text = "Profili Redakte et",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )
            Spacer(modifier = Modifier.height(20.dp))

            ProfileTextField(label = "Ad", value = name, onValueChange = { name = it })
            ProfileTextField(
                label = "Yas",
                value = age,
                onValueChange = { age = it.filter { c -> c.isDigit() } },
                keyboardType = KeyboardType.Number
            )
            ProfileTextField(
                label = "Ceki (kg)",
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

            // Bio field
            OutlinedTextField(
                value = bio,
                onValueChange = { bio = it },
                label = { Text("Haqqinda", color = AppTheme.Colors.secondaryText) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppTheme.Colors.accent,
                    unfocusedBorderColor = AppTheme.Colors.separator,
                    focusedTextColor = AppTheme.Colors.primaryText,
                    unfocusedTextColor = AppTheme.Colors.primaryText,
                    cursorColor = AppTheme.Colors.accent
                ),
                minLines = 2,
                maxLines = 4,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text)
            )

            // Trainer-specific fields
            if (isTrainer) {
                ProfileTextField(
                    label = "Ixtisas",
                    value = specialization,
                    onValueChange = { specialization = it }
                )
                ProfileTextField(
                    label = "Tecrube (il)",
                    value = experience,
                    onValueChange = { experience = it.filter { c -> c.isDigit() } },
                    keyboardType = KeyboardType.Number
                )
                ProfileTextField(
                    label = "Seans qiymeti (AZN)",
                    value = pricePerSession,
                    onValueChange = { pricePerSession = it.filter { c -> c.isDigit() || c == '.' } },
                    keyboardType = KeyboardType.Decimal
                )
            }

            // Goal secimi
            Text(
                text = "Meqsed",
                color = AppTheme.Colors.secondaryText,
                fontSize = 13.sp,
                modifier = Modifier.padding(bottom = 4.dp)
            )
            val goals = listOf("weight_loss", "weight_gain", "muscle_gain", "general_fitness")
            val goalLabels = listOf("Ceki itkisi", "Ceki artimi", "Ezele artimi", "Umumi fitness")
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
                            color = AppTheme.Colors.primaryText,
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
                            goal = goal.ifBlank { null },
                            bio = bio.ifBlank { null },
                            specialization = specialization.ifBlank { null },
                            experience = experience.toIntOrNull(),
                            pricePerSession = pricePerSession.toDoubleOrNull()
                        )
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = !isLoading,
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                shape = RoundedCornerShape(12.dp)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        color = Color.White,
                        modifier = Modifier.size(20.dp),
                        strokeWidth = 2.dp
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Saxlanilir...", fontWeight = FontWeight.SemiBold)
                } else {
                    Text("Saxla", fontWeight = FontWeight.SemiBold)
                }
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
            focusedTextColor = AppTheme.Colors.primaryText,
            unfocusedTextColor = AppTheme.Colors.primaryText,
            cursorColor = AppTheme.Colors.accent
        ),
        singleLine = true,
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType)
    )
}
