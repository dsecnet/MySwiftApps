package life.corevia.app.ui.trainerhub

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
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
import life.corevia.app.data.model.LiveSession
import life.corevia.app.data.model.LiveSessionDifficulty
import life.corevia.app.data.model.LiveSessionStatus
import life.corevia.app.data.repository.LiveSessionRepository
import life.corevia.app.ui.theme.*
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

// ═══════════════════════════════════════════════════════════════════
// MARK: - UI State
// ═══════════════════════════════════════════════════════════════════

data class TrainerSessionsUiState(
    val isLoading: Boolean = false,
    val sessions: List<LiveSession> = emptyList(),
    val selectedFilter: String = "all",
    val error: String? = null,
    val isDeleting: Boolean = false
) {
    val filteredSessions: List<LiveSession>
        get() = when (selectedFilter) {
            "all" -> sessions
            "upcoming" -> sessions.filter { it.status == "upcoming" }
            "live" -> sessions.filter { it.status == "live" }
            "completed" -> sessions.filter { it.status == "completed" }
            else -> sessions
        }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ═══════════════════════════════════════════════════════════════════

@HiltViewModel
class TrainerSessionsViewModel @Inject constructor(
    private val liveSessionRepository: LiveSessionRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(TrainerSessionsUiState())
    val uiState: StateFlow<TrainerSessionsUiState> = _uiState.asStateFlow()

    init {
        loadSessions()
    }

    fun loadSessions() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            when (val result = liveSessionRepository.getMyLiveSessions()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        sessions = result.data
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun setFilter(filter: String) {
        _uiState.value = _uiState.value.copy(selectedFilter = filter)
    }

    fun deleteSession(sessionId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isDeleting = true)
            when (liveSessionRepository.deleteLiveSession(sessionId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isDeleting = false,
                        sessions = _uiState.value.sessions.filter { it.id != sessionId }
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isDeleting = false,
                        error = "Sessiya silinə bilmədi"
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
 * iOS TrainerSessionsView equivalent
 * Canlı sessiyalar siyahısı — filter chips + session cards + FAB
 */
@Composable
fun TrainerSessionsContent(
    onNavigateToCreateSession: () -> Unit = {},
    viewModel: TrainerSessionsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Box(modifier = Modifier.fillMaxSize()) {
        Column(modifier = Modifier.fillMaxSize()) {
            // ── Filter Chips — iOS horizontal scroll ──
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                SessionFilterChip(
                    label = "Hamısı",
                    isSelected = uiState.selectedFilter == "all",
                    onClick = { viewModel.setFilter("all") }
                )
                SessionFilterChip(
                    label = "Gələcək",
                    isSelected = uiState.selectedFilter == "upcoming",
                    onClick = { viewModel.setFilter("upcoming") }
                )
                SessionFilterChip(
                    label = "Canlı",
                    isSelected = uiState.selectedFilter == "live",
                    onClick = { viewModel.setFilter("live") }
                )
                SessionFilterChip(
                    label = "Tamamlanmış",
                    isSelected = uiState.selectedFilter == "completed",
                    onClick = { viewModel.setFilter("completed") }
                )
            }

            // ── Content ──
            when {
                uiState.isLoading && uiState.sessions.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                    }
                }

                !uiState.isLoading && uiState.filteredSessions.isEmpty() -> {
                    // iOS empty state
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(40.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            Icons.Filled.Videocam,
                            contentDescription = null,
                            modifier = Modifier.size(70.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "Hələ sessiyanız yoxdur",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "Yeni canlı sessiya yaratmaq üçün + düyməsinə basın",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                else -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState())
                            .padding(horizontal = 16.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        uiState.filteredSessions.forEach { session ->
                            SessionCard(
                                session = session,
                                onDelete = { viewModel.deleteSession(session.id) }
                            )
                        }
                        Spacer(modifier = Modifier.height(80.dp))
                    }
                }
            }
        }

        // ── FAB — create session ──
        FloatingActionButton(
            onClick = onNavigateToCreateSession,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 20.dp, bottom = 24.dp),
            containerColor = CoreViaPrimary,
            contentColor = Color.White,
            shape = RoundedCornerShape(Layout.cornerRadiusL)
        ) {
            Icon(Icons.Filled.Add, contentDescription = "Yeni Sessiya")
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Filter Chip
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionFilterChip(
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(
                if (isSelected) CoreViaPrimary
                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Text(
            text = label,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
            color = if (isSelected) Color.White
            else MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Session Card
// ═══════════════════════════════════════════════════════════════════

/**
 * iOS session card — shadow card with cornerRadius(16),
 * status badge, difficulty, scheduled time, participants, delete button
 */
@Composable
private fun SessionCard(
    session: LiveSession,
    onDelete: () -> Unit
) {
    val statusColor = when (session.statusEnum) {
        LiveSessionStatus.UPCOMING -> AccentBlue
        LiveSessionStatus.LIVE -> CoreViaSuccess
        LiveSessionStatus.COMPLETED -> TextSecondary
        LiveSessionStatus.CANCELLED -> CoreViaError
    }

    val difficultyColor = when (LiveSessionDifficulty.fromValue(session.difficulty)) {
        LiveSessionDifficulty.BEGINNER -> CoreViaSuccess
        LiveSessionDifficulty.INTERMEDIATE -> AccentOrange
        LiveSessionDifficulty.ADVANCED -> CoreViaError
    }

    val sessionTypeIcon = when (session.sessionType) {
        "strength" -> Icons.Filled.FitnessCenter
        "cardio" -> Icons.Filled.Favorite
        "yoga" -> Icons.Filled.SelfImprovement
        "hiit" -> Icons.Filled.FlashOn
        "flexibility" -> Icons.Filled.SelfImprovement
        else -> Icons.Filled.FitnessCenter
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
            .background(MaterialTheme.colorScheme.surface)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // ── Row 1: Title + Delete ──
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                modifier = Modifier.weight(1f),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Session type icon
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(CoreViaPrimary.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        sessionTypeIcon,
                        contentDescription = null,
                        modifier = Modifier.size(22.dp),
                        tint = CoreViaPrimary
                    )
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = session.title,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onSurface,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    if (session.description.isNotBlank()) {
                        Text(
                            text = session.description,
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            }
            IconButton(onClick = onDelete) {
                Icon(
                    Icons.Filled.Delete,
                    contentDescription = "Sil",
                    tint = CoreViaError,
                    modifier = Modifier.size(20.dp)
                )
            }
        }

        // ── Row 2: Status Badge + Difficulty Badge ──
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Status badge
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .background(statusColor.copy(alpha = 0.12f))
                    .padding(horizontal = 10.dp, vertical = 4.dp)
            ) {
                Text(
                    text = session.statusEnum.displayName,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = statusColor
                )
            }

            // Difficulty badge
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .background(difficultyColor.copy(alpha = 0.12f))
                    .padding(horizontal = 10.dp, vertical = 4.dp)
            ) {
                Text(
                    text = session.difficultyDisplayName,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = difficultyColor
                )
            }
        }

        // ── Row 3: Time + Participants + Price ──
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Scheduled time
            if (session.formattedDate.isNotBlank()) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Schedule,
                        contentDescription = null,
                        modifier = Modifier.size(14.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = session.formattedDate,
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Participants
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.People,
                    contentDescription = null,
                    modifier = Modifier.size(14.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "${session.currentParticipants}/${session.maxParticipants}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Price
            Text(
                text = session.displayPrice,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
        }
    }
}
