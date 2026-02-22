package life.corevia.app.ui.livesession

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun LiveSessionDetailScreen(
    viewModel: LiveSessionsViewModel,
    onBack: () -> Unit
) {
    val session by viewModel.selectedSession.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()

    val currentSession = session ?: return

    val isLive = currentSession.status == "live"
    val isScheduled = currentSession.status == "scheduled"
    val isEnded = currentSession.status in listOf("completed", "ended", "cancelled")
    val isJoined = currentSession.isJoined
    val isFull = currentSession.currentParticipants >= currentSession.maxParticipants

    val statusColor = when (currentSession.status) {
        "live" -> AppTheme.Colors.success
        "scheduled" -> AppTheme.Colors.warning
        "cancelled" -> AppTheme.Colors.error
        else -> AppTheme.Colors.tertiaryText
    }
    val statusText = when (currentSession.status) {
        "live" -> "CANLI"
        "scheduled" -> "Planlanmış"
        "completed", "ended" -> "Bitib"
        "cancelled" -> "Ləğv edilib"
        else -> currentSession.status
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())
        ) {
            // Header
            Box(
                modifier = Modifier.fillMaxWidth()
                    .background(Brush.verticalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.2f), Color.Transparent)))
                    .padding(horizontal = 16.dp).padding(top = 50.dp, bottom = 24.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = onBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                        }
                        Spacer(Modifier.weight(1f))
                    }

                    // Status badge
                    Box(
                        Modifier.clip(RoundedCornerShape(12.dp))
                            .background(statusColor.copy(alpha = 0.15f))
                            .padding(horizontal = 16.dp, vertical = 8.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            if (isLive) {
                                // Pulsating dot for live
                                Box(Modifier.size(10.dp).background(statusColor, CircleShape))
                            } else {
                                Box(Modifier.size(8.dp).background(statusColor, CircleShape))
                            }
                            Spacer(Modifier.width(8.dp))
                            Text(
                                statusText,
                                fontWeight = FontWeight.Bold, fontSize = 14.sp,
                                color = statusColor
                            )
                        }
                    }

                    Spacer(Modifier.height(16.dp))
                    Text(
                        currentSession.title, fontSize = 26.sp, fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText, textAlign = TextAlign.Center
                    )
                    currentSession.trainerName?.let {
                        Spacer(Modifier.height(4.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Outlined.Person, null, Modifier.size(16.dp), tint = AppTheme.Colors.secondaryText)
                            Spacer(Modifier.width(4.dp))
                            Text("Müəllim: $it", fontSize = 15.sp, color = AppTheme.Colors.secondaryText)
                        }
                    }
                }
            }

            // Info cards
            Row(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Duration
                Box(
                    Modifier.weight(1f).clip(RoundedCornerShape(12.dp))
                        .background(AppTheme.Colors.cardBackground).padding(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Outlined.Schedule, null, Modifier.size(20.dp), tint = AppTheme.Colors.accent)
                        Spacer(Modifier.height(4.dp))
                        Text("${currentSession.durationMinutes} dəq", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        Text("Müddət", fontSize = 10.sp, color = AppTheme.Colors.tertiaryText)
                    }
                }

                // Participants
                Box(
                    Modifier.weight(1f).clip(RoundedCornerShape(12.dp))
                        .background(AppTheme.Colors.cardBackground).padding(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Outlined.Group, null, Modifier.size(20.dp), tint = AppTheme.Colors.accent)
                        Spacer(Modifier.height(4.dp))
                        Text(
                            "${currentSession.currentParticipants}/${currentSession.maxParticipants}",
                            fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText
                        )
                        Text("İştirakçı", fontSize = 10.sp, color = AppTheme.Colors.tertiaryText)
                    }
                }

                // Date
                Box(
                    Modifier.weight(1f).clip(RoundedCornerShape(12.dp))
                        .background(AppTheme.Colors.cardBackground).padding(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Outlined.CalendarMonth, null, Modifier.size(20.dp), tint = AppTheme.Colors.accent)
                        Spacer(Modifier.height(4.dp))
                        Text(
                            try { (currentSession.scheduledTime ?: "").take(10) } catch (e: Exception) { "" },
                            fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText
                        )
                        Text(
                            try { (currentSession.scheduledTime ?: "").substring(11, 16) } catch (e: Exception) { "" },
                            fontSize = 10.sp, color = AppTheme.Colors.tertiaryText
                        )
                    }
                }
            }

            // Participant progress bar
            Spacer(Modifier.height(16.dp))
            Box(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                    .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)
            ) {
                Column {
                    Row(
                        Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("İştirakçı sayı", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        Text(
                            if (isFull) "Doludur" else "${currentSession.maxParticipants - currentSession.currentParticipants} yer qalıb",
                            fontSize = 12.sp, color = if (isFull) AppTheme.Colors.error else AppTheme.Colors.success,
                            fontWeight = FontWeight.Medium
                        )
                    }
                    Spacer(Modifier.height(8.dp))
                    val progress = if (currentSession.maxParticipants > 0)
                        currentSession.currentParticipants.toFloat() / currentSession.maxParticipants
                    else 0f
                    LinearProgressIndicator(
                        progress = { progress },
                        modifier = Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(4.dp)),
                        color = if (isFull) AppTheme.Colors.error else AppTheme.Colors.accent,
                        trackColor = AppTheme.Colors.separator,
                    )
                }
            }

            // Description
            currentSession.description?.let { desc ->
                Spacer(Modifier.height(16.dp))
                Box(
                    Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                        .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)
                ) {
                    Column {
                        Text("Təsvir", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        Spacer(Modifier.height(8.dp))
                        Text(desc, fontSize = 14.sp, color = AppTheme.Colors.secondaryText, lineHeight = 22.sp)
                    }
                }
            }

            // Session type badge
            Spacer(Modifier.height(16.dp))
            Box(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                    .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(16.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        when (currentSession.sessionType) {
                            "group" -> Icons.Outlined.Group
                            "one_on_one" -> Icons.Outlined.Person
                            else -> Icons.Outlined.Public
                        },
                        null, Modifier.size(20.dp), tint = AppTheme.Colors.accent
                    )
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text("Sessiya növü", fontSize = 11.sp, color = AppTheme.Colors.tertiaryText)
                        Text(
                            when (currentSession.sessionType) {
                                "group" -> "Qrup sessiyası"
                                "one_on_one" -> "Fərdi sessiya"
                                "open" -> "Açıq sessiya"
                                else -> currentSession.sessionType
                            },
                            fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText
                        )
                    }
                }
            }

            Spacer(Modifier.height(120.dp))
        }

        // Join/Leave button
        Box(Modifier.fillMaxWidth().align(Alignment.BottomCenter).background(AppTheme.Colors.background).padding(20.dp)) {
            if (isJoined && !isEnded) {
                // Show Leave button
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    if (isLive) {
                        // Join live button
                        Button(
                            onClick = { /* Open live session stream */ },
                            modifier = Modifier.weight(1f).height(56.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.success),
                            shape = RoundedCornerShape(16.dp),
                        ) {
                            Icon(Icons.Filled.PlayArrow, null, Modifier.size(20.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("Canlı Bağlan", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                    OutlinedButton(
                        onClick = { viewModel.leaveSession(currentSession.id) },
                        modifier = Modifier.then(if (isLive) Modifier else Modifier.fillMaxWidth()).height(56.dp),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = AppTheme.Colors.error),
                        shape = RoundedCornerShape(16.dp),
                        enabled = !isLoading
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(color = AppTheme.Colors.error, modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                        } else {
                            Icon(Icons.Outlined.ExitToApp, null, Modifier.size(20.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("Ayrıl", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            } else {
                // Show Join button
                Button(
                    onClick = { viewModel.joinSession(currentSession.id) },
                    modifier = Modifier.fillMaxWidth().height(56.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (isEnded) AppTheme.Colors.tertiaryText else AppTheme.Colors.accent
                    ),
                    shape = RoundedCornerShape(16.dp),
                    enabled = !isLoading && !isEnded && !isFull
                ) {
                    if (isLoading) {
                        CircularProgressIndicator(color = Color.White, modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                    } else {
                        Icon(
                            if (isEnded) Icons.Outlined.Block
                            else if (isLive) Icons.Filled.PlayArrow
                            else Icons.Outlined.PersonAdd,
                            null, Modifier.size(20.dp)
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            when {
                                isEnded -> "Sessiya bitib"
                                isFull -> "Sessiya doludur"
                                isLive -> "Sessiyaya Qoşul"
                                else -> "Qeydiyyatdan Keç"
                            },
                            fontSize = 16.sp, fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }

        successMessage?.let { msg ->
            Snackbar(Modifier.align(Alignment.BottomCenter).padding(16.dp).padding(bottom = 80.dp), containerColor = AppTheme.Colors.success) {
                Text(msg, color = Color.White)
            }
            LaunchedEffect(msg) { kotlinx.coroutines.delay(2000); viewModel.clearSuccess() }
        }

        errorMessage?.let { msg ->
            Snackbar(Modifier.align(Alignment.BottomCenter).padding(16.dp).padding(bottom = 80.dp), containerColor = AppTheme.Colors.error) {
                Text(msg, color = Color.White)
            }
            LaunchedEffect(msg) { kotlinx.coroutines.delay(2000); viewModel.clearError() }
        }
    }
    } // CoreViaAnimatedBackground
}
