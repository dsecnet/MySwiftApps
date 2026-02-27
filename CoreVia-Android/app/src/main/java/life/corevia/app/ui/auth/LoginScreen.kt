package life.corevia.app.ui.auth

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.ui.theme.*

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit,
    onNavigateToForgotPassword: () -> Unit,
    viewModel: LoginViewModel = hiltViewModel()
) {
    val focusManager = LocalFocusManager.current
    val uiState by viewModel.uiState.collectAsState()

    // Navigate on successful login
    LaunchedEffect(uiState.isLoggedIn) {
        if (uiState.isLoggedIn) {
            onLoginSuccess()
        }
    }

    val languages = listOf("🇦🇿", "🇬🇧", "🇷🇺")
    var selectedLanguage by remember { mutableIntStateOf(0) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .clickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() }
            ) { focusManager.clearFocus() }
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 30.dp)
        ) {
            // Dil Seçici
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 24.dp, end = 24.dp, top = 52.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                languages.forEachIndexed { index, flag ->
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(
                                if (selectedLanguage == index) CoreViaPrimary.copy(alpha = 0.08f)
                                else Color(0xFFF0F0F0)
                            )
                            .then(
                                if (selectedLanguage == index)
                                    Modifier.border(2.dp, CoreViaPrimary, RoundedCornerShape(12.dp))
                                else Modifier
                            )
                            .clickable { selectedLanguage = index },
                        contentAlignment = Alignment.Center
                    ) {
                        Text(text = flag, fontSize = 24.sp)
                    }
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Logo - Red rounded square with fitness icon
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(90.dp)
                        .shadow(12.dp, RoundedCornerShape(22.dp), ambientColor = CoreViaPrimary.copy(alpha = 0.4f))
                        .clip(RoundedCornerShape(22.dp))
                        .background(CoreViaPrimary),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.FitnessCenter,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(44.dp)
                    )
                }

                Spacer(modifier = Modifier.height(18.dp))

                Text(
                    text = "CoreVia",
                    fontSize = 36.sp,
                    fontWeight = FontWeight.Black,
                    color = MaterialTheme.colorScheme.onBackground
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "GÜCƏ GEDƏN YOL",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = CoreViaPrimary,
                    letterSpacing = 3.sp
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Hesab növü
            Column(modifier = Modifier.padding(horizontal = 24.dp)) {
                Text(
                    text = "Hesab növü",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(modifier = Modifier.height(12.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    UserTypeButton(
                        icon = Icons.Filled.Person,
                        text = "Tələbə",
                        isSelected = uiState.userType == "client",
                        onClick = { viewModel.updateUserType("client") },
                        modifier = Modifier.weight(1f)
                    )
                    UserTypeButton(
                        icon = Icons.Filled.Groups,
                        text = "Müəllim",
                        isSelected = uiState.userType == "trainer",
                        onClick = { viewModel.updateUserType("trainer") },
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            // Step Content
            AnimatedContent(
                targetState = uiState.currentStep,
                transitionSpec = {
                    slideInHorizontally { it } + fadeIn() togetherWith slideOutHorizontally { -it } + fadeOut()
                },
                label = "step"
            ) { step ->
                if (step == 1) {
                    LoginFormContent(
                        email = uiState.email,
                        onEmailChange = { viewModel.updateEmail(it) },
                        password = uiState.password,
                        onPasswordChange = { viewModel.updatePassword(it) },
                        isPasswordVisible = uiState.isPasswordVisible,
                        onTogglePassword = { viewModel.togglePasswordVisibility() },
                        isLoading = uiState.isLoading,
                        errorMessage = uiState.errorMessage,
                        userType = uiState.userType,
                        onLoginClick = { viewModel.login() },
                        onForgotPasswordClick = onNavigateToForgotPassword,
                        onRegisterClick = onNavigateToRegister
                    )
                } else {
                    OTPContent(
                        email = uiState.email,
                        otpCode = uiState.otpCode,
                        onOtpChange = { viewModel.updateOtpCode(it) },
                        isLoading = uiState.isLoading,
                        errorMessage = uiState.errorMessage,
                        onVerifyClick = { viewModel.verifyOtp() },
                        onBackClick = { viewModel.goBackToLogin() }
                    )
                }
            }
        }
    }
}

@Composable
private fun UserTypeButton(
    icon: ImageVector,
    text: String,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .height(52.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(if (isSelected) CoreViaPrimary else Color(0xFFF5F5F5))
            .then(
                if (!isSelected) Modifier.border(1.5.dp, Color(0xFFE0E0E0), RoundedCornerShape(14.dp))
                else Modifier
            )
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                icon, null,
                modifier = Modifier.size(20.dp),
                tint = if (isSelected) Color.White else TextSecondary
            )
            Text(
                text = text,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = if (isSelected) Color.White else TextPrimary
            )
        }
    }
}

@Composable
private fun LoginFormContent(
    email: String, onEmailChange: (String) -> Unit,
    password: String, onPasswordChange: (String) -> Unit,
    isPasswordVisible: Boolean, onTogglePassword: () -> Unit,
    isLoading: Boolean, errorMessage: String?,
    userType: String, onLoginClick: () -> Unit,
    onForgotPasswordClick: () -> Unit, onRegisterClick: () -> Unit
) {
    Column {
        Column(modifier = Modifier.padding(horizontal = 24.dp)) {
            Text("Email", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = email, onValueChange = onEmailChange,
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("name@example.com", color = TextHint) },
                leadingIcon = { Icon(Icons.Filled.Email, null, Modifier.size(20.dp), tint = CoreViaPrimary) },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                singleLine = true, shape = RoundedCornerShape(14.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = Color(0xFFE8E8E8),
                    focusedContainerColor = Color(0xFFF8F8F8), unfocusedContainerColor = Color(0xFFF8F8F8)
                )
            )

            Spacer(Modifier.height(18.dp))

            Text("Şifrə", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = password, onValueChange = onPasswordChange,
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("Şifrənizi daxil edin", color = TextHint) },
                leadingIcon = { Icon(Icons.Filled.Lock, null, Modifier.size(20.dp), tint = CoreViaPrimary) },
                trailingIcon = {
                    IconButton(onClick = onTogglePassword) {
                        Icon(
                            if (isPasswordVisible) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                            null, Modifier.size(20.dp), tint = TextSecondary
                        )
                    }
                },
                visualTransformation = if (isPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                singleLine = true, shape = RoundedCornerShape(14.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = Color(0xFFE8E8E8),
                    focusedContainerColor = Color(0xFFF8F8F8), unfocusedContainerColor = Color(0xFFF8F8F8)
                )
            )
        }

        Spacer(Modifier.height(10.dp))

        Row(Modifier.fillMaxWidth().padding(horizontal = 24.dp), horizontalArrangement = Arrangement.End) {
            Text(
                "Şifrəni unutdunuz?", fontSize = 13.sp, fontWeight = FontWeight.Medium,
                color = TextSecondary, modifier = Modifier.clickable { onForgotPasswordClick() }
            )
        }

        Spacer(Modifier.height(20.dp))

        // Error message
        AnimatedVisibility(
            visible = errorMessage != null,
            enter = slideInVertically() + fadeIn(),
            exit = slideOutVertically() + fadeOut()
        ) {
            Row(
                Modifier.padding(horizontal = 24.dp).fillMaxWidth().clip(RoundedCornerShape(12.dp)).background(CoreViaError.copy(alpha = 0.1f)).padding(14.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Filled.Warning, null, Modifier.size(18.dp), tint = CoreViaError)
                Text(errorMessage ?: "", fontSize = 13.sp, color = MaterialTheme.colorScheme.onBackground)
            }
        }

        Spacer(Modifier.height(20.dp))

        Column(Modifier.padding(horizontal = 24.dp)) {
            Button(
                onClick = onLoginClick, enabled = !isLoading,
                modifier = Modifier.fillMaxWidth().height(54.dp)
                    .shadow(8.dp, RoundedCornerShape(14.dp), ambientColor = CoreViaPrimary.copy(alpha = 0.4f)),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp), strokeWidth = 2.dp)
                } else {
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            if (userType == "client") Icons.Filled.Person else Icons.Filled.Groups,
                            null, Modifier.size(20.dp), tint = Color.White
                        )
                        Text(
                            if (userType == "client") "Tələbə olaraq daxil ol" else "Müəllim olaraq daxil ol",
                            fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White
                        )
                        Icon(Icons.AutoMirrored.Filled.ArrowForward, null, Modifier.size(20.dp), tint = Color.White)
                    }
                }
            }
        }

        Spacer(Modifier.height(28.dp))

        Row(Modifier.padding(horizontal = 24.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
            HorizontalDivider(Modifier.weight(1f), color = Color(0xFFE0E0E0))
            Text("və ya", fontSize = 13.sp, fontWeight = FontWeight.Medium, color = TextSecondary)
            HorizontalDivider(Modifier.weight(1f), color = Color(0xFFE0E0E0))
        }

        Spacer(Modifier.height(28.dp))

        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
            Text("Hesabınız yoxdur? ", fontSize = 14.sp, color = TextSecondary)
            Text("Qeydiyyatdan keçin", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = CoreViaPrimary, modifier = Modifier.clickable { onRegisterClick() })
        }
    }
}

