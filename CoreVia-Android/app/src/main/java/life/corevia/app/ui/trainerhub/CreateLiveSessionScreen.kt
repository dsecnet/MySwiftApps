package life.corevia.app.ui.trainerhub

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.CreateSessionRequest
import life.corevia.app.data.model.LiveSessionDifficulty
import life.corevia.app.data.repository.LiveSessionRepository
import life.corevia.app.ui.theme.*
import life.corevia.app.util.NetworkResult
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import javax.inject.Inject

// ═══════════════════════════════════════════════════════════════════
// MARK: - Session Type Helper
// ═══════════════════════════════════════════════════════════════════

enum class SessionType(val value: String, val displayName: String, val icon: ImageVector) {
    STRENGTH("strength", "Güc", Icons.Filled.FitnessCenter),
    CARDIO("cardio", "Kardio", Icons.Filled.Favorite),
    YOGA("yoga", "Yoga", Icons.Filled.SelfImprovement),
    HIIT("hiit", "HIIT", Icons.Filled.FlashOn),
    FLEXIBILITY("flexibility", "Çeviklik", Icons.Filled.SelfImprovement)
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - UI State
// ═══════════════════════════════════════════════════════════════════

data class CreateSessionUiState(
    val title: String = "",
    val description: String = "",
    val selectedSessionType: SessionType = SessionType.STRENGTH,
    val maxParticipants: String = "20",
    val selectedDifficulty: LiveSessionDifficulty = LiveSessionDifficulty.BEGINNER,
    val duration: String = "45",
    val price: String = "",
    val currency: String = "AZN",
    val scheduledDate: Calendar = Calendar.getInstance().apply {
        add(Calendar.HOUR_OF_DAY, 1)
    },
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val errorMessage: String? = null
) {
    val isFormValid: Boolean
        get() = title.isNotBlank() &&
                description.isNotBlank() &&
                maxParticipants.toIntOrNull() != null &&
                (maxParticipants.toIntOrNull() ?: 0) > 0 &&
                duration.toIntOrNull() != null &&
                (duration.toIntOrNull() ?: 0) > 0 &&
                price.toDoubleOrNull() != null &&
                (price.toDoubleOrNull() ?: 0.0) >= 0

    val formattedDate: String
        get() {
            val dateFormat = SimpleDateFormat("dd MMM yyyy, HH:mm", Locale.getDefault())
            return dateFormat.format(scheduledDate.time)
        }

    val isoDate: String
        get() {
            val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            return isoFormat.format(scheduledDate.time)
        }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ═══════════════════════════════════════════════════════════════════

@HiltViewModel
class CreateSessionViewModel @Inject constructor(
    private val liveSessionRepository: LiveSessionRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CreateSessionUiState())
    val uiState: StateFlow<CreateSessionUiState> = _uiState.asStateFlow()

    fun updateTitle(title: String) {
        _uiState.value = _uiState.value.copy(title = title, errorMessage = null)
    }

    fun updateDescription(description: String) {
        _uiState.value = _uiState.value.copy(description = description, errorMessage = null)
    }

    fun updateSessionType(type: SessionType) {
        _uiState.value = _uiState.value.copy(selectedSessionType = type)
    }

    fun updateMaxParticipants(value: String) {
        _uiState.value = _uiState.value.copy(maxParticipants = value, errorMessage = null)
    }

    fun updateDifficulty(difficulty: LiveSessionDifficulty) {
        _uiState.value = _uiState.value.copy(selectedDifficulty = difficulty)
    }

    fun updateDuration(duration: String) {
        _uiState.value = _uiState.value.copy(duration = duration, errorMessage = null)
    }

    fun updatePrice(price: String) {
        _uiState.value = _uiState.value.copy(price = price, errorMessage = null)
    }

    fun updateCurrency(currency: String) {
        _uiState.value = _uiState.value.copy(currency = currency)
    }

    fun updateScheduledDate(calendar: Calendar) {
        _uiState.value = _uiState.value.copy(scheduledDate = calendar)
    }

    fun createSession() {
        val state = _uiState.value
        if (!state.isFormValid) {
            _uiState.value = state.copy(errorMessage = "Bütün sahələri düzgün doldurun")
            return
        }

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            val request = CreateSessionRequest(
                title = state.title.trim(),
                description = state.description.trim(),
                sessionType = state.selectedSessionType.value,
                maxParticipants = state.maxParticipants.toIntOrNull() ?: 20,
                scheduledAt = state.isoDate,
                duration = state.duration.toIntOrNull() ?: 45,
                price = state.price.toDoubleOrNull() ?: 0.0,
                currency = state.currency,
                difficulty = state.selectedDifficulty.value,
                isPublic = true
            )
            when (liveSessionRepository.createLiveSession(request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        isSaved = true
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = "Sessiya yaradıla bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Screen Composable
// ═══════════════════════════════════════════════════════════════════

/**
 * iOS CreateLiveSessionView equivalent
 * Yeni Sessiya yaratma forması — title, description, type, participants,
 * difficulty, duration, price, scheduled date/time
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateLiveSessionScreen(
    onBack: () -> Unit,
    viewModel: CreateSessionViewModel = hiltViewModel()
) {
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state.isSaved) {
        if (state.isSaved) onBack()
    }

    // Date & Time picker states
    var showDatePicker by remember { mutableStateOf(false) }
    var showTimePicker by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize()) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Text("Yeni Sessiya", fontWeight = FontWeight.Bold, fontSize = 22.sp)
                    },
                    navigationIcon = {
                        IconButton(onClick = onBack) {
                            Icon(Icons.Filled.Close, contentDescription = "Ləğv et")
                        }
                    },
                    actions = {
                        TextButton(
                            onClick = { viewModel.createSession() },
                            enabled = state.isFormValid && !state.isLoading
                        ) {
                            Text(
                                "Yarat",
                                fontWeight = FontWeight.Bold,
                                color = if (state.isFormValid && !state.isLoading)
                                    CoreViaPrimary else TextHint
                            )
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = Color.Transparent
                    )
                )
            }
        ) { padding ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                // ── Title ──
                SessionSectionLabel("Sessiya adı")
                OutlinedTextField(
                    value = state.title,
                    onValueChange = viewModel::updateTitle,
                    placeholder = { Text("məs: Səhər HIIT Sessiyası", color = TextHint) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = TextSeparator
                    )
                )

                // ── Description ──
                SessionSectionLabel("Təsvir")
                OutlinedTextField(
                    value = state.description,
                    onValueChange = viewModel::updateDescription,
                    placeholder = { Text("Sessiya haqqında ətraflı məlumat...", color = TextHint) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(100.dp),
                    shape = RoundedCornerShape(12.dp),
                    maxLines = 5,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = TextSeparator
                    )
                )

                // ── Session Type — Category Cards ──
                SessionSectionLabel("Sessiya növü")
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    SessionType.entries.forEach { type ->
                        SessionTypeCategoryCard(
                            type = type,
                            isSelected = state.selectedSessionType == type,
                            onClick = { viewModel.updateSessionType(type) },
                            modifier = Modifier.weight(1f)
                        )
                    }
                }

                // ── Difficulty — Segmented ──
                SessionSectionLabel("Çətinlik")
                SingleChoiceSegmentedButtonRow(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    val difficulties = LiveSessionDifficulty.entries
                    difficulties.forEachIndexed { index, diff ->
                        val diffColor = when (diff) {
                            LiveSessionDifficulty.BEGINNER -> CoreViaSuccess
                            LiveSessionDifficulty.INTERMEDIATE -> AccentOrange
                            LiveSessionDifficulty.ADVANCED -> CoreViaError
                        }
                        SegmentedButton(
                            selected = state.selectedDifficulty == diff,
                            onClick = { viewModel.updateDifficulty(diff) },
                            shape = SegmentedButtonDefaults.itemShape(
                                index = index,
                                count = difficulties.size,
                                baseShape = RoundedCornerShape(Layout.cornerRadiusM)
                            ),
                            colors = SegmentedButtonDefaults.colors(
                                activeContainerColor = diffColor,
                                activeContentColor = Color.White,
                                inactiveContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                                inactiveContentColor = MaterialTheme.colorScheme.onSurfaceVariant
                            ),
                            icon = {}
                        ) {
                            Text(
                                text = diff.displayName,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                    }
                }

                // ── Max Participants ──
                SessionSectionLabel("Maks. iştirakçı")
                OutlinedTextField(
                    value = state.maxParticipants,
                    onValueChange = viewModel::updateMaxParticipants,
                    placeholder = { Text("20", color = TextHint) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    leadingIcon = {
                        Icon(
                            Icons.Filled.People,
                            contentDescription = null,
                            tint = AccentBlue
                        )
                    },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = TextSeparator
                    )
                )

                // ── Duration (minutes) ──
                SessionSectionLabel("Müddət (dəqiqə)")
                OutlinedTextField(
                    value = state.duration,
                    onValueChange = viewModel::updateDuration,
                    placeholder = { Text("45", color = TextHint) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    leadingIcon = {
                        Icon(
                            Icons.Filled.Timer,
                            contentDescription = null,
                            tint = AccentOrange
                        )
                    },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = TextSeparator
                    )
                )

                // ── Price ──
                SessionSectionLabel("Qiymət (${state.currency})")
                OutlinedTextField(
                    value = state.price,
                    onValueChange = viewModel::updatePrice,
                    placeholder = { Text("0.00", color = TextHint) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    leadingIcon = {
                        Icon(
                            Icons.Filled.AttachMoney,
                            contentDescription = null,
                            tint = CoreViaPrimary
                        )
                    },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = TextSeparator
                    )
                )

                // ── Scheduled Date/Time ──
                SessionSectionLabel("Tarix və vaxt")
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Date button
                    OutlinedButton(
                        onClick = { showDatePicker = true },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        border = ButtonDefaults.outlinedButtonBorder(enabled = true),
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 14.dp)
                    ) {
                        Icon(
                            Icons.Filled.CalendarToday,
                            contentDescription = null,
                            tint = CoreViaPrimary,
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = SimpleDateFormat("dd MMM yyyy", Locale.getDefault())
                                .format(state.scheduledDate.time),
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }

                    // Time button
                    OutlinedButton(
                        onClick = { showTimePicker = true },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        border = ButtonDefaults.outlinedButtonBorder(enabled = true),
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 14.dp)
                    ) {
                        Icon(
                            Icons.Filled.Schedule,
                            contentDescription = null,
                            tint = CoreViaPrimary,
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = SimpleDateFormat("HH:mm", Locale.getDefault())
                                .format(state.scheduledDate.time),
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }

                // ── Error Message ──
                state.errorMessage?.let { error ->
                    Text(
                        text = error,
                        color = CoreViaError,
                        fontSize = 13.sp,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                // ── Save Button ──
                Button(
                    onClick = { viewModel.createSession() },
                    enabled = state.isFormValid && !state.isLoading,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CoreViaPrimary,
                        disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f)
                    )
                ) {
                    if (state.isLoading) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(22.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(Icons.Filled.Check, contentDescription = null, tint = Color.White)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Sessiya Yarat", fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))
            }
        }

        // ── Loading Overlay ──
        if (state.isLoading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.3f)),
                contentAlignment = Alignment.Center
            ) {
                Card(
                    shape = RoundedCornerShape(Layout.cornerRadiusL),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    ),
                    elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(32.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                        Text(
                            "Sessiya yaradılır...",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }
        }
    }

    // ── Date Picker Dialog ──
    if (showDatePicker) {
        val datePickerState = rememberDatePickerState(
            initialSelectedDateMillis = state.scheduledDate.timeInMillis
        )
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let { millis ->
                        val newCal = state.scheduledDate.clone() as Calendar
                        val selected = Calendar.getInstance().apply { timeInMillis = millis }
                        newCal.set(Calendar.YEAR, selected.get(Calendar.YEAR))
                        newCal.set(Calendar.MONTH, selected.get(Calendar.MONTH))
                        newCal.set(Calendar.DAY_OF_MONTH, selected.get(Calendar.DAY_OF_MONTH))
                        viewModel.updateScheduledDate(newCal)
                    }
                    showDatePicker = false
                }) {
                    Text("Təsdiq", color = CoreViaPrimary)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) {
                    Text("Ləğv et", color = TextSecondary)
                }
            }
        ) {
            DatePicker(
                state = datePickerState,
                colors = DatePickerDefaults.colors(
                    selectedDayContainerColor = CoreViaPrimary,
                    todayDateBorderColor = CoreViaPrimary
                )
            )
        }
    }

    // ── Time Picker Dialog ──
    if (showTimePicker) {
        val timePickerState = rememberTimePickerState(
            initialHour = state.scheduledDate.get(Calendar.HOUR_OF_DAY),
            initialMinute = state.scheduledDate.get(Calendar.MINUTE),
            is24Hour = true
        )
        AlertDialog(
            onDismissRequest = { showTimePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    val newCal = state.scheduledDate.clone() as Calendar
                    newCal.set(Calendar.HOUR_OF_DAY, timePickerState.hour)
                    newCal.set(Calendar.MINUTE, timePickerState.minute)
                    viewModel.updateScheduledDate(newCal)
                    showTimePicker = false
                }) {
                    Text("Təsdiq", color = CoreViaPrimary)
                }
            },
            dismissButton = {
                TextButton(onClick = { showTimePicker = false }) {
                    Text("Ləğv et", color = TextSecondary)
                }
            },
            title = { Text("Vaxt seçin", fontWeight = FontWeight.Bold) },
            text = {
                TimePicker(
                    state = timePickerState,
                    colors = TimePickerDefaults.colors(
                        selectorColor = CoreViaPrimary,
                        timeSelectorSelectedContainerColor = CoreViaPrimary.copy(alpha = 0.15f),
                        timeSelectorSelectedContentColor = CoreViaPrimary
                    )
                )
            }
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Session Type Category Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionTypeCategoryCard(
    type: SessionType,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val bgColor by animateColorAsState(
        if (isSelected) CoreViaPrimary else MaterialTheme.colorScheme.surface,
        label = "typeBg"
    )
    val contentColor = if (isSelected) Color.White else TextSecondary

    Column(
        modifier = modifier
            .height(72.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(bgColor)
            .border(
                width = if (isSelected) 2.dp else 1.dp,
                color = if (isSelected) CoreViaPrimary else TextSeparator,
                shape = RoundedCornerShape(12.dp)
            )
            .clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            type.icon,
            contentDescription = type.displayName,
            tint = contentColor,
            modifier = Modifier.size(24.dp)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            type.displayName,
            fontSize = 10.sp,
            color = contentColor,
            fontWeight = FontWeight.Medium
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Section Label
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionSectionLabel(text: String) {
    Text(
        text = text,
        fontSize = 14.sp,
        fontWeight = FontWeight.Medium,
        color = TextSecondary
    )
}
