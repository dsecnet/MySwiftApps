package life.corevia.app.ui.theme

import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.composed
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// ─── Modifier Extension: Təkmilləşdirilmiş kart stili ──────────────────────
/**
 * Pinterest-dən ilhamlanmış kart stili:
 * - Yüngül kölgə (depth effekti)
 * - İncə haşiyə (kart ayrılığı)
 * - Mövcud secondaryBackground saxlanır
 */
fun Modifier.coreViaCard(
    accentColor: Color = Color.Unspecified,
    cornerRadius: Dp = 14.dp,
    backgroundColor: Color = Color.Unspecified
): Modifier = composed {
    val resolvedAccent = if (accentColor == Color.Unspecified) AppTheme.Colors.accent else accentColor
    val resolvedBg = if (backgroundColor == Color.Unspecified) AppTheme.Colors.secondaryBackground else backgroundColor
    this
        .shadow(
            elevation = 4.dp,
            shape = RoundedCornerShape(cornerRadius),
            ambientColor = resolvedAccent.copy(alpha = 0.06f),
            spotColor = resolvedAccent.copy(alpha = 0.06f)
        )
        .background(resolvedBg, RoundedCornerShape(cornerRadius))
        .border(
            width = 0.5.dp,
            color = resolvedAccent.copy(alpha = 0.08f),
            shape = RoundedCornerShape(cornerRadius)
        )
}

// ─── İkon Badge: Emoji əvəzinə Material Icon badge ─────────────────────────
/**
 * Material Icon → rəngli yuvarlaq kvadrat fond içində.
 * Emoji əvəzinə daha professional görünüş verir.
 */
@Composable
fun CoreViaIconBadge(
    icon: ImageVector,
    modifier: Modifier = Modifier,
    tintColor: Color = AppTheme.Colors.accent,
    size: Dp = 36.dp,
    iconSize: Dp = 18.dp,
    cornerRadius: Dp = 10.dp
) {
    Box(
        modifier = modifier
            .size(size)
            .background(tintColor.copy(alpha = 0.15f), RoundedCornerShape(cornerRadius)),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(iconSize),
            tint = tintColor
        )
    }
}

// ─── Gradient Progress Bar ──────────────────────────────────────────────────
/**
 * Canvas ilə çəkilən gradient progress bar.
 * LinearProgressIndicator-dan daha gözəl görünür.
 */
@Composable
fun CoreViaGradientProgressBar(
    progress: Float,
    modifier: Modifier = Modifier,
    height: Dp = 8.dp,
    trackColor: Color = AppTheme.Colors.accent.copy(alpha = 0.15f),
    gradientColors: List<Color> = listOf(
        AppTheme.Colors.accent.copy(alpha = 0.7f),
        AppTheme.Colors.accent
    )
) {
    val animatedProgress by animateFloatAsState(
        targetValue = progress.coerceIn(0f, 1f),
        animationSpec = tween(durationMillis = 600, easing = EaseOutCubic),
        label = "progress"
    )

    Canvas(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .clip(RoundedCornerShape(height / 2))
    ) {
        // Track (arxa plan)
        drawRoundRect(
            color = trackColor,
            cornerRadius = CornerRadius(size.height / 2)
        )
        // Gradient progress (ön plan)
        if (animatedProgress > 0f) {
            drawRoundRect(
                brush = Brush.horizontalGradient(gradientColors),
                size = Size(size.width * animatedProgress, size.height),
                cornerRadius = CornerRadius(size.height / 2)
            )
        }
    }
}

// ─── Section Header ─────────────────────────────────────────────────────────
/**
 * Təkmilləşdirilmiş bölmə başlığı:
 * - Başlıq + opsional alt-başlıq
 * - İncə separator xətti
 * - Opsional sağ tərəf elementi
 */
@Composable
fun CoreViaSectionHeader(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    trailing: @Composable (() -> Unit)? = null
) {
    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
                if (subtitle != null) {
                    Text(
                        text = subtitle,
                        fontSize = 12.sp,
                        color = AppTheme.Colors.secondaryText
                    )
                }
            }
            trailing?.invoke()
        }
        Spacer(modifier = Modifier.height(6.dp))
        HorizontalDivider(
            color = AppTheme.Colors.separator.copy(alpha = 0.3f),
            thickness = 0.5.dp
        )
    }
}

// ─── Animated Background: Canvas gradient + geometric pattern ────────────────
/**
 * Ekranlar üçün dekorativ arxa plan:
 * - Radial gradient glow (yuxarı-sol)
 * - Corner glow (yuxarı-sağ)
 * - Diaqonal incə xətlər
 * - Aşağıdan yuxarıya fade
 * Dark theme-ə mükəmməl uyğundur.
 */
@Composable
fun CoreViaAnimatedBackground(
    modifier: Modifier = Modifier,
    accentColor: Color = AppTheme.Colors.accent,
    content: @Composable BoxScope.() -> Unit
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        // Background pattern canvas
        Canvas(modifier = Modifier.fillMaxSize()) {
            val w = size.width
            val h = size.height

            // 1. Top-left radial gradient glow (böyük, aydın)
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        accentColor.copy(alpha = 0.18f),
                        accentColor.copy(alpha = 0.06f),
                        Color.Transparent
                    ),
                    center = Offset(w * 0.1f, h * 0.06f),
                    radius = w * 0.7f
                ),
                radius = w * 0.7f,
                center = Offset(w * 0.1f, h * 0.06f)
            )

            // 2. Top-right corner glow
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        accentColor.copy(alpha = 0.12f),
                        accentColor.copy(alpha = 0.03f),
                        Color.Transparent
                    ),
                    center = Offset(w * 0.92f, h * 0.04f),
                    radius = w * 0.4f
                ),
                radius = w * 0.4f,
                center = Offset(w * 0.92f, h * 0.04f)
            )

            // 3. Diagonal lines pattern (daha görünən)
            val lineSpacing = 35f
            val lineColor = accentColor.copy(alpha = 0.07f)
            var offset = -h
            while (offset < w + h) {
                drawLine(
                    color = lineColor,
                    start = Offset(offset, 0f),
                    end = Offset(offset + h, h),
                    strokeWidth = 1f
                )
                offset += lineSpacing
            }

            // 4. Bottom-center glow
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        accentColor.copy(alpha = 0.10f),
                        accentColor.copy(alpha = 0.03f),
                        Color.Transparent
                    ),
                    center = Offset(w * 0.5f, h * 0.85f),
                    radius = w * 0.5f
                ),
                radius = w * 0.5f,
                center = Offset(w * 0.5f, h * 0.85f)
            )

            // 5. Center accent orb
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        accentColor.copy(alpha = 0.08f),
                        Color.Transparent
                    ),
                    center = Offset(w * 0.5f, h * 0.4f),
                    radius = w * 0.35f
                ),
                radius = w * 0.35f,
                center = Offset(w * 0.5f, h * 0.4f)
            )
        }

        // Actual content
        content()
    }
}
