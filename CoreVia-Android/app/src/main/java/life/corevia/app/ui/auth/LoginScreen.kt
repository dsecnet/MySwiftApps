package life.corevia.app.ui.auth

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.painterResource
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
import life.corevia.app.R
import life.corevia.app.ui.theme.AppTheme

/**
 * iOS LoginView.swift-in Android tam ekvivalenti.
 * 2-addımlı axın:
 *  - Addım 1: Email + Şifrə + User type → POST /api/v1/auth/login → OTP göndərilir
 *  - Addım 2: 6-rəqəmli OTP kodu → POST /api/v1/auth/login-verify → token alınır
 *
 * iOS-dan götürülmüş elementlər:
 *  - Dil seçici (🇦🇿 🇷🇺 🇬🇧) — sol üstdə
 *  - Blur halo + gym.png ikon (gradient fon, cornerRadius 20)
 *  - "CoreVia" 38sp Black + slogan 11sp accent letterSpacing 2.5
 *  - Tələbə/Məşqçi type toggle
 *  - Input sahələri: label + icon (accent) + TextField + border focus
 *  - "Şifrəni unutdum" — sağa yığılmış
 *  - Xəta: ⚠️ + error.opacity(0.2) fon
 *  - Gradient düymə: icon + label + arrow
 *  - "──── və ya ────" ayırıcı
 *  - OTP: 28sp monospaced TextField, 6 simvol limit
 */
@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit,
    onNavigateToForgotPassword: () -> Unit = {},
    viewModel: AuthViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val focusManager = LocalFocusManager.current

    // Step 1 state
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var passwordVisible by remember { mutableStateOf(false) }
    var selectedUserType by remember { mutableStateOf("client") } // "client" | "trainer"
    var currentLanguage by remember { mutableStateOf("az") } // "az" | "ru" | "en"

    // Step 2 state
    var currentStep by remember { mutableStateOf(1) }
    var otpCode by remember { mutableStateOf("") }

    // Error from ViewModel
    val showError = uiState is AuthUiState.Error
    val errorMessage = if (uiState is AuthUiState.Error) (uiState as AuthUiState.Error).message else ""
    val isLoading = uiState is AuthUiState.Loading

    // Navigate on success
    LaunchedEffect(uiState) {
        if (uiState is AuthUiState.Success) onLoginSuccess()
        if (uiState is AuthUiState.OtpSent) currentStep = 2
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
            .clickable(indication = null, interactionSource = remember { MutableInteractionSource() }) {
                focusManager.clearFocus()
            }
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(16.dp))

            // ─── Dil Seçici (iOS: HStack flags, sol üstdə) ──────────────────────
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 28.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                listOf("🇦🇿" to "az", "🇷🇺" to "ru", "🇬🇧" to "en").forEach { (flag, code) ->
                    val isSelected = currentLanguage == code
                    val bgColor by animateColorAsState(
                        if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.15f) else AppTheme.Colors.secondaryBackground,
                        label = "langBg"
                    )
                    val borderColor by animateColorAsState(
                        if (isSelected) AppTheme.Colors.accent else Color.Transparent,
                        label = "langBorder"
                    )
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .background(bgColor, RoundedCornerShape(10.dp))
                            .border(2.dp, borderColor, RoundedCornerShape(10.dp))
                            .clickable { currentLanguage = code },
                        contentAlignment = Alignment.Center
                    ) {
                        Text(text = flag, fontSize = 22.sp)
                    }
                }
                Spacer(modifier = Modifier.weight(1f))
            }

            // ─── Logo Bölməsi (iOS: ZStack blur + gym.png) ──────────────────────
            Box(
                modifier = Modifier.padding(vertical = 8.dp),
                contentAlignment = Alignment.Center
            ) {
                // Blur halo circle
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .background(
                            Brush.radialGradient(
                                colors = listOf(
                                    AppTheme.Colors.accent.copy(alpha = 0.3f),
                                    AppTheme.Colors.accent
                                )
                            ),
                            CircleShape
                        )
                        .blur(15.dp)
                )
                // gym.png — gradient fon, cornerRadius 20, white tint, shadow
                Box(
                    modifier = Modifier
                        .shadow(
                            elevation = 15.dp,
                            shape = RoundedCornerShape(20.dp),
                            spotColor = AppTheme.Colors.accent.copy(alpha = 0.5f),
                            ambientColor = AppTheme.Colors.accent.copy(alpha = 0.3f)
                        )
                        .clip(RoundedCornerShape(20.dp))
                        .background(
                            Brush.linearGradient(
                                colors = listOf(
                                    AppTheme.Colors.accent,
                                    AppTheme.Colors.accent.copy(alpha = 0.8f)
                                )
                            )
                        )
                        .padding(12.dp)
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.gym),
                        contentDescription = "CoreVia",
                        modifier = Modifier.size(75.dp),
                        contentScale = ContentScale.Fit,
                        colorFilter = ColorFilter.tint(Color.White)
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // iOS: font(.system(size: 38, weight: .black))
            Text(
                text = "CoreVia",
                fontSize = 38.sp,
                fontWeight = FontWeight.Black,
                color = AppTheme.Colors.primaryText
            )

            // iOS: font(.system(size: 11, weight: .semibold)) + accent + tracking 2.5
            Text(
                text = "FİTNES · SAĞLAMLIQ · HƏYAT",
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                color = AppTheme.Colors.accent,
                letterSpacing = 2.5.sp
            )

            Spacer(modifier = Modifier.height(28.dp))

            // ─── User Type Selection (iOS: Tələbə / Məşqçi toggle) ──────────────
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 28.dp),
                horizontalAlignment = Alignment.Start
            ) {
                Text(
                    text = "Hesab növü",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                    color = AppTheme.Colors.secondaryText
                )
                Spacer(modifier = Modifier.height(12.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Tələbə
                    UserTypeButton(
                        label = "Tələbə",
                        icon = "👤",
                        isSelected = selectedUserType == "client",
                        modifier = Modifier.weight(1f),
                        onClick = { selectedUserType = "client" }
                    )
                    // Məşqçi
                    UserTypeButton(
                        label = "Məşqçi",
                        icon = "👥",
                        isSelected = selectedUserType == "trainer",
                        modifier = Modifier.weight(1f),
                        onClick = { selectedUserType = "trainer" }
                    )
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            // ─── Step-based Content ───────────────────────────────────────────────
            if (currentStep == 1) {
                // Step 1: Email + Şifrə
                LoginStep1Content(
                    email = email,
                    onEmailChange = { email = it; viewModel.clearError() },
                    password = password,
                    onPasswordChange = { password = it; viewModel.clearError() },
                    passwordVisible = passwordVisible,
                    onPasswordToggle = { passwordVisible = !passwordVisible },
                    showError = showError,
                    errorMessage = errorMessage,
                    isLoading = isLoading,
                    selectedUserType = selectedUserType,
                    onLogin = {
                        focusManager.clearFocus()
                        viewModel.login(email.trim(), password)
                    },
                    onForgotPassword = onNavigateToForgotPassword,
                    onNavigateToRegister = {
                        viewModel.clearError()
                        onNavigateToRegister()
                    }
                )
            } else {
                // Step 2: OTP Verification
                OtpStep2Content(
                    email = email,
                    otpCode = otpCode,
                    onOtpChange = { newVal ->
                        otpCode = newVal.filter { it.isDigit() }.take(6)
                    },
                    showError = showError,
                    errorMessage = errorMessage,
                    isLoading = isLoading,
                    onVerify = {
                        focusManager.clearFocus()
                        viewModel.verifyOtp(email.trim(), otpCode)
                    },
                    onBack = {
                        currentStep = 1
                        otpCode = ""
                        viewModel.clearError()
                    }
                )
            }

            Spacer(modifier = Modifier.height(30.dp))
        }
    }
}

