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
import androidx.compose.material.icons.outlined.*
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
import life.corevia.app.ui.theme.CoreViaAnimatedBackground

/**
 * iOS: NotificationsView.swift — bildiriş siyahısı
 * Oxunmuş/oxunmamış status, tarix qruplaması, tip-e uyğun icon, mark all read
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

    // Bildirişləri tarixə görə qrupla
    val groupedNotifications = remember(notifications) {
        groupNotificationsByDate(notifications)
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(
        modifier = Modifier
            .fillMaxSize()
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
                                imageVector = Icons.Outlined.Notifications,
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

                    // Hamısını oxunmuş et düyməsi
                    if (unreadCount > 0) {
                        IconButton(onClick = { viewModel.markAllRead() }) {
                            Icon(
                                imageVector = Icons.Outlined.DoneAll,
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
                            // Icon evezine
                            Box(
                                modifier = Modifier
                                    .size(80.dp)
                                    .background(
                                        AppTheme.Colors.accent.copy(alpha = 0.1f),
                                        CircleShape
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.NotificationsNone,
                                    contentDescription = null,
                                    tint = AppTheme.Colors.accent,
                                    modifier = Modifier.size(40.dp)
                                )
                            }
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
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        groupedNotifications.forEach { (dateLabel, notifs) ->
                            // Tarix qrup başlığı
                            item(key = "header_$dateLabel") {
                                NotificationDateHeader(dateLabel = dateLabel)
                            }

                            items(
                                items = notifs,
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

                            // Qruplar arası boşluq
                            item(key = "spacer_$dateLabel") {
                                Spacer(modifier = Modifier.height(8.dp))
                            }
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
    } // CoreViaAnimatedBackground
}

// ─── Tarix qrup başlığı ──────────────────────────────────────────────────────
@Composable
fun NotificationDateHeader(dateLabel: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp, horizontal = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .weight(1f)
                .height(0.5.dp)
                .background(AppTheme.Colors.separator)
        )
        Text(
            text = dateLabel,
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold,
            color = AppTheme.Colors.secondaryText,
            modifier = Modifier.padding(horizontal = 12.dp)
        )
        Box(
            modifier = Modifier
                .weight(1f)
                .height(0.5.dp)
                .background(AppTheme.Colors.separator)
        )
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
        else AppTheme.Colors.cardBackground,
        label = "notif_bg"
    )

    // Oxunmamış bildirişlər üçün sol tərəfdə accent xətt
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(bgColor)
            .clickable(onClick = onMarkRead)
    ) {
        // Oxunmamış göstərici - sol tərəfdə rəngli xətt
        if (!notification.isRead) {
            Box(
                modifier = Modifier
                    .width(3.dp)
                    .fillMaxHeight()
                    .background(
                        notificationIconColor(notification.type),
                        RoundedCornerShape(topStart = 16.dp, bottomStart = 16.dp)
                    )
                    .align(Alignment.CenterStart)
            )
        }

        Row(
            modifier = Modifier.padding(14.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Tip-ə uyğun icon
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .background(
                        color = notificationIconColor(notification.type).copy(alpha = 0.12f),
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
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    // Unread dot + title
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
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )

                    // Vaxt
                    Text(
                        text = formatNotificationTimeShort(notification.createdAt),
                        fontSize = 11.sp,
                        color = AppTheme.Colors.tertiaryText,
                        modifier = Modifier.padding(start = 8.dp)
                    )
                }

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = notification.message,
                    fontSize = 13.sp,
                    color = if (notification.isRead) AppTheme.Colors.tertiaryText
                    else AppTheme.Colors.secondaryText,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    lineHeight = 18.sp
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Alt row: tip etiketi + mark read / delete
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    // Tip etiketi
                    Box(
                        modifier = Modifier
                            .background(
                                notificationIconColor(notification.type).copy(alpha = 0.1f),
                                RoundedCornerShape(6.dp)
                            )
                            .padding(horizontal = 8.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = notificationTypeLabel(notification.type),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Medium,
                            color = notificationIconColor(notification.type)
                        )
                    }

                    Spacer(modifier = Modifier.weight(1f))

                    // Oxunmuş et düyməsi
                    if (!notification.isRead) {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(AppTheme.Colors.accent.copy(alpha = 0.1f))
                                .clickable { onMarkRead() }
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.Done,
                                    contentDescription = null,
                                    tint = AppTheme.Colors.accent,
                                    modifier = Modifier.size(12.dp)
                                )
                                Text(
                                    text = "Oxundu",
                                    fontSize = 10.sp,
                                    color = AppTheme.Colors.accent,
                                    fontWeight = FontWeight.Medium
                                )
                            }
                        }
                    }

                    // Sil düyməsi
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .clickable { showDeleteConfirm = true }
                            .padding(4.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.Close,
                            contentDescription = "Sil",
                            tint = AppTheme.Colors.tertiaryText,
                            modifier = Modifier.size(14.dp)
                        )
                    }
                }
            }
        }
    }

    // Delete confirmation dialog
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

// Tip-ə uyğun icon seçimi (genişləndirilmiş)
private fun notificationIcon(type: String): ImageVector {
    return when {
        type.contains("workout") || type.contains("workout_reminder")
            -> Icons.Outlined.FitnessCenter
        type.contains("meal") || type.contains("meal_reminder") || type.contains("food")
            -> Icons.Outlined.Restaurant
        type.contains("plan") || type.contains("training")
            -> Icons.Outlined.DateRange
        type.contains("chat") || type.contains("message") || type.contains("new_message")
            -> Icons.Outlined.Email
        type.contains("trainer_message") || type.contains("trainer")
            -> Icons.Outlined.Person
        type.contains("weekly_report") || type.contains("report")
            -> Icons.Outlined.Assessment
        type.contains("achievement") || type.contains("badge")
            -> Icons.Outlined.EmojiEvents
        type.contains("premium") || type.contains("promo")
            -> Icons.Outlined.Star
        type.contains("review") || type.contains("new_review")
            -> Icons.Outlined.RateReview
        type.contains("subscriber") || type.contains("new_subscriber")
            -> Icons.Outlined.PersonAdd
        type.contains("route") || type.contains("route_assigned")
            -> Icons.Outlined.Map
        type.contains("system")
            -> Icons.Outlined.Info
        else -> Icons.Outlined.Notifications
    }
}

// Tip-ə uyğun rəng seçimi (genişləndirilmiş)
@Composable
private fun notificationIconColor(type: String): Color {
    return when {
        type.contains("workout") || type.contains("workout_reminder")
            -> AppTheme.Colors.accent
        type.contains("meal") || type.contains("meal_reminder") || type.contains("food")
            -> AppTheme.Colors.warning
        type.contains("plan") || type.contains("training")
            -> AppTheme.Colors.success
        type.contains("chat") || type.contains("message") || type.contains("new_message")
            -> AppTheme.Colors.statDistance
        type.contains("trainer_message") || type.contains("trainer")
            -> AppTheme.Colors.statSpeed
        type.contains("weekly_report") || type.contains("report")
            -> AppTheme.Colors.info
        type.contains("achievement") || type.contains("badge")
            -> AppTheme.Colors.warning
        type.contains("premium") || type.contains("promo")
            -> AppTheme.Colors.accent
        type.contains("review") || type.contains("new_review")
            -> AppTheme.Colors.starFilled
        type.contains("subscriber") || type.contains("new_subscriber")
            -> AppTheme.Colors.success
        type.contains("route") || type.contains("route_assigned")
            -> AppTheme.Colors.statDistance
        type.contains("system")
            -> AppTheme.Colors.info
        else -> AppTheme.Colors.accent
    }
}

// Tip etiketi (Azərbaycan dilində)
private fun notificationTypeLabel(type: String): String {
    return when {
        type.contains("workout_reminder") -> "Məşq"
        type.contains("meal_reminder")    -> "Qida"
        type.contains("weekly_report")    -> "Hesabat"
        type.contains("trainer_message")  -> "Trener"
        type.contains("new_message")      -> "Mesaj"
        type.contains("premium")          -> "Premium"
        type.contains("new_review")       -> "Rəy"
        type.contains("new_subscriber")   -> "Abunəçi"
        type.contains("route_assigned")   -> "Marşrut"
        type.contains("system")           -> "Sistem"
        type.contains("achievement")      -> "Nailiyyət"
        type.contains("plan")             -> "Plan"
        type.contains("chat")             -> "Söhbət"
        else                              -> "Bildiriş"
    }
}

// Qısa vaxt formatı (kart içində istifadə üçün)
private fun formatNotificationTimeShort(dateString: String): String {
    return try {
        val date = dateString.take(10)
        val time = dateString.substring(11, 16)
        val today = java.time.LocalDate.now()
        val msgDate = java.time.LocalDate.parse(date)

        val msgHour = dateString.substring(11, 13).toIntOrNull() ?: 0
        val msgMin = dateString.substring(14, 16).toIntOrNull() ?: 0
        val now = java.time.LocalDateTime.now()

        when {
            msgDate == today -> {
                val diffMinutes = java.time.Duration.between(
                    java.time.LocalDateTime.of(msgDate, java.time.LocalTime.of(msgHour, msgMin)),
                    now
                ).toMinutes()
                when {
                    diffMinutes < 1 -> "indi"
                    diffMinutes < 60 -> "${diffMinutes}d əvvəl"
                    else -> time
                }
            }
            msgDate == today.minusDays(1) -> "dünən"
            else -> date.substring(5) // "02-19"
        }
    } catch (e: Exception) {
        ""
    }
}

// Bildirişləri tarixə görə qrupla (Bu gün, Dünən, Əvvəlki)
private fun groupNotificationsByDate(
    notifications: List<AppNotification>
): List<Pair<String, List<AppNotification>>> {
    if (notifications.isEmpty()) return emptyList()

    val today = java.time.LocalDate.now().toString()
    val yesterday = java.time.LocalDate.now().minusDays(1).toString()

    val groups = linkedMapOf<String, MutableList<AppNotification>>()

    for (notification in notifications) {
        val dateStr = try {
            notification.createdAt.take(10)
        } catch (e: Exception) {
            ""
        }

        val label = when (dateStr) {
            today     -> "Bu gün"
            yesterday -> "Dünən"
            else      -> "Əvvəlki"
        }

        groups.getOrPut(label) { mutableListOf() }.add(notification)
    }

    return groups.map { (label, notifs) -> label to notifs.toList() }
}
