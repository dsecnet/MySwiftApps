package life.corevia.app.ui.news

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.NewsArticle

@Composable
fun NewsScreen(
    viewModel: NewsViewModel,
    onBack: () -> Unit,
    onArticleSelected: (NewsArticle) -> Unit
) {
    val articles by viewModel.articles.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val selectedCategory by viewModel.selectedCategory.collectAsState()

    val filteredArticles = viewModel.filteredArticles
    val featuredArticles = viewModel.featuredArticles

    val categories = listOf("fitness", "nutrition", "health", "lifestyle")
    val categoryLabels = mapOf(
        "fitness" to "Fitness",
        "nutrition" to "Qidalanma",
        "health" to "Sağlamlıq",
        "lifestyle" to "Həyat tərzi"
    )

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(modifier = Modifier.fillMaxSize()) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Header
            Box(
                modifier = Modifier.fillMaxWidth()
                    .background(Brush.verticalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.15f), Color.Transparent)))
                    .padding(horizontal = 16.dp).padding(top = 50.dp, bottom = 16.dp)
            ) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = onBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                        }
                        Spacer(Modifier.width(8.dp))
                        Text("Xəbərlər", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                    }

                    Spacer(Modifier.height(12.dp))

                    // Category filters
                    LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        item {
                            FilterChip(
                                selected = selectedCategory == null,
                                onClick = { viewModel.selectCategory(null) },
                                label = { Text("Hamısı", fontSize = 12.sp) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = AppTheme.Colors.accent,
                                    selectedLabelColor = Color.White,
                                    containerColor = AppTheme.Colors.cardBackground,
                                    labelColor = AppTheme.Colors.secondaryText
                                )
                            )
                        }
                        items(categories) { cat ->
                            FilterChip(
                                selected = selectedCategory == cat,
                                onClick = { viewModel.selectCategory(if (selectedCategory == cat) null else cat) },
                                label = { Text(categoryLabels[cat] ?: cat, fontSize = 12.sp) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = AppTheme.Colors.accent,
                                    selectedLabelColor = Color.White,
                                    containerColor = AppTheme.Colors.cardBackground,
                                    labelColor = AppTheme.Colors.secondaryText
                                )
                            )
                        }
                    }
                }
            }

            when {
                isLoading && articles.isEmpty() -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
                articles.isEmpty() -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("📰", fontSize = 64.sp)
                            Spacer(Modifier.height(16.dp))
                            Text("Xəbər tapılmadı", color = AppTheme.Colors.primaryText, fontSize = 18.sp, fontWeight = FontWeight.SemiBold)
                            Text("Yeni xəbərlər tezliklə əlavə olunacaq", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                        }
                    }
                }
                else -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        // Featured articles
                        if (featuredArticles.isNotEmpty() && selectedCategory == null) {
                            item {
                                Text("Seçilmiş", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                                Spacer(Modifier.height(8.dp))
                            }
                            items(featuredArticles, key = { "featured_${it.id}" }) { article ->
                                FeaturedArticleCard(article) {
                                    viewModel.selectArticle(article)
                                    onArticleSelected(article)
                                }
                            }
                            item {
                                Spacer(Modifier.height(8.dp))
                                Text("Bütün xəbərlər", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
                            }
                        }

                        items(filteredArticles, key = { it.id }) { article ->
                            ArticleCard(article) {
                                viewModel.selectArticle(article)
                                onArticleSelected(article)
                            }
                        }

                        item { Spacer(Modifier.height(80.dp)) }
                    }
                }
            }
        }
    }
    } // CoreViaAnimatedBackground
}

@Composable
fun FeaturedArticleCard(article: NewsArticle, onClick: () -> Unit) {
    Box(
        modifier = Modifier.fillMaxWidth().height(180.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(Brush.horizontalGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.3f), AppTheme.Colors.accent.copy(alpha = 0.1f))))
            .clickable(onClick = onClick).padding(16.dp)
    ) {
        Column(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.SpaceBetween) {
            Column {
                Box(
                    Modifier.clip(RoundedCornerShape(6.dp))
                        .background(AppTheme.Colors.accent.copy(alpha = 0.2f))
                        .padding(horizontal = 8.dp, vertical = 2.dp)
                ) {
                    Text("⭐ Seçilmiş", fontSize = 11.sp, color = AppTheme.Colors.accent, fontWeight = FontWeight.Bold)
                }
                Spacer(Modifier.height(8.dp))
                Text(
                    article.title, fontSize = 20.sp, fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText, maxLines = 2, overflow = TextOverflow.Ellipsis
                )
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                article.source?.let {
                    Text(it, fontSize = 12.sp, color = AppTheme.Colors.secondaryText)
                    Spacer(Modifier.width(12.dp))
                }
                article.readingTime?.let {
                    Text("$it dəq oxu", fontSize = 12.sp, color = AppTheme.Colors.tertiaryText)
                }
            }
        }
    }
}

@Composable
fun ArticleCard(article: NewsArticle, onClick: () -> Unit) {
    Box(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground).clickable(onClick = onClick).padding(16.dp)
    ) {
        Row {
            // Article image placeholder
            Box(
                modifier = Modifier.size(80.dp).clip(RoundedCornerShape(12.dp))
                    .background(AppTheme.Colors.accent.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    when (article.category) {
                        "fitness" -> "💪"
                        "nutrition" -> "🥗"
                        "health" -> "❤️"
                        "lifestyle" -> "🌟"
                        else -> "📰"
                    },
                    fontSize = 28.sp
                )
            }

            Spacer(Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    article.title, fontSize = 15.sp, fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText, maxLines = 2, overflow = TextOverflow.Ellipsis
                )
                article.summary?.let {
                    Spacer(Modifier.height(4.dp))
                    Text(it, fontSize = 13.sp, color = AppTheme.Colors.secondaryText, maxLines = 2, overflow = TextOverflow.Ellipsis)
                }
                Spacer(Modifier.height(6.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    article.source?.let {
                        Text(it, fontSize = 11.sp, color = AppTheme.Colors.tertiaryText)
                        Spacer(Modifier.width(8.dp))
                    }
                    article.readingTime?.let {
                        Text("$it dəq", fontSize = 11.sp, color = AppTheme.Colors.tertiaryText)
                    }
                }
            }
        }
    }
}