// ─── User Type Button ─────────────────────────────────────────────────────────
// iOS: selectedUserType == .client ? accent fon : secondaryBackground
@Composable
fun UserTypeButton(
    label: String,
    icon: String,
    isSelected: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    val bgColor by animateColorAsState(
        if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.secondaryBackground,
        animationSpec = spring(), label = "userTypeBg"
    )
    val textColor by animateColorAsState(
        if (isSelected) Color.White else AppTheme.Colors.primaryText,
        animationSpec = spring(), label = "userTypeText"
    )
    val borderColor by animateColorAsState(
        if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.separator,
        animationSpec = spring(), label = "userTypeBorder"
    )
    val borderWidth = if (isSelected) 2.dp else 1.dp

    Box(
        modifier = modifier
            .background(bgColor, RoundedCornerShape(10.dp))
            .border(borderWidth, borderColor, RoundedCornerShape(10.dp))
            .clickable(onClick = onClick)
            .padding(vertical = 12.dp),
        contentAlignment = Alignment.Center
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(text = icon, fontSize = 16.sp)
            Text(
                text = label,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = textColor
            )
        }
    }
}

// ─── Step 1: Email + Şifrə ────────────────────────────────────────────────────
@Composable
fun LoginStep1Content(
    email: String,
    onEmailChange: (String) -> Unit,
    password: String,
    onPasswordChange: (String) -> Unit,
    passwordVisible: Boolean,
    onPasswordToggle: () -> Unit,
    showError: Boolean,
    errorMessage: String,
    isLoading: Boolean,
    selectedUserType: String,
    onLogin: () -> Unit,
    onForgotPassword: () -> Unit,
    onNavigateToRegister: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 28.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Email
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text("E-poçt", fontSize = 13.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.secondaryText)
            LoginTextField(
                value = email,
                onValueChange = onEmailChange,
                placeholder = "email@example.com",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Email,
                        contentDescription = null,
                        tint = AppTheme.Colors.accent,
                        modifier = Modifier.size(20.dp)
                    )
                },
                keyboardType = KeyboardType.Email,
                imeAction = ImeAction.Next,
                hasValue = email.isNotEmpty()
            )
        }

        // Şifrə
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text("Şifrə", fontSize = 13.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.secondaryText)
            LoginTextField(
                value = password,
                onValueChange = onPasswordChange,
                placeholder = "••••••••",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Lock,
                        contentDescription = null,
                        tint = AppTheme.Colors.accent,
                        modifier = Modifier.size(20.dp)
                    )
                },
                isPassword = true,
                passwordVisible = passwordVisible,
                onPasswordToggle = onPasswordToggle,
                keyboardType = KeyboardType.Password,
                imeAction = ImeAction.Done,
                onDone = onLogin,
                hasValue = password.isNotEmpty()
            )
        }

        // Şifrəni unutdum — sağa yığılmış (iOS: HStack { Spacer() + NavigationLink })
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
            TextButton(
                onClick = onForgotPassword,
                contentPadding = PaddingValues(0.dp)
            ) {
                Text(
                    text = "Şifrəni unutdum?",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                    color = AppTheme.Colors.secondaryText
                )
            }
        }

        // Error message (iOS: HStack ⚠️ + error.opacity(0.2) fon)
        AnimatedVisibility(
            visible = showError,
            enter = slideInVertically() + fadeIn(),
            exit = fadeOut()
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppTheme.Colors.error.copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                    .padding(horizontal = 12.dp, vertical = 10.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Warning,
                    contentDescription = null,
                    tint = AppTheme.Colors.error,
                    modifier = Modifier.size(16.dp)
                )
                Text(
                    text = errorMessage,
                    fontSize = 13.sp,
                    color = AppTheme.Colors.primaryText
                )
            }
        }

        // Gradient Login Button
        // iOS: LinearGradient accent → accent.opacity(0.8), shadow accent.opacity(0.4), radius 8, y 4
        val buttonLabel = if (selectedUserType == "client") "Tələbə kimi daxil ol" else "Məşqçi kimi daxil ol"
        val buttonEnabled = email.isNotBlank() && password.isNotBlank() && !isLoading
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(
                    elevation = if (buttonEnabled) 8.dp else 0.dp,
                    shape = RoundedCornerShape(12.dp),
                    spotColor = AppTheme.Colors.accent.copy(alpha = 0.4f),
                    ambientColor = AppTheme.Colors.accent.copy(alpha = 0.2f)
                )
                .clip(RoundedCornerShape(12.dp))
                .background(
                    Brush.horizontalGradient(
                        listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.8f))
                    )
                )
                .clickable(enabled = buttonEnabled, onClick = onLogin)
                .padding(vertical = 14.dp),
            contentAlignment = Alignment.Center
        ) {
            if (isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(22.dp),
                    color = Color.White,
                    strokeWidth = 2.dp
                )
            } else {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = if (selectedUserType == "client") "👤" else "👥",
                        fontSize = 14.sp
                    )
                    Text(
                        text = buttonLabel,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(text = "→", fontSize = 14.sp, color = Color.White, fontWeight = FontWeight.Bold)
                }
            }
        }

        // Ayırıcı: ──── və ya ────
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Divider(modifier = Modifier.weight(1f), color = AppTheme.Colors.separator)
            Text("və ya", fontSize = 12.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.secondaryText)
            Divider(modifier = Modifier.weight(1f), color = AppTheme.Colors.separator)
        }

        // Qeydiyyat linki
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("Hesabınız yoxdur? ", fontSize = 14.sp, color = AppTheme.Colors.secondaryText)
            TextButton(
                onClick = onNavigateToRegister,
                contentPadding = PaddingValues(0.dp)
            ) {
                Text(
                    text = "Qeydiyyat",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.accent
                )
            }
        }
    }
}

