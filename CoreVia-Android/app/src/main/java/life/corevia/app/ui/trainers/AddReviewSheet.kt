package life.corevia.app.ui.trainers

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * iOS: AddReviewSheet — 1-5 ulduz seçimi + comment + "Göndər"
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddReviewSheet(
    onDismiss: () -> Unit,
    onSubmit: (rating: Int, comment: String?) -> Unit,
    isLoading: Boolean
) {
    var rating by remember { mutableIntStateOf(0) }
    var comment by remember { mutableStateOf("") }

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
                .padding(bottom = 40.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Rəy Yazın",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText,
                modifier = Modifier.padding(bottom = 20.dp)
            )

            // Star rating
            Text(
                text = "Qiymətləndirmə",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = AppTheme.Colors.secondaryText,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.padding(bottom = 20.dp)
            ) {
                repeat(5) { index ->
                    Icon(
                        imageVector = Icons.Outlined.Star,
                        contentDescription = "Ulduz ${index + 1}",
                        tint = if (index < rating) AppTheme.Colors.starFilled
                        else AppTheme.Colors.starEmpty,
                        modifier = Modifier
                            .size(40.dp)
                            .clickable { rating = index + 1 }
                    )
                }
            }

            // Rating text
            if (rating > 0) {
                Text(
                    text = when (rating) {
                        1 -> "Zəif"
                        2 -> "Orta"
                        3 -> "Yaxşı"
                        4 -> "Əla"
                        5 -> "Mükəmməl!"
                        else -> ""
                    },
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AppTheme.Colors.accent,
                    modifier = Modifier.padding(bottom = 16.dp)
                )
            }

            // Comment
            OutlinedTextField(
                value = comment,
                onValueChange = { comment = it },
                placeholder = {
                    Text("Rəyinizi yazın (isteğe bağlı)...", color = AppTheme.Colors.placeholderText)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp),
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
                maxLines = 5
            )

            Spacer(modifier = Modifier.height(24.dp))

            // Submit
            Button(
                onClick = { onSubmit(rating, comment.ifBlank { null }) },
                enabled = rating > 0 && !isLoading,
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
                        text = "Göndər",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}
