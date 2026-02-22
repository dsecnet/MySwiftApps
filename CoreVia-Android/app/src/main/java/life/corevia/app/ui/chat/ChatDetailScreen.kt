package life.corevia.app.ui.chat

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Done
import androidx.compose.material.icons.filled.DoneAll
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material.icons.outlined.Person
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
import kotlinx.coroutines.launch
import life.corevia.app.data.models.ChatMessage

/**
 * iOS: ChatDetailView.swift — mesaj axını
 * Sent mesajlar sağda (accent), received mesajlar solda (secondary)
 */
@Composable
fun ChatDetailScreen(
    viewModel: ChatViewModel,
    onBack: () -> Unit
) {
    val messages by viewModel.messages.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val messageLimit by viewModel.messageLimit.collectAsState()
    val userName by viewModel.activeChatUserName.collectAsState()
    val activeUserId by viewModel.activeChatUserId.collectAsState()

    var inputText by remember { mutableStateOf("") }
    val listState = rememberLazyListState()
    val coroutineScope = rememberCoroutineScope()

    // Auto-scroll to bottom on new messages
    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(messages.size - 1)
        }
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Column(
        modifier = Modifier
            .fillMaxSize()
    ) {
        // ── Header ──────────────────────────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppTheme.Colors.secondaryBackground)
                .padding(top = 50.dp, bottom = 12.dp)
                .padding(horizontal = 16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Back button
                IconButton(onClick = onBack) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Geri",
                        tint = AppTheme.Colors.accent
                    )
                }

                // Avatar
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .background(
                            brush = Brush.linearGradient(
                                colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                            ),
                            shape = CircleShape
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    val initials = userName
                        .split(" ")
                        .take(2)
                        .mapNotNull { it.firstOrNull()?.uppercaseChar() }
                        .joinToString("")
                    if (initials.isNotEmpty()) {
                        Text(
                            text = initials,
                            color = Color.White,
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    } else {
                        Icon(
                            imageVector = Icons.Outlined.Person,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }

                // Name
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = userName,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText
                    )
                    // Message limit info
                    messageLimit?.let { limit ->
                        Text(
                            text = "Qalan: ${limit.remaining}/${limit.dailyLimit} mesaj",
                            fontSize = 11.sp,
                            color = if (limit.remaining <= 5) AppTheme.Colors.warning
                            else AppTheme.Colors.secondaryText
                        )
                    }
                }
            }
        }

        // ── Messages ────────────────────────────────────────────────────────────
        Box(modifier = Modifier.weight(1f)) {
            when {
                isLoading && messages.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
                messages.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("💬", fontSize = 48.sp)
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "Hələ mesaj yoxdur",
                                color = AppTheme.Colors.secondaryText,
                                fontSize = 14.sp
                            )
                            Text(
                                text = "İlk mesajı siz göndərin!",
                                color = AppTheme.Colors.tertiaryText,
                                fontSize = 12.sp
                            )
                        }
                    }
                }
                else -> {
                    LazyColumn(
                        state = listState,
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(horizontal = 12.dp),
                        contentPadding = PaddingValues(vertical = 12.dp),
                        verticalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        items(messages, key = { it.id }) { message ->
                            // currentUser-in ID-si olmadığı üçün receiver_id ilə müqayisə
                            val isSent = message.receiverId == activeUserId
                            MessageBubble(
                                message = message,
                                isSent = isSent
                            )
                        }
                    }
                }
            }

            // Error snackbar
            errorMessage?.let { error ->
                Snackbar(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(16.dp),
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

        // ── Message limit warning ───────────────────────────────────────────────
        messageLimit?.let { limit ->
            if (limit.remaining <= 0) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppTheme.Colors.warning.copy(alpha = 0.15f))
                        .padding(8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.Info,
                            contentDescription = null,
                            tint = AppTheme.Colors.warning,
                            modifier = Modifier.size(16.dp)
                        )
                        Text(
                            text = "Günlük mesaj limitinə çatdınız",
                            color = AppTheme.Colors.warning,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }
        }

        // ── Input Row ───────────────────────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppTheme.Colors.secondaryBackground)
                .padding(horizontal = 12.dp, vertical = 8.dp)
                .padding(bottom = 20.dp) // safe area
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Text field
                OutlinedTextField(
                    value = inputText,
                    onValueChange = { inputText = it },
                    modifier = Modifier.weight(1f),
                    placeholder = {
                        Text(
                            "Mesaj yazın...",
                            color = AppTheme.Colors.placeholderText
                        )
                    },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText,
                        cursorColor = AppTheme.Colors.accent,
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedContainerColor = AppTheme.Colors.cardBackground,
                        unfocusedContainerColor = AppTheme.Colors.cardBackground
                    ),
                    shape = RoundedCornerShape(24.dp),
                    maxLines = 4,
                    enabled = (messageLimit?.remaining ?: 1) > 0
                )

                // Send button
                IconButton(
                    onClick = {
                        if (inputText.isNotBlank()) {
                            viewModel.sendMessage(inputText.trim())
                            inputText = ""
                        }
                    },
                    enabled = inputText.isNotBlank() && (messageLimit?.remaining ?: 1) > 0,
                    modifier = Modifier
                        .size(48.dp)
                        .background(
                            color = if (inputText.isNotBlank()) AppTheme.Colors.accent
                            else AppTheme.Colors.cardBackground,
                            shape = CircleShape
                        )
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.Send,
                        contentDescription = "Göndər",
                        tint = if (inputText.isNotBlank()) Color.White
                        else AppTheme.Colors.tertiaryText,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }
    }
    } // CoreViaAnimatedBackground
}

