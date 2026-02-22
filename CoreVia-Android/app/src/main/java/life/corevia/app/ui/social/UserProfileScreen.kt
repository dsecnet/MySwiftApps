package life.corevia.app.ui.social

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import life.corevia.app.ui.theme.coreViaCard
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.SocialPost

/**
 * Istifadeci profil sehifesi — her hansi istifadecinin profili
 * Gosterir: ad, bio, stats (izleyiciler, postlar), follow buttonu, postlar siyahisi
 */
@Composable
fun UserProfileScreen(
    viewModel: SocialViewModel,
    onBack: () -> Unit
) {
    val profile by viewModel.selectedUserProfile.collectAsState()
    val userPosts by viewModel.userPosts.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()

    val currentProfile = profile

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(
        modifier = Modifier.fillMaxSize()
    ) {
        if (currentProfile == null && isLoading) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = AppTheme.Colors.accent)
            }
        } else if (currentProfile == null) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Outlined.PersonOff, null, tint = AppTheme.Colors.tertiaryText, modifier = Modifier.size(48.dp))
                    Spacer(modifier = Modifier.height(12.dp))
                    Text("Istifadeci tapilmadi", color = AppTheme.Colors.secondaryText, fontSize = 16.sp)
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(bottom = 100.dp)
            ) {
                // ── Header ──────────────────────────────────────────────────────
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(
                                Brush.verticalGradient(
                                    colors = listOf(
                                        AppTheme.Colors.accent.copy(alpha = 0.2f),
                                        Color.Transparent
                                    )
                                )
                            )
                            .padding(horizontal = 16.dp)
                            .padding(top = 50.dp, bottom = 24.dp)
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                IconButton(onClick = onBack) {
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Outlined.ArrowBack,
                                        contentDescription = "Geri",
                                        tint = AppTheme.Colors.accent
                                    )
                                }
                                Spacer(modifier = Modifier.weight(1f))
                            }

                            // Avatar
                            Box(
                                modifier = Modifier
                                    .size(90.dp)
                                    .background(
                                        brush = Brush.linearGradient(
                                            colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                                        ),
                                        shape = CircleShape
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                val initials = currentProfile.name
                                    .split(" ")
                                    .take(2)
                                    .mapNotNull { it.firstOrNull()?.uppercaseChar() }
                                    .joinToString("")
                                Text(
                                    text = initials.ifEmpty { "?" },
                                    color = Color.White,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 28.sp
                                )
                            }

                            Spacer(modifier = Modifier.height(12.dp))

                            Text(
                                text = currentProfile.name,
                                fontSize = 24.sp,
                                fontWeight = FontWeight.Bold,
                                color = AppTheme.Colors.primaryText
                            )

                            // User type badge
                            Box(
                                modifier = Modifier
                                    .padding(top = 4.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(AppTheme.Colors.accent.copy(alpha = 0.15f))
                                    .padding(horizontal = 12.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = when (currentProfile.userType) {
                                        "trainer" -> "Muellim"
                                        else -> "Istifadeci"
                                    },
                                    fontSize = 12.sp,
                                    color = AppTheme.Colors.accent,
                                    fontWeight = FontWeight.Medium
                                )
                            }
                        }
                    }
                }

                // ── Stats Row ────────────────────────────────────────────────────
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        ProfileStatItem(
                            value = "${currentProfile.postCount}",
                            label = "Post"
                        )
                        ProfileStatItem(
                            value = "${currentProfile.followerCount}",
                            label = "Izleyici"
                        )
                        ProfileStatItem(
                            value = "${currentProfile.followingCount}",
                            label = "Izlenen"
                        )
                    }
                }

                // ── Follow/Unfollow Button ───────────────────────────────────────
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        if (currentProfile.isFollowing) {
                            OutlinedButton(
                                onClick = { viewModel.unfollowUser(currentProfile.id) },
                                modifier = Modifier.weight(1f).height(44.dp),
                                shape = RoundedCornerShape(14.dp),
                                colors = ButtonDefaults.outlinedButtonColors(
                                    contentColor = AppTheme.Colors.secondaryText
                                )
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.PersonRemove,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Izlemeyi dayandır",
                                    fontWeight = FontWeight.SemiBold,
                                    fontSize = 14.sp
                                )
                            }
                        } else {
                            Button(
                                onClick = { viewModel.followUser(currentProfile.id) },
                                modifier = Modifier.weight(1f).height(44.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                                shape = RoundedCornerShape(14.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.PersonAdd,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Izle",
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 14.sp
                                )
                            }
                        }
                    }
                }

                // ── Posts Section ─────────────────────────────────────────────────
                item {
                    Text(
                        text = "Postlar",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
                    )
                }

                if (userPosts.isEmpty()) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp)
                                .clip(RoundedCornerShape(16.dp))
                                .background(AppTheme.Colors.cardBackground)
                                .padding(32.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(
                                    imageVector = Icons.Outlined.Forum,
                                    contentDescription = null,
                                    tint = AppTheme.Colors.tertiaryText,
                                    modifier = Modifier.size(40.dp)
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = "Hele post yoxdur",
                                    color = AppTheme.Colors.secondaryText,
                                    fontSize = 14.sp
                                )
                            }
                        }
                    }
                } else {
                    items(userPosts, key = { it.id }) { post ->
                        UserPostCard(
                            post = post,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                        )
                    }
                }
            }
        }

        // Snackbars
        successMessage?.let { msg ->
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(16.dp),
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
                    .padding(16.dp),
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

@Composable
private fun ProfileStatItem(value: String, label: String) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(horizontal = 16.dp)
    ) {
        Text(
            text = value,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText
        )
        Text(
            text = label,
            fontSize = 13.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}

@Composable
private fun UserPostCard(
    post: SocialPost,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground)
            .padding(16.dp)
    ) {
        Column {
            // Post type + time
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                if (post.postType != "general") {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(AppTheme.Colors.accent.copy(alpha = 0.15f))
                            .padding(horizontal = 8.dp, vertical = 3.dp)
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
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = try { post.createdAt.take(10) } catch (e: Exception) { "" },
                    fontSize = 11.sp,
                    color = AppTheme.Colors.tertiaryText
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Content
            Text(
                text = post.content ?: "",
                fontSize = 15.sp,
                color = AppTheme.Colors.primaryText,
                lineHeight = 22.sp
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Stats
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.FavoriteBorder,
                        contentDescription = null,
                        tint = AppTheme.Colors.tertiaryText,
                        modifier = Modifier.size(16.dp)
                    )
                    Text(
                        text = "${post.likeCount}",
                        fontSize = 12.sp,
                        color = AppTheme.Colors.secondaryText
                    )
                }
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Email,
                        contentDescription = null,
                        tint = AppTheme.Colors.tertiaryText,
                        modifier = Modifier.size(16.dp)
                    )
                    Text(
                        text = "${post.commentCount}",
                        fontSize = 12.sp,
                        color = AppTheme.Colors.secondaryText
                    )
                }
            }
        }
    }
}
