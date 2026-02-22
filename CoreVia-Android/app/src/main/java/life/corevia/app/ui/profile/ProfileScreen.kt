package life.corevia.app.ui.profile

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaGradientProgressBar
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import life.corevia.app.ui.theme.coreViaCard
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.outlined.Logout
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.ProfileUpdateRequest

/**
 * Profil ekrani — yigilmis/qruplasdrilmis versiya
 *
 * Sections:
 *  1. profileHeader (avatar + ad + email + redakte)
 *  2. profileCompletionSection (only if <100%)
 *  3. premiumBanner (only if !isPremium)
 *  4. statsRow (yas, ceki, boy — kompakt)
 *  5. uzv olma tarixi
 *  6. tenzimlemer buttonu
 *  7. cixis buttonu
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    onNavigateToSettings: () -> Unit,
    onNavigateToPremium: () -> Unit = {},
    onLogout: () -> Unit,
    viewModel: ProfileViewModel = viewModel()
) {
    val user by viewModel.user.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val profileCompletion = viewModel.profileCompletion

    var showEditSheet by remember { mutableStateOf(false) }
    var showLogoutDialog by remember { mutableStateOf(false) }

    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearSuccess()
        }
    }
    LaunchedEffect(errorMessage) {
        if (errorMessage != null) {
            kotlinx.coroutines.delay(5000)
            viewModel.clearError()
        }
    }

    if (showLogoutDialog) {
        AlertDialog(
            onDismissRequest = { showLogoutDialog = false },
            containerColor = AppTheme.Colors.secondaryBackground,
            title = { Text("Cixis", color = AppTheme.Colors.primaryText) },
            text = { Text("Hesabdan cixmaq isteyirsiniz?", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = { showLogoutDialog = false; onLogout() }) {
                    Text("Cixis", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showLogoutDialog = false }) {
                    Text("Legv et", color = AppTheme.Colors.secondaryText)
                }
            }
        )
    }

    // Error state
    if (errorMessage != null && user == null) {
        Box(
            modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Icon(Icons.Outlined.Warning, null, tint = AppTheme.Colors.warning, modifier = Modifier.size(48.dp))
                Text(errorMessage ?: "Xeta bas verdi", color = AppTheme.Colors.error, fontSize = 16.sp)
                Button(
                    onClick = { viewModel.loadUser() },
                    colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text("Yeniden cehd et", color = Color.White, fontWeight = FontWeight.SemiBold)
                }
            }
        }
        return
    }

    // Loading state
    if (isLoading && user == null) {
        Box(
            modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                CircularProgressIndicator(color = AppTheme.Colors.accent)
                Text("Profil yuklenilir...", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
            }
        }
        return
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp)
            .padding(top = 8.dp, bottom = 100.dp)
    ) {
        // ═══ 1. PROFILE HEADER ══════════════════════════════════════════
        Column(
            modifier = Modifier.fillMaxWidth().padding(top = 48.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box {
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .shadow(15.dp, CircleShape, spotColor = AppTheme.Colors.accent.copy(alpha = 0.3f))
                        .background(
                            Brush.linearGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.3f), AppTheme.Colors.accent)),
                            CircleShape
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = user?.name?.firstOrNull()?.uppercase() ?: "?",
                        fontSize = 40.sp, fontWeight = FontWeight.Bold, color = Color.White
                    )
                }
                Box(
                    modifier = Modifier.align(Alignment.BottomEnd).size(32.dp)
                        .shadow(6.dp, CircleShape, spotColor = AppTheme.Colors.accent.copy(alpha = 0.5f))
                        .clip(CircleShape).background(AppTheme.Colors.accent),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Outlined.CameraAlt, null, tint = Color.White, modifier = Modifier.size(14.dp))
                }
                if (user?.isPremium == true) {
                    Box(
                        modifier = Modifier.align(Alignment.TopEnd).offset(x = (-2).dp, y = (-2).dp)
                            .size(30.dp).shadow(4.dp, CircleShape, spotColor = AppTheme.Colors.warning.copy(alpha = 0.5f))
                            .clip(CircleShape).background(Brush.linearGradient(listOf(AppTheme.Colors.warning, AppTheme.Colors.accent))),
                        contentAlignment = Alignment.Center
                    ) { Icon(Icons.Outlined.Star, null, tint = Color.White, modifier = Modifier.size(16.dp)) }
                }
            }

            Spacer(Modifier.height(12.dp))
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(user?.name ?: "Yuklenilir...", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                if (user?.isPremium == true) {
                    Icon(Icons.Filled.Verified, null, tint = AppTheme.Colors.accentDark, modifier = Modifier.size(16.dp))
                }
            }
            Text(user?.email ?: "", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)

            Spacer(Modifier.height(8.dp))
            Box(
                modifier = Modifier.clip(RoundedCornerShape(16.dp))
                    .background(AppTheme.Colors.accent.copy(alpha = 0.1f))
                    .clickable { showEditSheet = true }
                    .padding(horizontal = 14.dp, vertical = 6.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                    Icon(Icons.Outlined.Edit, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(12.dp))
                    Text("Redakte et", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.accent)
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        // ═══ 2. PROFILE COMPLETION (only if <100%) ══════════════════════
        if (profileCompletion < 1f) {
            Column(
                modifier = Modifier.fillMaxWidth().coreViaCard().padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Profil tamamlama", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                    Text("${(profileCompletion * 100).toInt()}%", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.accent)
                }
                CoreViaGradientProgressBar(progress = profileCompletion, height = 8.dp)
            }
            Spacer(Modifier.height(16.dp))
        }

        // ═══ 3. PREMIUM BANNER (only if !isPremium) ═════════════════════
        if (user?.isPremium != true) {
            Box(
                modifier = Modifier.fillMaxWidth()
                    .shadow(12.dp, RoundedCornerShape(16.dp), spotColor = AppTheme.Colors.accentDark.copy(alpha = 0.4f))
                    .clip(RoundedCornerShape(16.dp))
                    .background(Brush.horizontalGradient(listOf(AppTheme.Colors.accentDark, AppTheme.Colors.accent.copy(alpha = 0.8f))))
                    .clickable { onNavigateToPremium() }.padding(16.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                    Box(Modifier.size(44.dp).clip(CircleShape).background(Color.White.copy(alpha = 0.2f)), contentAlignment = Alignment.Center) {
                        Icon(Icons.Outlined.AutoAwesome, null, tint = Color.White, modifier = Modifier.size(20.dp))
                    }
                    Column(Modifier.weight(1f)) {
                        Text("Premium-a kec", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        Text("Butun xususiyyetleri acin", fontSize = 12.sp, color = Color.White.copy(alpha = 0.8f))
                    }
                    Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, null, tint = Color.White.copy(alpha = 0.7f), modifier = Modifier.size(14.dp))
                }
            }
            Spacer(Modifier.height(16.dp))
        }

        // ═══ 4. STATS ROW (kompakt) ═════════════════════════════════════
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            ClientStatCard(Modifier.weight(1f), Icons.Outlined.CalendarMonth, "${user?.age ?: 0}", "Yas")
            ClientStatCard(Modifier.weight(1f), Icons.Outlined.MonitorWeight, "${user?.weight?.toInt() ?: 0} kg", "Ceki")
            ClientStatCard(Modifier.weight(1f), Icons.Outlined.Straighten, "${user?.height?.toInt() ?: 0} cm", "Boy")
        }
        if (user?.goal?.isNullOrBlank() == false) {
            Spacer(Modifier.height(12.dp))
            Row(
                Modifier.fillMaxWidth().background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp)).padding(14.dp),
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(Icons.Outlined.GpsFixed, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(18.dp))
                Text("Meqsed:", fontSize = 14.sp, color = AppTheme.Colors.secondaryText)
                Text(user?.goal ?: "", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
            }
        }
        Spacer(Modifier.height(16.dp))

        // ═══ 5. MEMBER SINCE ═══════════════════════════════════════════
        if (user?.createdAt != null) {
            Row(
                Modifier.fillMaxWidth().coreViaCard().padding(14.dp),
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Box(Modifier.size(44.dp).clip(CircleShape).background(AppTheme.Colors.accent.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
                    Icon(Icons.Outlined.CalendarMonth, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(18.dp))
                }
                Column {
                    Text("Uzv olma tarixi", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)
                    Text(user?.createdAt?.take(10) ?: "", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                }
            }
            Spacer(Modifier.height(16.dp))
        }

        // ═══ 6. SETTINGS ═══════════════════════════════════════════════
        ProfileSettingsRow(Icons.Outlined.Settings, "Tenzimlemer", onClick = onNavigateToSettings)
        Spacer(Modifier.height(16.dp))

        // ═══ 7. LOGOUT ═════════════════════════════════════════════════
        OutlinedButton(
            onClick = { showLogoutDialog = true },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = AppTheme.Colors.error),
            border = ButtonDefaults.outlinedButtonBorder(enabled = true).copy(
                brush = androidx.compose.ui.graphics.SolidColor(AppTheme.Colors.error)
            )
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.padding(vertical = 4.dp)) {
                Icon(Icons.AutoMirrored.Outlined.Logout, null, tint = AppTheme.Colors.error, modifier = Modifier.size(18.dp))
                Text("Cixis", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.error)
            }
        }
    }
    } // CoreViaAnimatedBackground

    LaunchedEffect(successMessage) {
        if (successMessage != null && showEditSheet) {
            showEditSheet = false
        }
    }

    if (showEditSheet) {
        EditProfileSheet(
            user = user,
            isLoading = isLoading,
            onDismiss = { showEditSheet = false },
            onSave = { request -> viewModel.updateProfile(request) }
        )
    }
}

// ═══ ClientStatCard ════════════════════════════════════════════════════════
@Composable
private fun ClientStatCard(modifier: Modifier = Modifier, icon: ImageVector, value: String, label: String) {
    Column(
        modifier = modifier.coreViaCard(cornerRadius = 12.dp).padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(icon, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
        Text(value, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
        Text(label, fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
    }
}

// ═══ ProfileSettingsRow ════════════════════════════════════════════════════
@Composable
fun ProfileSettingsRow(icon: ImageVector, title: String, badge: String? = null, badgeColor: Color = Color.Gray, onClick: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(12.dp))
            .coreViaCard(cornerRadius = 12.dp).clickable(onClick = onClick).padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
        Spacer(Modifier.width(12.dp))
        Text(title, fontSize = 15.sp, color = AppTheme.Colors.primaryText, modifier = Modifier.weight(1f))
        if (badge != null) {
            Text(badge, fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = badgeColor,
                modifier = Modifier.background(badgeColor.copy(alpha = 0.2f), RoundedCornerShape(8.dp)).padding(horizontal = 8.dp, vertical = 4.dp))
            Spacer(Modifier.width(8.dp))
        }
        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, null, tint = AppTheme.Colors.secondaryText, modifier = Modifier.size(14.dp))
    }
}
