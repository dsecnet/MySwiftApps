package life.corevia.app.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarHalf
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.ui.theme.*

/**
 * Reusable star rating component — iOS RatingStarsView equivalent.
 *
 * Supports both interactive (tap to rate) and read-only modes.
 * When [onRatingChange] is null the component is read-only.
 * Fractional [rating] values render half-stars in read-only mode.
 */
@Composable
fun RatingStars(
    rating: Double,
    modifier: Modifier = Modifier,
    maxRating: Int = 5,
    onRatingChange: ((Int) -> Unit)? = null,
    size: Dp = 24.dp,
    showLabel: Boolean = false
) {
    val isInteractive = onRatingChange != null

    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(Layout.spacingXS)
    ) {
        for (index in 1..maxRating) {
            val icon = when {
                // Full star
                index <= rating.toInt() -> Icons.Filled.Star
                // Half star (only in read-only mode for fractional values)
                !isInteractive && index == rating.toInt() + 1 && (rating % 1) >= 0.25 && (rating % 1) < 0.75 -> Icons.Filled.StarHalf
                // Also full if fraction >= 0.75
                !isInteractive && index == rating.toInt() + 1 && (rating % 1) >= 0.75 -> Icons.Filled.Star
                // Empty star
                else -> Icons.Outlined.StarOutline
            }

            val tint = if (icon == Icons.Outlined.StarOutline) StarEmpty else StarFilled

            val starModifier = Modifier
                .size(size)
                .then(
                    if (isInteractive) {
                        Modifier.clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null
                        ) { onRatingChange?.invoke(index) }
                    } else {
                        Modifier
                    }
                )

            Icon(
                imageVector = icon,
                contentDescription = "Star $index",
                tint = tint,
                modifier = starModifier
            )
        }

        if (showLabel) {
            Text(
                text = String.format("%.1f", rating),
                fontSize = TypographySizes.caption,
                color = TextSecondary
            )
        }
    }
}

/**
 * Convenience overload accepting an Int rating for interactive use-cases.
 */
@Composable
fun RatingStars(
    rating: Int,
    modifier: Modifier = Modifier,
    maxRating: Int = 5,
    onRatingChange: ((Int) -> Unit)? = null,
    size: Dp = 24.dp,
    showLabel: Boolean = false
) {
    RatingStars(
        rating = rating.toDouble(),
        modifier = modifier,
        maxRating = maxRating,
        onRatingChange = onRatingChange,
        size = size,
        showLabel = showLabel
    )
}
