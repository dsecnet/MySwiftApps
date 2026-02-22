package life.corevia.app.ui.onboarding

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.automirrored.filled.TrendingUp
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch

// ═══════════════════════════════════════════════════════════════════════════════
// CoreVia Onboarding — 5-Step Flow
// CLIENT:  Welcome → Gender → Age → Weight/Height → Goal
// TRAINER: Welcome → Gender → Specialization → Experience/Bio → Confirmation
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
fun OnboardingScreen(
    viewModel: OnboardingViewModel,
    isTrainer: Boolean = false,
    onComplete: () -> Unit
) {
    val currentStep by viewModel.currentStep.collectAsState()
    val data by viewModel.data.collectAsState()
    val uiState by viewModel.uiState.collectAsState()

    // Navigate on success
    LaunchedEffect(uiState) {
        if (uiState is OnboardingUiState.Success) {
            onComplete()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        AppTheme.Colors.background,
                        AppTheme.Colors.secondaryBackground,
                        AppTheme.Colors.background
                    )
                )
            )
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Top bar with back arrow and step indicator (hidden on step 0)
            if (currentStep > 0) {
                OnboardingTopBar(
                    currentStep = currentStep,
                    totalSteps = viewModel.totalSteps,
                    onBack = { viewModel.previousStep() }
                )
            } else {
                Spacer(modifier = Modifier.height(50.dp))
            }

            // Step content
            Box(modifier = Modifier.weight(1f)) {
                AnimatedContent(
                    targetState = currentStep,
                    transitionSpec = {
                        if (targetState > initialState) {
                            slideInHorizontally { it } + fadeIn() togetherWith
                                    slideOutHorizontally { -it } + fadeOut()
                        } else {
                            slideInHorizontally { -it } + fadeIn() togetherWith
                                    slideOutHorizontally { it } + fadeOut()
                        }
                    },
                    label = "stepTransition"
                ) { step ->
                    if (isTrainer) {
                        // TRAINER steps
                        when (step) {
                            0 -> TrainerWelcomeStep(onNext = { viewModel.nextStep() })
                            1 -> GenderStep(
                                selectedGender = data.gender,
                                onGenderSelected = { viewModel.setGender(it) },
                                onNext = { viewModel.nextStep() }
                            )
                            2 -> SpecializationStep(
                                selectedSpecialization = data.specialization,
                                onSpecializationSelected = { viewModel.setSpecialization(it) },
                                onNext = { viewModel.nextStep() }
                            )
                            3 -> ExperienceBioStep(
                                experience = data.experience,
                                bio = data.bio,
                                onExperienceChanged = { viewModel.setExperience(it) },
                                onBioChanged = { viewModel.setBio(it) },
                                onNext = { viewModel.nextStep() }
                            )
                            4 -> TrainerConfirmationStep(
                                onComplete = { viewModel.completeOnboarding() },
                                isLoading = uiState is OnboardingUiState.Loading
                            )
                        }
                    } else {
                        // CLIENT steps (same as before)
                        when (step) {
                            0 -> WelcomeStep(onNext = { viewModel.nextStep() })
                            1 -> GenderStep(
                                selectedGender = data.gender,
                                onGenderSelected = { viewModel.setGender(it) },
                                onNext = { viewModel.nextStep() }
                            )
                            2 -> AgeStep(
                                age = data.age,
                                onAgeChanged = { viewModel.setAge(it) },
                                onNext = { viewModel.nextStep() }
                            )
                            3 -> WeightHeightStep(
                                weight = data.weight,
                                height = data.height,
                                onWeightChanged = { viewModel.setWeight(it) },
                                onHeightChanged = { viewModel.setHeight(it) },
                                onNext = { viewModel.nextStep() }
                            )
                            4 -> GoalStep(
                                selectedGoal = data.fitnessGoal,
                                onGoalSelected = { viewModel.setFitnessGoal(it) },
                                onComplete = { viewModel.completeOnboarding() },
                                isLoading = uiState is OnboardingUiState.Loading
                            )
                        }
                    }
                }
            }
        }

        // Loading overlay
        if (uiState is OnboardingUiState.Loading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.4f)),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = AppTheme.Colors.accent)
            }
        }
    }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────
