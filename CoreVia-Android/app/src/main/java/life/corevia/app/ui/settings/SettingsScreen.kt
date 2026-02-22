package life.corevia.app.ui.settings

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
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
import androidx.compose.material.icons.outlined.*
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
import androidx.lifecycle.viewmodel.compose.viewModel

/**
 * iOS SettingsView.swift — Android 1-to-1 port
 *
 * Sections:
 *  - Notifications (toggles persisted via API)
 *  - Security (biometric, change password, delete account)
 *  - About (logo, features, links, copyright)
 *
 * Connected to SettingsViewModel for API persistence.
 */
@Composable
fun SettingsScreen(
    onBack: () -> Unit,
    onLogout: () -> Unit = {},
    viewModel: SettingsViewModel = viewModel()
) {
    val context = LocalContext.current
    val settings by viewModel.settings.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val accountDeleted by viewModel.accountDeleted.collectAsState()

    // Notification preferences — driven by ViewModel
    val notificationsEnabled = settings?.notificationsEnabled ?: true
    val workoutReminders = settings?.workoutReminders ?: true
    val mealReminders = settings?.mealReminders ?: true
    val weeklyReport = settings?.weeklyReports ?: false

    // Security preferences (local only)
    var biometricEnabled by remember { mutableStateOf(false) }

    // Dialogs
    var showChangePasswordDialog by remember { mutableStateOf(false) }
    var showDeleteAccountDialog by remember { mutableStateOf(false) }

    // Handle account deletion — navigate to logout
    LaunchedEffect(accountDeleted) {
        if (accountDeleted) {
            onLogout()
        }
    }

    // Auto-clear messages
    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            kotlinx.coroutines.delay(3000)
            viewModel.clearSuccess()
        }
    }
    LaunchedEffect(errorMessage) {
        if (errorMessage != null) {
            kotlinx.coroutines.delay(5000)
            viewModel.clearError()
        }
    }

    // ── Change Password Dialog ──────────────────────────────────────────────────
    if (showChangePasswordDialog) {
        ChangePasswordDialog(
            isLoading = isLoading,
            onDismiss = { showChangePasswordDialog = false },
            onSave = { currentPw, newPw ->
                viewModel.changePassword(currentPw, newPw)
                showChangePasswordDialog = false
            }
        )
    }

    // ── Delete Account Dialog ───────────────────────────────────────────────────
    if (showDeleteAccountDialog) {
        DeleteAccountDialog(
            isLoading = isLoading,
            onDismiss = { showDeleteAccountDialog = false },
            onConfirm = { password ->
                viewModel.deleteAccount(password)
                showDeleteAccountDialog = false
            }
        )
    }

    // ── Snackbar for success/error ──────────────────────────────────────────────
    // (Using inline messages instead of Snackbar for simplicity)

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Column(
        modifier = Modifier
            .fillMaxSize()
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
                    tint = AppTheme.Colors.primaryText
                )
            }
            Text(
                text = "Tenzimlemeler",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )
        }

        // ── Success/Error messages ──────────────────────────────────────────
        successMessage?.let { msg ->
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = msg,
                color = AppTheme.Colors.success,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppTheme.Colors.success.copy(alpha = 0.1f), RoundedCornerShape(8.dp))
                    .padding(12.dp)
            )
        }
        errorMessage?.let { msg ->
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = msg,
                color = AppTheme.Colors.error,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppTheme.Colors.error.copy(alpha = 0.1f), RoundedCornerShape(8.dp))
                    .padding(12.dp)
            )
        }

        Spacer(modifier = Modifier.height(20.dp))

        // ═══════════════════════════════════════════════════════════════════
        // SECTION 1: Bildirisler (iOS: NotificationsSettingsView)
        // ═══════════════════════════════════════════════════════════════════
        Text(
            text = "Bildirisler",
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
                    title = "Bildirisler",
                    subtitle = "Butun bildirisleri aktivlesdir",
                    icon = Icons.Outlined.Notifications,
                    isChecked = notificationsEnabled,
                    onCheckedChange = { viewModel.updateNotificationsEnabled(it) }
                )
                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))
                SettingsToggle(
                    title = "Mesq xatirlatmalari",
                    subtitle = "Gundelik mesq bildirisleri",
                    icon = Icons.Outlined.FitnessCenter,
                    isChecked = workoutReminders,
                    enabled = notificationsEnabled,
                    onCheckedChange = { viewModel.updateWorkoutReminders(it) }
                )
                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))
                SettingsToggle(
                    title = "Yemek xatirlatmalari",
                    subtitle = "Qida izleme bildirisleri",
                    icon = Icons.Outlined.Restaurant,
                    isChecked = mealReminders,
                    enabled = notificationsEnabled,
                    onCheckedChange = { viewModel.updateMealReminders(it) }
                )
                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))
                SettingsToggle(
                    title = "Heftelik hesabat",
                    subtitle = "Her hefte irelileyis xulasesi",
                    icon = Icons.Outlined.BarChart,
                    isChecked = weeklyReport,
                    enabled = notificationsEnabled,
                    onCheckedChange = { viewModel.updateWeeklyReport(it) }
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // ═══════════════════════════════════════════════════════════════════
        // SECTION 2: Tehlukesizlik (iOS: SecuritySettingsView)
        // ═══════════════════════════════════════════════════════════════════
        Text(
            text = "Tehlukesizlik",
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
                // Biometric
                SettingsToggle(
                    title = "Biometrik giris",
                    subtitle = "Suretli daxil olma",
                    icon = Icons.Outlined.Fingerprint,
                    isChecked = biometricEnabled,
                    onCheckedChange = { biometricEnabled = it }
                )

                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))

                // Change password (account password via API)
                SettingsActionRow(
                    title = "Sifreni deyis",
                    icon = Icons.Outlined.Key,
                    onClick = { showChangePasswordDialog = true }
                )

                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))

                // 2FA (Coming soon)
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Shield,
                        contentDescription = null,
                        tint = AppTheme.Colors.accent,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = "Iki faktorlu dogrulama",
                        color = AppTheme.Colors.primaryText,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Medium,
                        modifier = Modifier.weight(1f)
                    )
                    Text(
                        text = "Tezlikle",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 12.sp
                    )
                }

                HorizontalDivider(color = AppTheme.Colors.separator, modifier = Modifier.padding(horizontal = 16.dp))

                // Delete account
                SettingsActionRow(
                    title = "Hesabi sil",
                    icon = Icons.Outlined.DeleteForever,
                    textColor = AppTheme.Colors.error,
                    onClick = { showDeleteAccountDialog = true }
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // ═══════════════════════════════════════════════════════════════════
        // SECTION 3: Haqqinda (iOS: AboutView — full version)
        // ═══════════════════════════════════════════════════════════════════
        Text(
            text = "Haqqinda",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = AppTheme.Colors.secondaryText,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        // Logo + App Name
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(contentAlignment = Alignment.Center) {
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
                    imageVector = Icons.Outlined.FitnessCenter,
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

        // Description card
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Tetbiq haqqinda",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "CoreVia idman ve qidalanma izleme tetbiqidir. Muellim-telebe sistemi, statistika, GPS izleme ve daha cox xususiyyetler.",
                    fontSize = 15.sp,
                    color = AppTheme.Colors.secondaryText,
                    lineHeight = 22.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Features
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Xususiyyetler",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
                Spacer(modifier = Modifier.height(12.dp))
                AboutFeatureRow(icon = Icons.Outlined.FitnessCenter, title = "Mesq izleme")
                AboutFeatureRow(icon = Icons.Outlined.Restaurant, title = "Qida izleme")
                AboutFeatureRow(icon = Icons.Outlined.People, title = "Muellim-telebe sistemi")
                AboutFeatureRow(icon = Icons.Outlined.BarChart, title = "Detalli statistika")
                AboutFeatureRow(icon = Icons.Outlined.Notifications, title = "Xatirlatmalar")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Links
        AboutLinkRow(
            icon = Icons.Outlined.Language,
            title = "Veb sayt",
            onClick = {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://corevia.life"))
                context.startActivity(intent)
            }
        )
        Spacer(modifier = Modifier.height(8.dp))
        AboutLinkRow(
            icon = Icons.Outlined.Email,
            title = "Elaqe",
            onClick = {
                val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:support@corevia.life"))
                context.startActivity(intent)
            }
        )
        Spacer(modifier = Modifier.height(8.dp))
        AboutLinkRow(
            icon = Icons.Outlined.Description,
            title = "Istifade sertleri",
            onClick = {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://corevia.life/terms"))
                context.startActivity(intent)
            }
        )
        Spacer(modifier = Modifier.height(8.dp))
        AboutLinkRow(
            icon = Icons.Outlined.PrivacyTip,
            title = "Mexfilik siyaseti",
            onClick = {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://corevia.life/privacy"))
                context.startActivity(intent)
            }
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Copyright
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "\u00A9 2026 CoreVia",
                fontSize = 13.sp,
                color = AppTheme.Colors.tertiaryText
            )
            Text(
                text = "Bakida sevgi ile hazirlandi",
                fontSize = 12.sp,
                color = AppTheme.Colors.tertiaryText
            )
        }

        Spacer(modifier = Modifier.height(100.dp))
    }
    } // CoreViaAnimatedBackground
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
                color = if (enabled) AppTheme.Colors.primaryText else AppTheme.Colors.primaryText.copy(alpha = 0.5f),
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
    textColor: Color = AppTheme.Colors.primaryText,
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
            imageVector = Icons.Outlined.ChevronRight,
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
        Text(text = value, color = AppTheme.Colors.primaryText, fontSize = 14.sp, fontWeight = FontWeight.Medium)
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
            imageVector = Icons.Outlined.CheckCircle,
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
// Change Password Dialog
// ═══════════════════════════════════════════════════════════════════════════════
@Composable
private fun ChangePasswordDialog(
    isLoading: Boolean,
    onDismiss: () -> Unit,
    onSave: (currentPassword: String, newPassword: String) -> Unit
) {
    var currentPassword by remember { mutableStateOf("") }
    var newPassword by remember { mutableStateOf("") }
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
                    imageVector = Icons.Outlined.Key,
                    contentDescription = null,
                    tint = AppTheme.Colors.accent,
                    modifier = Modifier.size(48.dp)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Sifreni deyis",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
            }
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value = currentPassword,
                    onValueChange = { currentPassword = it },
                    label = { Text("Cari sifre", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText,
                        cursorColor = AppTheme.Colors.accent
                    )
                )
                OutlinedTextField(
                    value = newPassword,
                    onValueChange = { newPassword = it },
                    label = { Text("Yeni sifre", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText,
                        cursorColor = AppTheme.Colors.accent
                    )
                )
                OutlinedTextField(
                    value = confirmPassword,
                    onValueChange = { confirmPassword = it },
                    label = { Text("Yeni sifreni tekrarla", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText,
                        cursorColor = AppTheme.Colors.accent
                    )
                )
                errorMessage?.let {
                    Text(it, color = AppTheme.Colors.error, fontSize = 13.sp)
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    when {
                        currentPassword.isBlank() -> errorMessage = "Cari sifreni daxil edin"
                        newPassword.length < 6 -> errorMessage = "Yeni sifre en az 6 simvol olmalidir"
                        newPassword != confirmPassword -> errorMessage = "Sifreler uygun gelmir"
                        else -> onSave(currentPassword, newPassword)
                    }
                },
                enabled = !isLoading
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        color = AppTheme.Colors.accent,
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Text("Deyis", color = AppTheme.Colors.accent, fontWeight = FontWeight.Bold)
                }
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Legv et", color = AppTheme.Colors.secondaryText)
            }
        }
    )
}

