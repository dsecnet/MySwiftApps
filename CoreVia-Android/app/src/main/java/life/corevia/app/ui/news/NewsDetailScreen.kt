package life.corevia.app.ui.news

import android.content.Intent
import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
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
    val bookmarkedIds by viewModel.bookmarkedIds.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val context = LocalContext.current

    val currentArticle = article ?: return
    val isBookmarked = bookmarkedIds.contains(currentArticle.id)

    // Reading time estimate: use backend value or calculate from text (~200 wpm)
    val readingTime = currentArticle.readingTime
        ?: run {
            val totalWords = (currentArticle.summary?.split("\\s+".toRegex())?.size ?: 0) +
                             (currentArticle.content?.split("\\s+".toRegex())?.size ?: 0)
            (totalWords / 200).coerceAtLeast(1)
        }

    val categoryIcon = when (currentArticle.category.lowercase()) {
        "workout" -> Icons.Outlined.FitnessCenter
        "nutrition" -> Icons.Outlined.Restaurant
        "research" -> Icons.Outlined.Science
        "tips" -> Icons.Outlined.Lightbulb
        "lifestyle" -> Icons.Outlined.FavoriteBorder
        "health" -> Icons.Outlined.HealthAndSafety
        else -> Icons.Outlined.Article
    }

    val categoryLabel = when (currentArticle.category.lowercase()) {
        "workout" -> "Məşq"
        "nutrition" -> "Qidalanma"
        "research" -> "Araşdırma"
        "tips" -> "Məsləhətlər"
        "lifestyle" -> "Həyat Tərzi"
        "health" -> "Sağlamlıq"
        "fitness" -> "Fitness"
        else -> currentArticle.category
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())
        ) {
            // Header
            Box(
                modifier = Modifier.fillMaxWidth()
                    .background(Brush.verticalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.15f), Color.Transparent)))
                    .padding(horizontal = 16.dp).padding(top = 50.dp, bottom = 24.dp)
            ) {
                Column {
                    // Top bar with back, bookmark, share
                    Row(
                        Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        IconButton(onClick = onBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                        }
                        Row {
                            // Bookmark button
                            IconButton(onClick = { viewModel.toggleBookmark(currentArticle) }) {
                                Icon(
                                    if (isBookmarked) Icons.Filled.Bookmark else Icons.Outlined.BookmarkBorder,
                                    if (isBookmarked) "Əlfəcini sil" else "Əlfəcinlə",
                                    tint = if (isBookmarked) AppTheme.Colors.accent else AppTheme.Colors.secondaryText
                                )
                            }
                            // Share button
                            IconButton(onClick = {
                                val shareText = "${currentArticle.title}\n\n${currentArticle.summary ?: ""}\n\nCoreVia App vasitəsilə"
                                val shareIntent = Intent(Intent.ACTION_SEND).apply {
                                    type = "text/plain"
                                    putExtra(Intent.EXTRA_TEXT, shareText)
                                    putExtra(Intent.EXTRA_SUBJECT, currentArticle.title)
                                }
                                context.startActivity(Intent.createChooser(shareIntent, "Paylaş"))
                            }) {
                                Icon(Icons.Outlined.Share, "Paylaş", tint = AppTheme.Colors.secondaryText)
                            }
                        }
                    }

                    Spacer(Modifier.height(12.dp))

                    // Category + Reading time badges
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        Box(
                            Modifier.clip(RoundedCornerShape(8.dp))
                                .background(AppTheme.Colors.accent.copy(alpha = 0.15f))
                                .padding(horizontal = 10.dp, vertical = 4.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(categoryIcon, null, Modifier.size(14.dp), tint = AppTheme.Colors.accent)
                                Spacer(Modifier.width(4.dp))
                                Text(categoryLabel, fontSize = 12.sp, color = AppTheme.Colors.accent, fontWeight = FontWeight.SemiBold)
                            }
                        }
                        Box(
                            Modifier.clip(RoundedCornerShape(8.dp))
                                .background(AppTheme.Colors.cardBackground)
                                .padding(horizontal = 10.dp, vertical = 4.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Outlined.Schedule, null, Modifier.size(14.dp), tint = AppTheme.Colors.secondaryText)
                                Spacer(Modifier.width(4.dp))
                                Text("$readingTime dəq oxuma", fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
                            }
                        }
                    }

                    Spacer(Modifier.height(16.dp))

                    // Title
                    Text(
                        currentArticle.title, fontSize = 24.sp, fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText, lineHeight = 32.sp
                    )

                    Spacer(Modifier.height(8.dp))

                    // Source & date
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        currentArticle.source?.let { src ->
                            Text(src, fontSize = 13.sp, color = AppTheme.Colors.accent, fontWeight = FontWeight.Medium)
                            Spacer(Modifier.width(8.dp))
                            Box(Modifier.size(4.dp).background(AppTheme.Colors.separator, CircleShape))
                            Spacer(Modifier.width(8.dp))
                        }
                        currentArticle.publishedAt?.let { date ->
                            Text(
                                try { date.take(10) } catch (e: Exception) { "" },
                                fontSize = 13.sp, color = AppTheme.Colors.tertiaryText
                            )
                        }
                    }
                }
            }

            // Image placeholder with description
            Box(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                    .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground)
                    .height(180.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(categoryIcon, null, Modifier.size(48.dp), tint = AppTheme.Colors.accent.copy(alpha = 0.3f))
                    currentArticle.imageDescription?.let { desc ->
                        if (desc.isNotBlank()) {
                            Spacer(Modifier.height(8.dp))
                            Text(desc, fontSize = 12.sp, color = AppTheme.Colors.tertiaryText,
                                textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 16.dp))
                        }
                    }
                }
            }

            // Summary highlight
            currentArticle.summary?.let { summary ->
                Spacer(Modifier.height(16.dp))
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

            // Full content
            currentArticle.content?.let { content ->
                if (content != currentArticle.summary && content.isNotBlank()) {
                    Spacer(Modifier.height(16.dp))
                    Box(
                        Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                            .clip(RoundedCornerShape(16.dp)).background(AppTheme.Colors.cardBackground).padding(20.dp)
                    ) {
                        Text(content, fontSize = 15.sp, color = AppTheme.Colors.secondaryText, lineHeight = 26.sp)
                    }
                }
            }

            // Reading time info card
            Spacer(Modifier.height(16.dp))
            Box(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(AppTheme.Colors.cardBackground).padding(16.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Outlined.MenuBook, null, Modifier.size(24.dp), tint = AppTheme.Colors.accent)
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text("Oxuma müddəti", fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
                        Text("$readingTime dəqiqə", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.accent)
                    }
                    Spacer(Modifier.weight(1f))
                    val wordCount = (currentArticle.summary?.split("\\s+".toRegex())?.size ?: 0) +
                                    (currentArticle.content?.split("\\s+".toRegex())?.size ?: 0)
                    if (wordCount > 0) {
                        Column(horizontalAlignment = Alignment.End) {
                            Text("Söz sayı", fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
                            Text("~$wordCount", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                        }
                    }
                }
            }

            Spacer(Modifier.height(40.dp))
        }

        // Snackbar
        successMessage?.let { msg ->
            Snackbar(Modifier.align(Alignment.BottomCenter).padding(16.dp), containerColor = AppTheme.Colors.success) {
                Text(msg, color = Color.White)
            }
            LaunchedEffect(msg) { kotlinx.coroutines.delay(2000); viewModel.clearSuccess() }
        }
    }
    } // CoreViaAnimatedBackground
}
