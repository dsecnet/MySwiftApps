package life.corevia.app.ui.social

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Person
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
import life.corevia.app.data.models.SocialComment

/**
 * iOS: CommentsSheet — şərhlər siyahısı + input
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CommentsSheet(
    viewModel: SocialViewModel,
    onDismiss: () -> Unit
) {
    val comments by viewModel.comments.collectAsState()
    var commentText by remember { mutableStateOf("") }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = AppTheme.Colors.background,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppTheme.Colors.secondaryText) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.7f)
        ) {
            // Header
            Text(
                text = "Şərhlər (${comments.size})",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText,
                modifier = Modifier.padding(horizontal = 20.dp, vertical = 12.dp)
            )

            // Comments list
            LazyColumn(
                modifier = Modifier.weight(1f),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                if (comments.isEmpty()) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(32.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "Hələ şərh yoxdur. İlk şərhi siz yazın!",
                                color = AppTheme.Colors.secondaryText,
                                fontSize = 14.sp
                            )
                        }
                    }
                }
                items(comments, key = { it.id }) { comment ->
                    CommentItem(comment)
                }
            }

            // Input row
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppTheme.Colors.secondaryBackground)
                    .padding(horizontal = 12.dp, vertical = 8.dp)
                    .padding(bottom = 20.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = commentText,
                        onValueChange = { commentText = it },
                        modifier = Modifier.weight(1f),
                        placeholder = {
                            Text("Şərh yazın...", color = AppTheme.Colors.placeholderText)
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
                        maxLines = 3,
                        singleLine = false
                    )

                    IconButton(
                        onClick = {
                            if (commentText.isNotBlank()) {
                                viewModel.createComment(commentText.trim())
                                commentText = ""
                            }
                        },
                        enabled = commentText.isNotBlank(),
                        modifier = Modifier
                            .size(44.dp)
                            .background(
                                color = if (commentText.isNotBlank()) AppTheme.Colors.accent
                                else AppTheme.Colors.cardBackground,
                                shape = CircleShape
                            )
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.Send,
                            contentDescription = "Göndər",
                            tint = if (commentText.isNotBlank()) Color.White
                            else AppTheme.Colors.tertiaryText,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun CommentItem(comment: SocialComment) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Avatar
        Box(
            modifier = Modifier
                .size(32.dp)
                .background(AppTheme.Colors.accent.copy(alpha = 0.3f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            val initial = (comment.userName ?: "?").firstOrNull()?.uppercaseChar() ?: '?'
            Text(
                text = "$initial",
                color = AppTheme.Colors.accent,
                fontWeight = FontWeight.Bold,
                fontSize = 12.sp
            )
        }

        Column(modifier = Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = comment.userName ?: "İstifadəçi",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AppTheme.Colors.primaryText
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = try { comment.createdAt.substring(11, 16) } catch (e: Exception) { "" },
                    fontSize = 11.sp,
                    color = AppTheme.Colors.tertiaryText
                )
            }
            Text(
                text = comment.content,
                fontSize = 14.sp,
                color = AppTheme.Colors.secondaryText,
                lineHeight = 20.sp
            )
        }
    }
}
