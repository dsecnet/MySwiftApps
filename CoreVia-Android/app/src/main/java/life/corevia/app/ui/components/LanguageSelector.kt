package life.corevia.app.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import life.corevia.app.ui.theme.*

/**
 * Language selector — iOS LanguageSelectorView equivalent.
 *
 * Displays 3 selectable chips for Azərbaycanca, English, Русский.
 * The currently selected language is highlighted with [CoreViaPrimary].
 */

private data class LanguageOption(
    val code: String,
    val label: String,
    val flag: String
)

private val languageOptions = listOf(
    LanguageOption("az", "Azərbaycanca", "\uD83C\uDDE6\uD83C\uDDFF"),
    LanguageOption("en", "English", "\uD83C\uDDEC\uD83C\uDDE7"),
    LanguageOption("ru", "Русский", "\uD83C\uDDF7\uD83C\uDDFA")
)

@Composable
fun LanguageSelector(
    selectedLanguage: String,
    onLanguageSelected: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(Layout.spacingS),
        verticalAlignment = Alignment.CenterVertically
    ) {
        languageOptions.forEach { option ->
            val isSelected = option.code == selectedLanguage

            if (isSelected) {
                Button(
                    onClick = { /* Already selected */ },
                    modifier = Modifier
                        .weight(1f)
                        .height(44.dp),
                    shape = RoundedCornerShape(Layout.cornerRadiusM),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CoreViaPrimary,
                        contentColor = Color.White
                    ),
                    elevation = ButtonDefaults.buttonElevation(
                        defaultElevation = 4.dp,
                        pressedElevation = 2.dp
                    )
                ) {
                    Text(
                        text = "${option.flag} ${option.label}",
                        fontWeight = FontWeight.SemiBold,
                        fontSize = TypographySizes.small,
                        maxLines = 1
                    )
                }
            } else {
                OutlinedButton(
                    onClick = { onLanguageSelected(option.code) },
                    modifier = Modifier
                        .weight(1f)
                        .height(44.dp),
                    shape = RoundedCornerShape(Layout.cornerRadiusM),
                    border = BorderStroke(1.dp, TextSeparator),
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = TextSecondary
                    )
                ) {
                    Text(
                        text = "${option.flag} ${option.label}",
                        fontWeight = FontWeight.Normal,
                        fontSize = TypographySizes.small,
                        maxLines = 1
                    )
                }
            }
        }
    }
}
