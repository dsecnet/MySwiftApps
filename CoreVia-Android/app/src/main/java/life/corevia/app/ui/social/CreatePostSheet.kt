package life.corevia.app.ui.social

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * iOS: CreatePostSheet — content textarea + post type + "Paylaş" button
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreatePostSheet(
    onDismiss: () -> Unit,
    onPost: (content: String, postType: String) -> Unit,
    isLoading: Boolean
) {
    var content by remember { mutableStateOf("") }
    var selectedType by remember { mutableStateOf("general") }

    val postTypes = listOf(
        "general" to "Ümumi",
        "workout" to "💪 Məşq",
        "achievement" to "🏆 Nailiyyət"
    )

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = AppTheme.Colors.background,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppTheme.Colors.secondaryText) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp)
        ) {
            Text(
                text = "Yeni Post",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText,
                modifier = Modifier.padding(bottom = 16.dp)
            )

            // Post type chips
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                postTypes.forEach { (type, label) ->
                    FilterChip(
                        selected = selectedType == type,
                        onClick = { selectedType = type },
                        label = { Text(label, fontSize = 13.sp) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = AppTheme.Colors.accent,
                            selectedLabelColor = AppTheme.Colors.primaryText,
                            containerColor = AppTheme.Colors.cardBackground,
                            labelColor = AppTheme.Colors.secondaryText
                        )
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Content
            OutlinedTextField(
                value = content,
                onValueChange = { content = it },
                placeholder = {
                    Text(
                        "Nə düşünürsünüz?",
                        color = AppTheme.Colors.placeholderText
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(150.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = AppTheme.Colors.primaryText,
                    unfocusedTextColor = AppTheme.Colors.primaryText,
                    cursorColor = AppTheme.Colors.accent,
                    focusedBorderColor = AppTheme.Colors.accent,
                    unfocusedBorderColor = AppTheme.Colors.separator,
                    focusedContainerColor = AppTheme.Colors.cardBackground,
                    unfocusedContainerColor = AppTheme.Colors.cardBackground
                ),
                shape = RoundedCornerShape(16.dp),
                maxLines = 8
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Post button
            Button(
                onClick = { onPost(content.trim(), selectedType) },
                enabled = content.isNotBlank() && !isLoading,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = AppTheme.Colors.accent,
                    disabledContainerColor = AppTheme.Colors.accent.copy(alpha = 0.3f)
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        color = AppTheme.Colors.primaryText,
                        modifier = Modifier.size(20.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Text(
                        text = "Paylaş",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}
