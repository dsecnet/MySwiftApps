package life.corevia.app.ui.components

import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import life.corevia.app.ui.theme.*

/**
 * Standard error dialog — iOS UIAlertController equivalent.
 *
 * Shows an error icon, title ("Xəta"), the error [message],
 * and optional Retry / Dismiss action buttons.
 * When [onRetry] is null the retry button is hidden.
 */
@Composable
fun ErrorDialog(
    message: String,
    onDismiss: () -> Unit,
    onRetry: (() -> Unit)? = null
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        icon = {
            Icon(
                imageVector = Icons.Filled.ErrorOutline,
                contentDescription = "Xəta",
                tint = CoreViaError,
                modifier = Modifier.size(40.dp)
            )
        },
        title = {
            Text(
                text = "Xəta",
                fontWeight = FontWeight.SemiBold,
                color = TextPrimary
            )
        },
        text = {
            Text(
                text = message,
                color = TextSecondary
            )
        },
        confirmButton = {
            if (onRetry != null) {
                TextButton(
                    onClick = {
                        onDismiss()
                        onRetry()
                    },
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = CoreViaPrimary
                    )
                ) {
                    Text(
                        text = "Yenidən cəhd et",
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        },
        dismissButton = {
            TextButton(
                onClick = onDismiss,
                colors = ButtonDefaults.textButtonColors(
                    contentColor = TextSecondary
                )
            ) {
                Text("Bağla")
            }
        },
        containerColor = CoreViaSurface,
        titleContentColor = TextPrimary,
        textContentColor = TextSecondary
    )
}
