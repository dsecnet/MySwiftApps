package life.corevia.app.ui.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.ChatConversation
import life.corevia.app.data.model.ChatMessage
import life.corevia.app.ui.theme.*

@Composable
fun ConversationsScreen(
    viewModel: ConversationsViewModel = hiltViewModel(),
    onConversationClick: ((String, String) -> Unit)? = null
) {
    val uiState by viewModel.uiState.collectAsState()

    if (uiState.selectedConversation != null) {
        ChatDetailContent(
            conversation = uiState.selectedConversation!!,
            messages = uiState.messages,
            isLoading = uiState.isLoadingMessages,
            isSending = uiState.isSending,
            formatTime = viewModel::formatTime,
            onSend = viewModel::sendMessage,
            onBack = viewModel::closeConversation
        )
    } else {
        ConversationsContent(
            uiState = uiState,
            formatTime = viewModel::formatTime,
            onConversationClick = { conversation ->
                if (onConversationClick != null) {
                    onConversationClick(conversation.usersId, conversation.userName)
                } else {
                    viewModel.openConversation(conversation)
                }
            }
        )
    }
}

// ─── Conversations List ─────────────────────────────────────────────

@Composable
private fun ConversationsContent(
    uiState: ConversationsUiState,
    formatTime: (String?) -> String,
    onConversationClick: (ChatConversation) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(bottom = 80.dp)
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Spacer(modifier = Modifier.height(48.dp))

            // Header
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    text = "Mesajlar",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "Treneriniz ilə əlaqə saxlayın",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Message Limit
            if (uiState.messageLimit.remaining < uiState.messageLimit.limit) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(10.dp))
                        .background(
                            Brush.linearGradient(
                                listOf(Color(0xFF2196F3).copy(alpha = 0.05f), Color(0xFF2196F3).copy(alpha = 0.1f))
                            )
                        )
                        .border(1.dp, Color(0xFF2196F3).copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Info, null,
                        modifier = Modifier.size(16.dp),
                        tint = Color(0xFF2196F3)
                    )
                    Text(
                        text = "${uiState.messageLimit.remaining} mesaj hüququnuz qalıb",
                        fontSize = 13.sp,
                        color = Color(0xFF2196F3),
                        fontWeight = FontWeight.Medium
                    )
                }
            }

            // Content
            if (uiState.isLoading) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 60.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = CoreViaPrimary, modifier = Modifier.size(32.dp))
                }
            } else if (uiState.conversations.isEmpty()) {
                // Empty state
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 60.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(56.dp)
                            .clip(CircleShape)
                            .background(CoreViaPrimary.copy(alpha = 0.1f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Filled.ChatBubbleOutline, null,
                            modifier = Modifier.size(26.dp),
                            tint = CoreViaPrimary
                        )
                    }
                    Text(
                        text = "Hələ mesajınız yoxdur",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = "Trenerinizlə söhbətə başlayın",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                }
            } else {
                // Conversation list
                uiState.conversations.forEach { conversation ->
                    ConversationRow(
                        conversation = conversation,
                        formatTime = formatTime,
                        onClick = { onConversationClick(conversation) }
                    )
                }
            }
        }
    }
}

