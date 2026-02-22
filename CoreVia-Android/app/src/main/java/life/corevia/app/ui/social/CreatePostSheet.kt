package life.corevia.app.ui.social

import android.net.Uri
import life.corevia.app.ui.theme.AppTheme
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * iOS: CreatePostSheet — content textarea + post type + image picker + "Paylas" button
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreatePostSheet(
    onDismiss: () -> Unit,
    onPost: (content: String, postType: String, imageUri: Uri?) -> Unit,
    isLoading: Boolean
) {
    var content by remember { mutableStateOf("") }
    var selectedType by remember { mutableStateOf("general") }
    var selectedImageUri by remember { mutableStateOf<Uri?>(null) }

    val postTypes = listOf(
        "general" to "Umumi",
        "workout" to "Mesq",
        "achievement" to "Nailiyyet"
    )

    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        selectedImageUri = uri
    }

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
                        "Ne dusunursunuz?",
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

            Spacer(modifier = Modifier.height(12.dp))

            // Image picker section
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Add photo button
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(AppTheme.Colors.cardBackground)
                        .clickable {
                            photoPickerLauncher.launch(
                                PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                            )
                        }
                        .padding(horizontal = 16.dp, vertical = 10.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.PhotoCamera,
                            contentDescription = "Sekil elave et",
                            tint = AppTheme.Colors.accent,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = "Sekil elave et",
                            fontSize = 14.sp,
                            color = AppTheme.Colors.accent,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }

                // Selected image indicator
                if (selectedImageUri != null) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.CheckCircle,
                            contentDescription = null,
                            tint = AppTheme.Colors.success,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = "Sekil secildi",
                            fontSize = 13.sp,
                            color = AppTheme.Colors.success
                        )
                        // Remove image button
                        Icon(
                            imageVector = Icons.Outlined.Close,
                            contentDescription = "Sekili sil",
                            tint = AppTheme.Colors.tertiaryText,
                            modifier = Modifier
                                .size(18.dp)
                                .clickable { selectedImageUri = null }
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Post button
            Button(
                onClick = { onPost(content.trim(), selectedType, selectedImageUri) },
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
                        text = "Paylas",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}
