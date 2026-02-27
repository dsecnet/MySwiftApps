package life.corevia.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.ui.theme.CoreViaPrimary

@Composable
fun CoreViaFilterChip(
    title: String,
    isSelected: Boolean,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    color: Color = CoreViaPrimary,
    onClick: () -> Unit
) {
    val backgroundColor = if (isSelected) color else color.copy(alpha = 0.15f)
    val contentColor = if (isSelected) Color.White else color

    Row(
        modifier = modifier
            .clip(RoundedCornerShape(20.dp))
            .background(backgroundColor)
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center
    ) {
        if (icon != null) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(14.dp),
                tint = contentColor
            )
            Spacer(modifier = Modifier.width(5.dp))
        }
        Text(
            text = title,
            fontSize = if (icon != null) 13.sp else 14.sp,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Bold,
            color = contentColor
        )
    }
}
