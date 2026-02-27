package life.corevia.app.ui.onboarding

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.OnboardingOption
import life.corevia.app.ui.theme.*

@Composable
fun OnboardingScreen(
    onComplete: () -> Unit,
    viewModel: OnboardingViewModel = hiltViewModel()
) {
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state.isCompleted) {
        if (state.isCompleted) onComplete()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoreViaBackground)
            .padding(20.dp)
    ) {
        // ── Progress ──
        Spacer(modifier = Modifier.height(40.dp))
        LinearProgressIndicator(
            progress = { state.progress },
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp)),
            color = CoreViaPrimary,
            trackColor = CoreViaPrimary.copy(alpha = 0.15f)
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            "${state.currentStep + 1} / ${state.totalSteps}",
            fontSize = 13.sp,
            color = TextSecondary,
            modifier = Modifier.fillMaxWidth(),
            textAlign = TextAlign.End
        )

        Spacer(modifier = Modifier.height(20.dp))

        // ── Step Content ──
        AnimatedContent(
            targetState = state.currentStep,
            transitionSpec = {
                slideInHorizontally { it } + fadeIn() togetherWith
                        slideOutHorizontally { -it } + fadeOut()
            },
            modifier = Modifier.weight(1f),
            label = "onboarding_step"
        ) { step ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
            ) {
                when (step) {
                    0 -> GoalStep(state, viewModel)
                    1 -> FitnessLevelStep(state, viewModel)
                    2 -> BodyInfoStep(state, viewModel)
                    3 -> TrainerTypeStep(state, viewModel)
                }
            }
        }

        // ── Navigation Buttons ──
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            if (state.currentStep > 0) {
                OutlinedButton(
                    onClick = { viewModel.previousStep() },
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Geri")
                }
            } else {
                Spacer(modifier = Modifier.width(1.dp))
            }

            Button(
                onClick = { viewModel.nextStep() },
                enabled = state.canProceed && !state.isLoading,
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CoreViaPrimary,
                    disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f)
                )
            ) {
                if (state.isLoading) {
                    CircularProgressIndicator(modifier = Modifier.size(20.dp), color = Color.White, strokeWidth = 2.dp)
                } else {
                    Text(if (state.currentStep == state.totalSteps - 1) "Tamamla" else "Davam et")
                    Spacer(modifier = Modifier.width(4.dp))
                    Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = null, modifier = Modifier.size(18.dp))
                }
            }
        }

        state.errorMessage?.let {
            Spacer(modifier = Modifier.height(8.dp))
            Text(it, color = CoreViaError, fontSize = 13.sp, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth())
        }

        Spacer(modifier = Modifier.height(20.dp))
    }
}

// ── Step 0: Goal ──
@Composable
private fun GoalStep(state: OnboardingUiState, viewModel: OnboardingViewModel) {
    StepHeader("Hedefin ne?", "Sene uygun proqram hazirlayaq")
    Spacer(modifier = Modifier.height(20.dp))
    state.goalOptions.forEach { option ->
        OnboardingOptionCard(
            option = option,
            isSelected = state.selectedGoal == option.id,
            onClick = { viewModel.selectGoal(option.id) }
        )
        Spacer(modifier = Modifier.height(10.dp))
    }
}

// ── Step 1: Fitness Level ──
@Composable
private fun FitnessLevelStep(state: OnboardingUiState, viewModel: OnboardingViewModel) {
    StepHeader("Fitness seviyyen?", "Hazirki fiziki veziyet")
    Spacer(modifier = Modifier.height(20.dp))
    state.fitnessLevelOptions.forEach { option ->
        OnboardingOptionCard(
            option = option,
            isSelected = state.selectedFitnessLevel == option.id,
            onClick = { viewModel.selectFitnessLevel(option.id) }
        )
        Spacer(modifier = Modifier.height(10.dp))
    }
}

