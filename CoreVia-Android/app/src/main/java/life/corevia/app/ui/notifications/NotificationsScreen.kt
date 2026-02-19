package life.corevia.app.ui.notifications

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.animation.animateColorAsState
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
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.AppNotification

/**
 * iOS: NotificationsView.swift — bildiriş siyahısı
 * Oxunmuş/oxunmamış status, swipe-to-delete, mark all read
 */
@Composable
fun NotificationsScreen(
    viewModel: NotificationsViewModel,
    onBack: () -> Unit
) {
    val notifications by viewModel.notifications.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val unreadCount by viewModel.unreadCount.collectAsState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        Column(modifier = Modifier.fillMaxSize()) {

            // ── Header ──────────────────────────────────────────────────────────
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(
                                AppTheme.Colors.accent.copy(alpha = 0.15f),
                                Color.Transparent
                            )
                        )
                    )
                    .padding(horizontal = 16.dp)
                    .padding(top = 50.dp, bottom = 16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Geri",
                            tint = AppTheme.Colors.accent
                        )
                    }
                    Spacer(modifier = Modifier.width(8.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Filled.Notifications,
                                contentDescription = null,
                                tint = AppTheme.Colors.accent,
                                modifier = Modifier.size(24.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "Bildirişlər",
                                fontSize = 24.sp,
                                fontWeight = FontWeight.Bold,
                                color = AppTheme.Colors.primaryText
                            )
                        }
                        if (unreadCount > 0) {
                            Text(
                                text = "$unreadCount oxunmamış bildiriş",
                                fontSize = 13.sp,
                                color = AppTheme.Colors.accent
                            )
                        }
                    }

                    // Mark all read button
                    if (unreadCount > 0) {
                        IconButton(onClick = { viewModel.markAllRead() }) {
                            Icon(
                                imageVector = Icons.Filled.Done,
                                contentDescription = "Hamısını oxu",
                                tint = AppTheme.Colors.accent
                            )
                        }
                    }
                }
            }

            // ── Content ─────────────────────────────────────────────────────────
            when {
                isLoading && notifications.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
                notifications.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("🔔", fontSize = 64.sp)
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(
                                text = "Bildirişiniz yoxdur",
                                color = AppTheme.Colors.primaryText,
                                fontSize = 18.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                            Text(
                                text = "Yeni bildirişlər burada görünəcək",
                                color = AppTheme.Colors.secondaryText,
                                fontSize = 14.sp
                            )
                        }
                    }
                }
                else -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        items(
                            items = notifications,
                            key = { it.id }
                        ) { notification ->
                            NotificationCard(
                                notification = notification,
                                onMarkRead = {
                                    if (!notification.isRead) {
                                        viewModel.markRead(notification.id)
                                    }
                                },
                                onDelete = { viewModel.deleteNotification(notification.id) }
                            )
                        }
                    }
                }
            }
        }

        // ── Success snackbar ────────────────────────────────────────────────────
        successMessage?.let { msg ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp)
                    .padding(bottom = 60.dp),
                containerColor = AppTheme.Colors.success,
                action = {
                    TextButton(onClick = { viewModel.clearSuccess() }) {
                        Text("OK", color = Color.White)
                    }
                }
            ) {
                Text(msg, color = Color.White)
            }
        }

        // ── Error snackbar ──────────────────────────────────────────────────────
        errorMessage?.let { error ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp)
                    .padding(bottom = 60.dp),
                containerColor = AppTheme.Colors.error,
                action = {
                    TextButton(onClick = { viewModel.clearError() }) {
                        Text("Bağla", color = Color.White)
                    }
                }
            ) {
                Text(error, color = Color.White)
            }
        }
    }
}

// ─── NotificationCard ────────────────────────────────────────────────────────
@Composable
fun NotificationCard(
    notification: AppNotification,
    onMarkRead: () -> Unit,
    onDelete: () -> Unit
) {
    var showDeleteConfirm by remember { mutableStateOf(false) }

    val bgColor by animateColorAsState(
        targetValue = if (notification.isRead) AppTheme.Colors.cardBackground
        else AppTheme.Colors.cardBackground.copy(alpha = 0.9f),
        label = "notif_bg"
    )

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(bgColor)
            .clickable(onClick = onMarkRead)
            .padding(16.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Icon
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .background(
                        color = notificationIconColor(notification.type).copy(alpha = 0.15f),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = notificationIcon(notification.type),
                    contentDescription = null,
                    tint = notificationIconColor(notification.type),
                    modifier = Modifier.size(22.dp)
                )
            }

            // Content
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    // Unread dot
                    if (!notification.isRead) {
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .background(AppTheme.Colors.accent, CircleShape)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                    }
                    Text(
                        text = notification.title,
                        fontSize = 15.sp,
                        fontWeight = if (notification.isRead) FontWeight.Medium else FontWeight.Bold,
                        color = AppTheme.Colors.primaryText,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = notification.message,
                    fontSize = 13.sp,
                    color = AppTheme.Colors.secondaryText,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = formatNotificationTime(notification.createdAt),
                    fontSize = 11.sp,
                    color = AppTheme.Colors.tertiaryText
                )
            }

            // Delete button
            IconButton(
                onClick = { showDeleteConfirm = true },
                modifier = Modifier.size(32.dp)
            ) {
                Icon(
                    imageVector = Icons.Filled.Close,
                    contentDescription = "Sil",
                    tint = AppTheme.Colors.tertiaryText,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }

    // Delete confirmation
    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("Bildirişi sil?", color = AppTheme.Colors.primaryText) },
            text = { Text("Bu bildiriş silinəcək.", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = {
                    showDeleteConfirm = false
                    onDelete()
                }) {
                    Text("Sil", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirm = false }) {
                    Text("Ləğv et", color = AppTheme.Colors.secondaryText)
                }
            },
            containerColor = AppTheme.Colors.secondaryBackground
        )
    }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
private fun notificationIcon(type: String): ImageVector {
    return when {
        type.contains("workout") -> Icons.Filled.Star
        type.contains("plan")    -> Icons.Filled.DateRange
        type.contains("chat") || type.contains("message") -> Icons.Filled.Email
        type.contains("food")    -> Icons.Filled.Favorite
        type.contains("achievement") -> Icons.Filled.Star
        else                     -> Icons.Filled.Notifications
    }
}

private fun notificationIconColor(type: String): Color {
    return when {
        type.contains("workout") -> AppTheme.Colors.accent
        type.contains("plan")    -> AppTheme.Colors.success
        type.contains("chat") || type.contains("message") -> Color(0xFF007AFF)
        type.contains("food")    -> AppTheme.Colors.warning
        type.contains("achievement") -> Color(0xFFFF9500)
        else                     -> AppTheme.Colors.accent
    }
}

private fun formatNotificationTime(dateString: String): String {
    return try {
        val date = dateString.take(10)
        val time = dateString.substring(11, 16)
        val today = java.time.LocalDate.now().toString()
        val yesterday = java.time.LocalDate.now().minusDays(1).toString()
        when (date) {
            today     -> "Bu gün, $time"
            yesterday -> "Dünən, $time"
            else      -> "$date $time"
        }
    } catch (e: Exception) {
        ""
    }
}
