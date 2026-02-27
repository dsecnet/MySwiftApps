package life.corevia.app.ui.livesession

import androidx.compose.foundation.background
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.LiveSession
import life.corevia.app.data.model.LiveSessionDifficulty
import life.corevia.app.data.model.LiveSessionStatus
import life.corevia.app.ui.theme.*

/**
 * iOS LiveSessionDetailView equivalent
 * Sessiya detalları — info card, status badge, join button
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LiveSessionDetailScreen(
    sessionId: String = "",
    onBack: () -> Unit = {},
    onNavigateToLiveWorkout: (String) -> Unit = {},
    viewModel: LiveSessionDetailViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val isDark = isSystemInDarkTheme()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Sessiya Detalları",
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
        when {
            uiState.isLoading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = CoreViaPrimary)
                }
            }

            uiState.error != null -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Filled.ErrorOutline,
                            contentDescription = null,
                            modifier = Modifier.size(60.dp),
                            tint = CoreViaError
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = uiState.error ?: "Xəta baş verdi",
                            fontSize = 16.sp,
                            color = TextSecondary,
                            textAlign = TextAlign.Center
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = { viewModel.loadSession() },
                            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
                        ) {
                            Text("Yenidən cəhd et")
                        }
                    }
                }
            }

            uiState.session != null -> {
                val session = uiState.session!!

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(MaterialTheme.colorScheme.background)
                        .padding(padding)
                ) {
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .verticalScroll(rememberScrollState())
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        // ── Header Card ──
                        SessionHeaderCard(session = session, isDark = isDark)

                        // ── Description Card ──
                        if (session.description.isNotBlank()) {
                            SessionDescriptionCard(
                                description = session.description,
                                isDark = isDark
                            )
                        }

                        // ── Details Card ──
                        SessionDetailsCard(session = session, isDark = isDark)

                        // ── Participants Card ──
                        SessionParticipantsCard(session = session, isDark = isDark)

                        Spacer(modifier = Modifier.height(8.dp))
                    }

                    // ── Bottom Join Button ──
                    if (session.statusEnum == LiveSessionStatus.UPCOMING ||
                        session.statusEnum == LiveSessionStatus.LIVE
                    ) {
                        JoinSessionButton(
                            session = session,
                            isJoining = uiState.isJoining,
                            onJoin = {
                                viewModel.joinSession {
                                    onNavigateToLiveWorkout(session.id)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Header Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionHeaderCard(session: LiveSession, isDark: Boolean) {
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
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Title + Status
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Top
        ) {
            Text(
                text = session.title,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.weight(1f)
            )
            Spacer(modifier = Modifier.width(12.dp))
            StatusBadge(status = session.statusEnum)
        }

        // Trainer
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Icon(
                Icons.Filled.Person,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = CoreViaPrimary
            )
            Text(
                text = session.trainerName.ifBlank { "Naməlum Təlimçi" },
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurface
            )
        }

        // Session Type + Difficulty Badges
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            SessionTypeBadgeDetail(sessionType = session.sessionType)
            DifficultyBadgeDetail(difficulty = session.difficulty)
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Description Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionDescriptionCard(description: String, isDark: Boolean) {
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
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            text = "Haqqında",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSurface
        )
        Text(
            text = description,
            fontSize = 14.sp,
            lineHeight = 20.sp,
            color = TextSecondary
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Details Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionDetailsCard(session: LiveSession, isDark: Boolean) {
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
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(
            text = "Detallar",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSurface
        )

        Spacer(modifier = Modifier.height(8.dp))

        DetailInfoRow(
            icon = Icons.Filled.Schedule,
            label = "Tarix",
            value = session.formattedDate.ifBlank { "Tarix yoxdur" },
            iconTint = AccentBlue
        )

        HorizontalDivider(
            modifier = Modifier.padding(vertical = 8.dp),
            color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
            thickness = 0.5.dp
        )

        DetailInfoRow(
            icon = Icons.Filled.Timer,
            label = "Müddət",
            value = "${session.duration} dəqiqə",
            iconTint = AccentOrange
        )

        HorizontalDivider(
            modifier = Modifier.padding(vertical = 8.dp),
            color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
            thickness = 0.5.dp
        )

        DetailInfoRow(
            icon = Icons.Filled.Payments,
            label = "Qiymət",
            value = session.displayPrice,
            iconTint = CoreViaPrimary
        )

        HorizontalDivider(
            modifier = Modifier.padding(vertical = 8.dp),
            color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
            thickness = 0.5.dp
        )

        DetailInfoRow(
            icon = Icons.Filled.FitnessCenter,
            label = "Çətinlik",
            value = session.difficultyDisplayName,
            iconTint = when (LiveSessionDifficulty.fromValue(session.difficulty)) {
                LiveSessionDifficulty.BEGINNER -> CoreViaSuccess
                LiveSessionDifficulty.INTERMEDIATE -> AccentOrange
                LiveSessionDifficulty.ADVANCED -> CoreViaError
            }
        )

        if (session.isPublic) {
            HorizontalDivider(
                modifier = Modifier.padding(vertical = 8.dp),
                color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
                thickness = 0.5.dp
            )

            DetailInfoRow(
                icon = Icons.Filled.Public,
                label = "Görünürlük",
                value = "İctimai sessiya",
                iconTint = CoreViaSuccess
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Detail Info Row
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun DetailInfoRow(
    icon: ImageVector,
    label: String,
    value: String,
    iconTint: Color
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Icon(
                icon,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = iconTint
            )
            Text(
                text = label,
                fontSize = 14.sp,
                color = TextSecondary
            )
        }
        Text(
            text = value,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Participants Card
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionParticipantsCard(session: LiveSession, isDark: Boolean) {
    val progress = if (session.maxParticipants > 0)
        session.currentParticipants.toFloat() / session.maxParticipants
    else 0f

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
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "İştirakçılar",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurface
            )
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Icon(
                    Icons.Filled.Group,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp),
                    tint = AccentOrange
                )
                Text(
                    text = "${session.currentParticipants} / ${session.maxParticipants}",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                )
            }
        }

        // Progress bar
        LinearProgressIndicator(
            progress = { progress.coerceIn(0f, 1f) },
            modifier = Modifier
                .fillMaxWidth()
                .height(8.dp)
                .clip(RoundedCornerShape(4.dp)),
            color = if (progress > 0.8f) CoreViaError else CoreViaPrimary,
            trackColor = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f)
        )

        // Slots remaining
        val slotsLeft = (session.maxParticipants - session.currentParticipants).coerceAtLeast(0)
        Text(
            text = if (slotsLeft > 0) "$slotsLeft yer qalıb"
            else "Tam dolu",
            fontSize = 13.sp,
            fontWeight = FontWeight.Medium,
            color = if (slotsLeft > 0) CoreViaSuccess else CoreViaError
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Join Button
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun JoinSessionButton(
    session: LiveSession,
    isJoining: Boolean,
    onJoin: () -> Unit
) {
    val isFull = session.currentParticipants >= session.maxParticipants && session.maxParticipants > 0
    val buttonLabel = when {
        isJoining -> "Qoşulur..."
        session.statusEnum == LiveSessionStatus.LIVE -> "Canlı Qoşul"
        isFull -> "Tam Dolu"
        else -> "Qoşul"
    }

    Surface(
        modifier = Modifier.fillMaxWidth(),
        shadowElevation = 8.dp,
        color = MaterialTheme.colorScheme.surface
    ) {
        Button(
            onClick = onJoin,
            enabled = !isJoining && !isFull,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp)
                .height(52.dp),
            shape = RoundedCornerShape(16.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = CoreViaPrimary,
                contentColor = Color.White,
                disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f),
                disabledContentColor = Color.White.copy(alpha = 0.6f)
            )
        ) {
            if (isJoining) {
                CircularProgressIndicator(
                    modifier = Modifier.size(20.dp),
                    color = Color.White,
                    strokeWidth = 2.dp
                )
                Spacer(modifier = Modifier.width(8.dp))
            }
            Text(
                text = buttonLabel,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Session Type Badge (Detail variant)
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun SessionTypeBadgeDetail(sessionType: String) {
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
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            color = AccentPurple
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Difficulty Badge (Detail variant)
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun DifficultyBadgeDetail(difficulty: String) {
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
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            color = color
        )
    }
}
