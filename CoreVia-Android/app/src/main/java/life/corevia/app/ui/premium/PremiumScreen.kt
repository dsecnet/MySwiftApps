package life.corevia.app.ui.premium

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.automirrored.filled.DirectionsRun
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * iOS PremiumView.swift — Android 1-ə-1 port
 *
 * 2 state:
 *  - isPremium = true  → activePremiumSection (crown badge + plan info + cancel)
 *  - isPremium = false → premiumOfferSection (sparkle hero + price card + activate)
 * + featuresSection (always shown)
 */
@Composable
fun PremiumScreen(
    viewModel: PremiumViewModel,
    onBack: () -> Unit
) {
    val status by viewModel.status.collectAsState()
    val plans by viewModel.plans.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()

    val isPremium = status?.isPremium == true

    var showCancelDialog by remember { mutableStateOf(false) }

    // Cancel confirmation dialog
    if (showCancelDialog) {
        AlertDialog(
            onDismissRequest = { showCancelDialog = false },
            containerColor = AppTheme.Colors.secondaryBackground,
            title = { Text("Abunəliyi ləğv et?", color = Color.White) },
            text = { Text("Premium abunəliyinizi ləğv etmək istədiyinizdən əminsiniz?", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = {
                    showCancelDialog = false
                    viewModel.cancel()
                }) { Text("Ləğv et", color = AppTheme.Colors.error) }
            },
            dismissButton = {
                TextButton(onClick = { showCancelDialog = false }) {
                    Text("Xeyr", color = AppTheme.Colors.secondaryText)
                }
            }
        )
    }

    Box(modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 100.dp)
        ) {
            // ─── Header ─────────────────────────────────────────────────
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .padding(top = 50.dp, bottom = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                }
            }

            Column(
                modifier = Modifier.padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                if (isPremium) {
                    // ═══════════════════════════════════════════════════════
                    // iOS: activePremiumSection
                    // ═══════════════════════════════════════════════════════
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        // iOS: Crown badge — 100dp gradient circle + crown 50sp
                        Box(
                            modifier = Modifier
                                .padding(top = 20.dp)
                                .size(100.dp)
                                .shadow(20.dp, CircleShape, spotColor = AppTheme.Colors.accentDark.copy(alpha = 0.5f))
                                .clip(CircleShape)
                                .background(Brush.linearGradient(listOf(AppTheme.Colors.accentDark, AppTheme.Colors.accent))),
                            contentAlignment = Alignment.Center
                        ) { Text("👑", fontSize = 50.sp) }

                        // iOS: .system(size: 24, weight: .bold)
                        Text("Premium Aktiv", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)

                        Text(
                            "Bütün premium xüsusiyyətlərə girişiniz var",
                            fontSize = 14.sp, color = AppTheme.Colors.secondaryText,
                            textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 16.dp)
                        )

                        // iOS: Plan Info — secondaryBackground, cornerRadius 20
                        Column(
                            modifier = Modifier.fillMaxWidth()
                                .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(20.dp))
                                .padding(20.dp),
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            InfoRow(Icons.Outlined.CalendarMonth, "Plan", status?.planName ?: "Aylıq")
                            HorizontalDivider(color = AppTheme.Colors.tertiaryText.copy(alpha = 0.3f))
                            InfoRow(Icons.Outlined.CreditCard, "Qiymət", "9.99 ₼/ay")
                        }

                        // iOS: Cancel Button — error, bordered, cornerRadius 20
                        OutlinedButton(
                            onClick = { showCancelDialog = true },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(20.dp),
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = AppTheme.Colors.error),
                            border = ButtonDefaults.outlinedButtonBorder(enabled = true).copy(
                                brush = androidx.compose.ui.graphics.SolidColor(AppTheme.Colors.error), width = 1.5.dp
                            ),
                            contentPadding = PaddingValues(vertical = 16.dp)
                        ) {
                            Icon(Icons.Outlined.Close, null, Modifier.size(18.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("Abunəliyi ləğv et", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                        }
                    }
                } else {
                    // ═══════════════════════════════════════════════════════
                    // iOS: premiumOfferSection
                    // ═══════════════════════════════════════════════════════
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(20.dp)
                    ) {
                        // iOS: Sparkle hero — 120dp circle + sparkles icon 60sp
                        Box(
                            modifier = Modifier.padding(top = 20.dp).size(120.dp).clip(CircleShape)
                                .background(Brush.linearGradient(listOf(
                                    AppTheme.Colors.accentDark.copy(alpha = 0.2f),
                                    AppTheme.Colors.accent.copy(alpha = 0.2f)
                                ))),
                            contentAlignment = Alignment.Center
                        ) { Icon(Icons.Outlined.AutoAwesome, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(60.dp)) }

                        // iOS: .system(size: 32, weight: .bold)
                        Text("Premium", fontSize = 32.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText, textAlign = TextAlign.Center)

                        // iOS: Price Card — secondaryBackground, cornerRadius 20
                        Column(
                            modifier = Modifier.fillMaxWidth()
                                .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(20.dp))
                                .padding(vertical = 20.dp, horizontal = 16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            // iOS: 9.99 (52sp bold) + ₼/ay
                            Row(verticalAlignment = Alignment.Bottom) {
                                Text("9.99", fontSize = 52.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                                Spacer(Modifier.width(6.dp))
                                Column {
                                    Text("₼", fontSize = 22.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.secondaryText)
                                    Text("/ay", fontSize = 15.sp, color = AppTheme.Colors.tertiaryText)
                                }
                            }
                            Text("3 günlük pulsuz sınaq müddəti ilə başlayın", fontSize = 13.sp, color = AppTheme.Colors.tertiaryText)
                        }

                        // iOS: Activate Button (gradient, cornerRadius 20, shadow)
                        Button(
                            onClick = { viewModel.activatePremium() },
                            modifier = Modifier.fillMaxWidth().height(56.dp)
                                .shadow(12.dp, RoundedCornerShape(20.dp), spotColor = AppTheme.Colors.accentDark.copy(alpha = 0.4f)),
                            shape = RoundedCornerShape(20.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
                            contentPadding = PaddingValues(0.dp),
                            enabled = !isLoading
                        ) {
                            Box(
                                Modifier.fillMaxSize().background(Brush.horizontalGradient(listOf(AppTheme.Colors.accentDark, AppTheme.Colors.accent))),
                                contentAlignment = Alignment.Center
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                                    Text("👑", fontSize = 18.sp)
                                    Text("Premium-ı Aktivləşdir", fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = Color.White)
                                }
                            }
                        }

                        Text("Ödəniş tezliklə əlavə olunacaq", fontSize = 13.sp, color = AppTheme.Colors.tertiaryText, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 16.dp))
                    }
                }

                // ═══════════════════════════════════════════════════════════
                // iOS: featuresSection — always shown
                // ═══════════════════════════════════════════════════════════
                Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
                    Text("Premium Xüsusiyyətlər", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText, modifier = Modifier.padding(horizontal = 4.dp))

                    Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                        FeatureRow(Icons.AutoMirrored.Filled.DirectionsRun, "GPS İzləmə & Aktivliklər", "Real vaxtda GPS izləmə ilə qaçış, gəzinti və velosiped sürmə")
                        FeatureRow(Icons.AutoMirrored.Filled.Chat, "Müəllimlə Söhbət", "Şəxsi müəlliminizlə birbaşa mesajlaşma")
                        FeatureRow(Icons.Outlined.CameraAlt, "AI Qida Analizi", "Kamera ilə qidanızı çəkin, kalorini avtomatik hesablayın")
                        FeatureRow(Icons.Outlined.Person, "Şəxsi Müəllim", "Peşəkar müəllim seçin və fərdi plan alın")
                        FeatureRow(Icons.Outlined.BarChart, "Ətraflı Statistika", "Həftəlik və aylıq irəliləyiş hesabatları")
                        FeatureRow(Icons.Outlined.AutoAwesome, "AI Tövsiyələr", "Süni intellekt ilə fərdi məşq və qidalanma tövsiyələri")
                    }
                }
            }
        }

        // ─── Loading overlay ────────────────────────────────────────────
        if (isLoading) {
            Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.3f)), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(
                    color = Color.White,
                    modifier = Modifier.background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp)).padding(20.dp)
                )
            }
        }

        // ─── Success snackbar ──────────────────────────────────────────
        successMessage?.let { msg ->
            Snackbar(modifier = Modifier.align(Alignment.BottomCenter).padding(16.dp), containerColor = AppTheme.Colors.success) { Text(msg, color = Color.White) }
            LaunchedEffect(msg) { kotlinx.coroutines.delay(2000); viewModel.clearSuccess() }
        }

        // ─── Error snackbar ────────────────────────────────────────────
        errorMessage?.let { error ->
            Snackbar(
                modifier = Modifier.align(Alignment.BottomCenter).padding(16.dp),
                containerColor = AppTheme.Colors.error,
                action = { TextButton(onClick = { viewModel.clearError() }) { Text("Bağla", color = Color.White) } }
            ) { Text(error, color = Color.White) }
        }
    }
}

// ═══ iOS: InfoRow ══════════════════════════════════════════════════════════
@Composable
private fun InfoRow(icon: ImageVector, title: String, value: String) {
    Row(Modifier.fillMaxWidth().padding(horizontal = 4.dp, vertical = 2.dp), verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(18.dp))
        Spacer(Modifier.width(12.dp))
        Text(title, fontSize = 15.sp, color = AppTheme.Colors.secondaryText)
        Spacer(Modifier.weight(1f))
        Text(value, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
    }
}

// ═══ iOS: FeatureRow — 48dp icon circle + title + desc ═════════════════════
@Composable
private fun FeatureRow(icon: ImageVector, title: String, description: String) {
    Row(
        modifier = Modifier.fillMaxWidth().background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(20.dp)).padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Box(Modifier.size(48.dp).clip(CircleShape).background(AppTheme.Colors.accent.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
            Icon(icon, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
        }
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text(title, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
            Text(description, fontSize = 14.sp, color = AppTheme.Colors.secondaryText)
        }
    }
}
