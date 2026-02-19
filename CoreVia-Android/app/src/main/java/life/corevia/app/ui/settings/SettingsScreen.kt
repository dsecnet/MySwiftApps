package life.corevia.app.ui.settings

import life.corevia.app.ui.theme.AppTheme
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.OpenInNew
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * iOS SettingsView.swift — Android 1-ə-1 port
 *
 * iOS-da Settings 3 alt-ekrandan ibarətdir:
 *  - NotificationsSettingsView
 *  - SecuritySettingsView (biometric, PIN, 2FA)
 *  - AboutView (logo, features, links, copyright)
 *
 * Android-da hamısını bir ScrollView-da göstəririk (iOS sheet-ləri əvəzinə inline).
 */
@Composable
fun SettingsScreen(
    onBack: () -> Unit
) {
    val context = LocalContext.current

    // ── Notification preferences (iOS: @AppStorage) ────────────────────────────
    var notificationsEnabled by remember { mutableStateOf(true) }
    var workoutReminders by remember { mutableStateOf(true) }
    var mealReminders by remember { mutableStateOf(true) }
    var weeklyReport by remember { mutableStateOf(false) }

    // ── Security preferences ───────────────────────────────────────────────────
    var biometricEnabled by remember { mutableStateOf(false) }
    var hasPassword by remember { mutableStateOf(false) }
    var showSetPasswordDialog by remember { mutableStateOf(false) }
    var showRemovePasswordDialog by remember { mutableStateOf(false) }

    // ── Set Password Dialog ────────────────────────────────────────────────────
    if (showSetPasswordDialog) {
        SetPasswordDialog(
            isChanging = hasPassword,
            onDismiss = { showSetPasswordDialog = false },
            onSave = {
                hasPassword = true
                showSetPasswordDialog = false
            }
        )
    }

    // ── Remove Password Dialog ─────────────────────────────────────────────────
    if (showRemovePasswordDialog) {
        AlertDialog(
            onDismissRequest = { showRemovePasswordDialog = false },
            containerColor = AppTheme.Colors.secondaryBackground,
            title = { Text("Şifrəni sil", color = Color.White) },
            text = { Text("Tətbiq şifrəsini silmək istədiyinizə əminsiniz?", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = {
                    hasPassword = false
                    showRemovePasswordDialog = false
                }) {
                    Text("Sil", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showRemovePasswordDialog = false }) {
                    Text("Ləğv et", color = AppTheme.Colors.secondaryText)
                }
            }
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp)
    ) {
        Spacer(modifier = Modifier.height(56.dp))

        // ─── Header ─────────────────────────────────────────────────────────
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Geri",
                    tint = Color.White
                )
            }
            Text(
                text = "Tənzimləmələr",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }

        Spacer(modifier = Modifier.height(20.dp))

        // ═══════════════════════════════════════════════════════════════════
        // SECTION 1: Bildirişlər (iOS: NotificationsSettingsView)
        // ═══════════════════════════════════════════════════════════════════
        Text(
            text = "Bildirişlər",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = AppTheme.Colors.secondaryText,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
        ) {
            Column(modifier = Modifier.padding(4.dp)) {
                SettingsToggle(
                    title = "Bildirişlər",
                    subtitle = "Bütün bildirişləri aktivləşdir",
                    icon = Icons.Filled.Notifications,
                    isChecked = notificationsEnabled,
                    onCheckedChange = { notificationsEnabled = it }
                )
                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))
                SettingsToggle(
                    title = "Məşq xatırlatmaları",
                    subtitle = "Gündəlik məşq bildirişləri",
                    icon = Icons.Filled.FitnessCenter,
                    isChecked = workoutReminders,
                    enabled = notificationsEnabled,
                    onCheckedChange = { workoutReminders = it }
                )
                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))
                SettingsToggle(
                    title = "Yemək xatırlatmaları",
                    subtitle = "Qida izləmə bildirişləri",
                    icon = Icons.Filled.Restaurant,
                    isChecked = mealReminders,
                    enabled = notificationsEnabled,
                    onCheckedChange = { mealReminders = it }
                )
                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))
                SettingsToggle(
                    title = "Həftəlik hesabat",
                    subtitle = "Hər həftə irəliləyiş xülasəsi",
                    icon = Icons.Filled.BarChart,
                    isChecked = weeklyReport,
                    enabled = notificationsEnabled,
                    onCheckedChange = { weeklyReport = it }
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // ═══════════════════════════════════════════════════════════════════
        // SECTION 2: Təhlükəsizlik (iOS: SecuritySettingsView)
        // ═══════════════════════════════════════════════════════════════════
        Text(
            text = "Təhlükəsizlik",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = AppTheme.Colors.secondaryText,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
        ) {
            Column(modifier = Modifier.padding(4.dp)) {
                // ── Biometric (iOS: Face ID toggle) ────────────────────────
                SettingsToggle(
                    title = "Biometrik giriş",
                    subtitle = "Sürətli daxil olma",
                    icon = Icons.Filled.Fingerprint,
                    isChecked = biometricEnabled,
                    onCheckedChange = { biometricEnabled = it }
                )

                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))

                // ── Password (iOS: 4-digit PIN) ────────────────────────────
                if (hasPassword) {
                    // Change password
                    SettingsActionRow(
                        title = "Şifrəni dəyiş",
                        icon = Icons.Filled.Key,
                        onClick = { showSetPasswordDialog = true }
                    )
                    HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))
                    // Remove password
                    SettingsActionRow(
                        title = "Şifrəni sil",
                        icon = Icons.Filled.Delete,
                        textColor = AppTheme.Colors.error,
                        onClick = { showRemovePasswordDialog = true }
                    )
                } else {
                    SettingsActionRow(
                        title = "Şifrə təyin et",
                        icon = Icons.Filled.Lock,
                        onClick = { showSetPasswordDialog = true }
                    )
                }

                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))

                // ── 2FA (iOS: "Coming soon") ───────────────────────────────
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Filled.Shield,
                        contentDescription = null,
                        tint = AppTheme.Colors.accent,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = "İki faktorlu doğrulama",
                        color = Color.White,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Medium,
                        modifier = Modifier.weight(1f)
                    )
                    Text(
                        text = "Tezliklə",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 12.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // ═══════════════════════════════════════════════════════════════════
        // SECTION 3: Haqqında (iOS: AboutView — full version)
        // ═══════════════════════════════════════════════════════════════════
        Text(
            text = "Haqqında",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = AppTheme.Colors.secondaryText,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        // ── Logo + App Name (iOS: gradient circle + icon) ──────────────
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(contentAlignment = Alignment.Center) {
                // Gradient circle
                Box(
                    modifier = Modifier
                        .size(120.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                colors = listOf(
                                    AppTheme.Colors.accent.copy(alpha = 0.3f),
                                    AppTheme.Colors.accent
                                )
                            )
                        )
                )
                Icon(
                    imageVector = Icons.Filled.FitnessCenter,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(50.dp)
                )
            }
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = "CoreVia",
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )
            Text(
                text = "Fitness & Nutrition Tracking",
                fontSize = 16.sp,
                color = AppTheme.Colors.secondaryText
            )
            Text(
                text = "Versiya 1.0.0",
                fontSize = 14.sp,
                color = AppTheme.Colors.tertiaryText
            )
        }

        Spacer(modifier = Modifier.height(20.dp))

        // ── Description card ────────────────────────────────────────────
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Tətbiq haqqında",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "CoreVia idman və qidalanma izləmə tətbiqidir. Müəllim-tələbə sistemi, statistika, GPS izləmə və daha çox xüsusiyyətlər.",
                    fontSize = 15.sp,
                    color = AppTheme.Colors.secondaryText,
                    lineHeight = 22.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── Features (iOS: AboutFeatureRow with checkmarks) ─────────────
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Xüsusiyyətlər",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
                Spacer(modifier = Modifier.height(12.dp))
                AboutFeatureRow(icon = Icons.Filled.FitnessCenter, title = "Məşq izləmə")
                AboutFeatureRow(icon = Icons.Filled.Restaurant, title = "Qida izləmə")
                AboutFeatureRow(icon = Icons.Filled.People, title = "Müəllim-tələbə sistemi")
                AboutFeatureRow(icon = Icons.Filled.BarChart, title = "Detallı statistika")
                AboutFeatureRow(icon = Icons.Filled.Notifications, title = "Xatırlatmalar")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── Links (iOS: AboutLinkButton) ────────────────────────────────
        AboutLinkRow(
            icon = Icons.Filled.Language,
            title = "Veb sayt",
            onClick = {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://corevia.life"))
                context.startActivity(intent)
            }
        )
        Spacer(modifier = Modifier.height(8.dp))
        AboutLinkRow(
            icon = Icons.Filled.Email,
            title = "Əlaqə",
            onClick = {
                val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:support@corevia.life"))
                context.startActivity(intent)
            }
        )
        Spacer(modifier = Modifier.height(8.dp))
        AboutLinkRow(
            icon = Icons.Filled.Description,
            title = "İstifadə şərtləri",
            onClick = {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://corevia.life/terms"))
                context.startActivity(intent)
            }
        )
        Spacer(modifier = Modifier.height(8.dp))
        AboutLinkRow(
            icon = Icons.Filled.PrivacyTip,
            title = "Məxfilik siyasəti",
            onClick = {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://corevia.life/privacy"))
                context.startActivity(intent)
            }
        )

        Spacer(modifier = Modifier.height(24.dp))

        // ── Copyright (iOS: bottom text) ────────────────────────────────
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "© 2026 CoreVia",
                fontSize = 13.sp,
                color = AppTheme.Colors.tertiaryText
            )
            Text(
                text = "Bakıda sevgi ilə hazırlandı ❤️",
                fontSize = 12.sp,
                color = AppTheme.Colors.tertiaryText
            )
        }

        Spacer(modifier = Modifier.height(100.dp))
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Components
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
fun SettingsToggle(
    title: String,
    subtitle: String,
    icon: ImageVector? = null,
    isChecked: Boolean,
    enabled: Boolean = true,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp)
            .then(if (!enabled) Modifier.let { it } else Modifier),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (icon != null) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = AppTheme.Colors.accent,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(12.dp))
        }
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                color = if (enabled) Color.White else Color.White.copy(alpha = 0.5f),
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium
            )
            Text(
                text = subtitle,
                color = if (enabled) AppTheme.Colors.secondaryText else AppTheme.Colors.secondaryText.copy(alpha = 0.5f),
                fontSize = 12.sp
            )
        }
        Switch(
            checked = isChecked,
            onCheckedChange = onCheckedChange,
            enabled = enabled,
            colors = SwitchDefaults.colors(
                checkedThumbColor = Color.White,
                checkedTrackColor = AppTheme.Colors.accent,
                uncheckedThumbColor = AppTheme.Colors.secondaryText,
                uncheckedTrackColor = AppTheme.Colors.separator
            )
        )
    }
}