@Composable
private fun OnboardingTopBar(
    currentStep: Int,
    totalSteps: Int,
    onBack: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 50.dp, start = 16.dp, end = 16.dp, bottom = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Back button
        IconButton(onClick = onBack) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Geri",
                tint = AppTheme.Colors.primaryText,
                modifier = Modifier.size(24.dp)
            )
        }

        Spacer(modifier = Modifier.width(8.dp))

        // Step indicator dots
        Row(
            modifier = Modifier.weight(1f),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            for (i in 0 until totalSteps) {
                Box(
                    modifier = Modifier
                        .padding(horizontal = 3.dp)
                        .size(
                            width = if (i == currentStep) 24.dp else 8.dp,
                            height = 8.dp
                        )
                        .clip(CircleShape)
                        .background(
                            if (i < currentStep) AppTheme.Colors.accent
                            else if (i == currentStep) AppTheme.Colors.accent
                            else AppTheme.Colors.separator
                        )
                )
            }
        }

        // Spacer to balance the back button
        Spacer(modifier = Modifier.width(48.dp))
    }
}

// ─── Gradient Button ─────────────────────────────────────────────────────────
@Composable
private fun GradientButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    showArrow: Boolean = false
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .clip(RoundedCornerShape(16.dp))
            .then(
                if (enabled) {
                    Modifier
                        .background(
                            Brush.horizontalGradient(
                                colors = listOf(
                                    AppTheme.Colors.accent,
                                    AppTheme.Colors.accentDark
                                )
                            )
                        )
                        .clickable { onClick() }
                } else {
                    Modifier.background(AppTheme.Colors.separator)
                }
            ),
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            Text(
                text = text,
                color = if (enabled) Color.White else AppTheme.Colors.tertiaryText,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold
            )
            if (showArrow) {
                Spacer(modifier = Modifier.width(8.dp))
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                    contentDescription = null,
                    tint = if (enabled) Color.White else AppTheme.Colors.tertiaryText,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 0 — Welcome (3-slide pager)
// ═══════════════════════════════════════════════════════════════════════════════

private data class WelcomeSlide(
    val title: String,
    val description: String,
    val icon: ImageVector
)

@Composable
private fun WelcomeStep(onNext: () -> Unit) {
    val slides = listOf(
        WelcomeSlide(
            title = "Müəlliminizi tapın,\nsəyahətinizə başlayın",
            description = "Peşəkar müəllimlərlə əlaqə qurun və fitnes hədəflərinizə çatın.",
            icon = Icons.Outlined.People
        ),
        WelcomeSlide(
            title = "Formda qalmaq üçün\nplan yaradın",
            description = "Şəxsi məşq və qida planları ilə sağlam həyat tərzi qurun.",
            icon = Icons.Outlined.FitnessCenter
        ),
        WelcomeSlide(
            title = "Hərəkət bütün\nuğurların açarıdır",
            description = "Hər addımınızı izləyin, irəliləyişinizi görün və motivasiya olun.",
            icon = Icons.Outlined.RocketLaunch
        )
    )

    val pagerState = rememberPagerState(pageCount = { slides.size })
    val coroutineScope = rememberCoroutineScope()

    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Pager
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.weight(1f)
        ) { page ->
            WelcomeSlideContent(slides[page])
        }

        // Page dots
        Row(
            modifier = Modifier.padding(bottom = 24.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            slides.indices.forEach { index ->
                Box(
                    modifier = Modifier
                        .size(
                            width = if (index == pagerState.currentPage) 24.dp else 8.dp,
                            height = 8.dp
                        )
                        .clip(CircleShape)
                        .background(
                            if (index == pagerState.currentPage) AppTheme.Colors.accent
                            else AppTheme.Colors.separator
                        )
                )
            }
        }

        // Bottom button
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 40.dp)
        ) {
            if (pagerState.currentPage == slides.size - 1) {
                GradientButton(
                    text = "İndi Başla",
                    onClick = onNext
                )
            } else {
                GradientButton(
                    text = "Növbəti",
                    showArrow = true,
                    onClick = {
                        coroutineScope.launch {
                            pagerState.animateScrollToPage(pagerState.currentPage + 1)
                        }
                    }
                )
            }
        }
    }
}

