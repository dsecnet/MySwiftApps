package life.corevia.app.ui.profile

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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.ui.theme.*

/**
 * iOS EditClientProfileView.swift equivalent
 */
@Composable
fun EditProfileScreen(
    onBack: () -> Unit = {}
) {
    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var weight by remember { mutableStateOf("") }
    var height by remember { mutableStateOf("") }
    var goal by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // ── Top Bar ──
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 16.dp, end = 16.dp, top = 50.dp, bottom = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Profili Redaktə Et",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "Ləğv et",
                modifier = Modifier.clickable(onClick = onBack),
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium,
                color = CoreViaPrimary
            )
        }

        // ── Form ──
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            EditField(
                label = "Ad, Soyad",
                icon = Icons.Filled.Person,
                value = name,
                onValueChange = { name = it }
            )

            EditField(
                label = "Email",
                icon = Icons.Filled.Email,
                value = email,
                onValueChange = { email = it },
                keyboardType = KeyboardType.Email
            )

            EditField(
                label = "Yaş",
                icon = Icons.Filled.CalendarMonth,
                value = age,
                onValueChange = {
                    val filtered = it.filter { c -> c.isDigit() }
                    age = if (filtered.isNotEmpty() && filtered.toInt() > 120) "120" else filtered
                },
                keyboardType = KeyboardType.Number
            )

            EditField(
                label = "Çəki (kq)",
                icon = Icons.Filled.MonitorWeight,
                value = weight,
                onValueChange = {
                    val filtered = it.filter { c -> c.isDigit() || c == '.' }
                    weight = if (filtered.isNotEmpty() && (filtered.toDoubleOrNull() ?: 0.0) > 500) "500" else filtered
                },
                keyboardType = KeyboardType.Decimal
            )

            EditField(
                label = "Boy (sm)",
                icon = Icons.Filled.Straighten,
                value = height,
                onValueChange = {
                    val filtered = it.filter { c -> c.isDigit() }
                    height = if (filtered.isNotEmpty() && filtered.toInt() > 300) "300" else filtered
                },
                keyboardType = KeyboardType.Number
            )

            // ── Goal Selection ──
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Hədəf",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    listOf("Arıqlamaq", "Əzələ", "Sağlam").forEach { option ->
                        GoalChip(
                            title = option,
                            isSelected = goal == option,
                            onClick = { goal = option }
                        )
                    }
                }
            }

            // ── Save Button ──
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 10.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(CoreViaPrimary)
                    .clickable { onBack() }
                    .padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.CheckCircle,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp),
                        tint = Color.White
                    )
                    Text(
                        text = "Yadda Saxla",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }

            Spacer(modifier = Modifier.height(40.dp))
        }
    }
}

// ── Edit Field ─────────────────────────────────────────────────────
@Composable
private fun EditField(
    label: String,
    icon: ImageVector,
    value: String,
    onValueChange: (String) -> Unit,
    keyboardType: KeyboardType = KeyboardType.Text
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = label,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                .padding(horizontal = 16.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                icon,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = CoreViaPrimary
            )
            TextField(
                value = value,
                onValueChange = onValueChange,
                modifier = Modifier.fillMaxWidth(),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    focusedTextColor = MaterialTheme.colorScheme.onBackground,
                    unfocusedTextColor = MaterialTheme.colorScheme.onBackground
                ),
                keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
                singleLine = true
            )
        }
    }
}

// ── Goal Chip ──────────────────────────────────────────────────────
@Composable
private fun GoalChip(
    title: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(
                if (isSelected) CoreViaPrimary
                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 8.dp)
    ) {
        Text(
            text = title,
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold,
            color = if (isSelected) Color.White else MaterialTheme.colorScheme.onBackground
        )
    }
}
