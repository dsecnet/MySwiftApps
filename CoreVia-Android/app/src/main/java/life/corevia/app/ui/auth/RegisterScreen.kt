package life.corevia.app.ui.auth

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.layout.imePadding
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
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.ui.theme.AppTheme

/**
 * iOS RegisterView.swift-in Android tam ekvivalenti.
 * 2-step qeydiyyat:
 *  - Step 1: Ad, email, şifrə, user type, şərtlər — form
 *  - Step 2: 6-rəqəmli OTP verification (yalnız client üçün)
 *
 * iOS ilə tam uyğun:
 *  - Back button: chevron.left icon + "Geri" text, secondaryBackground, cornerRadius 10
 *  - User type cards: 50dp circle icon, cornerRadius 14
 *  - Compact input fields: Material icons (person.fill, envelope.fill, lock.fill)
 *  - Password toggle: eye / eye.slash Material icons
 *  - Password strength: 3 bar, height 3dp, cornerRadius 1.5
 *  - Terms checkbox: 20dp, 2dp accent border, cornerRadius 5
 *  - Button: gradient + shadow + arrow
 */
@Composable
fun RegisterScreen(
    onRegisterSuccess: () -> Unit,
    onNavigateToLogin: () -> Unit,
    viewModel: AuthViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val focusManager = LocalFocusManager.current

    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var userType by remember { mutableStateOf("client") }
    var passwordVisible by remember { mutableStateOf(false) }
    var confirmPasswordVisible by remember { mutableStateOf(false) }
    var acceptTerms by remember { mutableStateOf(false) }

    var currentStep by remember { mutableStateOf(1) }
    var otpCode by remember { mutableStateOf("") }

    val showError = uiState is AuthUiState.Error
    val errorMessage = if (uiState is AuthUiState.Error) (uiState as AuthUiState.Error).message else ""
    val isLoading = uiState is AuthUiState.Loading

    LaunchedEffect(uiState) {
        if (uiState is AuthUiState.Success) onRegisterSuccess()
        if (uiState is AuthUiState.RegisterSuccess) onNavigateToLogin()  // iOS kimi: login ekranına qayıt
        if (uiState is AuthUiState.RegisterOtpSent) currentStep = 2
    }

    // iOS: passwordStrength 0-3 (< 6 → 0, 6-7 → 1, 8+ without digits → 2, 8+ with digits → 3)
    val passwordStrength = when {
        password.length < 6 -> 0
        password.length < 8 -> 1
        password.length >= 8 && password.any { it.isDigit() } -> 3
        else -> 2
    }
    val strengthColor = when (passwordStrength) {
        0, 1 -> AppTheme.Colors.error
        2 -> AppTheme.Colors.warning
        else -> AppTheme.Colors.success
    }
    val strengthText = when (passwordStrength) {
        0, 1 -> "Zəif şifrə"
        2 -> "Orta şifrə"
        else -> "Güclü şifrə"
    }
    val passwordsMatch = confirmPassword.isNotEmpty() && password == confirmPassword

    val isFormValid = name.isNotBlank() &&
            email.isNotBlank() && email.contains("@") &&
            password.length >= 6 && passwordsMatch && acceptTerms

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
            .imePadding()
    ) {
        // Header (iOS: HStack { back button (chevron.left + "Geri") })
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppTheme.Colors.background)
                .padding(16.dp)
        ) {
            // iOS: chevron.left icon + "Geri" text, secondaryBackground bg, cornerRadius 10
            Row(
                modifier = Modifier
                    .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(10.dp))
                    .clickable(onClick = onNavigateToLogin)
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
        }

        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (currentStep == 1) {
                // Title (iOS: VStack spacing:8 { "Qeydiyyat" 32sp black + subtitle })
                Column(
                    modifier = Modifier.padding(top = 10.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text("Qeydiyyat", fontSize = 32.sp, fontWeight = FontWeight.Black, color = AppTheme.Colors.primaryText)
                    Text("Hesab yaradın", fontSize = 14.sp, color = AppTheme.Colors.secondaryText)
                }

                Spacer(modifier = Modifier.height(24.dp))

                // User Type Selection (iOS: VStack alignment: .leading, spacing: 12)
                Column(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp)
                ) {
                    Text("Hesab növü seçin", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                    Spacer(modifier = Modifier.height(12.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        // iOS: person.fill icon + "Tələbə" + description, 50dp circle
                        RegisterUserTypeCard(
                            label = "Tələbə", isClient = true, description = "İdman və qidalanmanı izlə",
                            isSelected = userType == "client", modifier = Modifier.weight(1f),
                            onClick = { userType = "client" }
                        )
                        // iOS: person.2.fill icon + "Məşqçi" + description, 50dp circle
                        RegisterUserTypeCard(
                            label = "Məşqçi", isClient = false, description = "Tələbələri idarə et",
                            isSelected = userType == "trainer", modifier = Modifier.weight(1f),
                            onClick = { userType = "trainer" }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                // Input Fields (iOS: VStack spacing: 14)
                Column(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    // Name — iOS: person.fill icon, 14sp font
                    RegisterInputField(
                        value = name, onValueChange = { name = it; viewModel.clearError() },
                        placeholder = "Ad və soyad",
                        leadingIcon = { Icon(Icons.Outlined.Person, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(16.dp)) },
                        hasValue = name.isNotEmpty()
                    )
                    // Email — iOS: envelope.fill icon
                    RegisterInputField(
                        value = email, onValueChange = { email = it; viewModel.clearError() },
                        placeholder = "E-poçt",
                        leadingIcon = { Icon(Icons.Outlined.Email, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(16.dp)) },
                        keyboardType = KeyboardType.Email, hasValue = email.isNotEmpty()
                    )
                    // Password — iOS: lock.fill icon + eye toggle
                    RegisterPasswordField(
                        value = password, onValueChange = { password = it; viewModel.clearError() },
                        placeholder = "Şifrə", isVisible = passwordVisible,
                        onToggle = { passwordVisible = !passwordVisible }, hasValue = password.isNotEmpty()
                    )

                    // Password strength (iOS: 3 bars, height 3, cornerRadius 1.5)
                    if (password.isNotEmpty()) {
                        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Row(horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                                repeat(3) { idx ->
                                    Box(modifier = Modifier.weight(1f).height(3.dp)
                                        .background(if (passwordStrength > idx) strengthColor else AppTheme.Colors.separator, RoundedCornerShape(1.5.dp)))
                                }
                            }
                            Text(strengthText, fontSize = 11.sp, color = strengthColor)
                        }
                    }

                    // Confirm password — iOS: lock.fill icon + eye toggle
                    RegisterPasswordField(
                        value = confirmPassword, onValueChange = { confirmPassword = it },
                        placeholder = "Şifrəni təkrar daxil edin", isVisible = confirmPasswordVisible,
                        onToggle = { confirmPasswordVisible = !confirmPasswordVisible }, hasValue = confirmPassword.isNotEmpty()
                    )

                    // Password match indicator (iOS: checkmark.circle.fill / xmark.circle.fill)
                    if (confirmPassword.isNotEmpty()) {
                        Row(horizontalArrangement = Arrangement.spacedBy(5.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text(if (passwordsMatch) "✓" else "✗", fontSize = 12.sp,
                                color = if (passwordsMatch) AppTheme.Colors.success else AppTheme.Colors.error)
                            Text(if (passwordsMatch) "Şifrələr uyğundur" else "Şifrələr uyğun deyil",
                                fontSize = 11.sp, color = if (passwordsMatch) AppTheme.Colors.success else AppTheme.Colors.error)
                        }
                    }

                    // Terms checkbox (iOS: 20dp, 2dp accent border, cornerRadius 5)
                    Row(
                        modifier = Modifier.fillMaxWidth().clickable { acceptTerms = !acceptTerms },
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(modifier = Modifier.size(20.dp).border(2.dp, AppTheme.Colors.accent, RoundedCornerShape(5.dp)),
                            contentAlignment = Alignment.Center) {
                            if (acceptTerms) Text("✓", fontSize = 12.sp, color = AppTheme.Colors.accent, fontWeight = FontWeight.Bold)
                        }
                        Text("İstifadə şərtlərini qəbul edirəm", fontSize = 13.sp, color = AppTheme.Colors.primaryText)
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Error
                AnimatedVisibility(visible = showError, enter = slideInVertically() + fadeIn(), exit = fadeOut(),
                    modifier = Modifier.padding(horizontal = 20.dp)) {
                    Row(modifier = Modifier.fillMaxWidth()
                        .background(AppTheme.Colors.error.copy(alpha = 0.2f), RoundedCornerShape(10.dp)).padding(12.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Outlined.Warning, null, tint = AppTheme.Colors.error, modifier = Modifier.size(16.dp))
                        Text(errorMessage, fontSize = 13.sp, color = AppTheme.Colors.primaryText)
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Register button (iOS: gradient accent→accent(0.8), shadow, cornerRadius 12)
                val btnEnabled = isFormValid && !isLoading
                Box(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Brush.horizontalGradient(listOf(
                            AppTheme.Colors.accent.copy(alpha = if (btnEnabled) 1f else 0.5f),
                            AppTheme.Colors.accent.copy(alpha = if (btnEnabled) 0.8f else 0.4f)
                        )))
                        .clickable(enabled = btnEnabled) {
                            focusManager.clearFocus()
                            viewModel.register(name.trim(), email.trim(), password, userType)
                        }
                        .padding(vertical = 14.dp),
                    contentAlignment = Alignment.Center
                ) {
                    if (isLoading) {
                        CircularProgressIndicator(modifier = Modifier.size(22.dp), color = Color.White, strokeWidth = 2.dp)
                    } else {
                        Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text(if (userType == "client") "OTP Göndər" else "Qeydiyyat",
                                fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                            Text("→", fontSize = 14.sp, color = Color.White, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(30.dp))

            } else {
                // Step 2: OTP (iOS ilə tam uyğun)
                Column(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 28.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(24.dp)
                ) {
                    Spacer(modifier = Modifier.height(40.dp))
                    Text("OTP Kodu", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                    Text("$email ünvanına göndərilən\n6 rəqəmli kodu daxil edin",
                        fontSize = 14.sp, color = AppTheme.Colors.secondaryText, textAlign = TextAlign.Center)

                    // OTP TextField — iOS: 28sp monospaced bold, cornerRadius 12
                    OutlinedTextField(
                        value = otpCode,
                        onValueChange = { otpCode = it.filter { c -> c.isDigit() }.take(6) },
                        placeholder = {
                            Text("000000", fontSize = 28.sp, fontFamily = FontFamily.Monospace,
                                fontWeight = FontWeight.Bold, textAlign = TextAlign.Center,
                                color = AppTheme.Colors.placeholderText, modifier = Modifier.fillMaxWidth())
                        },
                        modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp),
                        textStyle = androidx.compose.ui.text.TextStyle(
                            fontSize = 28.sp, fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Bold, textAlign = TextAlign.Center,
                            color = AppTheme.Colors.primaryText
                        ),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword, imeAction = ImeAction.Done),
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = AppTheme.Colors.accent,
                            unfocusedBorderColor = AppTheme.Colors.separator,
                            focusedContainerColor = AppTheme.Colors.secondaryBackground,
                            unfocusedContainerColor = AppTheme.Colors.secondaryBackground,
                            focusedTextColor = AppTheme.Colors.primaryText,
                            unfocusedTextColor = AppTheme.Colors.primaryText
                        ),
                        shape = RoundedCornerShape(12.dp)
                    )

                    // Error
                    AnimatedVisibility(visible = showError, enter = fadeIn(), exit = fadeOut()) {
                        Row(modifier = Modifier.fillMaxWidth()
                            .background(AppTheme.Colors.error.copy(alpha = 0.2f), RoundedCornerShape(10.dp)).padding(12.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Outlined.Warning, null, tint = AppTheme.Colors.error, modifier = Modifier.size(16.dp))
                            Text(errorMessage, fontSize = 13.sp, color = AppTheme.Colors.primaryText)
                        }
                    }

                    // Verify button
                    val verifyEnabled = otpCode.length == 6 && !isLoading
                    Box(
                        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(12.dp))
                            .background(Brush.horizontalGradient(listOf(
                                AppTheme.Colors.accent.copy(alpha = if (verifyEnabled) 1f else 0.5f),
                                AppTheme.Colors.accent.copy(alpha = if (verifyEnabled) 0.8f else 0.4f)
                            )))
                            .clickable(enabled = verifyEnabled) {
                                focusManager.clearFocus()
                                viewModel.verifyRegisterOtp(name.trim(), email.trim(), password, userType, otpCode.trim())
                            }
                            .padding(vertical = 14.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(modifier = Modifier.size(22.dp), color = Color.White, strokeWidth = 2.dp)
                        } else {
                            Text("Təsdiq Et və Qeydiyyatdan Keç", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }

                    // Resend + Back buttons
                    TextButton(onClick = { viewModel.register(name.trim(), email.trim(), password, userType) }) {
                        Text("OTP-ni yenidən göndər", fontSize = 14.sp, color = AppTheme.Colors.accent)
                    }
                    TextButton(onClick = { currentStep = 1; otpCode = ""; viewModel.clearError() }) {
                        Text("Geri qayıt", fontSize = 14.sp, color = AppTheme.Colors.accent)
                    }
                }
            }
        }
    }
}

// ─── User Type Card (iOS: VStack { 50dp Circle icon + label + description }, cornerRadius 14) ─
@Composable
fun RegisterUserTypeCard(
    label: String, isClient: Boolean, description: String,
    isSelected: Boolean, modifier: Modifier = Modifier, onClick: () -> Unit
) {
    val bgColor by animateColorAsState(
        if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.1f) else AppTheme.Colors.secondaryBackground,
        animationSpec = spring(), label = "regTypeBg"
    )
    val borderColor by animateColorAsState(
        if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.separator,
        animationSpec = spring(), label = "regTypeBorder"
    )
    val iconColor by animateColorAsState(
        if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.secondaryText,
        animationSpec = spring(), label = "regTypeIcon"
    )
    Column(
        modifier = modifier.background(bgColor, RoundedCornerShape(14.dp))
            .border(if (isSelected) 2.dp else 1.dp, borderColor, RoundedCornerShape(14.dp))
            .clickable(onClick = onClick).padding(vertical = 14.dp, horizontal = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // iOS: 50dp circle with person.fill / person.2.fill icon (20pt)
        Box(modifier = Modifier.size(50.dp)
            .background(if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.2f) else AppTheme.Colors.cardBackground, CircleShape),
            contentAlignment = Alignment.Center) {
            Icon(
                imageVector = Icons.Outlined.Person,
                contentDescription = null,
                tint = iconColor,
                modifier = Modifier.size(20.dp)
            )
        }
        // iOS: VStack(spacing:3) { name 14sp bold + description 10sp }
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(3.dp)
        ) {
            Text(label, fontSize = 14.sp, fontWeight = FontWeight.Bold,
                color = if (isSelected) AppTheme.Colors.primaryText else AppTheme.Colors.secondaryText)
            Text(description, fontSize = 10.sp, color = AppTheme.Colors.secondaryText,
                textAlign = TextAlign.Center, maxLines = 2)
        }
    }
}

// ─── Input Field (iOS: HStack { icon + TextField }, cornerRadius 12) ──────────
@Composable
fun RegisterInputField(
    value: String, onValueChange: (String) -> Unit, placeholder: String,
    leadingIcon: @Composable () -> Unit, keyboardType: KeyboardType = KeyboardType.Text, hasValue: Boolean = false
) {
    var isFocused by remember { mutableStateOf(false) }
    val borderColor by animateColorAsState(
        if (hasValue || isFocused) AppTheme.Colors.accent.copy(alpha = 0.5f) else AppTheme.Colors.separator, label = "regFieldBorder")
    Row(modifier = Modifier.fillMaxWidth()
        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
        .border(1.dp, borderColor, RoundedCornerShape(12.dp)).padding(horizontal = 16.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        leadingIcon()
        OutlinedTextField(
            value = value, onValueChange = onValueChange,
            placeholder = { Text(placeholder, color = AppTheme.Colors.placeholderText, fontSize = 14.sp) },
            modifier = Modifier.weight(1f).onFocusChanged { isFocused = it.isFocused },
            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = Color.Transparent, unfocusedBorderColor = Color.Transparent,
                focusedTextColor = AppTheme.Colors.primaryText, unfocusedTextColor = AppTheme.Colors.primaryText,
                cursorColor = AppTheme.Colors.accent),
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType, imeAction = ImeAction.Next), singleLine = true
        )
    }
}

// ─── Password Field (iOS: HStack { lock.fill + TextField + eye toggle }, cornerRadius 12) ─
@Composable
fun RegisterPasswordField(
    value: String, onValueChange: (String) -> Unit, placeholder: String,
    isVisible: Boolean, onToggle: () -> Unit, hasValue: Boolean = false
) {
    var isFocused by remember { mutableStateOf(false) }
    val borderColor by animateColorAsState(
        if (hasValue || isFocused) AppTheme.Colors.accent.copy(alpha = 0.5f) else AppTheme.Colors.separator, label = "regPassBorder")
    Row(modifier = Modifier.fillMaxWidth()
        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
        .border(1.dp, borderColor, RoundedCornerShape(12.dp)).padding(horizontal = 16.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        // iOS: lock.fill icon
        Icon(Icons.Outlined.Lock, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(16.dp))
        OutlinedTextField(
            value = value, onValueChange = onValueChange,
            placeholder = { Text(placeholder, color = AppTheme.Colors.placeholderText, fontSize = 14.sp) },
            modifier = Modifier.weight(1f).onFocusChanged { isFocused = it.isFocused },
            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = Color.Transparent, unfocusedBorderColor = Color.Transparent,
                focusedTextColor = AppTheme.Colors.primaryText, unfocusedTextColor = AppTheme.Colors.primaryText,
                cursorColor = AppTheme.Colors.accent),
            visualTransformation = if (!isVisible) PasswordVisualTransformation() else VisualTransformation.None,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Next), singleLine = true
        )
        // iOS: eye.fill / eye.slash.fill — Material icons (not emojis)
        IconButton(
            onClick = onToggle,
            modifier = Modifier.size(32.dp)
        ) {
            Icon(
                imageVector = if (isVisible) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                contentDescription = if (isVisible) "Şifrəni gizlət" else "Şifrəni göstər",
                tint = AppTheme.Colors.secondaryText,
                modifier = Modifier.size(16.dp)
            )
        }
    }
}