@Composable
private fun WelcomeSlideContent(slide: WelcomeSlide) {
    val infiniteTransition = rememberInfiniteTransition(label = "welcome")
    val iconScale by infiniteTransition.animateFloat(
        initialValue = 0.95f,
        targetValue = 1.05f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = EaseInOutSine),
            repeatMode = RepeatMode.Reverse
        ),
        label = "iconScale"
    )
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.08f,
        targetValue = 0.18f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = EaseInOutSine),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glowAlpha"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Animated icon with glow
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(160.dp)
        ) {
            // Outer glow
            Box(
                modifier = Modifier
                    .size(140.dp)
                    .scale(iconScale)
                    .background(
                        AppTheme.Colors.accent.copy(alpha = glowAlpha),
                        CircleShape
                    )
            )
            // Inner circle
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .background(
                        AppTheme.Colors.accent.copy(alpha = 0.15f),
                        CircleShape
                    )
            )
            // Icon
            Icon(
                imageVector = slide.icon,
                contentDescription = null,
                tint = AppTheme.Colors.accent,
                modifier = Modifier
                    .size(48.dp)
                    .scale(iconScale)
            )
        }

        Spacer(modifier = Modifier.height(40.dp))

        Text(
            text = slide.title,
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center,
            lineHeight = 36.sp
        )

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = slide.description,
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center,
            lineHeight = 24.sp
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 1 — Gender Selection
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
private fun GenderStep(
    selectedGender: String?,
    onGenderSelected: (String) -> Unit,
    onNext: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "Özünüz haqqında danışın",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Cinsinizi seçin",
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(48.dp))

        // Gender cards
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            GenderCard(
                label = "Kişi",
                icon = Icons.Outlined.Male,
                isSelected = selectedGender == "male",
                onClick = { onGenderSelected("male") },
                modifier = Modifier.weight(1f)
            )
            GenderCard(
                label = "Qadın",
                icon = Icons.Outlined.Female,
                isSelected = selectedGender == "female",
                onClick = { onGenderSelected("female") },
                modifier = Modifier.weight(1f)
            )
        }

        Spacer(modifier = Modifier.weight(1f))

        // Next button
        GradientButton(
            text = "Növbəti",
            showArrow = true,
            enabled = selectedGender != null,
            onClick = onNext,
            modifier = Modifier.padding(bottom = 40.dp)
        )
    }
}

