package life.corevia.app.ui.analytics

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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.BodyMeasurementCreateRequest

/**
 * iOS: AddMeasurementSheet — weight, height, bodyFat, waist, chest, arms inputları
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMeasurementSheet(
    onDismiss: () -> Unit,
    onSave: (BodyMeasurementCreateRequest) -> Unit,
    isLoading: Boolean
) {
    var weight by remember { mutableStateOf("") }
    var height by remember { mutableStateOf("") }
    var bodyFat by remember { mutableStateOf("") }
    var muscleMass by remember { mutableStateOf("") }
    var chest by remember { mutableStateOf("") }
    var waist by remember { mutableStateOf("") }
    var hips by remember { mutableStateOf("") }
    var arms by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }

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
                text = "Yeni Ölçü Əlavə Et",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText,
                modifier = Modifier.padding(bottom = 20.dp)
            )

            // ── Əsas ölçülər ────────────────────────────────────────────────────
            Text(
                text = "Əsas ölçülər",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = AppTheme.Colors.secondaryText,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                MeasurementField(
                    label = "Çəki (kg)",
                    value = weight,
                    onValueChange = { weight = it },
                    modifier = Modifier.weight(1f)
                )
                MeasurementField(
                    label = "Boy (cm)",
                    value = height,
                    onValueChange = { height = it },
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                MeasurementField(
                    label = "Yağ %",
                    value = bodyFat,
                    onValueChange = { bodyFat = it },
                    modifier = Modifier.weight(1f)
                )
                MeasurementField(
                    label = "Əzələ kütləsi (kg)",
                    value = muscleMass,
                    onValueChange = { muscleMass = it },
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            // ── Bədən ölçüləri ──────────────────────────────────────────────────
            Text(
                text = "Bədən ölçüləri (cm)",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = AppTheme.Colors.secondaryText,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                MeasurementField(
                    label = "Sinə",
                    value = chest,
                    onValueChange = { chest = it },
                    modifier = Modifier.weight(1f)
                )
                MeasurementField(
                    label = "Bel",
                    value = waist,
                    onValueChange = { waist = it },
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                MeasurementField(
                    label = "Omba",
                    value = hips,
                    onValueChange = { hips = it },
                    modifier = Modifier.weight(1f)
                )
                MeasurementField(
                    label = "Qol",
                    value = arms,
                    onValueChange = { arms = it },
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            // ── Qeydlər ────────────────────────────────────────────────────────
            OutlinedTextField(
                value = notes,
                onValueChange = { notes = it },
                label = { Text("Qeydlər (isteğe bağlı)", color = AppTheme.Colors.placeholderText) },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = AppTheme.Colors.primaryText,
                    unfocusedTextColor = AppTheme.Colors.primaryText,
                    cursorColor = AppTheme.Colors.accent,
                    focusedBorderColor = AppTheme.Colors.accent,
                    unfocusedBorderColor = AppTheme.Colors.separator,
                    focusedLabelColor = AppTheme.Colors.accent
                ),
                shape = RoundedCornerShape(12.dp),
                maxLines = 3
            )

            Spacer(modifier = Modifier.height(24.dp))

            // ── Save Button ─────────────────────────────────────────────────────
            val hasAnyValue = listOf(weight, height, bodyFat, muscleMass, chest, waist, hips, arms)
                .any { it.isNotBlank() }

            Button(
                onClick = {
                    val request = BodyMeasurementCreateRequest(
                        weight = weight.toDoubleOrNull(),
                        height = height.toDoubleOrNull(),
                        bodyFat = bodyFat.toDoubleOrNull(),
                        muscleMass = muscleMass.toDoubleOrNull(),
                        chest = chest.toDoubleOrNull(),
                        waist = waist.toDoubleOrNull(),
                        hips = hips.toDoubleOrNull(),
                        arms = arms.toDoubleOrNull(),
                        notes = notes.ifBlank { null }
                    )
                    onSave(request)
                },
                enabled = hasAnyValue && !isLoading,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = AppTheme.Colors.accent,
                    disabledContainerColor = AppTheme.Colors.accent.copy(alpha = 0.3f)
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        color = AppTheme.Colors.primaryText,
                        modifier = Modifier.size(20.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Text(
                        text = "Yadda Saxla",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

@Composable
fun MeasurementField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    OutlinedTextField(
        value = value,
        onValueChange = { newValue ->
            // Yalnız rəqəm və nöqtə
            if (newValue.isEmpty() || newValue.matches(Regex("^\\d*\\.?\\d*$"))) {
                onValueChange(newValue)
            }
        },
        label = { Text(label, fontSize = 12.sp, color = AppTheme.Colors.placeholderText) },
        modifier = modifier,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
        colors = OutlinedTextFieldDefaults.colors(
            focusedTextColor = AppTheme.Colors.primaryText,
            unfocusedTextColor = AppTheme.Colors.primaryText,
            cursorColor = AppTheme.Colors.accent,
            focusedBorderColor = AppTheme.Colors.accent,
            unfocusedBorderColor = AppTheme.Colors.separator,
            focusedLabelColor = AppTheme.Colors.accent
        ),
        shape = RoundedCornerShape(12.dp),
        singleLine = true
    )
}
