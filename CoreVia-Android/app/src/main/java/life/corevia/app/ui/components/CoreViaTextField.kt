package life.corevia.app.ui.components

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import life.corevia.app.ui.theme.*

@Composable
fun CoreViaTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    placeholder: String = "",
    isError: Boolean = false,
    errorMessage: String? = null,
    enabled: Boolean = true,
    singleLine: Boolean = true,
    maxLines: Int = if (singleLine) 1 else Int.MAX_VALUE,
    leadingIcon: @Composable (() -> Unit)? = null,
    trailingIcon: @Composable (() -> Unit)? = null,
    visualTransformation: VisualTransformation = VisualTransformation.None
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        placeholder = if (placeholder.isNotEmpty()) {
            { Text(placeholder, color = TextHint) }
        } else null,
        modifier = modifier.fillMaxWidth(),
        isError = isError,
        enabled = enabled,
        singleLine = singleLine,
        maxLines = maxLines,
        leadingIcon = leadingIcon,
        trailingIcon = trailingIcon,
        visualTransformation = visualTransformation,
        shape = RoundedCornerShape(Layout.cornerRadiusM),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = CoreViaPrimary,
            unfocusedBorderColor = TextSeparator,
            errorBorderColor = CoreViaError,
            focusedLabelColor = CoreViaPrimary,
            unfocusedLabelColor = TextSecondary,
            cursorColor = CoreViaPrimary,
            disabledBorderColor = TextSeparator.copy(alpha = 0.5f),
            disabledTextColor = TextHint,
            disabledLabelColor = TextHint
        ),
        supportingText = if (isError && errorMessage != null) {
            { Text(errorMessage, color = CoreViaError) }
        } else null
    )
}