// ─── Step 2: OTP Verification ─────────────────────────────────────────────────
// iOS: monospace 28sp TextField + Təsdiq et düyməsi + Geri qayıt
@Composable
fun OtpStep2Content(
    email: String,
    otpCode: String,
    onOtpChange: (String) -> Unit,
    showError: Boolean,
    errorMessage: String,
    isLoading: Boolean,
    onVerify: () -> Unit,
    onBack: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "OTP Təsdiqi",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )
            Text(
                text = "$email ünvanına göndərilən\n6 rəqəmli kodu daxil edin",
                fontSize = 14.sp,
                color = AppTheme.Colors.secondaryText,
                textAlign = TextAlign.Center
            )
        }

        // OTP TextField — 28sp monospaced (iOS: .system(size:28, weight:.bold, design:.monospaced))
        OutlinedTextField(
            value = otpCode,
            onValueChange = onOtpChange,
            placeholder = {
                Text(
                    text = "000000",
                    fontSize = 28.sp,
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    color = AppTheme.Colors.placeholderText,
                    modifier = Modifier.fillMaxWidth()
                )
            },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp),
            textStyle = androidx.compose.ui.text.TextStyle(
                fontSize = 28.sp,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center,
                color = AppTheme.Colors.primaryText
            ),
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.NumberPassword,
                imeAction = ImeAction.Done
            ),
            keyboardActions = KeyboardActions(onDone = { if (otpCode.length == 6) onVerify() }),
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
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppTheme.Colors.error.copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                    .padding(12.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Warning,
                    contentDescription = null,
                    tint = AppTheme.Colors.error,
                    modifier = Modifier.size(16.dp)
                )
                Text(text = errorMessage, fontSize = 13.sp, color = AppTheme.Colors.primaryText)
            }
        }

        // Verify Button
        val verifyEnabled = otpCode.length == 6 && !isLoading
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(
                    elevation = if (verifyEnabled) 8.dp else 0.dp,
                    shape = RoundedCornerShape(12.dp),
                    spotColor = AppTheme.Colors.accent.copy(alpha = 0.4f),
                    ambientColor = AppTheme.Colors.accent.copy(alpha = 0.2f)
                )
                .clip(RoundedCornerShape(12.dp))
                .background(
                    Brush.horizontalGradient(
                        listOf(
                            AppTheme.Colors.accent.copy(alpha = if (verifyEnabled) 1f else 0.5f),
                            AppTheme.Colors.accent.copy(alpha = if (verifyEnabled) 0.8f else 0.4f)
                        )
                    )
                )
                .clickable(enabled = verifyEnabled, onClick = onVerify)
                .padding(vertical = 14.dp),
            contentAlignment = Alignment.Center
        ) {
            if (isLoading) {
                CircularProgressIndicator(modifier = Modifier.size(22.dp), color = Color.White, strokeWidth = 2.dp)
            } else {
                Text(
                    text = "Təsdiq Et və Daxil Ol",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }

        // Geri qayıt (iOS: "Geri qayıt" accent rəngli link)
        TextButton(onClick = onBack) {
            Text(
                text = "Geri qayıt",
                fontSize = 14.sp,
                color = AppTheme.Colors.accent
            )
        }
    }
}