@Composable
private fun GenderCard(
    label: String,
    icon: ImageVector,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val borderColor = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.separator
    val bgColor = if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.1f) else AppTheme.Colors.cardBackground

    Box(
        modifier = modifier
            .aspectRatio(0.85f)
            .clip(RoundedCornerShape(20.dp))
            .then(
                if (isSelected) {
                    Modifier.border(
                        width = 2.dp,
                        brush = Brush.linearGradient(
                            colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                        ),
                        shape = RoundedCornerShape(20.dp)
                    )
                } else {
                    Modifier.border(
                        width = 1.dp,
                        color = AppTheme.Colors.separator,
                        shape = RoundedCornerShape(20.dp)
                    )
                }
            )
            .background(bgColor)
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Icon circle
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .background(
                        if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.15f)
                        else AppTheme.Colors.secondaryBackground,
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = label,
                    tint = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.secondaryText,
                    modifier = Modifier.size(40.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = label,
                fontSize = 20.sp,
                fontWeight = FontWeight.SemiBold,
                color = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.primaryText
            )

            // Selected checkmark
            if (isSelected) {
                Spacer(modifier = Modifier.height(8.dp))
                Box(
                    modifier = Modifier
                        .size(24.dp)
                        .background(AppTheme.Colors.accent, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.Check,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 2 — Age Picker
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
private fun AgeStep(
    age: Int,
    onAgeChanged: (Int) -> Unit,
    onNext: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "Neçə yaşınız var?",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Yaşınız planınızın hazırlanmasına kömək edəcək",
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.weight(0.3f))

        // Large age display
        Text(
            text = "$age",
            fontSize = 72.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.accent
        )

        Text(
            text = "yaş",
            fontSize = 18.sp,
            color = AppTheme.Colors.secondaryText,
            modifier = Modifier.padding(top = 4.dp)
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Plus/Minus buttons
        Row(
            horizontalArrangement = Arrangement.spacedBy(24.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Minus
            IconButton(
                onClick = { if (age > 12) onAgeChanged(age - 1) },
                modifier = Modifier
                    .size(56.dp)
                    .background(AppTheme.Colors.cardBackground, CircleShape)
                    .border(1.dp, AppTheme.Colors.separator, CircleShape)
            ) {
                Icon(
                    imageVector = Icons.Filled.Remove,
                    contentDescription = "Azalt",
                    tint = AppTheme.Colors.primaryText,
                    modifier = Modifier.size(28.dp)
                )
            }

            // Age scroll picker
            Box(
                modifier = Modifier
                    .width(100.dp)
                    .height(200.dp)
            ) {
                val listState = rememberLazyListState()
                val ages = (12..80).toList()
                val initialIndex = ages.indexOf(age).coerceAtLeast(0)

                LaunchedEffect(Unit) {
                    listState.scrollToItem(
                        index = (initialIndex - 2).coerceAtLeast(0)
                    )
                }

                LazyColumn(
                    state = listState,
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    itemsIndexed(ages) { _, ageValue ->
                        val isSelected = ageValue == age
                        Text(
                            text = "$ageValue",
                            fontSize = if (isSelected) 32.sp else 20.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                            color = if (isSelected) AppTheme.Colors.accent
                            else AppTheme.Colors.tertiaryText,
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { onAgeChanged(ageValue) }
                                .padding(vertical = 8.dp),
                            textAlign = TextAlign.Center
                        )
                    }
                }

                // Top/bottom fade indicators
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(40.dp)
                        .align(Alignment.TopCenter)
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    AppTheme.Colors.background,
                                    Color.Transparent
                                )
                            )
                        )
                )
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(40.dp)
                        .align(Alignment.BottomCenter)
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    Color.Transparent,
                                    AppTheme.Colors.background
                                )
                            )
                        )
                )
            }

            // Plus
            IconButton(
                onClick = { if (age < 80) onAgeChanged(age + 1) },
                modifier = Modifier
                    .size(56.dp)
                    .background(AppTheme.Colors.cardBackground, CircleShape)
                    .border(1.dp, AppTheme.Colors.separator, CircleShape)
            ) {
                Icon(
                    imageVector = Icons.Filled.Add,
                    contentDescription = "Artır",
                    tint = AppTheme.Colors.primaryText,
                    modifier = Modifier.size(28.dp)
                )
            }
        }

        Spacer(modifier = Modifier.weight(0.5f))

        // Next button
        GradientButton(
            text = "Növbəti",
            showArrow = true,
            onClick = onNext,
            modifier = Modifier.padding(bottom = 40.dp)
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 3 — Weight & Height
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
private fun WeightHeightStep(
    weight: Int,
    height: Int,
    onWeightChanged: (Int) -> Unit,
    onHeightChanged: (Int) -> Unit,
    onNext: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "Çəkiniz nə qədərdir?",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Ölçüləriniz şəxsi planınız üçün lazımdır",
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(40.dp))

        // Weight section
        ValuePickerCard(
            label = "Çəki",
            value = weight,
            unit = "kg",
            minValue = 30,
            maxValue = 200,
            onValueChanged = onWeightChanged
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Height section
        Text(
            text = "Boyunuz",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(16.dp))

        ValuePickerCard(
            label = "Boy",
            value = height,
            unit = "cm",
            minValue = 120,
            maxValue = 220,
            onValueChanged = onHeightChanged
        )

        Spacer(modifier = Modifier.height(40.dp))

        // Next button
        GradientButton(
            text = "Növbəti",
            showArrow = true,
            onClick = onNext,
            modifier = Modifier.padding(bottom = 40.dp)
        )
    }
}