@Composable
private fun OTPContent(
    email: String, otpCode: String, onOtpChange: (String) -> Unit,
    isLoading: Boolean, errorMessage: String?,
    onVerifyClick: () -> Unit, onBackClick: () -> Unit
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Spacer(Modifier.height(40.dp))
        Text("OTP Təsdiqi", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onBackground)
        Spacer(Modifier.height(12.dp))
        Text(
            "$email ünvanına göndərilən 6 rəqəmli kodu daxil edin",
            fontSize = 14.sp, color = TextSecondary, textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 30.dp)
        )
        Spacer(Modifier.height(24.dp))

        OutlinedTextField(
            value = otpCode, onValueChange = onOtpChange,
            modifier = Modifier.fillMaxWidth().padding(horizontal = 40.dp),
            placeholder = { Text("000000", color = TextHint) },
            textStyle = LocalTextStyle.current.copy(fontSize = 28.sp, fontWeight = FontWeight.Bold, textAlign = TextAlign.Center, letterSpacing = 8.sp),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            singleLine = true, shape = RoundedCornerShape(14.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = CoreViaPrimary, unfocusedBorderColor = Color(0xFFE8E8E8),
                focusedContainerColor = Color(0xFFF8F8F8), unfocusedContainerColor = Color(0xFFF8F8F8)
            )
        )

        Spacer(Modifier.height(16.dp))

        // Error message
        AnimatedVisibility(
            visible = errorMessage != null,
            enter = slideInVertically() + fadeIn(),
            exit = slideOutVertically() + fadeOut()
        ) {
            Row(
                Modifier.padding(horizontal = 24.dp).fillMaxWidth().clip(RoundedCornerShape(12.dp)).background(CoreViaError.copy(alpha = 0.1f)).padding(14.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Filled.Warning, null, Modifier.size(18.dp), tint = CoreViaError)
                Text(errorMessage ?: "", fontSize = 13.sp, color = MaterialTheme.colorScheme.onBackground)
            }
        }

        Spacer(Modifier.height(24.dp))

        Button(
            onClick = onVerifyClick, enabled = !isLoading && otpCode.length == 6,
            modifier = Modifier.fillMaxWidth().height(54.dp).padding(horizontal = 24.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
        ) {
            if (isLoading) {
                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp), strokeWidth = 2.dp)
            } else {
                Text("Təsdiq Et və Daxil Ol", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
            }
        }

        Spacer(Modifier.height(16.dp))
        Text("Geri qayıt", fontSize = 14.sp, fontWeight = FontWeight.Medium, color = CoreViaPrimary, modifier = Modifier.clickable { onBackClick() })
    }
}