// ── Step 2: Body Info ──
@Composable
private fun BodyInfoStep(state: OnboardingUiState, viewModel: OnboardingViewModel) {
    StepHeader("Beden olculeriniz", "Daha dəqiq nəticələr ucun")
    Spacer(modifier = Modifier.height(20.dp))

    BodyInfoField("Yas", state.age, viewModel::updateAge, "il")
    Spacer(modifier = Modifier.height(14.dp))
    BodyInfoField("Ceki", state.weight, viewModel::updateWeight, "kg")
    Spacer(modifier = Modifier.height(14.dp))
    BodyInfoField("Boy", state.height, viewModel::updateHeight, "sm")

    // BMI indicator
    state.bmi?.let { bmi ->
        Spacer(modifier = Modifier.height(20.dp))
        Card(
            shape = RoundedCornerShape(14.dp),
            colors = CardDefaults.cardColors(
                containerColor = when {
                    bmi < 18.5 -> CoreViaInfo.copy(alpha = 0.1f)
                    bmi < 25 -> CoreViaSuccess.copy(alpha = 0.1f)
                    bmi < 30 -> CoreViaWarning.copy(alpha = 0.1f)
                    else -> CoreViaError.copy(alpha = 0.1f)
                }
            )
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text("BMI", fontSize = 13.sp, color = TextSecondary)
                    Text("%.1f".format(bmi), fontSize = 22.sp, fontWeight = FontWeight.Bold, color = TextPrimary)
                }
                Text(
                    state.bmiCategory,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = when {
                        bmi < 18.5 -> CoreViaInfo
                        bmi < 25 -> CoreViaSuccess
                        bmi < 30 -> CoreViaWarning
                        else -> CoreViaError
                    }
                )
            }
        }
    }
}

// ── Step 3: Trainer Type ──
@Composable
private fun TrainerTypeStep(state: OnboardingUiState, viewModel: OnboardingViewModel) {
    StepHeader("Trener tipi", "Hansı trener tipini ustun tutursan?")
    Spacer(modifier = Modifier.height(20.dp))
    state.trainerTypeOptions.forEach { option ->
        OnboardingOptionCard(
            option = option,
            isSelected = state.selectedTrainerType == option.id,
            onClick = { viewModel.selectTrainerType(option.id) }
        )
        Spacer(modifier = Modifier.height(10.dp))
    }
}

// ── Shared Components ──

@Composable
private fun StepHeader(title: String, subtitle: String) {
    Text(title, fontSize = 26.sp, fontWeight = FontWeight.Bold, color = TextPrimary)
    Spacer(modifier = Modifier.height(6.dp))
    Text(subtitle, fontSize = 15.sp, color = TextSecondary)
}

@Composable
private fun OnboardingOptionCard(
    option: OnboardingOption,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val borderColor = if (isSelected) CoreViaPrimary else TextSeparator
    val bgColor = if (isSelected) CoreViaPrimary.copy(alpha = 0.08f) else Color.Transparent

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(bgColor)
            .border(
                width = if (isSelected) 2.dp else 1.dp,
                color = borderColor,
                shape = RoundedCornerShape(14.dp)
            )
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Selection indicator
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(if (isSelected) CoreViaPrimary else Color.Transparent)
                .border(2.dp, if (isSelected) CoreViaPrimary else TextSeparator, RoundedCornerShape(12.dp)),
            contentAlignment = Alignment.Center
        ) {
            if (isSelected) {
                Icon(Icons.Filled.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
            }
        }

        Spacer(modifier = Modifier.width(14.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                option.nameAz.ifBlank { option.id },
                fontWeight = FontWeight.SemiBold,
                fontSize = 15.sp,
                color = TextPrimary
            )
        }
    }
}

@Composable
private fun BodyInfoField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    unit: String
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        suffix = { Text(unit, color = TextSecondary) },
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        singleLine = true,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = CoreViaPrimary,
            unfocusedBorderColor = TextSeparator
        )
    )
}
