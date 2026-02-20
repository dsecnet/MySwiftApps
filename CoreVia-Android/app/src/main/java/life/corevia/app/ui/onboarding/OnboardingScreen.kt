package life.corevia.app.ui.onboarding

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch

/**
 * iOS: OnboardingView.swift — 4 səhifəlik HorizontalPager
 * welcome → workout → nutrition → ready
 */

data class OnboardingPage(
    val emoji: String,
    val title: String,
    val description: String,
    val icon: ImageVector,
    val color: Color
)

@Composable
fun OnboardingScreen(
    onComplete: () -> Unit
) {
    val pages = listOf(
        OnboardingPage(
            emoji = "🏋️",
            title = "CoreVia-ya Xoş Gəlmisiniz!",
            description = "Sağlamlıq və fitnes səyahətinizə başlayın. Şəxsi məşq planları, qida izləmə və daha çoxu.",
            icon = Icons.Outlined.Home,
            color = AppTheme.Colors.accent
        ),
        OnboardingPage(
            emoji = "💪",
            title = "Şəxsi Məşqlər",
            description = "Məqsədlərinizə uyğun məşq planları alın. İrəliləyişinizi izləyin və motivasiya olun.",
            icon = Icons.Outlined.Star,
            color = AppTheme.Colors.success
        ),
        OnboardingPage(
            emoji = "🥗",
            title = "Qida İzləmə",
            description = "Gündəlik qida qəbulunuzu izləyin. AI ilə qida analizi edin və sağlam qidalanın.",
            icon = Icons.Outlined.Favorite,
            color = AppTheme.Colors.warning
        ),
        OnboardingPage(
            emoji = "🚀",
            title = "Hazırsınız!",
            description = "İndi başlayın! Müəllim tapın, plan seçin və hədəflərinizə çatın.",
            icon = Icons.Filled.Check,
            color = AppTheme.Colors.accent
        )
    )

    val pagerState = rememberPagerState(pageCount = { pages.size })
    val coroutineScope = rememberCoroutineScope()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Skip button
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 50.dp, end = 20.dp),
                horizontalArrangement = Arrangement.End
            ) {
                if (pagerState.currentPage < pages.size - 1) {
                    TextButton(onClick = onComplete) {
                        Text("Keç", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                    }
                }
            }

            // Pager
            HorizontalPager(
                state = pagerState,
                modifier = Modifier.weight(1f)
            ) { page ->
                OnboardingPageContent(pages[page])
            }

            // Page indicators
            Row(
                modifier = Modifier.padding(bottom = 24.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                pages.indices.forEach { index ->
                    Box(
                        modifier = Modifier
                            .size(if (index == pagerState.currentPage) 24.dp else 8.dp, 8.dp)
                            .clip(CircleShape)
                            .background(
                                if (index == pagerState.currentPage) AppTheme.Colors.accent
                                else AppTheme.Colors.separator
                            )
                    )
                }
            }

            // Bottom button
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
                    .padding(bottom = 40.dp)
            ) {
                if (pagerState.currentPage == pages.size - 1) {
                    // Last page: Başla button
                    Button(
                        onClick = onComplete,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(56.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                        shape = RoundedCornerShape(16.dp)
                    ) {
                        Text(
                            text = "Başla!",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                } else {
                    // Next button
                    Button(
                        onClick = {
                            coroutineScope.launch {
                                pagerState.animateScrollToPage(pagerState.currentPage + 1)
                            }
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(56.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                        shape = RoundedCornerShape(16.dp)
                    ) {
                        Text(
                            text = "Növbəti",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                            contentDescription = null,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun OnboardingPageContent(page: OnboardingPage) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Emoji
        Text(
            text = page.emoji,
            fontSize = 80.sp,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        // Icon with glow
        Box(contentAlignment = Alignment.Center) {
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .background(
                        page.color.copy(alpha = 0.15f),
                        CircleShape
                    )
            )
            Icon(
                imageVector = page.icon,
                contentDescription = null,
                tint = page.color,
                modifier = Modifier.size(40.dp)
            )
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Title
        Text(
            text = page.title,
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center,
            lineHeight = 34.sp
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Description
        Text(
            text = page.description,
            fontSize = 16.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center,
            lineHeight = 24.sp
        )
    }
}
