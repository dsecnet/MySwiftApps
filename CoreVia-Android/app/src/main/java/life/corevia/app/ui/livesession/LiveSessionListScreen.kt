package life.corevia.app.ui.livesession

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.LiveSession
import life.corevia.app.data.model.LiveSessionDifficulty
import life.corevia.app.data.model.LiveSessionStatus
import life.corevia.app.ui.theme.*

/**
 * iOS LiveSessionListView equivalent
 * Canlı sessiyaların siyahı ekranı — filter chips, session cards, empty state
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LiveSessionListScreen(
    onBack: () -> Unit = {},
    onNavigateToDetail: (String) -> Unit = {},
    viewModel: LiveSessionViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Canlı Sessiyalar",
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
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
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(padding)
        ) {
            // ── Filter Chips — iOS horizontal scroll ──
            SessionFilterChips(
                selectedFilter = uiState.selectedFilter,
                onFilterSelected = { viewModel.setFilter(it) }
            )

            // ── Content ──
            when {
                uiState.isLoading && uiState.filteredSessions.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                    }
                }

                !uiState.isLoading && uiState.filteredSessions.isEmpty() -> {
                    SessionEmptyState()
                }

                else -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState())
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        uiState.filteredSessions.forEach { session ->
                            SessionCard(
                                session = session,
                                onClick = { onNavigateToDetail(session.id) }
                            )
                        }
                        Spacer(modifier = Modifier.height(20.dp))
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Filter Chips
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionFilterChips(
    selectedFilter: String,
    onFilterSelected: (String) -> Unit
) {
    val filters = listOf(
        "all" to "Hamısı",
        "upcoming" to "Gələcək",
        "live" to "Canlı",
        "completed" to "Tamamlanmış"
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        filters.forEach { (key, label) ->
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(20.dp))
                    .background(
                        if (selectedFilter == key) CoreViaPrimary
                        else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f)
                    )
                    .clickable { onFilterSelected(key) }
                    .padding(horizontal = 16.dp, vertical = 8.dp)
            ) {
                Text(
                    text = label,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = if (selectedFilter == key) Color.White
                    else MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Session Card
// ═══════════════════════════════════════════════════════════════════

/**
 * iOS SessionCard equivalent:
 * VStack — title, trainer, badges, schedule, participants, price
 * surface bg + cornerRadius(16) + shadow(0.05, radius 10, y: 2)
 */
@Composable
private fun SessionCard(
    session: LiveSession,
    onClick: () -> Unit
) {
    val isDark = isSystemInDarkTheme()

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.08f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(if (isDark) CoreViaSurfaceNight else CoreViaSurface)
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // ── Row 1: Title + Status Badge ──
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = session.title,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f)
            )
            Spacer(modifier = Modifier.width(8.dp))
            StatusBadge(status = session.statusEnum)
        }

        // ── Row 2: Trainer Name ──
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Icon(
                Icons.Filled.Person,
                contentDescription = null,
                modifier = Modifier.size(16.dp),
                tint = TextSecondary
            )
            Text(
                text = session.trainerName.ifBlank { "Naməlum Təlimçi" },
                fontSize = 14.sp,
                color = TextSecondary
            )
        }

        // ── Row 3: Type Badge + Difficulty Badge ──
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SessionTypeBadge(sessionType = session.sessionType)
            DifficultyBadge(difficulty = session.difficulty)
        }

        // ── Divider ──
        HorizontalDivider(
            color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
            thickness = 0.5.dp
        )

        // ── Row 4: Schedule + Participants + Price ──
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Schedule
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Icon(
                    Icons.Filled.Schedule,
                    contentDescription = null,
                    modifier = Modifier.size(14.dp),
                    tint = AccentBlue
                )
                Text(
                    text = session.formattedDate.ifBlank { "Tarix yoxdur" },
                    fontSize = 12.sp,
                    color = TextSecondary
                )
            }

            // Participants
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Icon(
                    Icons.Filled.Group,
                    contentDescription = null,
                    modifier = Modifier.size(14.dp),
                    tint = AccentOrange
                )
                Text(
                    text = "${session.currentParticipants}/${session.maxParticipants}",
                    fontSize = 12.sp,
                    color = TextSecondary
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

// ═══════════════════════════════════════════════════════════════════
// MARK: - Status Badge
// ═══════════════════════════════════════════════════════════════════

@Composable
fun StatusBadge(status: LiveSessionStatus) {
    val (bgColor, textColor, label) = when (status) {
        LiveSessionStatus.UPCOMING -> Triple(AccentBlue.copy(alpha = 0.15f), AccentBlue, "Gələcək")
        LiveSessionStatus.LIVE -> Triple(CoreViaSuccess.copy(alpha = 0.15f), CoreViaSuccess, "Canlı")
        LiveSessionStatus.COMPLETED -> Triple(TextSecondary.copy(alpha = 0.15f), TextSecondary, "Tamamlanmış")
        LiveSessionStatus.CANCELLED -> Triple(CoreViaError.copy(alpha = 0.15f), CoreViaError, "Ləğv edilmiş")
    }

    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(bgColor)
            .padding(horizontal = 10.dp, vertical = 4.dp)
    ) {
        Text(
            text = label,
            fontSize = 11.sp,
            fontWeight = FontWeight.SemiBold,
            color = textColor
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Session Type Badge
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionTypeBadge(sessionType: String) {
    val label = when (sessionType) {
        "strength" -> "Güc"
        "cardio" -> "Kardiyo"
        "yoga" -> "Yoga"
        "hiit" -> "HIIT"
        "stretching" -> "Esnəmə"
        "pilates" -> "Pilates"
        else -> sessionType.replaceFirstChar { it.uppercaseChar() }
    }

    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(AccentPurple.copy(alpha = 0.12f))
            .padding(horizontal = 10.dp, vertical = 4.dp)
    ) {
        Text(
            text = label,
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
            color = AccentPurple
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Difficulty Badge
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun DifficultyBadge(difficulty: String) {
    val diffEnum = LiveSessionDifficulty.fromValue(difficulty)
    val color = when (diffEnum) {
        LiveSessionDifficulty.BEGINNER -> CoreViaSuccess
        LiveSessionDifficulty.INTERMEDIATE -> AccentOrange
        LiveSessionDifficulty.ADVANCED -> CoreViaError
    }

    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(color.copy(alpha = 0.12f))
            .padding(horizontal = 10.dp, vertical = 4.dp)
    ) {
        Text(
            text = diffEnum.displayName,
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
            color = color
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Empty State
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionEmptyState() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            Icons.Filled.VideoCameraFront,
            contentDescription = null,
            modifier = Modifier.size(70.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Hələ sessiya yoxdur",
            fontSize = 18.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "Tezliklə yeni canlı sessiyalar əlavə olunacaq",
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
