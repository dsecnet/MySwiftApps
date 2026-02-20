package life.corevia.app.ui.profile

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
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
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.ProfileUpdateRequest

/**
 * iOS ClientProfileView.swift — Android 1-ə-1 port
 *
 * Sections (iOS sırası ilə):
 *  1. profileHeader
 *  2. profileCompletionSection (only if <100%)
 *  3. premiumBanner (only if !isPremium)
 *  4. todayHighlightsSection
 *  5. weeklyProgressSection
 *  6. goalsSection
 *  7. memberSinceSection
 *  8. settingsSection
 *  9. logoutButton
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
            title = { Text("Çıxış", color = Color.White) },
            text = { Text("Hesabdan çıxmaq istədiyinizdən əminsiniz?", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = { showLogoutDialog = false; onLogout() }) {
                    Text("Çıxış", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showLogoutDialog = false }) {
                    Text("Ləğv et", color = AppTheme.Colors.secondaryText)
                }
            }
        )
    }

    // Error state — API fail olduqda
    if (errorMessage != null && user == null) {
        Box(
            modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Text("⚠️", fontSize = 48.sp)
                Text(errorMessage ?: "Xəta baş verdi", color = AppTheme.Colors.error, fontSize = 16.sp)
                Button(
                    onClick = { viewModel.loadUser() },
                    colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text("Yenidən cəhd et", color = Color.White, fontWeight = FontWeight.SemiBold)
                }
            }
        }
        return
    }

    // Loading state — user hələ yüklənməyib
    if (isLoading && user == null) {
        Box(
            modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                CircularProgressIndicator(color = AppTheme.Colors.accent)
                Text("Profil yüklənir...", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
            }
        }
        return
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
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
                // Camera
                Box(
                    modifier = Modifier.align(Alignment.BottomEnd).size(32.dp)
                        .shadow(6.dp, CircleShape, spotColor = AppTheme.Colors.accent.copy(alpha = 0.5f))
                        .clip(CircleShape).background(AppTheme.Colors.accent),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Outlined.CameraAlt, null, tint = Color.White, modifier = Modifier.size(14.dp))
                }
                // Premium crown
                if (user?.isPremium == true) {
                    Box(
                        modifier = Modifier.align(Alignment.TopEnd).offset(x = (-2).dp, y = (-2).dp)
                            .size(30.dp).shadow(4.dp, CircleShape, spotColor = AppTheme.Colors.warning.copy(alpha = 0.5f))
                            .clip(CircleShape).background(Brush.linearGradient(listOf(AppTheme.Colors.warning, AppTheme.Colors.accent))),
                        contentAlignment = Alignment.Center
                    ) { Text("👑", fontSize = 14.sp) }
                }
            }

            Spacer(Modifier.height(12.dp))
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(user?.name ?: "Yüklənir...", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                if (user?.isPremium == true) {
                    Icon(Icons.Filled.Verified, null, tint = AppTheme.Colors.accentDark, modifier = Modifier.size(16.dp))
                }
            }
            Text(user?.email ?: "", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)

            if (user?.isPremium == true) {
                Spacer(Modifier.height(6.dp))
                Box(
                    modifier = Modifier.clip(RoundedCornerShape(12.dp))
                        .background(Brush.horizontalGradient(listOf(AppTheme.Colors.warning.copy(alpha = 0.9f), AppTheme.Colors.accent)))
                        .padding(horizontal = 12.dp, vertical = 5.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                        Text("👑", fontSize = 11.sp)
                        Text("Premium", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }
            }

            Spacer(Modifier.height(8.dp))
            Box(
                modifier = Modifier.clip(RoundedCornerShape(16.dp))
                    .background(AppTheme.Colors.accent.copy(alpha = 0.1f))
                    .clickable { showEditSheet = true }
                    .padding(horizontal = 14.dp, vertical = 6.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                    Icon(Icons.Outlined.Edit, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(12.dp))
                    Text("Redaktə et", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.accent)
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        // ═══ 2. PROFILE COMPLETION (only if <100%) ══════════════════════
        if (profileCompletion < 1f) {
            Column(
                modifier = Modifier.fillMaxWidth().background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp)).padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Profil tamamlama", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                    Text("${(profileCompletion * 100).toInt()}%", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.accent)
                }
                LinearProgressIndicator(
                    progress = { profileCompletion },
                    modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
                    color = AppTheme.Colors.accent, trackColor = AppTheme.Colors.separator
                )
                Text("Profilinizi tamamlayaraq daha yaxşı təcrübə əldə edin", fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
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
                        Text("Premium-a keç", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        Text("Bütün xüsusiyyətləri açın", fontSize = 12.sp, color = Color.White.copy(alpha = 0.8f))
                    }
                    Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, null, tint = Color.White.copy(alpha = 0.7f), modifier = Modifier.size(14.dp))
                }
            }
            Spacer(Modifier.height(16.dp))
        }

        // ═══ 4. TODAY HIGHLIGHTS ════════════════════════════════════════
        Text("Bugünkü nailiyyətlər", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
        Spacer(Modifier.height(12.dp))
        Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            TodayHighlightCard(Icons.Outlined.FitnessCenter, "0", "Məşqlər", AppTheme.Colors.accent)
            TodayHighlightCard(Icons.Outlined.LocalFireDepartment, "0", "Kalori", AppTheme.Colors.accent)
            TodayHighlightCard(Icons.Outlined.Restaurant, "0", "Yeməklər", AppTheme.Colors.success)
        }
        Spacer(Modifier.height(16.dp))

        // ═══ 5. WEEKLY PROGRESS ════════════════════════════════════════
        Text("Həftəlik irəliləyiş", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
        Spacer(Modifier.height(12.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(14.dp)) {
            CircularProgressCard(Modifier.weight(1f), 0f, 5f, "Məşqlər", AppTheme.Colors.accent, Icons.Outlined.FitnessCenter)
            CircularProgressCard(Modifier.weight(1f), 0f, 2000f, "Kalori", AppTheme.Colors.accent, Icons.Outlined.LocalFireDepartment)
        }
        Spacer(Modifier.height(16.dp))

        // ═══ 6. GOALS SECTION ══════════════════════════════════════════
        Text("Məqsəd və ölçülər", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
        Spacer(Modifier.height(12.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            ClientStatCard(Modifier.weight(1f), Icons.Outlined.CalendarMonth, "${user?.age ?: 0}", "Yaş")
            ClientStatCard(Modifier.weight(1f), Icons.Outlined.MonitorWeight, "${user?.weight?.toInt() ?: 0} kg", "Çəki")
            ClientStatCard(Modifier.weight(1f), Icons.Outlined.Straighten, "${user?.height?.toInt() ?: 0} cm", "Boy")
        }
        if (!user?.goal.isNullOrBlank()) {
            Spacer(Modifier.height(12.dp))
            Row(
                Modifier.fillMaxWidth().background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp)).padding(16.dp),
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(Icons.Outlined.GpsFixed, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(18.dp))
                Text("Məqsəd:", fontSize = 14.sp, color = AppTheme.Colors.secondaryText)
                Text(user?.goal ?: "", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
            }
        }
        if (user?.age == null || user?.weight == null || user?.height == null || user?.goal.isNullOrBlank()) {
            Spacer(Modifier.height(12.dp))
            Row(
                Modifier.fillMaxWidth().clip(RoundedCornerShape(12.dp))
                    .background(AppTheme.Colors.accent.copy(alpha = 0.08f))
                    .border(1.dp, AppTheme.Colors.accent.copy(alpha = 0.2f), RoundedCornerShape(12.dp))
                    .clickable { showEditSheet = true }.padding(14.dp),
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Icon(Icons.Outlined.Info, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(18.dp))
                Column(Modifier.weight(1f)) {
                    Text("Profili tamamla", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                    Text("Daha yaxşı nəticələr üçün məlumatlarınızı doldurun", fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
                }
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, null, tint = AppTheme.Colors.tertiaryText, modifier = Modifier.size(13.dp))
            }
        }
        Spacer(Modifier.height(16.dp))

        // ═══ 7. MEMBER SINCE ═══════════════════════════════════════════
        if (user?.createdAt != null) {
            Row(
                Modifier.fillMaxWidth().background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp)).padding(14.dp),
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Box(Modifier.size(44.dp).clip(CircleShape).background(AppTheme.Colors.accent.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
                    Icon(Icons.Outlined.CalendarMonth, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(18.dp))
                }
                Column {
                    Text("Üzv olma tarixi", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)
                    Text(user?.createdAt?.take(10) ?: "", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                }
            }
            Spacer(Modifier.height(16.dp))
        }

        // ═══ 8. SETTINGS SECTION ═══════════════════════════════════════
        Text("Tənzimləmələr", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
        Spacer(Modifier.height(12.dp))
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            ProfileSettingsRow(Icons.Outlined.Notifications, "Bildirişlər", onClick = onNavigateToSettings)
            ProfileSettingsRow(Icons.Outlined.Lock, "Təhlükəsizlik", onClick = onNavigateToSettings)
            ProfileSettingsRow(Icons.Outlined.AutoAwesome, "Premium",
                badge = if (user?.isPremium == true) "Aktiv" else null,
                badgeColor = if (user?.isPremium == true) AppTheme.Colors.success else AppTheme.Colors.accentDark,
                onClick = onNavigateToPremium
            )
            ProfileSettingsRow(Icons.Outlined.Info, "Haqqında", onClick = onNavigateToSettings)
        }
        Spacer(Modifier.height(16.dp))

        // ═══ 9. LOGOUT BUTTON ══════════════════════════════════════════
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
                Text("Çıxış", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.error)
            }
        }
    }

    if (showEditSheet) {
        EditProfileSheet(
            user = user,
            onDismiss = { showEditSheet = false },
            onSave = { request -> viewModel.updateProfile(request); showEditSheet = false }
        )
    }
}

// ═══ TodayHighlightCard ════════════════════════════════════════════════════
@Composable
private fun TodayHighlightCard(icon: ImageVector, value: String, label: String, color: Color) {
    Column(
        modifier = Modifier.width(110.dp)
            .shadow(6.dp, RoundedCornerShape(14.dp), spotColor = color.copy(alpha = 0.08f))
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
            .padding(vertical = 14.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Box(Modifier.size(48.dp).clip(CircleShape).background(color.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
            Icon(icon, null, tint = color, modifier = Modifier.size(20.dp))
        }
        Text(value, fontSize = 22.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
        Text(label, fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
    }
}

// ═══ CircularProgressCard ══════════════════════════════════════════════════
@Composable
private fun CircularProgressCard(modifier: Modifier = Modifier, value: Float, total: Float, label: String, color: Color, icon: ImageVector) {
    val progress = if (total > 0) (value / total).coerceIn(0f, 1f) else 0f
    Column(
        modifier = modifier.background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(16.dp)).padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Box(Modifier.size(70.dp), contentAlignment = Alignment.Center) {
            Canvas(Modifier.size(70.dp)) {
                drawCircle(color = color.copy(alpha = 0.15f), style = Stroke(width = 8.dp.toPx()))
            }
            Canvas(Modifier.size(70.dp)) {
                drawArc(
                    brush = Brush.linearGradient(listOf(color, color.copy(alpha = 0.6f))),
                    startAngle = -90f, sweepAngle = 360f * progress, useCenter = false,
                    style = Stroke(width = 8.dp.toPx(), cap = StrokeCap.Round)
                )
            }
            Icon(icon, null, tint = color, modifier = Modifier.size(20.dp))
        }
        Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            Text("${value.toInt()}", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
            Text("/ ${total.toInt()}", fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
        }
        Text(label, fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
    }
}

// ═══ ClientStatCard ════════════════════════════════════════════════════════
@Composable
private fun ClientStatCard(modifier: Modifier = Modifier, icon: ImageVector, value: String, label: String) {
    Column(
        modifier = modifier.background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp)).padding(16.dp),
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
            .background(AppTheme.Colors.secondaryBackground).clickable(onClick = onClick).padding(16.dp),
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
