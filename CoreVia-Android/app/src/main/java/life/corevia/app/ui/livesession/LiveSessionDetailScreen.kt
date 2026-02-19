package life.corevia.app.ui.livesession

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
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

    Box(modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background)) {
        Column(modifier = Modifier.fillMaxSize()) {
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

                    // Status
                    val isLive = currentSession.status == "live"
                    Box(
                        Modifier.clip(RoundedCornerShape(12.dp))
                            .background(if (isLive) AppTheme.Colors.success.copy(alpha = 0.15f) else AppTheme.Colors.warning.copy(alpha = 0.15f))
                            .padding(horizontal = 16.dp, vertical = 8.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(Modifier.size(8.dp).background(if (isLive) AppTheme.Colors.success else AppTheme.Colors.warning, CircleShape))
                            Spacer(Modifier.width(8.dp))
                            Text(
                                if (isLive) "CANLI" else "Planlanmış",
                                fontWeight = FontWeight.Bold, fontSize = 14.sp,
                                color = if (isLive) AppTheme.Colors.success else AppTheme.Colors.warning
                            )
                        }
                    }

                    Spacer(Modifier.height(16.dp))
                    Text(currentSession.title, fontSize = 26.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText, textAlign = TextAlign.Center)
                    currentSession.trainerName?.let {
                        Spacer(Modifier.height(4.dp))
                        Text("Müəllim: $it", fontSize = 15.sp, color = AppTheme.Colors.secondaryText)
                    }
                }
            }

            // Info cards
            Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                InfoChip("⏱", "${currentSession.durationMinutes} dəq", Modifier.weight(1f))
                InfoChip("👥", "${currentSession.currentParticipants}/${currentSession.maxParticipants}", Modifier.weight(1f))
                InfoChip("📅", try { currentSession.scheduledAt.take(10) } catch (e: Exception) { "" }, Modifier.weight(1f))
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

            Spacer(Modifier.weight(1f))

            // Join/Leave button
            Box(Modifier.fillMaxWidth().padding(20.dp).padding(bottom = 20.dp)) {
                Button(
                    onClick = { viewModel.joinSession(currentSession.id) },
                    modifier = Modifier.fillMaxWidth().height(56.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                    shape = RoundedCornerShape(16.dp),
                    enabled = !isLoading && currentSession.status != "ended"
                ) {
                    if (isLoading) {
                        CircularProgressIndicator(color = Color.White, modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                    } else {
                        Text(if (currentSession.status == "live") "Sessiyaya Qoşul" else "Qeydiyyatdan Keç", fontSize = 16.sp, fontWeight = FontWeight.Bold)
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
fun InfoChip(emoji: String, value: String, modifier: Modifier = Modifier) {
    Box(
        modifier.clip(RoundedCornerShape(12.dp)).background(AppTheme.Colors.cardBackground).padding(12.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(emoji, fontSize = 20.sp)
            Spacer(Modifier.height(4.dp))
            Text(value, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
        }
    }
}