@Composable
fun SettingsActionRow(
    title: String,
    icon: ImageVector,
    textColor: Color = Color.White,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = AppTheme.Colors.accent,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.width(12.dp))
        Text(
            text = title,
            color = textColor,
            fontSize = 15.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.weight(1f)
        )
        Icon(
            imageVector = Icons.Filled.ChevronRight,
            contentDescription = null,
            tint = AppTheme.Colors.secondaryText,
            modifier = Modifier.size(16.dp)
        )
    }
}

@Composable
fun SettingsInfoRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(text = label, color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
        Text(text = value, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Medium)
    }
}

// ── iOS AboutFeatureRow (icon + title + checkmark) ──────────────────────────
@Composable
private fun AboutFeatureRow(icon: ImageVector, title: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = AppTheme.Colors.accent,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.width(12.dp))
        Text(
            text = title,
            color = AppTheme.Colors.primaryText,
            fontSize = 15.sp,
            modifier = Modifier.weight(1f)
        )
        Icon(
            imageVector = Icons.Filled.CheckCircle,
            contentDescription = null,
            tint = AppTheme.Colors.success,
            modifier = Modifier.size(20.dp)
        )
    }
}

// ── iOS AboutLinkButton (icon + title + arrow.up.right) ─────────────────────
@Composable
private fun AboutLinkRow(icon: ImageVector, title: String, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = AppTheme.Colors.accent,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(12.dp))
            Text(
                text = title,
                color = AppTheme.Colors.primaryText,
                fontSize = 15.sp,
                modifier = Modifier.weight(1f)
            )
            Icon(
                imageVector = Icons.AutoMirrored.Filled.OpenInNew,
                contentDescription = null,
                tint = AppTheme.Colors.secondaryText,
                modifier = Modifier.size(16.dp)
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Set Password Dialog (iOS: SetPasswordView — 4-digit PIN)
// ═══════════════════════════════════════════════════════════════════════════════
@Composable
private fun SetPasswordDialog(
    isChanging: Boolean,
    onDismiss: () -> Unit,
    onSave: () -> Unit
) {
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = AppTheme.Colors.secondaryBackground,
        title = {
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(
                    imageVector = Icons.Filled.Shield,
                    contentDescription = null,
                    tint = AppTheme.Colors.accent,
                    modifier = Modifier.size(60.dp)
                )
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = if (isChanging) "Şifrəni dəyiş" else "Şifrə təyin et",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "4 rəqəmli şifrə daxil edin",
                    fontSize = 14.sp,
                    color = AppTheme.Colors.secondaryText
                )
            }
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                // Password field
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("Şifrə", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                    PinDots(length = password.length)
                    OutlinedTextField(
                        value = password,
                        onValueChange = { if (it.length <= 4 && it.all { c -> c.isDigit() }) password = it },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(1.dp), // Hidden — just for keyboard
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword),
                        visualTransformation = PasswordVisualTransformation(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color.Transparent,
                            unfocusedBorderColor = Color.Transparent,
                            focusedTextColor = Color.Transparent,
                            unfocusedTextColor = Color.Transparent
                        )
                    )
                }

                // Confirm password field
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("Təkrar şifrə", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                    PinDots(length = confirmPassword.length)
                    OutlinedTextField(
                        value = confirmPassword,
                        onValueChange = { if (it.length <= 4 && it.all { c -> c.isDigit() }) confirmPassword = it },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(1.dp),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword),
                        visualTransformation = PasswordVisualTransformation(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color.Transparent,
                            unfocusedBorderColor = Color.Transparent,
                            focusedTextColor = Color.Transparent,
                            unfocusedTextColor = Color.Transparent
                        )
                    )
                }

                // Error
                errorMessage?.let {
                    Text(it, color = AppTheme.Colors.error, fontSize = 13.sp, textAlign = TextAlign.Center)
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    when {
                        password.length != 4 -> errorMessage = "Şifrə 4 rəqəm olmalıdır"
                        password != confirmPassword -> errorMessage = "Şifrələr uyğun gəlmir"
                        else -> onSave()
                    }
                },
                enabled = password.length == 4 && confirmPassword.length == 4
            ) {
                Text("Saxla", color = AppTheme.Colors.accent, fontWeight = FontWeight.Bold)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Ləğv et", color = AppTheme.Colors.secondaryText)
            }
        }
    )
}

// ── iOS PinCodeField — 4 filled/empty dots ──────────────────────────────────
@Composable
private fun PinDots(length: Int) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(4) { index ->
            Box(
                modifier = Modifier
                    .size(60.dp)
                    .background(AppTheme.Colors.background, RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center
            ) {
                if (length > index) {
                    Box(
                        modifier = Modifier
                            .size(16.dp)
                            .background(AppTheme.Colors.accent, CircleShape)
                    )
                }
            }
        }
    }
}
