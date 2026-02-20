package life.corevia.app.ui.auth

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.outlined.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import kotlinx.coroutines.delay
import life.corevia.app.ui.theme.AppTheme

/**
 * iOS ForgotPasswordView.swift-in Android tam ekvivalenti.
 * 3-step şifrə bərpası — real backend-ə bağlı:
 *  - Step 1: Email → POST /api/v1/auth/forgot-password
 *  - Step 2: OTP → POST /api/v1/auth/verify-otp
 *  - Step 3: Yeni şifrə → POST /api/v1/auth/reset-password
 *
 * iOS ilə tam uyğun:
 *  - Header: Material icons (envelope.fill, lock.shield.fill, key.fill), accent(0.1) circle bg
 *  - Input fields: HStack border style, 20dp icon, cornerRadius 12
 *  - Password toggle: eye / eye.slash Material icons
 *  - Buttons: gradient accent→accent(0.8) or success→success(0.8)
 *  - Password strength: 4 bar, cornerRadius 2
 *  - 60s OTP countdown timer
 */
enum class ForgotPasswordStep { EMAIL, OTP_AND_PASSWORD }

@Composable
fun ForgotPasswordScreen(
    onBack: () -> Unit,
    authViewModel: AuthViewModel = viewModel()
) {
    val focusManager = LocalFocusManager.current
    val uiState by authViewModel.uiState.collectAsState()

    var email by remember { mutableStateOf("") }
    var otpCode by remember { mutableStateOf("") }
    var newPassword by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var passwordVisible by remember { mutableStateOf(false) }

    var currentStep by remember { mutableStateOf(ForgotPasswordStep.EMAIL) }
    var showSuccess by remember { mutableStateOf(false) }

    val isLoading = uiState is AuthUiState.Loading
    val showError = uiState is AuthUiState.Error
    val errorMessage = if (uiState is AuthUiState.Error) (uiState as AuthUiState.Error).message else ""

    // 60s countdown timer (iOS: otpCountdown)
    var otpCountdown by remember { mutableStateOf(0) }
    LaunchedEffect(otpCountdown) {
        if (otpCountdown > 0) {
            delay(1000L)
            otpCountdown--
        }
    }

    // React to state changes
    // iOS flow: forgot-password → OTP göndərilir → user OTP + yeni şifrə daxil edir → reset-password
    // verify-otp addımı YOX — iOS-da birbaşa reset-password-ə OTP göndərilir
    LaunchedEffect(uiState) {
        when (uiState) {
            is AuthUiState.ForgotOtpSent -> {
                currentStep = ForgotPasswordStep.OTP_AND_PASSWORD
                otpCountdown = 60
                authViewModel.resetToIdle()
            }
            is AuthUiState.PasswordReset -> {
                showSuccess = true
                authViewModel.resetToIdle()
            }
            else -> {}
        }
    }

    // Password strength (iOS: 4-level — 0:weak, 1:medium, 2:good, 3:strong, 4:very strong)
    val passwordStrength = when {
        newPassword.length < 6 -> 0
        newPassword.length < 8 -> 1
        newPassword.any { it.isDigit() } && newPassword.any { it.isUpperCase() } -> 4
        newPassword.any { it.isDigit() } -> 3
        else -> 2
    }
    val strengthColor = when (passwordStrength) {
        0, 1 -> Color.Red
        2 -> Color(0xFFFF9800)
        3 -> Color.Yellow
        else -> AppTheme.Colors.success
    }
    val strengthText = when (passwordStrength) {
        0, 1 -> "Zəif"
        2 -> "Orta"
        3 -> "Yaxşı"
        else -> "Güclü"
    }

    val isPasswordValid = newPassword.length >= 6 && newPassword == confirmPassword

    // iOS: step-based icons & titles (SF Symbols → Material icons)
    val stepIcon: ImageVector = when (currentStep) {
        ForgotPasswordStep.EMAIL -> Icons.Outlined.Email
        ForgotPasswordStep.OTP_AND_PASSWORD -> Icons.Outlined.Lock
    }
    val stepTitle = when (currentStep) {
        ForgotPasswordStep.EMAIL -> "Şifrəni Bərpa Et"
        ForgotPasswordStep.OTP_AND_PASSWORD -> "Yeni Şifrə Təyin Et"
    }
    val stepDesc = when (currentStep) {
        ForgotPasswordStep.EMAIL -> "E-poçtunuza OTP kodu göndəriləcək"
        ForgotPasswordStep.OTP_AND_PASSWORD -> "E-poçta göndərilən kodu və yeni şifrənizi daxil edin"
    }

    // Success dialog (iOS: Alert "Uğurlu!")
    if (showSuccess) {
        AlertDialog(
            onDismissRequest = { onBack() },
            title = { Text("Uğurlu!", color = AppTheme.Colors.primaryText) },
            text = { Text("Şifrəniz uğurla yeniləndi", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = onBack) {
                    Text("Giriş et", color = AppTheme.Colors.accent)
                }
            },
            containerColor = AppTheme.Colors.secondaryBackground
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        // Top bar (iOS: NavigationView .inline title + dismiss)
        Row(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // iOS: back button — chevron.left + "Geri", secondaryBackground, cornerRadius 10
            Row(
                modifier = Modifier
                    .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(10.dp))
                    .clickable {
                        authViewModel.resetToIdle()
                        onBack()
                    }
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = null,
                    tint = AppTheme.Colors.accent,
                    modifier = Modifier.size(14.dp)
                )
                Text(
                    text = "Geri",
                    color = AppTheme.Colors.accent,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Medium
                )
            }
            Spacer(modifier = Modifier.weight(1f))
            Text("Şifrəni Bərpa Et", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
            Spacer(modifier = Modifier.weight(1f))
        }

        Column(
            modifier = Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // Header — iOS: circle icon + title + description
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.padding(top = 20.dp)
            ) {
                // iOS: Circle().fill(accent.opacity(0.1)), 80dp, icon 35sp
                Box(
                    modifier = Modifier.size(80.dp).background(AppTheme.Colors.accent.copy(alpha = 0.1f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = stepIcon,
                        contentDescription = null,
                        tint = AppTheme.Colors.accent,
                        modifier = Modifier.size(35.dp)
                    )
                }
                Text(text = stepTitle, fontSize = 22.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                Text(text = stepDesc, fontSize = 14.sp, color = AppTheme.Colors.secondaryText, textAlign = TextAlign.Center)
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Error
            if (showError) {
                Box(
                    modifier = Modifier.fillMaxWidth()
                        .background(AppTheme.Colors.error.copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                        .padding(12.dp)
                ) {
                    Text(text = "⚠️ $errorMessage", fontSize = 13.sp, color = AppTheme.Colors.primaryText)
                }
            }

            // Step content (iOS: AnimatedContent with fade)
            AnimatedContent(
                targetState = currentStep,
                transitionSpec = { fadeIn() togetherWith fadeOut() },
                label = "stepContent"
            ) { step ->
                when (step) {
                    // ─── Step 1: Email ─────────────────────────────────────────
                    ForgotPasswordStep.EMAIL -> {
                        Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("Email", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.secondaryText)
                                // iOS: HStack { envelope.fill + TextField }, cornerRadius 12, border
                                Row(
                                    modifier = Modifier.fillMaxWidth()
                                        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                                        .border(1.dp, if (email.isNotEmpty()) AppTheme.Colors.accent.copy(0.5f) else AppTheme.Colors.separator, RoundedCornerShape(12.dp))
                                        .padding(16.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Icon(Icons.Outlined.Email, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
                                    OutlinedTextField(
                                        value = email, onValueChange = { email = it; authViewModel.clearError() },
                                        placeholder = { Text("email@example.com", color = AppTheme.Colors.placeholderText) },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedBorderColor = Color.Transparent, unfocusedBorderColor = Color.Transparent,
                                            focusedTextColor = AppTheme.Colors.primaryText, unfocusedTextColor = AppTheme.Colors.primaryText
                                        ),
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email, imeAction = ImeAction.Done),
                                        singleLine = true
                                    )
                                }
                            }

                            FpGradientButton(
                                label = "Email-ə OTP Göndər",
                                enabled = email.isNotBlank() && !isLoading,
                                isLoading = isLoading
                            ) {
                                focusManager.clearFocus()
                                authViewModel.sendForgotPasswordOtp(email.trim())
                            }
                        }
                    }

                    // ─── Step 2: OTP + New Password (iOS: birbaşa reset-password, verify-otp yoxdur) ───
                    ForgotPasswordStep.OTP_AND_PASSWORD -> {
                        Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
                            // OTP field
                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("Təsdiq Kodu", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.secondaryText)
                                Row(
                                    modifier = Modifier.fillMaxWidth()
                                        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                                        .border(1.dp, if (otpCode.isNotEmpty()) AppTheme.Colors.accent.copy(0.5f) else AppTheme.Colors.separator, RoundedCornerShape(12.dp))
                                        .padding(16.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Icon(Icons.Outlined.Email, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
                                    OutlinedTextField(
                                        value = otpCode,
                                        onValueChange = { otpCode = it.filter { c -> c.isDigit() }.take(6); authViewModel.clearError() },
                                        placeholder = { Text("6 rəqəmli kod", color = AppTheme.Colors.placeholderText) },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedBorderColor = Color.Transparent, unfocusedBorderColor = Color.Transparent,
                                            focusedTextColor = AppTheme.Colors.primaryText, unfocusedTextColor = AppTheme.Colors.primaryText
                                        ),
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword, imeAction = ImeAction.Next),
                                        singleLine = true
                                    )
                                }
                            }

                            // Resend countdown (iOS: 60s timer)
                            if (otpCountdown > 0) {
                                Text("Yenidən göndər: ${otpCountdown}s", fontSize = 13.sp, color = AppTheme.Colors.tertiaryText,
                                    modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
                            } else {
                                TextButton(onClick = {
                                    otpCountdown = 60
                                    authViewModel.sendForgotPasswordOtp(email.trim())
                                }, modifier = Modifier.fillMaxWidth()) {
                                    Text("Kodu yenidən göndər", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.accent)
                                }
                            }

                            // New password
                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("Yeni Şifrə", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.secondaryText)
                                Row(
                                    modifier = Modifier.fillMaxWidth()
                                        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                                        .border(1.dp, if (newPassword.isNotEmpty()) AppTheme.Colors.accent.copy(0.5f) else AppTheme.Colors.separator, RoundedCornerShape(12.dp))
                                        .padding(horizontal = 16.dp, vertical = 4.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Icon(Icons.Outlined.Lock, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
                                    OutlinedTextField(
                                        value = newPassword, onValueChange = { newPassword = it },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedBorderColor = Color.Transparent, unfocusedBorderColor = Color.Transparent,
                                            focusedTextColor = AppTheme.Colors.primaryText, unfocusedTextColor = AppTheme.Colors.primaryText
                                        ),
                                        visualTransformation = if (!passwordVisible) PasswordVisualTransformation() else VisualTransformation.None,
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Next),
                                        singleLine = true
                                    )
                                    IconButton(onClick = { passwordVisible = !passwordVisible }, modifier = Modifier.size(32.dp)) {
                                        Icon(
                                            imageVector = if (passwordVisible) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                                            contentDescription = null, tint = AppTheme.Colors.secondaryText, modifier = Modifier.size(18.dp)
                                        )
                                    }
                                }
                            }

                            // Confirm password
                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("Şifrəni Təsdiq Et", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.secondaryText)
                                Row(
                                    modifier = Modifier.fillMaxWidth()
                                        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                                        .border(1.dp,
                                            if (confirmPassword.isEmpty()) AppTheme.Colors.separator
                                            else if (newPassword == confirmPassword) AppTheme.Colors.success else AppTheme.Colors.error,
                                            RoundedCornerShape(12.dp))
                                        .padding(horizontal = 16.dp, vertical = 4.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Icon(Icons.Outlined.Lock, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
                                    OutlinedTextField(
                                        value = confirmPassword, onValueChange = { confirmPassword = it },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedBorderColor = Color.Transparent, unfocusedBorderColor = Color.Transparent,
                                            focusedTextColor = AppTheme.Colors.primaryText, unfocusedTextColor = AppTheme.Colors.primaryText
                                        ),
                                        visualTransformation = PasswordVisualTransformation(),
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Done),
                                        singleLine = true
                                    )
                                }
                            }

                            // Password strength (iOS: 4 bars)
                            if (newPassword.isNotEmpty()) {
                                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                        repeat(4) { idx ->
                                            Box(modifier = Modifier.weight(1f).height(4.dp)
                                                .background(if (passwordStrength > idx) strengthColor else Color.Gray.copy(0.3f), RoundedCornerShape(2.dp)))
                                        }
                                    }
                                    Text(strengthText, fontSize = 12.sp, color = strengthColor)
                                }
                            }

                            // iOS: birbaşa reset-password — verify-otp çağırmır!
                            val canSubmit = otpCode.length == 6 && isPasswordValid && !isLoading
                            Box(
                                modifier = Modifier.fillMaxWidth()
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(Brush.horizontalGradient(listOf(
                                        AppTheme.Colors.success.copy(alpha = if (canSubmit) 1f else 0.5f),
                                        AppTheme.Colors.success.copy(alpha = if (canSubmit) 0.8f else 0.4f)
                                    )))
                                    .then(if (canSubmit) Modifier.clickable {
                                        focusManager.clearFocus()
                                        authViewModel.resetPassword(email.trim(), otpCode, newPassword)
                                    } else Modifier)
                                    .padding(vertical = 14.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                if (isLoading) {
                                    CircularProgressIndicator(modifier = Modifier.size(22.dp), color = Color.White, strokeWidth = 2.dp)
                                } else {
                                    Text("Şifrəni Yenilə", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = Color.White)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// ─── Gradient button (iOS: accent gradient, cornerRadius 12, disabled opacity 0.6) ───
@Composable
private fun FpGradientButton(
    label: String,
    enabled: Boolean,
    isLoading: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier.fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Brush.horizontalGradient(listOf(
                AppTheme.Colors.accent.copy(alpha = if (enabled) 1f else 0.6f),
                AppTheme.Colors.accent.copy(alpha = if (enabled) 0.8f else 0.4f)
            )))
            .then(if (enabled) Modifier.clickable(onClick = onClick) else Modifier)
            .padding(vertical = 16.dp),
        contentAlignment = Alignment.Center
    ) {
        if (isLoading) {
            CircularProgressIndicator(modifier = Modifier.size(22.dp), color = Color.White, strokeWidth = 2.dp)
        } else {
            Text(label, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = Color.White)
        }
    }
}