// ─── MessageBubble ───────────────────────────────────────────────────────────
@Composable
fun MessageBubble(
    message: ChatMessage,
    isSent: Boolean
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isSent) Arrangement.End else Arrangement.Start
    ) {
        Box(
            modifier = Modifier
                .widthIn(max = 280.dp)
                .clip(
                    RoundedCornerShape(
                        topStart = 16.dp,
                        topEnd = 16.dp,
                        bottomStart = if (isSent) 16.dp else 4.dp,
                        bottomEnd = if (isSent) 4.dp else 16.dp
                    )
                )
                .background(
                    if (isSent) AppTheme.Colors.accent
                    else AppTheme.Colors.cardBackground
                )
                .padding(horizontal = 14.dp, vertical = 10.dp)
        ) {
            Column {
                Text(
                    text = message.message,
                    color = if (isSent) Color.White else AppTheme.Colors.primaryText,
                    fontSize = 15.sp
                )
                Spacer(modifier = Modifier.height(2.dp))
                // Vaxt + oxundu isaresi
                Row(
                    modifier = Modifier.align(Alignment.End),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(3.dp)
                ) {
                    Text(
                        text = formatMessageTime(message.createdAt),
                        color = if (isSent) Color.White.copy(alpha = 0.7f)
                        else AppTheme.Colors.tertiaryText,
                        fontSize = 10.sp
                    )
                    // Gonderilmis mesajlarda oxundu isaresi (double checkmark)
                    if (isSent) {
                        Icon(
                            imageVector = if (message.isRead) Icons.Filled.DoneAll else Icons.Filled.Done,
                            contentDescription = if (message.isRead) "Oxundu" else "Gonderildi",
                            tint = if (message.isRead) Color.White
                            else Color.White.copy(alpha = 0.5f),
                            modifier = Modifier.size(14.dp)
                        )
                    }
                }
            }
        }
    }
}

private fun formatMessageTime(dateString: String): String {
    return try {
        if (dateString.length < 16) return ""
        dateString.substring(11, 16)  // "14:30"
    } catch (e: Exception) {
        ""
    }
}