@Composable
private fun ConversationRow(
    conversation: ChatConversation,
    formatTime: (String?) -> String,
    onClick: () -> Unit
) {
    val isTrainer = conversation.isTrainer

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(
                if (isTrainer) CoreViaPrimary.copy(alpha = 0.05f)
                else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
            )
            .then(
                if (isTrainer) Modifier.border(1.dp, CoreViaPrimary.copy(alpha = 0.2f), RoundedCornerShape(12.dp))
                else Modifier
            )
            .clickable(onClick = onClick)
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Avatar
        Box(
            modifier = Modifier
                .size(46.dp)
                .clip(CircleShape)
                .background(
                    if (isTrainer) CoreViaPrimary.copy(alpha = 0.15f)
                    else MaterialTheme.colorScheme.surfaceVariant
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = conversation.userName.take(1).uppercase(),
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = if (isTrainer) CoreViaPrimary else MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(3.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = conversation.userName,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    if (isTrainer) {
                        Text(
                            text = "Trener",
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Medium,
                            color = CoreViaPrimary,
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(CoreViaPrimary.copy(alpha = 0.1f))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }
                Text(
                    text = formatTime(conversation.lastMessageTime),
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = conversation.lastMessage ?: "",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f)
                )
                if (conversation.unreadCount > 0) {
                    Box(
                        modifier = Modifier
                            .size(20.dp)
                            .clip(CircleShape)
                            .background(CoreViaPrimary),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "${conversation.unreadCount}",
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }
            }
        }

        Icon(
            Icons.Filled.ChevronRight, null,
            modifier = Modifier.size(14.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ─── Chat Detail ────────────────────────────────────────────────────

@Composable
private fun ChatDetailContent(
    conversation: ChatConversation,
    messages: List<ChatMessage>,
    isLoading: Boolean,
    isSending: Boolean,
    formatTime: (String?) -> String,
    onSend: (String) -> Unit,
    onBack: () -> Unit
) {
    var messageText by remember { mutableStateOf("") }
    val listState = rememberLazyListState()

    // Auto-scroll to bottom
    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(messages.size - 1)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // Top bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surface)
                .padding(start = 8.dp, end = 16.dp, top = 52.dp, bottom = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    Icons.Filled.ArrowBack, null,
                    tint = MaterialTheme.colorScheme.onBackground
                )
            }
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(CoreViaPrimary.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = conversation.userName.take(1).uppercase(),
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = CoreViaPrimary
                )
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = conversation.userName,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                if (conversation.isTrainer) {
                    Text(
                        text = "Trener",
                        fontSize = 11.sp,
                        color = CoreViaPrimary
                    )
                }
            }
        }

        // Messages
        if (isLoading) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = CoreViaPrimary, modifier = Modifier.size(28.dp))
            }
        } else if (messages.isEmpty()) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Icon(
                        Icons.Filled.ChatBubbleOutline, null,
                        modifier = Modifier.size(32.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                    )
                    Text(
                        text = "Söhbətə başlayın",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                state = listState,
                verticalArrangement = Arrangement.spacedBy(8.dp),
                contentPadding = PaddingValues(vertical = 12.dp)
            ) {
                items(messages, key = { it.id }) { message ->
                    val isSent = message.senderId != conversation.usersId
                    MessageBubble(
                        message = message,
                        isSent = isSent,
                        formatTime = formatTime
                    )
                }
            }
        }

        // Input bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surface)
                .padding(horizontal = 12.dp, vertical = 8.dp)
                .padding(bottom = 20.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            OutlinedTextField(
                value = messageText,
                onValueChange = { messageText = it },
                modifier = Modifier.weight(1f),
                placeholder = {
                    Text(
                        "Mesaj yazın...",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                    )
                },
                shape = RoundedCornerShape(20.dp),
                singleLine = false,
                maxLines = 3,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary,
                    unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f)
                )
            )

            Box(
                modifier = Modifier
                    .size(42.dp)
                    .clip(CircleShape)
                    .background(
                        if (messageText.isNotBlank()) CoreViaPrimary
                        else CoreViaPrimary.copy(alpha = 0.3f)
                    )
                    .clickable(enabled = messageText.isNotBlank() && !isSending) {
                        onSend(messageText)
                        messageText = ""
                    },
                contentAlignment = Alignment.Center
            ) {
                if (isSending) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(18.dp),
                        strokeWidth = 2.dp,
                        color = Color.White
                    )
                } else {
                    Icon(
                        Icons.Filled.Send, null,
                        modifier = Modifier.size(18.dp),
                        tint = Color.White
                    )
                }
            }
        }
    }
}

@Composable
private fun MessageBubble(
    message: ChatMessage,
    isSent: Boolean,
    formatTime: (String?) -> String
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = if (isSent) Alignment.End else Alignment.Start
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
                    if (isSent) CoreViaPrimary else MaterialTheme.colorScheme.surfaceVariant
                )
                .padding(horizontal = 14.dp, vertical = 10.dp)
        ) {
            Text(
                text = message.message,
                fontSize = 14.sp,
                color = if (isSent) Color.White else MaterialTheme.colorScheme.onSurface,
                lineHeight = 20.sp
            )
        }
        Spacer(modifier = Modifier.height(2.dp))
        Text(
            text = formatTime(message.createdAt),
            fontSize = 10.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f)
        )
    }
}