// ═══════════════════════════════════════════════════════════════════════════════
// Delete Account Dialog
// ═══════════════════════════════════════════════════════════════════════════════
@Composable
private fun DeleteAccountDialog(
    isLoading: Boolean,
    onDismiss: () -> Unit,
    onConfirm: (password: String) -> Unit
) {
    var password by remember { mutableStateOf("") }
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
                    imageVector = Icons.Outlined.Warning,
                    contentDescription = null,
                    tint = AppTheme.Colors.error,
                    modifier = Modifier.size(48.dp)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Hesabi sil",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.error
                )
            }
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(
                    text = "Bu emeliyyat geri qaytarila bilmez. Hesabiniz ve butun melumatlariniz silinecek.",
                    color = AppTheme.Colors.secondaryText,
                    fontSize = 14.sp
                )
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Sifreni daxil edin", color = AppTheme.Colors.secondaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.error,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText,
                        cursorColor = AppTheme.Colors.error
                    )
                )
                errorMessage?.let {
                    Text(it, color = AppTheme.Colors.error, fontSize = 13.sp)
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    if (password.isBlank()) {
                        errorMessage = "Sifreni daxil edin"
                    } else {
                        onConfirm(password)
                    }
                },
                enabled = !isLoading
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        color = AppTheme.Colors.error,
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Text("Hesabi sil", color = AppTheme.Colors.error, fontWeight = FontWeight.Bold)
                }
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Legv et", color = AppTheme.Colors.secondaryText)
            }
        }
    )
}
