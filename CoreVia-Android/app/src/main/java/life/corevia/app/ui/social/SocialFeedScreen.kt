package life.corevia.app.ui.social

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.SocialPost

/**
 * iOS: SocialFeedView.swift — post siyahisi + FAB + follow + user profile navigation
 */
@Composable
fun SocialFeedScreen(
    viewModel: SocialViewModel,
    onBack: () -> Unit,
    onNavigateToUserProfile: (String) -> Unit = {},
    onNavigateToAchievements: () -> Unit = {}
) {
    val posts by viewModel.posts.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()
    val showCreatePost by viewModel.showCreatePost.collectAsState()
    val showComments by viewModel.showComments.collectAsState()

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(
        modifier = Modifier
            .fillMaxSize()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // ── Header ──────────────────────────────────────────────────────────
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(
                                AppTheme.Colors.accent.copy(alpha = 0.15f),
                                Color.Transparent
                            )
                        )
                    )
                    .padding(horizontal = 16.dp)
                    .padding(top = 50.dp, bottom = 16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Geri",
                            tint = AppTheme.Colors.accent
                        )
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    Icon(
                        imageVector = Icons.Outlined.Person,
                        contentDescription = null,
                        tint = AppTheme.Colors.accent,
                        modifier = Modifier.size(28.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Ictimaiyyet",
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText
                    )
                    Spacer(modifier = Modifier.weight(1f))
                    // Achievements button
                    IconButton(onClick = onNavigateToAchievements) {
                        Icon(
                            imageVector = Icons.Outlined.EmojiEvents,
                            contentDescription = "Nailiyyetler",
                            tint = AppTheme.Colors.accent
                        )
                    }
                }
            }

            // ── Content ─────────────────────────────────────────────────────────
            when {
                isLoading && posts.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
                posts.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(Icons.Outlined.Forum, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(64.dp))
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(
                                text = "Hele post yoxdur",
                                color = AppTheme.Colors.primaryText,
                                fontSize = 18.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                            Text(
                                text = "Ilk postu siz paylasin!",
                                color = AppTheme.Colors.secondaryText,
                                fontSize = 14.sp
                            )
                        }
                    }
                }
                else -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(posts, key = { it.id }) { post ->
                            PostCard(
                                post = post,
                                onLike = { viewModel.toggleLike(post.id) },
                                onComment = { viewModel.openComments(post.id) },
                                onDelete = { viewModel.deletePost(post.id) },
                                onUserTap = { onNavigateToUserProfile(post.userId) },
                                onFollow = { viewModel.followUser(post.userId) }
                            )
                        }
                        // Bottom padding for FAB
                        item { Spacer(modifier = Modifier.height(80.dp)) }
                    }
                }
            }
        }

        // ── FAB ─────────────────────────────────────────────────────────────────
        FloatingActionButton(
            onClick = { viewModel.setShowCreatePost(true) },
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(20.dp)
                .padding(bottom = 60.dp),
            containerColor = AppTheme.Colors.accent,
            contentColor = Color.White
        ) {
            Icon(Icons.Outlined.Add, contentDescription = "Yeni post")
        }

        // ── Create Post Sheet ───────────────────────────────────────────────────
        if (showCreatePost) {
            CreatePostSheet(
                onDismiss = { viewModel.setShowCreatePost(false) },
                onPost = { content, type, imageUri -> viewModel.createPost(content, type, imageUri) },
                isLoading = isLoading
            )
        }

        // ── Comments Sheet ──────────────────────────────────────────────────────
        if (showComments) {
            CommentsSheet(
                viewModel = viewModel,
                onDismiss = { viewModel.closeComments() }
            )
        }

        // ── Snackbars ───────────────────────────────────────────────────────────
        successMessage?.let { msg ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp)
                    .padding(bottom = 60.dp),
                containerColor = AppTheme.Colors.success
            ) { Text(msg, color = Color.White) }
            LaunchedEffect(msg) {
                kotlinx.coroutines.delay(2000)
                viewModel.clearSuccess()
            }
        }
        errorMessage?.let { error ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp)
                    .padding(bottom = 60.dp),
                containerColor = AppTheme.Colors.error,
                action = {
                    TextButton(onClick = { viewModel.clearError() }) {
                        Text("Bagla", color = Color.White)
                    }
                }
            ) { Text(error, color = Color.White) }
        }
    }
    } // CoreViaAnimatedBackground
}

