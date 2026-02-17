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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Warning
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
        if (uiState is AuthUiState.OtpSent) currentStep = 2
    }

    val passwordStrength = when {
        password.length < 6 -> 0
        password.length < 8 -> 1
        password.length >= 8 && password.any { it.isDigit() } -> 2
        else -> 3
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
    ) {
        // Header (iOS: back button)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppTheme.Colors.background)
                .padding(16.dp)
        ) {
            Box(
                modifier = Modifier
                    .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(10.dp))
                    .clickable(onClick = onNavigateToLogin)
                    .padding(horizontal = 12.dp, vertical = 6.dp)
            ) {
                Text("← Geri", color = AppTheme.Colors.accent, fontSize = 15.sp, fontWeight = FontWeight.Medium)
            }
        }

        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (currentStep == 1) {
                // Title
                Column(
                    modifier = Modifier.padding(top = 10.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("Qeydiyyat", fontSize = 32.sp, fontWeight = FontWeight.Black, color = AppTheme.Colors.primaryText)
                    Text("Hesab yaradın", fontSize = 14.sp, color = AppTheme.Colors.secondaryText)
                }

                Spacer(modifier = Modifier.height(24.dp))

                // User Type Selection
                Column(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp)
                ) {
                    Text("Hesab növü seçin", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                    Spacer(modifier = Modifier.height(12.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        RegisterUserTypeCard(
                            label = "Tələbə", icon = "👤", description = "İdman və qidalanmanı izlə",
                            isSelected = userType == "client", modifier = Modifier.weight(1f),
                            onClick = { userType = "client" }
                        )
                        RegisterUserTypeCard(
                            label = "Məşqçi", icon = "👥", description = "Tələbələri idarə et",
                            isSelected = userType == "trainer", modifier = Modifier.weight(1f),
                            onClick = { userType = "trainer" }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                // Input Fields
                Column(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    RegisterInputField(
                        value = name, onValueChange = { name = it; viewModel.clearError() },
                        placeholder = "Ad və soyad",
                        leadingIcon = { Icon(Icons.Default.Person, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(16.dp)) },
                        hasValue = name.isNotEmpty()
                    )
                    RegisterInputField(
                        value = email, onValueChange = { email = it; viewModel.clearError() },
                        placeholder = "E-poçt",
                        leadingIcon = { Icon(Icons.Default.Email, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(16.dp)) },
                        keyboardType = KeyboardType.Email, hasValue = email.isNotEmpty()
                    )
                    RegisterPasswordField(
                        value = password, onValueChange = { password = it; viewModel.clearError() },
                        placeholder = "Şifrə", isVisible = passwordVisible,
                        onToggle = { passwordVisible = !passwordVisible }, hasValue = password.isNotEmpty()
                    )

                    // Password strength
                    if (password.isNotEmpty()) {
                        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                repeat(3) { idx ->
                                    Box(modifier = Modifier.weight(1f).height(3.dp)
                                        .background(if (passwordStrength > idx) strengthColor else AppTheme.Colors.separator, RoundedCornerShape(2.dp)))
                                }
                            }
                            Text(strengthText, fontSize = 11.sp, color = strengthColor)
                        }
                    }

                    RegisterPasswordField(
                        value = confirmPassword, onValueChange = { confirmPassword = it },
                        placeholder = "Şifrəni təkrar daxil edin", isVisible = confirmPasswordVisible,
                        onToggle = { confirmPasswordVisible = !confirmPasswordVisible }, hasValue = confirmPassword.isNotEmpty()
                    )

                    if (confirmPassword.isNotEmpty()) {
                        Row(horizontalArrangement = Arrangement.spacedBy(5.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text(if (passwordsMatch) "✓" else "✗", fontSize = 12.sp,
                                color = if (passwordsMatch) AppTheme.Colors.success else AppTheme.Colors.error)
                            Text(if (passwordsMatch) "Şifrələr uyğundur" else "Şifrələr uyğun deyil",
                                fontSize = 11.sp, color = if (passwordsMatch) AppTheme.Colors.success else AppTheme.Colors.error)
                        }
                    }

                    // Terms checkbox
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

                AnimatedVisibility(visible = showError, enter = slideInVertically() + fadeIn(), exit = fadeOut(),
                    modifier = Modifier.padding(horizontal = 20.dp)) {
                    Row(modifier = Modifier.fillMaxWidth()
                        .background(AppTheme.Colors.error.copy(alpha = 0.2f), RoundedCornerShape(10.dp)).padding(12.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Warning, null, tint = AppTheme.Colors.error, modifier = Modifier.size(16.dp))
                        Text(errorMessage, fontSize = 13.sp, color = AppTheme.Colors.primaryText)
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

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
                // Step 2: OTP
                Column(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 28.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(24.dp)
                ) {
                    Spacer(modifier = Modifier.height(40.dp))
                    Text("OTP Kodu", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                    Text("$email ünvanına göndərilən\n6 rəqəmli kodu daxil edin",
                        fontSize = 14.sp, color = AppTheme.Colors.secondaryText, textAlign = TextAlign.Center)

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

                    AnimatedVisibility(visible = showError, enter = fadeIn(), exit = fadeOut()) {
                        Row(modifier = Modifier.fillMaxWidth()
                            .background(AppTheme.Colors.error.copy(alpha = 0.2f), RoundedCornerShape(10.dp)).padding(12.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Warning, null, tint = AppTheme.Colors.error, modifier = Modifier.size(16.dp))
                            Text(errorMessage, fontSize = 13.sp, color = AppTheme.Colors.primaryText)
                        }
                    }

                    val verifyEnabled = otpCode.length == 6 && !isLoading
                    Box(
                        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(12.dp))
                            .background(Brush.horizontalGradient(listOf(
                                AppTheme.Colors.accent.copy(alpha = if (verifyEnabled) 1f else 0.5f),
                                AppTheme.Colors.accent.copy(alpha = if (verifyEnabled) 0.8f else 0.4f)
                            )))
                            .clickable(enabled = verifyEnabled) {
                                focusManager.clearFocus()
                                viewModel.verifyOtp(email.trim(), otpCode)
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

@Composable
fun RegisterUserTypeCard(
    label: String, icon: String, description: String,
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
    Column(
        modifier = modifier.background(bgColor, RoundedCornerShape(14.dp))
            .border(if (isSelected) 2.dp else 1.dp, borderColor, RoundedCornerShape(14.dp))
            .clickable(onClick = onClick).padding(vertical = 14.dp, horizontal = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Box(modifier = Modifier.size(50.dp)
            .background(if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.2f) else AppTheme.Colors.cardBackground, CircleShape),
            contentAlignment = Alignment.Center) {
            Text(text = icon, fontSize = 20.sp)
        }
        Text(label, fontSize = 14.sp, fontWeight = FontWeight.Bold,
            color = if (isSelected) AppTheme.Colors.primaryText else AppTheme.Colors.secondaryText)
        Text(description, fontSize = 10.sp, color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center, maxLines = 2)
    }
}

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
        Icon(Icons.Default.Lock, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(16.dp))
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
        TextButton(onClick = onToggle, contentPadding = PaddingValues(horizontal = 4.dp)) {
            Text(if (isVisible) "👁" else "👁‍🗨", fontSize = 16.sp)
        }
    }
}
