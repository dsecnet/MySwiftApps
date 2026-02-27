package life.corevia.app.ui.auth

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.automirrored.filled.Notes
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
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
fun RegisterScreen(
    onBack: () -> Unit,
    onRegisterSuccess: () -> Unit,
    viewModel: RegisterViewModel = hiltViewModel()
) {
    val focusManager = LocalFocusManager.current
    val uiState by viewModel.uiState.collectAsState()

    // Navigate on successful registration
    LaunchedEffect(uiState.isRegistered) {
        if (uiState.isRegistered) {
            onRegisterSuccess()
        }
    }

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
            // ── Header ──
            RegisterHeader(onBack = onBack)

            Spacer(modifier = Modifier.height(16.dp))

            // ── Step Content ──
            AnimatedContent(
                targetState = uiState.currentStep,
                transitionSpec = {
                    slideInHorizontally { it } + fadeIn() togetherWith
                            slideOutHorizontally { -it } + fadeOut()
                },
                label = "register-step"
            ) { step ->
                if (step == 1) {
                    RegisterFormContent(
                        uiState = uiState,
                        viewModel = viewModel
                    )
                } else {
                    RegisterOTPContent(
                        uiState = uiState,
                        viewModel = viewModel
                    )
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// HEADER — iOS headerView
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun RegisterHeader(onBack: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(start = 16.dp, end = 16.dp, top = 52.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(10.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                .clickable(onClick = onBack)
                .padding(horizontal = 16.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = null,
                modifier = Modifier.size(14.dp),
                tint = CoreViaPrimary
            )
            Text(
                text = "Geri",
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium,
                color = CoreViaPrimary
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// STEP 1: FORM CONTENT
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun RegisterFormContent(
    uiState: RegisterUiState,
    viewModel: RegisterViewModel
) {
    Column(
        modifier = Modifier.padding(bottom = 20.dp),
        verticalArrangement = Arrangement.spacedBy(0.dp)
    ) {
        // ── Title ──
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Qeydiyyat",
                fontSize = 32.sp,
                fontWeight = FontWeight.Black,
                color = MaterialTheme.colorScheme.onBackground
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "CoreVia ailəsinə qoşulun",
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // ── User Type Selection ──
        UserTypeSelection(
            selectedType = uiState.userType,
            onTypeSelected = { viewModel.updateUserType(it) }
        )

        Spacer(modifier = Modifier.height(20.dp))

        // ── Input Fields ──
        Column(
            modifier = Modifier.padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Ad və Soyad
            RegisterInputField(
                icon = Icons.Filled.Person,
                placeholder = "Ad və Soyad",
                value = uiState.name,
                onValueChange = { viewModel.updateName(it) }
            )

            // Email
            RegisterInputField(
                icon = Icons.Filled.Email,
                placeholder = "Email",
                value = uiState.email,
                onValueChange = { viewModel.updateEmail(it) },
                keyboardType = KeyboardType.Email
            )

            // Şifrə
            RegisterSecureField(
                icon = Icons.Filled.Lock,
                placeholder = "Şifrə",
                value = uiState.password,
                onValueChange = { viewModel.updatePassword(it) },
                isVisible = uiState.isPasswordVisible,
                onToggleVisibility = { viewModel.togglePasswordVisibility() }
            )

            // Password strength indicator
            if (uiState.password.isNotEmpty()) {
                PasswordStrengthIndicator(strength = uiState.passwordStrength, text = uiState.strengthText)
            }

            // Şifrə təkrarı
            RegisterSecureField(
                icon = Icons.Filled.Lock,
                placeholder = "Şifrə təkrarı",
                value = uiState.confirmPassword,
                onValueChange = { viewModel.updateConfirmPassword(it) },
                isVisible = uiState.isConfirmPasswordVisible,
                onToggleVisibility = { viewModel.toggleConfirmPasswordVisibility() }
            )

            // Password match indicator
            if (uiState.confirmPassword.isNotEmpty()) {
                PasswordMatchIndicator(match = uiState.passwordsMatch)
            }
        }

        // ── Trainer Extra Fields ──
        if (uiState.isTrainer) {
            Spacer(modifier = Modifier.height(14.dp))
            TrainerExtraFields(
                instagram = uiState.instagram,
                onInstagramChange = { viewModel.updateInstagram(it) },
                selectedSpecialization = uiState.selectedSpecialization,
                onSpecializationChange = { viewModel.updateSpecialization(it) },
                experience = uiState.experience,
                onExperienceChange = { viewModel.updateExperience(it) },
                bio = uiState.bio,
                onBioChange = { viewModel.updateBio(it) }
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── Terms Checkbox ──
        TermsCheckbox(
            accepted = uiState.acceptTerms,
            onToggle = { viewModel.toggleAcceptTerms() }
        )

        Spacer(modifier = Modifier.height(12.dp))

        // ── Error Message ──
        AnimatedVisibility(
            visible = uiState.errorMessage != null,
            enter = slideInVertically() + fadeIn(),
            exit = slideOutVertically() + fadeOut()
        ) {
            Row(
                modifier = Modifier
                    .padding(horizontal = 20.dp)
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(CoreViaError.copy(alpha = 0.1f))
                    .padding(14.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Filled.Warning, null, Modifier.size(18.dp), tint = CoreViaError)
                Text(
                    uiState.errorMessage ?: "",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ── Register / Send OTP Button ──
        Button(
            onClick = { viewModel.sendOTPOrRegister() },
            enabled = !uiState.isLoading && uiState.isFormValid,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp)
                .padding(horizontal = 20.dp)
                .shadow(
                    8.dp,
                    RoundedCornerShape(14.dp),
                    ambientColor = CoreViaPrimary.copy(alpha = 0.4f)
                ),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(
                    color = Color.White,
                    modifier = Modifier.size(24.dp),
                    strokeWidth = 2.dp
                )
            } else {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = if (uiState.isTrainer) "Qeydiyyat" else "OTP Gondar",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Icon(
                        Icons.AutoMirrored.Filled.ArrowForward,
                        null,
                        Modifier.size(20.dp),
                        tint = Color.White
                    )
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// USER TYPE SELECTION — iOS userTypeSelection
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun UserTypeSelection(
    selectedType: String,
    onTypeSelected: (String) -> Unit
) {
    Column(
        modifier = Modifier.padding(horizontal = 20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(
            text = "Hesab novunu secin",
            fontSize = 15.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            RegisterUserTypeCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Person,
                title = "Talaba",
                description = "Mesq ve qida planlari alin",
                isSelected = selectedType == "client",
                onClick = { onTypeSelected("client") }
            )
            RegisterUserTypeCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Groups,
                title = "Muallim",
                description = "Talabalara mesq planlari yaradir",
                isSelected = selectedType == "trainer",
                onClick = { onTypeSelected("trainer") }
            )
        }
    }
}

@Composable
private fun RegisterUserTypeCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    title: String,
    description: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(14.dp))
            .background(
                if (isSelected) CoreViaPrimary.copy(alpha = 0.1f)
                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
            )
            .border(
                width = if (isSelected) 2.dp else 1.dp,
                color = if (isSelected) CoreViaPrimary else TextSeparator,
                shape = RoundedCornerShape(14.dp)
            )
            .clickable(onClick = onClick)
            .padding(vertical = 14.dp, horizontal = 10.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Box(
            modifier = Modifier
                .size(50.dp)
                .clip(CircleShape)
                .background(
                    if (isSelected) CoreViaPrimary.copy(alpha = 0.2f)
                    else MaterialTheme.colorScheme.surfaceVariant
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                icon, null,
                modifier = Modifier.size(20.dp),
                tint = if (isSelected) CoreViaPrimary else TextSecondary
            )
        }

        Text(
            text = title,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold,
            color = if (isSelected) MaterialTheme.colorScheme.onBackground else TextSecondary
        )

        Text(
            text = description,
            fontSize = 10.sp,
            color = TextSecondary,
            textAlign = TextAlign.Center,
            lineHeight = 13.sp,
            maxLines = 2
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// INPUT FIELDS
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun RegisterInputField(
    icon: ImageVector,
    placeholder: String,
    value: String,
    onValueChange: (String) -> Unit,
    keyboardType: KeyboardType = KeyboardType.Text
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        modifier = Modifier.fillMaxWidth(),
        placeholder = { Text(placeholder, color = TextHint) },
        leadingIcon = { Icon(icon, null, Modifier.size(20.dp), tint = CoreViaPrimary) },
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        singleLine = true,
        shape = RoundedCornerShape(12.dp),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = CoreViaPrimary.copy(alpha = 0.5f),
            unfocusedBorderColor = TextSeparator,
            focusedContainerColor = Color(0xFFF8F8F8),
            unfocusedContainerColor = Color(0xFFF8F8F8)
        )
    )
}

@Composable
private fun RegisterSecureField(
    icon: ImageVector,
    placeholder: String,
    value: String,
    onValueChange: (String) -> Unit,
    isVisible: Boolean,
    onToggleVisibility: () -> Unit
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        modifier = Modifier.fillMaxWidth(),
        placeholder = { Text(placeholder, color = TextHint) },
        leadingIcon = { Icon(icon, null, Modifier.size(20.dp), tint = CoreViaPrimary) },
        trailingIcon = {
            IconButton(onClick = onToggleVisibility) {
                Icon(
                    if (isVisible) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                    null, Modifier.size(20.dp), tint = TextSecondary
                )
            }
        },
        visualTransformation = if (isVisible) VisualTransformation.None else PasswordVisualTransformation(),
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
        singleLine = true,
        shape = RoundedCornerShape(12.dp),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = CoreViaPrimary.copy(alpha = 0.5f),
            unfocusedBorderColor = TextSeparator,
            focusedContainerColor = Color(0xFFF8F8F8),
            unfocusedContainerColor = Color(0xFFF8F8F8)
        )
    )
}

// ═══════════════════════════════════════════════════════════════════
// PASSWORD STRENGTH INDICATOR
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun PasswordStrengthIndicator(strength: Int, text: String) {
    val color = when (strength) {
        0, 1 -> CoreViaError
        2 -> CoreViaWarning
        3 -> CoreViaSuccess
        else -> TextSecondary
    }

    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(3.dp)
        ) {
            repeat(3) { index ->
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(3.dp)
                        .clip(RoundedCornerShape(1.5.dp))
                        .background(if (strength > index) color else TextSeparator)
                )
            }
        }
        Text(text = text, fontSize = 11.sp, color = color)
    }
}

@Composable
private fun PasswordMatchIndicator(match: Boolean) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(5.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            if (match) Icons.Filled.CheckCircle else Icons.Filled.Cancel,
            null,
            Modifier.size(12.dp),
            tint = if (match) CoreViaSuccess else CoreViaError
        )
        Text(
            text = if (match) "Sifralar uygunlasir" else "Sifralar uygunlasmir",
            fontSize = 11.sp,
            color = if (match) CoreViaSuccess else CoreViaError
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// TRAINER EXTRA FIELDS — iOS trainerExtraFields
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TrainerExtraFields(
    instagram: String,
    onInstagramChange: (String) -> Unit,
    selectedSpecialization: String,
    onSpecializationChange: (String) -> Unit,
    experience: Int,
    onExperienceChange: (Int) -> Unit,
    bio: String,
    onBioChange: (String) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
        // ── Instagram ──
        Column(
            modifier = Modifier.padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Filled.CameraAlt, null, Modifier.size(13.dp), tint = CoreViaPrimary)
                Text(
                    "Instagram",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }

            OutlinedTextField(
                value = instagram,
                onValueChange = onInstagramChange,
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("instagram_username", color = TextHint) },
                leadingIcon = {
                    Text(
                        "@",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = CoreViaPrimary,
                        modifier = Modifier.padding(start = 14.dp)
                    )
                },
                singleLine = true,
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary.copy(alpha = 0.5f),
                    unfocusedBorderColor = TextSeparator,
                    focusedContainerColor = Color(0xFFF8F8F8),
                    unfocusedContainerColor = Color(0xFFF8F8F8)
                )
            )
        }

        // ── Ixtisas ──
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Row(
                modifier = Modifier.padding(horizontal = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Filled.Star, null, Modifier.size(13.dp), tint = CoreViaPrimary)
                Text(
                    "Ixtisas",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState())
                    .padding(horizontal = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                specializations.forEach { spec ->
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(10.dp))
                            .background(
                                if (selectedSpecialization == spec) CoreViaPrimary
                                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                            )
                            .clickable { onSpecializationChange(spec) }
                            .padding(horizontal = 14.dp, vertical = 8.dp)
                    ) {
                        Text(
                            text = spec,
                            fontSize = 12.sp,
                            fontWeight = if (selectedSpecialization == spec) FontWeight.Bold else FontWeight.Medium,
                            color = if (selectedSpecialization == spec) Color.White
                            else MaterialTheme.colorScheme.onBackground
                        )
                    }
                }
            }
        }

        // ── Tacruba ──
        Column(
            modifier = Modifier.padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Filled.Schedule, null, Modifier.size(13.dp), tint = CoreViaPrimary)
                Text(
                    "Tacruba",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFFF8F8F8))
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(
                    text = "$experience il",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground,
                    modifier = Modifier.width(50.dp)
                )
                Slider(
                    value = experience.toFloat(),
                    onValueChange = { onExperienceChange(it.toInt()) },
                    valueRange = 1f..30f,
                    steps = 28,
                    modifier = Modifier.weight(1f),
                    colors = SliderDefaults.colors(
                        thumbColor = CoreViaPrimary,
                        activeTrackColor = CoreViaPrimary
                    )
                )
            }
        }

        // ── Haqqinizda (Bio) ──
        Column(
            modifier = Modifier.padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.AutoMirrored.Filled.Notes, null, Modifier.size(13.dp), tint = CoreViaPrimary)
                Text(
                    "Haqqinizda",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }

            OutlinedTextField(
                value = bio,
                onValueChange = onBioChange,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp),
                placeholder = { Text("Ozunuz haqqinda qisa melumat yazin...", color = TextHint, fontSize = 14.sp) },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary.copy(alpha = 0.5f),
                    unfocusedBorderColor = TextSeparator,
                    focusedContainerColor = Color(0xFFF8F8F8),
                    unfocusedContainerColor = Color(0xFFF8F8F8)
                )
            )

            Text(
                text = "${bio.length}/500",
                fontSize = 11.sp,
                color = if (bio.length > 500) CoreViaError else TextSecondary,
                modifier = Modifier.fillMaxWidth(),
                textAlign = TextAlign.End
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// TERMS CHECKBOX
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TermsCheckbox(
    accepted: Boolean,
    onToggle: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp)
            .clickable(onClick = onToggle),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(20.dp)
                .clip(RoundedCornerShape(5.dp))
                .border(2.dp, CoreViaPrimary, RoundedCornerShape(5.dp)),
            contentAlignment = Alignment.Center
        ) {
            if (accepted) {
                Icon(
                    Icons.Filled.Check,
                    null,
                    modifier = Modifier.size(12.dp),
                    tint = CoreViaPrimary
                )
            }
        }

        Text(
            text = "Sertlar va qaydalar ile raziyam",
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// STEP 2: OTP VERIFICATION — iOS otpVerificationSection
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun RegisterOTPContent(
    uiState: RegisterUiState,
    viewModel: RegisterViewModel
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(40.dp))

        Text(
            text = "OTP Kodu",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = "${uiState.email} unvanina gonderilen 6 reqemli kodu daxil edin",
            fontSize = 14.sp,
            color = TextSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 30.dp)
        )

        Spacer(modifier = Modifier.height(24.dp))

        // OTP Input
        OutlinedTextField(
            value = uiState.otpCode,
            onValueChange = { viewModel.updateOtpCode(it) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 40.dp),
            placeholder = { Text("000000", color = TextHint) },
            textStyle = LocalTextStyle.current.copy(
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center,
                letterSpacing = 8.sp
            ),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            singleLine = true,
            shape = RoundedCornerShape(14.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = CoreViaPrimary,
                unfocusedBorderColor = Color(0xFFE8E8E8),
                focusedContainerColor = Color(0xFFF8F8F8),
                unfocusedContainerColor = Color(0xFFF8F8F8)
            )
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Error
        AnimatedVisibility(
            visible = uiState.errorMessage != null,
            enter = slideInVertically() + fadeIn(),
            exit = slideOutVertically() + fadeOut()
        ) {
            Row(
                modifier = Modifier
                    .padding(horizontal = 24.dp)
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(CoreViaError.copy(alpha = 0.1f))
                    .padding(14.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Filled.Warning, null, Modifier.size(18.dp), tint = CoreViaError)
                Text(uiState.errorMessage ?: "", fontSize = 13.sp, color = MaterialTheme.colorScheme.onBackground)
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Verify Button
        Button(
            onClick = { viewModel.verifyOTPAndRegister() },
            enabled = !uiState.isLoading && uiState.otpCode.length == 6,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp)
                .padding(horizontal = 20.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(
                    color = Color.White,
                    modifier = Modifier.size(24.dp),
                    strokeWidth = 2.dp
                )
            } else {
                Text(
                    "Tesdiq Et ve Qeydiyyatdan Kec",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Resend OTP
        Text(
            text = "OTP-ni yeniden gonder",
            fontSize = 14.sp,
            color = CoreViaPrimary,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.clickable { viewModel.sendOTPOrRegister() }
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Go back
        Text(
            text = "Geri qayit",
            fontSize = 14.sp,
            color = TextSecondary,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.clickable { viewModel.goBackToForm() }
        )
    }
}
