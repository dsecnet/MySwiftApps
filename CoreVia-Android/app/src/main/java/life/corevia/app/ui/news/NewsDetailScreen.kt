package life.corevia.app.ui.news

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun NewsDetailScreen(
    viewModel: NewsViewModel,
    onBack: () -> Unit
) {
    val article by viewModel.selectedArticle.collectAsState()
    val currentArticle = article ?: return

    val categoryLabels = mapOf(
        "fitness" to "Fitness",
        "nutrition" to "Qidalanma",
        "health" to "Sağlamlıq",
        "lifestyle" to "Həyat tərzi"
    )

    Box(modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background)) {
        Column(
            modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())
        ) {
            // Header
            Box(
                modifier = Modifier.fillMaxWidth()
                    .background(Brush.verticalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.2f), Color.Transparent)))
                    .padding(horizontal = 16.dp).padding(top = 50.dp, bottom = 24.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = onBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                        }
                        Spacer(Modifier.weight(1f))
                    }

                    // Category badge
                    Box(
                        Modifier.clip(RoundedCornerShape(8.dp))
                            .background(AppTheme.Colors.accent.copy(alpha = 0.15f))
                            .padding(horizontal = 12.dp, vertical = 4.dp)
                    ) {
                        Text(
                            categoryLabels[currentArticle.category] ?: currentArticle.category,
                            fontSize = 12.sp, color = AppTheme.Colors.accent, fontWeight = FontWeight.SemiBold
                        )
                    }

                    Spacer(Modifier.height(12.dp))

                    // Title
                    Text(
                        currentArticle.title, fontSize = 24.sp, fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText, textAlign = TextAlign.Center,
                        lineHeight = 32.sp
                    )

                    Spacer(Modifier.height(12.dp))

                    // Author & read time
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        currentArticle.author?.let {
                            Text(it, fontSize = 14.sp, color = AppTheme.Colors.secondaryText, fontWeight = FontWeight.Medium)
                        }
                        if (currentArticle.author != null && currentArticle.readTime != null) {
                            Text(" · ", fontSize = 14.sp, color = AppTheme.Colors.tertiaryText)
                        }
                        currentArticle.readTime?.let {
                            Text("$it dəq oxu", fontSize = 14.sp, color = AppTheme.Colors.tertiaryText)
                        }
                    }

                    // Date
                    currentArticle.createdAt?.let { date ->
                        Spacer(Modifier.height(4.dp))
                        Text(
                            try { date.take(10) } catch (e: Exception) { "" },
                            fontSize = 12.sp, color = AppTheme.Colors.tertiaryText
                        )
                    }
                }
            }

            // Summary
            currentArticle.summary?.let { summary ->
                Box(
                    Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(AppTheme.Colors.accent.copy(alpha = 0.08f))
                        .padding(16.dp)
                ) {
                    Text(
                        summary, fontSize = 15.sp, color = AppTheme.Colors.primaryText,
                        fontWeight = FontWeight.Medium, lineHeight = 24.sp
                    )
                }
            }

            // Content
            currentArticle.content?.let { content ->
                Spacer(Modifier.height(16.dp))
                Box(
                    Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(AppTheme.Colors.cardBackground)
                        .padding(16.dp)
                ) {
                    Text(
                        content, fontSize = 15.sp, color = AppTheme.Colors.secondaryText,
                        lineHeight = 26.sp
                    )
                }
            }

            Spacer(Modifier.height(40.dp))
        }
    }
}