// ─── PostCard ────────────────────────────────────────────────────────────────
@Composable
fun PostCard(
    post: SocialPost,
    onLike: () -> Unit,
    onComment: () -> Unit,
    onDelete: () -> Unit,
    onUserTap: () -> Unit = {},
    onFollow: () -> Unit = {}
) {
    var showDeleteConfirm by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground)
            .padding(16.dp)
    ) {
        Column {
            // Header: avatar + name + time + follow
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                // Avatar (clickable to profile)
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .background(
                            brush = Brush.linearGradient(
                                colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                            ),
                            shape = CircleShape
                        )
                        .clickable { onUserTap() },
                    contentAlignment = Alignment.Center
                ) {
                    val initials = (post.userName ?: "?")
                        .split(" ")
                        .take(2)
                        .mapNotNull { it.firstOrNull()?.uppercaseChar() }
                        .joinToString("")
                    Text(
                        text = initials.ifEmpty { "?" },
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp
                    )
                }

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = post.userName ?: "Istifadeci",
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = AppTheme.Colors.primaryText,
                        modifier = Modifier.clickable { onUserTap() }
                    )
                    Text(
                        text = formatPostTime(post.createdAt),
                        fontSize = 11.sp,
                        color = AppTheme.Colors.tertiaryText
                    )
                }

                // Post type badge
                if (post.postType != "general") {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(AppTheme.Colors.accent.copy(alpha = 0.15f))
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = when (post.postType) {
                                "workout" -> "Mesq"
                                "achievement" -> "Nailiyyet"
                                else -> post.postType
                            },
                            fontSize = 11.sp,
                            color = AppTheme.Colors.accent
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Content
            Text(
                text = post.content ?: "",
                fontSize = 15.sp,
                color = AppTheme.Colors.primaryText,
                lineHeight = 22.sp
            )

            // Image indicator (if post has image)
            if (!post.imageUrl.isNullOrBlank()) {
                Spacer(modifier = Modifier.height(8.dp))
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(160.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(AppTheme.Colors.accent.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            imageVector = Icons.Outlined.Image,
                            contentDescription = null,
                            tint = AppTheme.Colors.accent,
                            modifier = Modifier.size(32.dp)
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Sekil",
                            fontSize = 12.sp,
                            color = AppTheme.Colors.accent
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Action row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                // Like
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.clickable(onClick = onLike)
                ) {
                    Icon(
                        imageVector = if (post.isLiked) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                        contentDescription = "Beyen",
                        tint = if (post.isLiked) AppTheme.Colors.accent else AppTheme.Colors.tertiaryText,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "${post.likeCount}",
                        fontSize = 13.sp,
                        color = if (post.isLiked) AppTheme.Colors.accent else AppTheme.Colors.secondaryText
                    )
                }

                // Comment
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.clickable(onClick = onComment)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Email,
                        contentDescription = "Serh",
                        tint = AppTheme.Colors.tertiaryText,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "${post.commentCount}",
                        fontSize = 13.sp,
                        color = AppTheme.Colors.secondaryText
                    )
                }

                Spacer(modifier = Modifier.weight(1f))

                // Delete (only show menu icon)
                IconButton(
                    onClick = { showDeleteConfirm = true },
                    modifier = Modifier.size(24.dp)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.MoreVert,
                        contentDescription = "Daha cox",
                        tint = AppTheme.Colors.tertiaryText,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }

    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("Postu sil?", color = AppTheme.Colors.primaryText) },
            text = { Text("Bu post silinecek.", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = {
                    showDeleteConfirm = false
                    onDelete()
                }) { Text("Sil", color = AppTheme.Colors.error) }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirm = false }) {
                    Text("Legv et", color = AppTheme.Colors.secondaryText)
                }
            },
            containerColor = AppTheme.Colors.secondaryBackground
        )
    }
}

private fun formatPostTime(dateString: String): String {
    return try {
        val date = dateString.take(10)
        val time = dateString.substring(11, 16)
        val today = java.time.LocalDate.now().toString()
        if (date == today) time else "$date $time"
    } catch (e: Exception) { "" }
}
