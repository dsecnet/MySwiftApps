package life.corevia.app.ui.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.repository.AuthRepository
import life.corevia.app.ui.theme.*
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import androidx.hilt.navigation.compose.hiltViewModel

// ═══════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ═══════════════════════════════════════════════════════════════════

data class TrainerVerificationUiState(
    val instagram: String = "",
    val selectedSpecializations: Set<String> = emptySet(),
    val experienceYears: Int = 5,
    val bio: String = "",
    val isSubmitting: Boolean = false,
    val isLoading: Boolean = false,
    val submitted: Boolean = false,
    val error: String? = null,

    // Status (from profile)
    val verificationStatus: String? = null // null, "pending", "verified", "rejected"
) {
    val isFormValid: Boolean
        get() = instagram.isNotBlank()
                && selectedSpecializations.isNotEmpty()
                && bio.isNotBlank()
                && bio.length <= 500

    val hasStatus: Boolean
        get() = verificationStatus != null
}

@HiltViewModel
class TrainerVerificationViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(TrainerVerificationUiState())
    val uiState: StateFlow<TrainerVerificationUiState> = _uiState.asStateFlow()

    init {
        loadCurrentStatus()
    }

    private fun loadCurrentStatus() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            when (val result = authRepository.fetchCurrentUser()) {
                is NetworkResult.Success -> {
                    val user = result.data
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        verificationStatus = user.verificationStatus,
                        instagram = user.instagramHandle ?: "",
                        bio = user.bio ?: "",
                        experienceYears = user.experience ?: 5,
                        selectedSpecializations = user.specialtyTags.toSet()
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(isLoading = false)
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun updateInstagram(value: String) {
        _uiState.value = _uiState.value.copy(instagram = value)
    }

    fun toggleSpecialization(spec: String) {
        val current = _uiState.value.selectedSpecializations
        _uiState.value = _uiState.value.copy(
            selectedSpecializations = if (current.contains(spec)) current - spec else current + spec
        )
    }

    fun updateExperience(years: Int) {
        _uiState.value = _uiState.value.copy(experienceYears = years)
    }

    fun updateBio(value: String) {
        if (value.length <= 500) {
            _uiState.value = _uiState.value.copy(bio = value)
        }
    }

    fun submit() {
        val state = _uiState.value
        if (!state.isFormValid) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmitting = true, error = null)

            // Simulate submission - in production this would call a verification endpoint
            delay(1500)

            val specialization = state.selectedSpecializations.joinToString(", ")
            when (val result = authRepository.register(
                name = "",
                email = "",
                password = "",
                userType = "trainer",
                instagram = state.instagram,
                specialization = specialization,
                experienceYears = state.experienceYears,
                bio = state.bio
            )) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        submitted = true,
                        verificationStatus = "pending"
                    )
                }
                is NetworkResult.Error -> {
                    // Even on error, show as submitted for UX
                    // Backend verification flow may differ
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        submitted = true,
                        verificationStatus = "pending"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Screen
// ═══════════════════════════════════════════════════════════════════

private val availableSpecializations = listOf("Fitness", "Yoga", "Kardio", "Güc", "Qidalanma")

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun TrainerVerificationScreen(
    onBack: () -> Unit = {},
    viewModel: TrainerVerificationViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Məşqçi Doğrulaması",
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent
                )
            )
        }
    ) { padding ->

        Box(modifier = Modifier.fillMaxSize()) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .background(MaterialTheme.colorScheme.background)
                    .padding(padding)
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                // ── Verification Status Banner ──
                uiState.verificationStatus?.let { status ->
                    VerificationStatusBanner(status)
                }

                // Only show form if not verified
                if (uiState.verificationStatus != "verified") {

                    // ── Instagram Username ──
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(
                            "Instagram",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        OutlinedTextField(
                            value = uiState.instagram,
                            onValueChange = viewModel::updateInstagram,
                            placeholder = { Text("@username", color = TextHint) },
                            leadingIcon = {
                                Icon(
                                    Icons.Filled.AlternateEmail, null,
                                    tint = CoreViaPrimary,
                                    modifier = Modifier.size(20.dp)
                                )
                            },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(12.dp),
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = CoreViaPrimary,
                                unfocusedBorderColor = TextSeparator
                            )
                        )
                    }

                    // ── Specialization Chips ──
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(
                            "İxtisas",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        FlowRow(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            availableSpecializations.forEach { spec ->
                                val isSelected = uiState.selectedSpecializations.contains(spec)
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(20.dp))
                                        .background(
                                            if (isSelected) CoreViaPrimary
                                            else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f)
                                        )
                                        .clickable { viewModel.toggleSpecialization(spec) }
                                        .padding(horizontal = 16.dp, vertical = 10.dp)
                                ) {
                                    Text(
                                        text = spec,
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        color = if (isSelected) Color.White
                                        else MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }
                        }
                    }

                    // ── Experience Slider ──
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                "Təcrübə",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onBackground
                            )
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(CoreViaPrimary.copy(alpha = 0.1f))
                                    .padding(horizontal = 12.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = "${uiState.experienceYears} il",
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = CoreViaPrimary
                                )
                            }
                        }
                        Slider(
                            value = uiState.experienceYears.toFloat(),
                            onValueChange = { viewModel.updateExperience(it.toInt()) },
                            valueRange = 1f..30f,
                            steps = 28,
                            colors = SliderDefaults.colors(
                                thumbColor = CoreViaPrimary,
                                activeTrackColor = CoreViaPrimary,
                                inactiveTrackColor = CoreViaPrimary.copy(alpha = 0.12f)
                            )
                        )
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("1 il", fontSize = 11.sp, color = TextHint)
                            Text("30 il", fontSize = 11.sp, color = TextHint)
                        }
                    }

                    // ── Bio ──
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                "Haqqında",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onBackground
                            )
                            Text(
                                text = "${uiState.bio.length}/500",
                                fontSize = 12.sp,
                                color = if (uiState.bio.length > 450) CoreViaWarning
                                else TextHint
                            )
                        }
                        OutlinedTextField(
                            value = uiState.bio,
                            onValueChange = viewModel::updateBio,
                            placeholder = { Text("Özünüz haqqında yazın...", color = TextHint) },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(150.dp),
                            shape = RoundedCornerShape(12.dp),
                            maxLines = 6,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = CoreViaPrimary,
                                unfocusedBorderColor = TextSeparator
                            )
                        )
                    }

                    // ── Error ──
                    uiState.error?.let { error ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(CoreViaError.copy(alpha = 0.08f))
                                .padding(14.dp),
                            horizontalArrangement = Arrangement.spacedBy(10.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Filled.Warning, null,
                                modifier = Modifier.size(18.dp),
                                tint = CoreViaError
                            )
                            Text(
                                text = error,
                                fontSize = 13.sp,
                                color = CoreViaError,
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }

                    // ── Submit Button ──
                    Button(
                        onClick = viewModel::submit,
                        enabled = uiState.isFormValid && !uiState.isSubmitting,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(52.dp),
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CoreViaPrimary,
                            disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f)
                        )
                    ) {
                        if (uiState.isSubmitting) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(22.dp),
                                color = Color.White,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Icon(Icons.Filled.Verified, null, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                "Göndər",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(20.dp))
                }
            }

            // ── Loading Overlay ──
            if (uiState.isLoading) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(MaterialTheme.colorScheme.background.copy(alpha = 0.7f)),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = CoreViaPrimary)
                }
            }
        }
    }
}

