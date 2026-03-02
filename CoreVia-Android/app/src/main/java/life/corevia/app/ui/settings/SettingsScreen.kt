package life.corevia.app.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    viewModel: SettingsViewModel = hiltViewModel(),
    onBack: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        TopAppBar(
            title = { Text("Tənzimləmələr", fontWeight = FontWeight.Bold, fontSize = 20.sp) },
            navigationIcon = {
                IconButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri")
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.background)
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
        ) {
            Spacer(modifier = Modifier.height(8.dp))

            SettingsToggleItem(
                icon = Icons.Filled.Notifications,
                title = "Bildirişlər",
                subtitle = "Push bildirişlərini al",
                isChecked = uiState.notificationsEnabled,
                onCheckedChange = { viewModel.toggleNotifications(it) },
                iconColor = Color(0xFF2196F3)
            )
            Spacer(modifier = Modifier.height(8.dp))

            // Biometric toggle
            if (viewModel.canUseBiometric()) {
                SettingsToggleItem(
                    icon = Icons.Filled.Fingerprint,
                    title = "Biometrik giriş",
                    subtitle = uiState.biometricType,
                    isChecked = uiState.biometricEnabled,
                    onCheckedChange = { viewModel.toggleBiometric(it) },
                    iconColor = CoreViaSuccess
                )
            } else {
                SettingsClickItem(
                    icon = Icons.Filled.Fingerprint,
                    title = "Biometrik giriş",
                    subtitle = "Mövcud deyil",
                    iconColor = TextSecondary,
                    onClick = {}
                )
            }
            Spacer(modifier = Modifier.height(8.dp))

            SettingsToggleItem(
                icon = Icons.Filled.DarkMode,
                title = "Qaranlıq rejim",
                subtitle = "Tünd tema istifadə et",
                isChecked = uiState.darkModeEnabled,
                onCheckedChange = { viewModel.toggleDarkMode(it) },
                iconColor = CoreViaPrimary
            )
            Spacer(modifier = Modifier.height(8.dp))

            SettingsClickItem(
                icon = Icons.Filled.Language,
                title = "Dil",
                subtitle = uiState.selectedLanguage,
                iconColor = CoreViaSuccess,
                onClick = {}
            )
            Spacer(modifier = Modifier.height(8.dp))

            SettingsClickItem(
                icon = Icons.Filled.Info,
                title = "Haqqında",
                subtitle = "Versiya ${uiState.appVersion}",
                iconColor = CoreViaSecondary,
                onClick = {}
            )
            Spacer(modifier = Modifier.height(8.dp))

            SettingsClickItem(
                icon = Icons.Filled.PrivacyTip,
                title = "Məxfilik Siyasəti",
                subtitle = "",
                iconColor = Color(0xFFFF9800),
                onClick = {}
            )
            Spacer(modifier = Modifier.height(8.dp))

            SettingsClickItem(
                icon = Icons.Filled.Description,
                title = "İstifadə Şərtləri",
                subtitle = "",
                iconColor = TextSecondary,
                onClick = {}
            )

            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
private fun SettingsToggleItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    isChecked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    iconColor: Color
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(2.dp, RoundedCornerShape(14.dp))
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(horizontal = 16.dp, vertical = 14.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(iconColor.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(icon, null, tint = iconColor, modifier = Modifier.size(20.dp))
                }
                Column {
                    Text(title, fontSize = 16.sp, fontWeight = FontWeight.Medium, color = MaterialTheme.colorScheme.onSurface)
                    if (subtitle.isNotEmpty()) {
                        Text(subtitle, fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
            Switch(
                checked = isChecked,
                onCheckedChange = onCheckedChange,
                colors = SwitchDefaults.colors(checkedTrackColor = CoreViaPrimary)
            )
        }
    }
}

@Composable
private fun SettingsClickItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    iconColor: Color,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(2.dp, RoundedCornerShape(14.dp))
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surface)
            .clickable { onClick() }
            .padding(horizontal = 16.dp, vertical = 14.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(iconColor.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(icon, null, tint = iconColor, modifier = Modifier.size(20.dp))
                }
                Column {
                    Text(title, fontSize = 16.sp, fontWeight = FontWeight.Medium, color = MaterialTheme.colorScheme.onSurface)
                    if (subtitle.isNotEmpty()) {
                        Text(subtitle, fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
            Icon(
                Icons.Filled.ChevronRight,
                null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(22.dp)
            )
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun SettingsScreenPreview() {
    CoreViaTheme {
        SettingsScreen()
    }
}
