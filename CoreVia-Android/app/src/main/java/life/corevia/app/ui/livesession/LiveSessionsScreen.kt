package life.corevia.app.ui.livesession

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.LiveSession

@Composable
fun LiveSessionsScreen(
    viewModel: LiveSessionsViewModel,
    onBack: () -> Unit,
    onSessionSelected: (LiveSession) -> Unit
) {
    val sessions by viewModel.sessions.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()

    Box(modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background)) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Header
            Box(
                modifier = Modifier.fillMaxWidth()
                    .background(Brush.verticalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.15f), Color.Transparent)))
                    .padding(horizontal = 16.dp).padding(top = 50.dp, bottom = 16.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                    }
                    Spacer(Modifier.width(8.dp))
                    Text("Canlı Sessiyalar", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                }
            }

            when {
                isLoading && sessions.isEmpty() -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
                sessions.isEmpty() -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("📹", fontSize = 64.sp)
                            Spacer(Modifier.height(16.dp))
                            Text("Aktiv sessiya yoxdur", color = AppTheme.Colors.primaryText, fontSize = 18.sp, fontWeight = FontWeight.SemiBold)
                            Text("Yeni sessiyalar burada görünəcək", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                        }
                    }
                }
                else -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        items(sessions, key = { it.id }) { session ->
                            SessionCard(session) {
                                viewModel.selectSession(session)
                                onSessionSelected(session)
                            }
                        }
                        item { Spacer(Modifier.height(80.dp)) }
                    }
                }
            }
        }
        successMessage?.let { msg ->
            Snackbar(Modifier.align(Alignment.BottomCenter).padding(16.dp), containerColor = AppTheme.Colors.success) {
                Text(msg, color = Color.White)
            }
            LaunchedEffect(msg) { kotlinx.coroutines.delay(2000); viewModel.clearSuccess() }
        }
    }
}

@Composable
fun SessionCard(session: LiveSession, onClick: () -> Unit) {
    val statusColor = when (session.status) {
        "live" -> AppTheme.Colors.success
        "scheduled" -> AppTheme.Colors.warning
        else -> AppTheme.Colors.tertiaryText
    }

    Box(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground).clickable(onClick = onClick).padding(16.dp)
    ) {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Status indicator
                Box(Modifier.size(10.dp).background(statusColor, CircleShape))
                Spacer(Modifier.width(8.dp))
                Text(
                    when (session.status) { "live" -> "CANLI"; "scheduled" -> "Planlanmış"; else -> "Bitib" },
                    fontSize = 12.sp, fontWeight = FontWeight.Bold, color = statusColor
                )
                Spacer(Modifier.weight(1f))
                Text("${session.currentParticipants}/${session.maxParticipants}", fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
                Spacer(Modifier.width(4.dp))
                Icon(Icons.Outlined.Person, null, Modifier.size(14.dp), tint = AppTheme.Colors.secondaryText)
            }
            Spacer(Modifier.height(8.dp))
            Text(session.title, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
            session.trainerName?.let {
                Text("Müəllim: $it", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)
            }
            Spacer(Modifier.height(4.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Outlined.PlayArrow, null, Modifier.size(14.dp), tint = AppTheme.Colors.tertiaryText)
                Spacer(Modifier.width(4.dp))
                Text("${session.durationMinutes} dəq", fontSize = 12.sp, color = AppTheme.Colors.tertiaryText)
                Spacer(Modifier.width(12.dp))
                Text(try { session.scheduledAt.substring(11, 16) } catch (e: Exception) { "" }, fontSize = 12.sp, color = AppTheme.Colors.tertiaryText)
            }
        }
    }
}