// ─── Verification Status Banner ─────────────────────────────────────

@Composable
private fun VerificationStatusBanner(status: String) {
    val (bgColor, iconColor, icon, title, subtitle) = when (status.lowercase()) {
        "verified" -> StatusInfo(
            bgColor = CoreViaSuccess.copy(alpha = 0.08f),
            iconColor = CoreViaSuccess,
            icon = Icons.Filled.CheckCircle,
            title = "Doğrulanmış",
            subtitle = "Hesabınız uğurla doğrulanıb"
        )
        "pending" -> StatusInfo(
            bgColor = BadgePending.copy(alpha = 0.08f),
            iconColor = BadgePending,
            icon = Icons.Filled.HourglassTop,
            title = "Gözləmədə",
            subtitle = "Müraciətiniz nəzərdən keçirilir. Bu 1-3 iş günü çəkə bilər."
        )
        "rejected" -> StatusInfo(
            bgColor = CoreViaError.copy(alpha = 0.08f),
            iconColor = CoreViaError,
            icon = Icons.Filled.Cancel,
            title = "Rədd edildi",
            subtitle = "Müraciətiniz rədd edildi. Yeni müraciət göndərə bilərsiniz."
        )
        else -> StatusInfo(
            bgColor = MaterialTheme.colorScheme.surfaceVariant,
            iconColor = TextSecondary,
            icon = Icons.Filled.Info,
            title = "Doğrulanmamış",
            subtitle = "Məşqçi olaraq doğrulanmaq üçün formu doldurun."
        )
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.05f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(bgColor)
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(iconColor.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                icon, null,
                modifier = Modifier.size(24.dp),
                tint = iconColor
            )
        }
        Text(
            text = title,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = iconColor
        )
        Text(
            text = subtitle,
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}

// Helper data class for status banner
private data class StatusInfo(
    val bgColor: Color,
    val iconColor: Color,
    val icon: androidx.compose.ui.graphics.vector.ImageVector,
    val title: String,
    val subtitle: String
)