@Composable
private fun ValuePickerCard(
    label: String,
    value: Int,
    unit: String,
    minValue: Int,
    maxValue: Int,
    onValueChanged: (Int) -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(AppTheme.Colors.cardBackground)
            .border(1.dp, AppTheme.Colors.separator, RoundedCornerShape(20.dp))
            .padding(vertical = 24.dp, horizontal = 16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Minus button
            IconButton(
                onClick = { if (value > minValue) onValueChanged(value - 1) },
                modifier = Modifier
                    .size(48.dp)
                    .background(AppTheme.Colors.secondaryBackground, CircleShape)
                    .border(1.dp, AppTheme.Colors.separator, CircleShape)
            ) {
                Icon(
                    imageVector = Icons.Filled.Remove,
                    contentDescription = "Azalt",
                    tint = AppTheme.Colors.primaryText,
                    modifier = Modifier.size(24.dp)
                )
            }

            // Value display
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        text = "$value",
                        fontSize = 48.sp,
                        fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.accent
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = unit,
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Medium,
                        color = AppTheme.Colors.secondaryText,
                        modifier = Modifier.padding(bottom = 8.dp)
                    )
                }

                // Ruler-style indicator
                Row(
                    horizontalArrangement = Arrangement.Center,
                    modifier = Modifier.padding(top = 8.dp)
                ) {
                    for (i in -4..4) {
                        val tickHeight = when {
                            i == 0 -> 20.dp
                            i % 2 == 0 -> 14.dp
                            else -> 8.dp
                        }
                        val tickColor = if (i == 0) AppTheme.Colors.accent
                        else AppTheme.Colors.separator
                        Box(
                            modifier = Modifier
                                .padding(horizontal = 3.dp)
                                .width(2.dp)
                                .height(tickHeight)
                                .background(tickColor, RoundedCornerShape(1.dp))
                        )
                    }
                }
            }

            // Plus button
            IconButton(
                onClick = { if (value < maxValue) onValueChanged(value + 1) },
                modifier = Modifier
                    .size(48.dp)
                    .background(AppTheme.Colors.secondaryBackground, CircleShape)
                    .border(1.dp, AppTheme.Colors.separator, CircleShape)
            ) {
                Icon(
                    imageVector = Icons.Filled.Add,
                    contentDescription = "Artır",
                    tint = AppTheme.Colors.primaryText,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP 4 — Goal Selection
// ═══════════════════════════════════════════════════════════════════════════════

private data class GoalOption(
    val key: String,
    val label: String,
    val description: String,
    val icon: ImageVector
)

@Composable
private fun GoalStep(
    selectedGoal: String?,
    onGoalSelected: (String) -> Unit,
    onComplete: () -> Unit,
    isLoading: Boolean
) {
    val goals = listOf(
        GoalOption(
            key = "gain_weight",
            label = "Kilo almaq",
            description = "Əzələ kütləsi artırmaq",
            icon = Icons.AutoMirrored.Filled.TrendingUp
        ),
        GoalOption(
            key = "lose_weight",
            label = "Arıqlamaq",
            description = "Yağ kütləsini azaltmaq",
            icon = Icons.Filled.TrendingDown
        ),
        GoalOption(
            key = "stay_fit",
            label = "Formda qalmaq",
            description = "Ümumi sağlamlığı yaxşılaşdırmaq",
            icon = Icons.Outlined.FitnessCenter
        ),
        GoalOption(
            key = "flexibility",
            label = "Çeviklik",
            description = "Elastiklik və hərəkət azadlığı",
            icon = Icons.Outlined.SelfImprovement
        ),
        GoalOption(
            key = "learn_basics",
            label = "Əsas məşqlər",
            description = "Fitnesin əsaslarını öyrənmək",
            icon = Icons.Outlined.School
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "Məqsədiniz nədir?",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Bir məqsəd seçin, biz sizə uyğun plan hazırlayaq",
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Goal cards
        goals.forEach { goal ->
            GoalCard(
                goal = goal,
                isSelected = selectedGoal == goal.key,
                onClick = { onGoalSelected(goal.key) }
            )
            Spacer(modifier = Modifier.height(12.dp))
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Complete button
        GradientButton(
            text = "Tamamla",
            enabled = selectedGoal != null && !isLoading,
            onClick = onComplete,
            modifier = Modifier.padding(bottom = 40.dp)
        )
    }
}

@Composable
private fun GoalCard(
    goal: GoalOption,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .then(
                if (isSelected) {
                    Modifier.border(
                        width = 2.dp,
                        brush = Brush.linearGradient(
                            colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                        ),
                        shape = RoundedCornerShape(16.dp)
                    )
                } else {
                    Modifier.border(
                        width = 1.dp,
                        color = AppTheme.Colors.separator,
                        shape = RoundedCornerShape(16.dp)
                    )
                }
            )
            .background(
                if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.08f)
                else AppTheme.Colors.cardBackground
            )
            .clickable { onClick() }
            .padding(16.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
        ) {
            // Icon
            Box(
                modifier = Modifier
                    .size(50.dp)
                    .background(
                        if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.15f)
                        else AppTheme.Colors.secondaryBackground,
                        RoundedCornerShape(14.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = goal.icon,
                    contentDescription = null,
                    tint = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.secondaryText,
                    modifier = Modifier.size(26.dp)
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            // Text
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = goal.label,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.primaryText
                )
                Text(
                    text = goal.description,
                    fontSize = 13.sp,
                    color = AppTheme.Colors.secondaryText
                )
            }

            // Selection indicator
            if (isSelected) {
                Box(
                    modifier = Modifier
                        .size(24.dp)
                        .background(AppTheme.Colors.accent, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.Check,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(14.dp)
                    )
                }
            } else {
                Box(
                    modifier = Modifier
                        .size(24.dp)
                        .border(2.dp, AppTheme.Colors.separator, CircleShape)
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TRAINER STEP 0 — Welcome (3-slide pager with trainer-specific text)
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
private fun TrainerWelcomeStep(onNext: () -> Unit) {
    val slides = listOf(
        WelcomeSlide(
            title = "Tələbələrinizi\nidarə edin",
            description = "Tələbələrinizlə əlaqə qurun və onlara yol göstərin.",
            icon = Icons.Outlined.People
        ),
        WelcomeSlide(
            title = "Plan yaradın,\nnəticə əldə edin",
            description = "Şəxsi məşq və qida planları hazırlayın.",
            icon = Icons.Outlined.Assignment
        ),
        WelcomeSlide(
            title = "Peşəkar müəllim\nkimi inkişaf edin",
            description = "Müəllim profilinizi yaradın və karyeranızı qurun.",
            icon = Icons.Outlined.Star
        )
    )

    val pagerState = rememberPagerState(pageCount = { slides.size })
    val coroutineScope = rememberCoroutineScope()

    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Pager
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.weight(1f)
        ) { page ->
            WelcomeSlideContent(slides[page])
        }

        // Page dots
        Row(
            modifier = Modifier.padding(bottom = 24.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            slides.indices.forEach { index ->
                Box(
                    modifier = Modifier
                        .size(
                            width = if (index == pagerState.currentPage) 24.dp else 8.dp,
                            height = 8.dp
                        )
                        .clip(CircleShape)
                        .background(
                            if (index == pagerState.currentPage) AppTheme.Colors.accent
                            else AppTheme.Colors.separator
                        )
                )
            }
        }

        // Bottom button
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 40.dp)
        ) {
            if (pagerState.currentPage == slides.size - 1) {
                GradientButton(
                    text = "İndi Başla",
                    onClick = onNext
                )
            } else {
                GradientButton(
                    text = "Növbəti",
                    showArrow = true,
                    onClick = {
                        coroutineScope.launch {
                            pagerState.animateScrollToPage(pagerState.currentPage + 1)
                        }
                    }
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TRAINER STEP 2 — Specialization Picker
// ═══════════════════════════════════════════════════════════════════════════════

private data class SpecializationOption(
    val key: String,
    val label: String,
    val description: String,
    val icon: ImageVector
)

@Composable
private fun SpecializationStep(
    selectedSpecialization: String?,
    onSpecializationSelected: (String) -> Unit,
    onNext: () -> Unit
) {
    val specializations = listOf(
        SpecializationOption(
            key = "fitness",
            label = "Fitness",
            description = "Ümumi fitness məşqləri",
            icon = Icons.Outlined.FitnessCenter
        ),
        SpecializationOption(
            key = "yoga",
            label = "Yoga",
            description = "Yoga və meditasiya",
            icon = Icons.Outlined.SelfImprovement
        ),
        SpecializationOption(
            key = "cardio",
            label = "Kardio",
            description = "Kardio və dayanıqlılıq",
            icon = Icons.Outlined.DirectionsRun
        ),
        SpecializationOption(
            key = "nutrition",
            label = "Qidalanma",
            description = "Diyet və qidalanma planları",
            icon = Icons.Outlined.Restaurant
        ),
        SpecializationOption(
            key = "strength",
            label = "Güc",
            description = "Güc məşqləri",
            icon = Icons.Outlined.FitnessCenter
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "İxtisasınız nədir?",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Sizin ixtisas sahənizi seçin",
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Specialization cards (same style as GoalStep)
        specializations.forEach { spec ->
            SpecializationCard(
                specialization = spec,
                isSelected = selectedSpecialization == spec.key,
                onClick = { onSpecializationSelected(spec.key) }
            )
            Spacer(modifier = Modifier.height(12.dp))
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Next button
        GradientButton(
            text = "Növbəti",
            showArrow = true,
            enabled = selectedSpecialization != null,
            onClick = onNext,
            modifier = Modifier.padding(bottom = 40.dp)
        )
    }
}

@Composable
private fun SpecializationCard(
    specialization: SpecializationOption,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .then(
                if (isSelected) {
                    Modifier.border(
                        width = 2.dp,
                        brush = Brush.linearGradient(
                            colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                        ),
                        shape = RoundedCornerShape(16.dp)
                    )
                } else {
                    Modifier.border(
                        width = 1.dp,
                        color = AppTheme.Colors.separator,
                        shape = RoundedCornerShape(16.dp)
                    )
                }
            )
            .background(
                if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.08f)
                else AppTheme.Colors.cardBackground
            )
            .clickable { onClick() }
            .padding(16.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
        ) {
            // Icon
            Box(
                modifier = Modifier
                    .size(50.dp)
                    .background(
                        if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.15f)
                        else AppTheme.Colors.secondaryBackground,
                        RoundedCornerShape(14.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = specialization.icon,
                    contentDescription = null,
                    tint = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.secondaryText,
                    modifier = Modifier.size(26.dp)
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            // Text
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = specialization.label,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.primaryText
                )
                Text(
                    text = specialization.description,
                    fontSize = 13.sp,
                    color = AppTheme.Colors.secondaryText
                )
            }

            // Selection indicator
            if (isSelected) {
                Box(
                    modifier = Modifier
                        .size(24.dp)
                        .background(AppTheme.Colors.accent, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.Check,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(14.dp)
                    )
                }
            } else {
                Box(
                    modifier = Modifier
                        .size(24.dp)
                        .border(2.dp, AppTheme.Colors.separator, CircleShape)
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TRAINER STEP 3 — Experience & Bio
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
private fun ExperienceBioStep(
    experience: Int,
    bio: String,
    onExperienceChanged: (Int) -> Unit,
    onBioChanged: (String) -> Unit,
    onNext: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "Təcrübəniz haqqında",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Təcrübəniz və özünüz haqqında məlumat verin",
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Experience display
        Text(
            text = "$experience",
            fontSize = 72.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.accent
        )

        Text(
            text = "il təcrübə",
            fontSize = 18.sp,
            color = AppTheme.Colors.secondaryText,
            modifier = Modifier.padding(top = 4.dp)
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Plus/Minus buttons for experience
        Row(
            horizontalArrangement = Arrangement.spacedBy(24.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Minus
            IconButton(
                onClick = { if (experience > 1) onExperienceChanged(experience - 1) },
                modifier = Modifier
                    .size(56.dp)
                    .background(AppTheme.Colors.cardBackground, CircleShape)
                    .border(1.dp, AppTheme.Colors.separator, CircleShape)
            ) {
                Icon(
                    imageVector = Icons.Filled.Remove,
                    contentDescription = "Azalt",
                    tint = AppTheme.Colors.primaryText,
                    modifier = Modifier.size(28.dp)
                )
            }

            // Experience scroll picker
            Box(
                modifier = Modifier
                    .width(100.dp)
                    .height(200.dp)
            ) {
                val listState = rememberLazyListState()
                val years = (1..30).toList()
                val initialIndex = years.indexOf(experience).coerceAtLeast(0)

                LaunchedEffect(Unit) {
                    listState.scrollToItem(
                        index = (initialIndex - 2).coerceAtLeast(0)
                    )
                }

                LazyColumn(
                    state = listState,
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    itemsIndexed(years) { _, yearValue ->
                        val isSelected = yearValue == experience
                        Text(
                            text = "$yearValue",
                            fontSize = if (isSelected) 32.sp else 20.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                            color = if (isSelected) AppTheme.Colors.accent
                            else AppTheme.Colors.tertiaryText,
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { onExperienceChanged(yearValue) }
                                .padding(vertical = 8.dp),
                            textAlign = TextAlign.Center
                        )
                    }
                }

                // Top/bottom fade indicators
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(40.dp)
                        .align(Alignment.TopCenter)
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    AppTheme.Colors.background,
                                    Color.Transparent
                                )
                            )
                        )
                )
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(40.dp)
                        .align(Alignment.BottomCenter)
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    Color.Transparent,
                                    AppTheme.Colors.background
                                )
                            )
                        )
                )
            }

            // Plus
            IconButton(
                onClick = { if (experience < 30) onExperienceChanged(experience + 1) },
                modifier = Modifier
                    .size(56.dp)
                    .background(AppTheme.Colors.cardBackground, CircleShape)
                    .border(1.dp, AppTheme.Colors.separator, CircleShape)
            ) {
                Icon(
                    imageVector = Icons.Filled.Add,
                    contentDescription = "Artır",
                    tint = AppTheme.Colors.primaryText,
                    modifier = Modifier.size(28.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Bio text field
        OutlinedTextField(
            value = bio,
            onValueChange = { if (it.length <= 500) onBioChanged(it) },
            label = { Text("Haqqınızda") },
            placeholder = { Text("Tələbələriniz sizi daha yaxşı tanısın...") },
            modifier = Modifier
                .fillMaxWidth()
                .height(150.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = AppTheme.Colors.primaryText,
                unfocusedTextColor = AppTheme.Colors.primaryText,
                focusedBorderColor = AppTheme.Colors.accent,
                unfocusedBorderColor = AppTheme.Colors.separator,
                cursorColor = AppTheme.Colors.accent,
                focusedLabelColor = AppTheme.Colors.accent,
                unfocusedLabelColor = AppTheme.Colors.secondaryText,
                focusedPlaceholderColor = AppTheme.Colors.tertiaryText,
                unfocusedPlaceholderColor = AppTheme.Colors.tertiaryText,
                focusedContainerColor = AppTheme.Colors.cardBackground,
                unfocusedContainerColor = AppTheme.Colors.cardBackground
            ),
            shape = RoundedCornerShape(16.dp),
            maxLines = 5
        )

        // Character count
        Text(
            text = "${bio.length}/500",
            fontSize = 12.sp,
            color = AppTheme.Colors.tertiaryText,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp, end = 4.dp),
            textAlign = TextAlign.End
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Next button
        GradientButton(
            text = "Növbəti",
            showArrow = true,
            onClick = onNext,
            modifier = Modifier.padding(bottom = 40.dp)
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TRAINER STEP 4 — Confirmation / Complete
// ═══════════════════════════════════════════════════════════════════════════════

@Composable
private fun TrainerConfirmationStep(
    onComplete: () -> Unit,
    isLoading: Boolean
) {
    val infiniteTransition = rememberInfiniteTransition(label = "confirmation")
    val iconScale by infiniteTransition.animateFloat(
        initialValue = 0.95f,
        targetValue = 1.05f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = EaseInOutSine),
            repeatMode = RepeatMode.Reverse
        ),
        label = "iconScale"
    )
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.08f,
        targetValue = 0.18f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = EaseInOutSine),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glowAlpha"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Spacer(modifier = Modifier.weight(0.3f))

        // Animated icon with glow
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(160.dp)
        ) {
            // Outer glow
            Box(
                modifier = Modifier
                    .size(140.dp)
                    .scale(iconScale)
                    .background(
                        AppTheme.Colors.accent.copy(alpha = glowAlpha),
                        CircleShape
                    )
            )
            // Inner circle
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .background(
                        AppTheme.Colors.accent.copy(alpha = 0.15f),
                        CircleShape
                    )
            )
            // Icon
            Icon(
                imageVector = Icons.Outlined.CheckCircle,
                contentDescription = null,
                tint = AppTheme.Colors.accent,
                modifier = Modifier
                    .size(48.dp)
                    .scale(iconScale)
            )
        }

        Spacer(modifier = Modifier.height(40.dp))

        Text(
            text = "Hər şey hazırdır!",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = "Müəllim profiliniz yaradılmağa hazırdır.\nTələbələrinizlə əlaqə qurmağa başlayın.",
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center,
            lineHeight = 24.sp
        )

        Spacer(modifier = Modifier.weight(0.5f))

        // Complete button
        GradientButton(
            text = "Tamamla",
            enabled = !isLoading,
            onClick = onComplete,
            modifier = Modifier.padding(bottom = 40.dp)
        )
    }
}
