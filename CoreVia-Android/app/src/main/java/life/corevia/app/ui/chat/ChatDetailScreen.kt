package life.corevia.app.ui.chat

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
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.ChatMessage
import life.corevia.app.ui.theme.*
import java.text.SimpleDateFormat
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatDetailScreen(
    onBack: () -> Unit,
    viewModel: ChatDetailViewModel = hiltViewModel()
) {
    val state by viewModel.uiState.collectAsState()
    val listState = rememberLazyListState()

    // Auto-scroll to bottom when new messages arrive
    LaunchedEffect(state.messages.size) {
        if (state.messages.isNotEmpty()) {
            listState.animateScrollToItem(state.messages.size - 1)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(state.userName, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        state.remainingMessages?.let { remaining ->
                            Text(
                                "$remaining mesaj qaldi",
                                fontSize = 12.sp,
                                color = if (remaining < 5) CoreViaError else TextSecondary
                            )
                        }
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
            )
        },
        bottomBar = {
            // ── Message Input Bar ──
            Surface(
                modifier = Modifier.fillMaxWidth(),
                tonalElevation = 8.dp,
                shadowElevation = 8.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 8.dp)
                        .navigationBarsPadding(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = state.messageText,
                        onValueChange = viewModel::updateMessageText,
                        placeholder = { Text("Mesaj yazin...", color = TextHint) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(24.dp),
                        maxLines = 4,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = CoreViaPrimary,
                            unfocusedBorderColor = TextSeparator
                        )
                    )

                    // Send button
                    IconButton(
                        onClick = { viewModel.sendMessage() },
                        enabled = state.messageText.trim().isNotEmpty() && !state.isSending,
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(
                                if (state.messageText.trim().isNotEmpty())
                                    Brush.linearGradient(listOf(CoreViaPrimary, CoreViaPrimaryLight))
                                else Brush.linearGradient(listOf(TextSeparator, TextSeparator))
                            )
                    ) {
                        if (state.isSending) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(20.dp),
                                color = Color.White,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Icon(
                                Icons.AutoMirrored.Filled.Send,
                                contentDescription = "Gonder",
                                tint = Color.White,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    }
                }
            }
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            if (state.isLoading && state.messages.isEmpty()) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center),
                    color = CoreViaPrimary
                )
            } else if (state.messages.isEmpty()) {
                // Empty state
                Column(
                    modifier = Modifier
                        .align(Alignment.Center)
                        .padding(40.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("Henuz mesaj yoxdur", fontSize = 16.sp, color = TextSecondary)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "Sohbete baslayaraq ilk mesajinizi gonderin!",
                        fontSize = 13.sp,
                        color = TextHint,
                        textAlign = TextAlign.Center
                    )
                }
            } else {
                LazyColumn(
                    state = listState,
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    contentPadding = PaddingValues(vertical = 12.dp)
                ) {
                    items(state.messages) { message ->
                        MessageBubble(
                            message = message,
                            isMe = message.senderId != state.userId
                        )
                    }
                }
            }

            // Error
            state.errorMessage?.let { error ->
                Snackbar(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(16.dp)
                ) {
                    Text(error)
                }
            }
        }
    }
}

@Composable
private fun MessageBubble(
    message: ChatMessage,
    isMe: Boolean
) {
    val bubbleColor = if (isMe)
        Brush.linearGradient(listOf(CoreViaPrimary, CoreViaPrimaryLight))
    else
        Brush.linearGradient(listOf(CoreViaSurface, CoreViaSurface))

    val textColor = if (isMe) Color.White else TextPrimary
    val timeColor = if (isMe) Color.White.copy(alpha = 0.7f) else TextHint

    val alignment = if (isMe) Arrangement.End else Arrangement.Start

    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = alignment
    ) {
        Box(
            modifier = Modifier
                .widthIn(max = 280.dp)
                .clip(
                    RoundedCornerShape(
                        topStart = 16.dp,
                        topEnd = 16.dp,
                        bottomStart = if (isMe) 16.dp else 4.dp,
                        bottomEnd = if (isMe) 4.dp else 16.dp
                    )
                )
                .background(bubbleColor)
                .padding(horizontal = 14.dp, vertical = 10.dp)
        ) {
            Column {
                Text(
                    text = message.message,
                    color = textColor,
                    fontSize = 14.sp,
                    lineHeight = 20.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = formatMessageTime(message.createdAt),
                    color = timeColor,
                    fontSize = 10.sp,
                    modifier = Modifier.align(Alignment.End)
                )
            }
        }
    }
}

private fun formatMessageTime(dateStr: String?): String {
    if (dateStr.isNullOrBlank()) return ""
    return try {
        val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
        val parsed = isoFormat.parse(dateStr) ?: return ""
        SimpleDateFormat("HH:mm", Locale.getDefault()).format(parsed)
    } catch (_: Exception) { "" }
}