// ─── CoreVia Login TextField ──────────────────────────────────────────────────
// iOS: HStack { icon + TextField } — accent icon, border changes on value
@Composable
fun LoginTextField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    leadingIcon: @Composable () -> Unit,
    keyboardType: KeyboardType = KeyboardType.Text,
    imeAction: ImeAction = ImeAction.Next,
    isPassword: Boolean = false,
    passwordVisible: Boolean = false,
    onPasswordToggle: (() -> Unit)? = null,
    onDone: (() -> Unit)? = null,
    hasValue: Boolean = false
) {
    var isFocused by remember { mutableStateOf(false) }

    // iOS: border: empty→separator, hasValue→accent.opacity(0.5), focused→accent.opacity(0.5)
    val borderColor by animateColorAsState(
        when {
            isFocused || hasValue -> AppTheme.Colors.accent.copy(alpha = 0.5f)
            else -> AppTheme.Colors.separator
        },
        label = "textFieldBorder"
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
            .border(1.dp, borderColor, RoundedCornerShape(12.dp))
            .padding(horizontal = 16.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        leadingIcon()
        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            placeholder = {
                Text(
                    text = placeholder,
                    color = AppTheme.Colors.placeholderText,
                    fontSize = 15.sp
                )
            },
            modifier = Modifier
                .weight(1f)
                .onFocusChanged { isFocused = it.isFocused },
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.Transparent,
                unfocusedBorderColor = Color.Transparent,
                focusedTextColor = AppTheme.Colors.primaryText,
                unfocusedTextColor = AppTheme.Colors.primaryText,
                cursorColor = AppTheme.Colors.accent
            ),
            visualTransformation = if (isPassword && !passwordVisible)
                PasswordVisualTransformation() else VisualTransformation.None,
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType, imeAction = imeAction),
            keyboardActions = KeyboardActions(onDone = { onDone?.invoke() }),
            singleLine = true
        )
        if (isPassword && onPasswordToggle != null) {
            TextButton(
                onClick = onPasswordToggle,
                contentPadding = PaddingValues(horizontal = 4.dp)
            ) {
                Text(
                    text = if (passwordVisible) "👁" else "👁‍🗨",
                    fontSize = 18.sp
                )
            }
        }
    }
}
