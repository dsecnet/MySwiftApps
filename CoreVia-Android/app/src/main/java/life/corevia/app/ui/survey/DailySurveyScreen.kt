package life.corevia.app.ui.survey

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.ui.theme.*

@Composable
fun DailySurveyScreen(
    viewModel: DailySurveyViewModel = hiltViewModel(),
    onBack: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // Top Bar
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 8.dp, end = 16.dp, top = 48.dp, bottom = 8.dp)
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    Icons.Filled.ArrowBack,
                    contentDescription = "Geri",
                    modifier = Modifier.size(24.dp),
                    tint = MaterialTheme.colorScheme.onBackground
                )
            }
            Text(
                text = "Günlük Sorğu",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground,
                modifier = Modifier.align(Alignment.Center)
            )
        }

        if (uiState.isLoading) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = CoreViaPrimary)
            }
        } else if (uiState.isCompleted) {
            // Completed state
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Icon(
                        Icons.Filled.CheckCircle,
                        contentDescription = null,
                        modifier = Modifier.size(72.dp),
                        tint = CoreViaSuccess
                    )
                    Text(
                        text = "Sorğu tamamlandı!",
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = "Bugünkü sorğunuz uğurla qeydə alındı.",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 40.dp)
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Button(
                        onClick = onBack,
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
                    ) {
                        Text("Geri qayıt", fontWeight = FontWeight.Bold)
                    }
                }
            }
        } else {
            // Survey form
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp)
                    .padding(bottom = 32.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Bugünkü vəziyyətinizi qiymətləndirin",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 4.dp)
                )

                // 1. Energy Level (1-5)
                SurveyEmojiCard(
                    title = "Enerji Səviyyəsi",
                    subtitle = "Bu gün özünüzü necə hiss edirsiniz?",
                    icon = Icons.Filled.FlashOn,
                    iconColor = Color(0xFFFF9800),
                    emojis = listOf("😴", "😐", "🙂", "😊", "⚡"),
                    labels = listOf("Çox aşağı", "Aşağı", "Normal", "Yaxşı", "Əla"),
                    selectedIndex = uiState.energyLevel - 1,
                    onSelect = { viewModel.setEnergyLevel(it + 1) }
                )

                // 2. Sleep Hours (0-24)
                SurveySliderCard(
                    title = "Yuxu Müddəti",
                    subtitle = "Neçə saat yatdınız?",
                    icon = Icons.Filled.DarkMode,
                    iconColor = Color(0xFF9C27B0),
                    value = uiState.sleepHours.toFloat(),
                    valueText = String.format("%.1f saat", uiState.sleepHours),
                    range = 0f..14f,
                    steps = 27,
                    onValueChange = { viewModel.setSleepHours(it.toDouble()) }
                )

                // 3. Sleep Quality (1-5)
                SurveyEmojiCard(
                    title = "Yuxu Keyfiyyəti",
                    subtitle = "Yuxunuzun keyfiyyətini qiymətləndirin",
                    icon = Icons.Filled.Bedtime,
                    iconColor = Color(0xFF9C27B0),
                    emojis = listOf("😫", "😕", "😐", "😊", "😴"),
                    labels = listOf("Çox pis", "Pis", "Normal", "Yaxşı", "Əla"),
                    selectedIndex = uiState.sleepQuality - 1,
                    onSelect = { viewModel.setSleepQuality(it + 1) }
                )

                // 4. Stress Level (1-5)
                SurveyEmojiCard(
                    title = "Stress Səviyyəsi",
                    subtitle = "Nə qədər stresslisiz?",
                    icon = Icons.Filled.Psychology,
                    iconColor = Color(0xFFF44336),
                    emojis = listOf("😌", "🙂", "😐", "😰", "🤯"),
                    labels = listOf("Rahat", "Az", "Normal", "Yüksək", "Çox yüksək"),
                    selectedIndex = uiState.stressLevel - 1,
                    onSelect = { viewModel.setStressLevel(it + 1) }
                )

                // 5. Muscle Soreness (1-5)
                SurveyEmojiCard(
                    title = "Əzələ Ağrısı",
                    subtitle = "Əzələləriniz necə hiss edir?",
                    icon = Icons.Filled.FitnessCenter,
                    iconColor = CoreViaPrimary,
                    emojis = listOf("💪", "🙂", "😐", "😣", "🥵"),
                    labels = listOf("Yoxdur", "Az", "Orta", "Çox", "Həddindən artıq"),
                    selectedIndex = uiState.muscleSoreness - 1,
                    onSelect = { viewModel.setMuscleSoreness(it + 1) }
                )

                // 6. Mood (1-5)
                SurveyEmojiCard(
                    title = "Əhval-ruhiyyə",
                    subtitle = "Ümumi əhvalınız necədir?",
                    icon = Icons.Filled.Mood,
                    iconColor = CoreViaSuccess,
                    emojis = listOf("😢", "😕", "😐", "😊", "🤩"),
                    labels = listOf("Pis", "Aşağı", "Normal", "Yaxşı", "Əla"),
                    selectedIndex = uiState.mood - 1,
                    onSelect = { viewModel.setMood(it + 1) }
                )

                // 7. Water Glasses (stepper)
                SurveyStepperCard(
                    title = "Su İçmə",
                    subtitle = "Neçə stəkan su içdiniz?",
                    icon = Icons.Filled.WaterDrop,
                    iconColor = Color(0xFF2196F3),
                    value = uiState.waterGlasses,
                    onDecrement = { viewModel.setWaterGlasses(uiState.waterGlasses - 1) },
                    onIncrement = { viewModel.setWaterGlasses(uiState.waterGlasses + 1) }
                )

                // Notes
                OutlinedTextField(
                    value = uiState.notes,
                    onValueChange = { viewModel.setNotes(it) },
                    label = { Text("Qeydlər (ixtiyari)") },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    maxLines = 3,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f)
                    )
                )

                // Error message
                if (uiState.error != null) {
                    Text(
                        text = uiState.error!!,
                        color = Color(0xFFF44336),
                        fontSize = 13.sp,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                // Submit button
                Button(
                    onClick = { viewModel.submitSurvey { /* stays on screen, shows completed */ } },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(14.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary),
                    enabled = !uiState.isSubmitting
                ) {
                    if (uiState.isSubmitting) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(22.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(Icons.Filled.Send, null, modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            "Göndər",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}

// ── Emoji Selection Card (for 1-5 scales) ─────────────────────────────

@Composable
private fun SurveyEmojiCard(
    title: String,
    subtitle: String,
    icon: ImageVector,
    iconColor: Color,
    emojis: List<String>,
    labels: List<String>,
    selectedIndex: Int,
    onSelect: (Int) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Header
        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(iconColor.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    icon, null,
                    modifier = Modifier.size(18.dp),
                    tint = iconColor
                )
            }
            Column {
                Text(
                    text = title,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = subtitle,
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        // Emoji row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            emojis.forEachIndexed { index, emoji ->
                val isSelected = index == selectedIndex
                val scale by animateFloatAsState(
                    targetValue = if (isSelected) 1.2f else 1f,
                    label = "scale"
                )
                val bgColor by animateColorAsState(
                    targetValue = if (isSelected) iconColor.copy(alpha = 0.2f) else Color.Transparent,
                    label = "bgColor"
                )

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(bgColor)
                        .clickable { onSelect(index) }
                        .padding(horizontal = 8.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = emoji,
                        fontSize = 28.sp,
                        modifier = Modifier.scale(scale)
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = labels[index],
                        fontSize = 9.sp,
                        color = if (isSelected) iconColor else MaterialTheme.colorScheme.onSurfaceVariant,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}

// ── Slider Card (for sleep hours) ──────────────────────────────────────

@Composable
private fun SurveySliderCard(
    title: String,
    subtitle: String,
    icon: ImageVector,
    iconColor: Color,
    value: Float,
    valueText: String,
    range: ClosedFloatingPointRange<Float>,
    steps: Int,
    onValueChange: (Float) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
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
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(iconColor.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(icon, null, modifier = Modifier.size(18.dp), tint = iconColor)
                }
                Column {
                    Text(
                        text = title,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = subtitle,
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            Text(
                text = valueText,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = iconColor
            )
        }

        Slider(
            value = value,
            onValueChange = { onValueChange((it * 2).toInt() / 2f) }, // round to 0.5
            valueRange = range,
            steps = steps,
            colors = SliderDefaults.colors(
                thumbColor = iconColor,
                activeTrackColor = iconColor,
                inactiveTrackColor = iconColor.copy(alpha = 0.2f)
            )
        )
    }
}

// ── Stepper Card (for water glasses) ───────────────────────────────────

@Composable
private fun SurveyStepperCard(
    title: String,
    subtitle: String,
    icon: ImageVector,
    iconColor: Color,
    value: Int,
    onDecrement: () -> Unit,
    onIncrement: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(iconColor.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(icon, null, modifier = Modifier.size(18.dp), tint = iconColor)
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = subtitle,
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Minus button
            IconButton(
                onClick = onDecrement,
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(iconColor.copy(alpha = 0.15f))
            ) {
                Icon(
                    Icons.Filled.Remove,
                    contentDescription = "Azalt",
                    tint = iconColor,
                    modifier = Modifier.size(24.dp)
                )
            }

            Spacer(modifier = Modifier.width(24.dp))

            // Value display
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "$value",
                    fontSize = 36.sp,
                    fontWeight = FontWeight.Bold,
                    color = iconColor
                )
                Text(
                    text = "stəkan",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.width(24.dp))

            // Plus button
            IconButton(
                onClick = onIncrement,
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(iconColor.copy(alpha = 0.15f))
            ) {
                Icon(
                    Icons.Filled.Add,
                    contentDescription = "Artır",
                    tint = iconColor,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}
