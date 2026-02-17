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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import life.corevia.app.ui.theme.AppTheme

/**
 * iOS ForgotPasswordView.swift-in Android tam ekvivalenti.
 * 3-step şifrə bərpası:
 *  - Step 1: Email daxil et → POST /api/v1/auth/forgot-password
 *  - Step 2: OTP kodu (60s geri sayım)
 *  - Step 3: Yeni şifrə + POST /api/v1/auth/reset-password
 */
enum class ForgotPasswordStep { EMAIL, OTP, NEW_PASSWORD }

@Composable
fun ForgotPasswordScreen(
    onBack: () -> Unit
) {
    val focusManager = LocalFocusManager.current

    var email by remember { mutableStateOf("") }
    var otpCode by remember { mutableStateOf("") }
    var newPassword by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var passwordVisible by remember { mutableStateOf(false) }

    var currentStep by remember { mutableStateOf(ForgotPasswordStep.EMAIL) }
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }
    var showError by remember { mutableStateOf(false) }
    var showSuccess by remember { mutableStateOf(false) }

    // 60s countdown timer
    var otpCountdown by remember { mutableStateOf(0) }
    LaunchedEffect(otpCountdown) {
        if (otpCountdown > 0) {
            delay(1000L)
            otpCountdown--
        }
    }

    // Password strength
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

    val stepIcon = when (currentStep) {
        ForgotPasswordStep.EMAIL -> "✉️"
        ForgotPasswordStep.OTP -> "🔒"
        ForgotPasswordStep.NEW_PASSWORD -> "🔑"
    }
    val stepTitle = when (currentStep) {
        ForgotPasswordStep.EMAIL -> "Şifrəni Bərpa Et"
        ForgotPasswordStep.OTP -> "Kodu Daxil Et"
        ForgotPasswordStep.NEW_PASSWORD -> "Yeni Şifrə"
    }
    val stepDesc = when (currentStep) {
        ForgotPasswordStep.EMAIL -> "E-poçtunuza OTP kodu göndəriləcək"
        ForgotPasswordStep.OTP -> "E-poçta göndərilən 6 rəqəmli kodu daxil edin"
        ForgotPasswordStep.NEW_PASSWORD -> "Yeni şifrənizi daxil edin"
    }

    // Success dialog
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
        // Top bar
        Row(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Text("← Geri", color = AppTheme.Colors.accent, fontSize = 15.sp)
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
            // Header (iOS: ZStack { Circle + icon })
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Box(
                    modifier = Modifier.size(80.dp).background(AppTheme.Colors.accent.copy(alpha = 0.1f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = stepIcon, fontSize = 35.sp)
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

            // Step content
            AnimatedContent(
                targetState = currentStep,
                transitionSpec = { fadeIn() togetherWith fadeOut() },
                label = "stepContent"
            ) { step ->
                when (step) {
                    ForgotPasswordStep.EMAIL -> {
                        Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("Email", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.secondaryText)
                                Row(
                                    modifier = Modifier.fillMaxWidth()
                                        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                                        .border(1.dp, if (email.isNotEmpty()) AppTheme.Colors.accent.copy(0.5f) else AppTheme.Colors.separator, RoundedCornerShape(12.dp))
                                        .padding(16.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Icon(Icons.Default.Email, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
                                    OutlinedTextField(
                                        value = email, onValueChange = { email = it },
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
                                isLoading = true
                                // Simulate API call — real implementation: api.forgotPassword(email)
                                // TODO: connect to AuthRepository.sendForgotPasswordOtp(email)
                                isLoading = false
                                currentStep = ForgotPasswordStep.OTP
                                otpCountdown = 60
                            }
                        }
                    }

                    ForgotPasswordStep.OTP -> {
                        Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
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
                                    Text("💬", fontSize = 20.sp)
                                    OutlinedTextField(
                                        value = otpCode,
                                        onValueChange = { otpCode = it.filter { c -> c.isDigit() }.take(6) },
                                        placeholder = { Text("6 rəqəmli kod", color = AppTheme.Colors.placeholderText) },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedBorderColor = Color.Transparent, unfocusedBorderColor = Color.Transparent,
                                            focusedTextColor = AppTheme.Colors.primaryText, unfocusedTextColor = AppTheme.Colors.primaryText
                                        ),
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword, imeAction = ImeAction.Done),
                                        singleLine = true
                                    )
                                }
                            }

                            // Resend (iOS: 60s countdown)
                            if (otpCountdown > 0) {
                                Text("Yenidən göndər: ${otpCountdown}s", fontSize = 13.sp, color = AppTheme.Colors.tertiaryText,
                                    modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
                            } else {
                                TextButton(onClick = {
                                    otpCountdown = 60
                                    // TODO: resend OTP
                                }, modifier = Modifier.fillMaxWidth()) {
                                    Text("Kodu yenidən göndər", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.accent)
                                }
                            }

                            FpGradientButton(
                                label = "Təsdiq Et",
                                enabled = otpCode.length == 6 && !isLoading,
                                isLoading = isLoading
                            ) {
                                focusManager.clearFocus()
                                currentStep = ForgotPasswordStep.NEW_PASSWORD
                            }
                        }
                    }

                    ForgotPasswordStep.NEW_PASSWORD -> {
                        Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
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
                                    Icon(Icons.Default.Lock, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
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
                                    IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                        Text(if (passwordVisible) "👁" else "👁‍🗨", fontSize = 18.sp)
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
                                    Icon(Icons.Default.Lock, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
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

                            // Password strength (iOS: 4-bar indicator)
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

                            // Şifrəni Yenilə button (iOS: success gradient)
                            Box(
                                modifier = Modifier.fillMaxWidth()
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(Brush.horizontalGradient(listOf(
                                        AppTheme.Colors.success.copy(alpha = if (isPasswordValid && !isLoading) 1f else 0.5f),
                                        AppTheme.Colors.success.copy(alpha = if (isPasswordValid && !isLoading) 0.8f else 0.4f)
                                    )))
                                    .run { if (isPasswordValid && !isLoading) this.then(Modifier) else this }
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

// ─── Gradient button (iOS: LinearGradient accent → accent.opacity(0.8)) ────────
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
