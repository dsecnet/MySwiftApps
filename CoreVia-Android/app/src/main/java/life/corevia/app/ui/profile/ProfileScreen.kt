package life.corevia.app.ui.profile

import android.graphics.Bitmap
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.filled.Logout
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.DashboardStudentSummary
import life.corevia.app.ui.theme.*

@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel = hiltViewModel(),
    onNavigateToEditProfile: () -> Unit = {},
    onNavigateToAnalytics: () -> Unit = {},
    onNavigateToNotifications: () -> Unit = {},
    onNavigateToPremium: () -> Unit = {},
    onNavigateToTeachers: () -> Unit = {},
    onNavigateToSettings: () -> Unit = {},
    onNavigateToAbout: () -> Unit = {},
    onLogout: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    @OptIn(ExperimentalMaterial3Api::class)
    PullToRefreshBox(
        isRefreshing = uiState.isLoading,
        onRefresh = { viewModel.refreshProfile() },
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 32.dp)
        ) {
        Spacer(modifier = Modifier.height(50.dp))

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Profile Header (shared) ──
            ProfileHeaderSection(
                fullName = uiState.userProfile.fullName,
                email = uiState.userProfile.email,
                isPremium = uiState.userProfile.isPremium,
                isTrainer = uiState.userProfile.isTrainer,
                userTypeDisplayName = uiState.userProfile.userTypeDisplayName,
                verificationStatus = uiState.userProfile.verificationStatus,
                verificationDisplayName = uiState.userProfile.verificationDisplayName,
                isVerified = uiState.userProfile.isVerified,
                onEditProfile = onNavigateToEditProfile
            )

            // ── Profile Completion (shared) ──
            if (uiState.profileCompletion < 1f) {
                ProfileCompletionSection(
                    percentage = uiState.profileCompletion
                )
            }

            if (uiState.userProfile.isTrainer) {
                // ════════════════════════════════════════════════
                // TRAINER PROFILE CONTENT
                // ════════════════════════════════════════════════

                // ── Statistikalar (2x3 grid) ──
                TrainerStatsSection(
                    subscribers = uiState.totalSubscribers,
                    activeStudents = uiState.activeStudents,
                    experience = uiState.userProfile.experience ?: 0,
                    avgWeeklyWorkouts = uiState.avgWorkoutsPerWeek,
                    totalWorkouts = uiState.totalWorkoutsAllStudents,
                    rating = uiState.userProfile.rating ?: 0.0
                )

                // ── Gəlir ──
                TrainerIncomeSection(
                    earnings = uiState.monthlyEarnings,
                    currency = uiState.currency,
                    subscribers = uiState.totalSubscribers
                )

                // ── Planlarım ──
                TrainerPlansSection(
                    trainingPlans = uiState.totalTrainingPlans,
                    mealPlans = uiState.totalMealPlans
                )

                // ── Aktiv Tələbələr ──
                if (uiState.students.isNotEmpty()) {
                    TrainerStudentsSection(
                        students = uiState.students
                    )
                }

                // ── İxtisas və Bio ──
                TrainerBioSection(
                    specialization = uiState.userProfile.specialization,
                    specialtyTags = uiState.userProfile.specialtyTags,
                    bio = uiState.userProfile.bio,
                    pricePerSession = uiState.userProfile.displayPrice,
                    instagramHandle = uiState.userProfile.instagramHandle,
                    onEditProfile = onNavigateToEditProfile
                )

                // ── Üzvlük tarixi ──
                if (uiState.userProfile.memberSinceFormatted.isNotBlank()) {
                    MemberSinceSection(
                        memberSince = uiState.userProfile.memberSinceFormatted
                    )
                }

            } else {
                // ════════════════════════════════════════════════
                // CLIENT PROFILE CONTENT
                // ════════════════════════════════════════════════

                // ── Premium Banner (only if not premium) ──
                if (!uiState.userProfile.isPremium) {
                    PremiumBannerSection(onClick = onNavigateToPremium)
                }

                // ── Today Highlights ──
                TodayHighlightsSection(
                    todayWorkouts = uiState.todayWorkouts,
                    todayCalories = uiState.todayCalories,
                    todayMeals = uiState.todayMeals
                )

                // ── Weekly Progress ──
                WeeklyProgressSection(
                    weekWorkouts = uiState.weekWorkouts,
                    weekWorkoutGoal = uiState.weekWorkoutGoal,
                    weekCalories = uiState.weekCalories,
                    weekCalorieGoal = uiState.weekCalorieGoal
                )

                // ── Teachers Section ──
                TeachersSection(
                    onNavigateToTeachers = onNavigateToTeachers
                )

                // ── Goals Section ──
                GoalsSection(
                    age = uiState.userProfile.age,
                    weight = uiState.userProfile.weight,
                    height = uiState.userProfile.height,
                    goal = uiState.userProfile.fitnessGoal,
                    onEditProfile = onNavigateToEditProfile
                )

                // ── Üzvlük tarixi (client) ──
                if (uiState.userProfile.memberSinceFormatted.isNotBlank()) {
                    MemberSinceSection(
                        memberSince = uiState.userProfile.memberSinceFormatted
                    )
                }
            }

            // ── Settings Section (shared) ──
            SettingsSectionProfile(
                isPremium = uiState.userProfile.isPremium,
                isTrainer = uiState.userProfile.isTrainer,
                onNotifications = onNavigateToNotifications,
                onPremium = onNavigateToPremium,
                onAbout = onNavigateToAbout,
                onSettings = onNavigateToSettings
            )

            // ── Logout Button (shared) ──
            LogoutButton(onLogout = { viewModel.logout(); onLogout() })
        }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// PROFILE HEADER — iOS profileHeader equivalent
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun ProfileHeaderSection(
    fullName: String,
    email: String,
    isPremium: Boolean,
    isTrainer: Boolean = false,
    userTypeDisplayName: String = "Müştəri",
    verificationStatus: String? = null,
    verificationDisplayName: String = "Doğrulanmamış",
    isVerified: Boolean = false,
    onEditProfile: () -> Unit
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Avatar with gradient circle + camera button
        Box(contentAlignment = Alignment.BottomEnd) {
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .shadow(
                        elevation = 15.dp,
                        shape = CircleShape,
                        ambientColor = CoreViaPrimary.copy(alpha = 0.3f),
                        spotColor = CoreViaPrimary.copy(alpha = 0.3f)
                    )
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            listOf(CoreViaPrimary.copy(alpha = 0.3f), CoreViaPrimary)
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    if (isTrainer) Icons.Filled.Groups else Icons.Filled.Person,
                    contentDescription = null,
                    modifier = Modifier.size(40.dp),
                    tint = Color.White
                )
            }

            // Premium crown badge
            if (isPremium) {
                Box(
                    modifier = Modifier
                        .offset(x = (-2).dp, y = (-2).dp)
                        .size(30.dp)
                        .shadow(4.dp, CircleShape, ambientColor = StarFilled.copy(alpha = 0.5f))
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(listOf(StarFilled, CoreViaPrimary))
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.Star,
                        contentDescription = null,
                        modifier = Modifier.size(14.dp),
                        tint = Color.White
                    )
                }
            }

            // Camera button
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .size(32.dp)
                    .shadow(6.dp, CircleShape, ambientColor = CoreViaPrimary.copy(alpha = 0.5f))
                    .clip(CircleShape)
                    .background(CoreViaPrimary)
                    .clickable { /* image picker */ },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.CameraAlt,
                    contentDescription = null,
                    modifier = Modifier.size(14.dp),
                    tint = Color.White
                )
            }
        }

        // Name + verified badge
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = fullName,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            if (isPremium) {
                Icon(
                    Icons.Filled.Verified,
                    contentDescription = null,
                    modifier = Modifier.size(16.dp),
                    tint = CoreViaPrimaryDark
                )
            }
        }

        // Email
        Text(
            text = email,
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        // User type badge + Verified trainer badge + Premium badge
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // User type badge (Müəllim / Müştəri)
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(
                        if (isTrainer) CoreViaPrimary.copy(alpha = 0.12f)
                        else CoreViaPrimary.copy(alpha = 0.1f)
                    )
                    .padding(horizontal = 12.dp, vertical = 5.dp),
                horizontalArrangement = Arrangement.spacedBy(5.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    if (isTrainer) Icons.Filled.Groups else Icons.Filled.Person,
                    contentDescription = null,
                    modifier = Modifier.size(11.dp),
                    tint = CoreViaPrimary
                )
                Text(
                    text = if (isTrainer) "Müəllim" else userTypeDisplayName,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = CoreViaPrimary
                )
            }

            // Verification badge (trainer only — dynamic status)
            if (isTrainer) {
                val vColor = when (verificationStatus?.lowercase()) {
                    "verified" -> CoreViaSuccess
                    "pending" -> BadgePending
                    "rejected" -> BadgeRejected
                    else -> TextSecondary
                }
                val vIcon = when (verificationStatus?.lowercase()) {
                    "verified" -> Icons.Filled.Verified
                    "pending" -> Icons.Filled.HourglassTop
                    "rejected" -> Icons.Filled.Cancel
                    else -> Icons.Filled.Info
                }
                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(vColor.copy(alpha = 0.12f))
                        .padding(horizontal = 10.dp, vertical = 5.dp),
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        vIcon,
                        contentDescription = null,
                        modifier = Modifier.size(11.dp),
                        tint = vColor
                    )
                    Text(
                        text = verificationDisplayName,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = vColor
                    )
                }
            }

            // Premium badge
            if (isPremium) {
                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(
                            Brush.horizontalGradient(
                                listOf(StarFilled.copy(alpha = 0.9f), CoreViaPrimary)
                            )
                        )
                        .padding(horizontal = 12.dp, vertical = 5.dp),
                    horizontalArrangement = Arrangement.spacedBy(5.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Star,
                        contentDescription = null,
                        modifier = Modifier.size(11.dp),
                        tint = Color.White
                    )
                    Text(
                        text = "Premium",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }
        }

        // Edit profile button
        Box(
            modifier = Modifier
                .padding(top = 2.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(CoreViaPrimary.copy(alpha = 0.1f))
                .clickable(onClick = onEditProfile)
                .padding(horizontal = 14.dp, vertical = 6.dp)
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(5.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.Edit,
                    contentDescription = null,
                    modifier = Modifier.size(12.dp),
                    tint = CoreViaPrimary
                )
                Text(
                    text = "Profili Redaktə Et",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = CoreViaPrimary
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// PROFILE COMPLETION — iOS profileCompletionSection
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun ProfileCompletionSection(percentage: Float) {
    val animatedProgress by animateFloatAsState(
        targetValue = percentage,
        animationSpec = tween(800),
        label = "completion"
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "Profil tamamlanma",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "${(percentage * 100).toInt()}%",
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
        }

        LinearProgressIndicator(
            progress = { animatedProgress },
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp)),
            color = CoreViaPrimary,
            trackColor = CoreViaPrimary.copy(alpha = 0.15f)
        )

        Text(
            text = "Profilinizi tamamlayın daha yaxşı tövsiyələr alın",
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// TRAINER: STATISTIKALAR — iOS trainerStatsSection (2x3 grid)
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TrainerStatsSection(
    subscribers: Int,
    activeStudents: Int,
    experience: Int,
    avgWeeklyWorkouts: Double,
    totalWorkouts: Int,
    rating: Double
) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Statistikalar",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        // Row 1
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TrainerMiniStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.People,
                value = "$subscribers",
                label = "Abunəçilər",
                color = CoreViaPrimary
            )
            TrainerMiniStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Groups,
                value = "$activeStudents",
                label = "Aktiv Tələbələr",
                color = AccentBlue
            )
            TrainerMiniStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.WorkHistory,
                value = "$experience il",
                label = "Təcrübə",
                color = AccentOrange
            )
        }

        // Row 2
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TrainerMiniStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.FitnessCenter,
                value = "%.1f".format(avgWeeklyWorkouts),
                label = "Ort. həftəlik məşq",
                color = CoreViaSuccess
            )
            TrainerMiniStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.EmojiEvents,
                value = "$totalWorkouts",
                label = "Ümumi məşqlər",
                color = AccentPurple
            )
            TrainerMiniStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Star,
                value = "%.1f".format(rating),
                label = "Reytinq",
                color = StarFilled
            )
        }
    }
}

@Composable
private fun TrainerMiniStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(color.copy(alpha = 0.08f))
            .border(1.dp, color.copy(alpha = 0.12f), RoundedCornerShape(12.dp))
            .padding(10.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Box(
            modifier = Modifier
                .size(32.dp)
                .clip(CircleShape)
                .background(color.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, modifier = Modifier.size(14.dp), tint = color)
        }
        Text(
            text = value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground,
            textAlign = TextAlign.Center
        )
        Text(
            text = label,
            fontSize = 9.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
            maxLines = 2,
            lineHeight = 11.sp
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// TRAINER: GƏLİR — iOS incomeSection
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TrainerIncomeSection(
    earnings: Double,
    currency: String,
    subscribers: Int
) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Gəlir",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            // Aylıq gəlir
            Column(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(14.dp))
                    .background(
                        Brush.linearGradient(
                            listOf(CoreViaSuccess.copy(alpha = 0.9f), CoreViaSuccess)
                        )
                    )
                    .padding(14.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Icon(
                    Icons.Filled.AccountBalanceWallet, null,
                    modifier = Modifier.size(20.dp),
                    tint = Color.White.copy(alpha = 0.9f)
                )
                Text(
                    text = "%.0f %s".format(earnings, currency),
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Text(
                    text = "Aylıq gəlir",
                    fontSize = 12.sp,
                    color = Color.White.copy(alpha = 0.8f)
                )
            }

            // Abunəçilər
            Column(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(14.dp))
                    .background(
                        Brush.linearGradient(
                            listOf(AccentBlue.copy(alpha = 0.9f), AccentBlue)
                        )
                    )
                    .padding(14.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Icon(
                    Icons.Filled.People, null,
                    modifier = Modifier.size(20.dp),
                    tint = Color.White.copy(alpha = 0.9f)
                )
                Text(
                    text = "$subscribers",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Text(
                    text = "Abunəçilər",
                    fontSize = 12.sp,
                    color = Color.White.copy(alpha = 0.8f)
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// TRAINER: PLANLARIM — iOS plansSection
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TrainerPlansSection(
    trainingPlans: Int,
    mealPlans: Int
) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Planlarım",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "${trainingPlans + mealPlans} plan",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            // İdman Planı
            Column(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(14.dp))
                    .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                    .padding(14.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(CoreViaPrimary.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.FitnessCenter, null,
                        modifier = Modifier.size(20.dp),
                        tint = CoreViaPrimary
                    )
                }
                Text(
                    text = "$trainingPlans",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "İdman Planı",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Yemək Planı
            Column(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(14.dp))
                    .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                    .padding(14.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(AccentOrange.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.Restaurant, null,
                        modifier = Modifier.size(20.dp),
                        tint = AccentOrange
                    )
                }
                Text(
                    text = "$mealPlans",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "Yemək Planı",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// TRAINER: AKTİV TƏLƏBƏLƏR — iOS activeStudentsSection
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TrainerStudentsSection(
    students: List<DashboardStudentSummary>
) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Aktiv Tələbələr",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "${students.size} nəfər",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        students.forEach { student ->
            TrainerStudentRow(student = student)
        }
    }
}

@Composable
private fun TrainerStudentRow(student: DashboardStudentSummary) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Avatar
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(student.avatarColor),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = student.initials,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }

        // Name + Goal
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(3.dp)
        ) {
            Text(
                text = student.name,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (student.weight != null) {
                    Text(
                        text = "${student.weight.toInt()} kq",
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                if (student.goal != null) {
                    Text(
                        text = student.goal,
                        fontSize = 11.sp,
                        color = CoreViaPrimary
                    )
                }
            }
        }

        // This week workouts
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                text = "${student.thisWeekWorkouts}",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
            Text(
                text = "Bu həftə",
                fontSize = 9.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// TRAINER: İXTİSAS VƏ BIO
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TrainerBioSection(
    specialization: String?,
    specialtyTags: List<String>,
    bio: String?,
    pricePerSession: String,
    instagramHandle: String?,
    onEditProfile: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = "İxtisas və Bio",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            // Specialty tags as chips (FlowRow-like)
            if (specialtyTags.isNotEmpty()) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.School, null,
                        modifier = Modifier.size(16.dp),
                        tint = CoreViaPrimary
                    )
                    specialtyTags.forEach { tag ->
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(8.dp))
                                .background(CoreViaPrimary.copy(alpha = 0.1f))
                                .padding(horizontal = 10.dp, vertical = 4.dp)
                        ) {
                            Text(
                                text = tag,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Medium,
                                color = CoreViaPrimary
                            )
                        }
                    }
                }
            } else if (!specialization.isNullOrBlank()) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.School, null,
                        modifier = Modifier.size(16.dp),
                        tint = CoreViaPrimary
                    )
                    Text(
                        text = specialization,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                }
            }

            // Bio text
            if (!bio.isNullOrBlank()) {
                Text(
                    text = bio,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    lineHeight = 18.sp
                )
            }

            // Price per session
            if (pricePerSession.isNotBlank()) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Payments, null,
                        modifier = Modifier.size(16.dp),
                        tint = CoreViaSuccess
                    )
                    Text(
                        text = "Seansa qiymət: ",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = pricePerSession,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = CoreViaSuccess
                    )
                }
            }

            // Instagram handle
            if (!instagramHandle.isNullOrBlank()) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.CameraAlt, null,
                        modifier = Modifier.size(16.dp),
                        tint = AccentPurple
                    )
                    Text(
                        text = "@$instagramHandle",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        color = AccentPurple
                    )
                }
            }

            // Empty state prompt
            if (specialization.isNullOrBlank() && bio.isNullOrBlank()) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(8.dp))
                        .background(CoreViaPrimary.copy(alpha = 0.08f))
                        .clickable(onClick = onEditProfile)
                        .padding(10.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Info, null,
                        modifier = Modifier.size(14.dp),
                        tint = CoreViaPrimary
                    )
                    Text(
                        text = "İxtisas və bio əlavə edin",
                        fontSize = 13.sp,
                        color = CoreViaPrimary,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// TRAINER: ÜZVLÜK TARİXİ — iOS memberSinceSection
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun MemberSinceSection(memberSince: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(14.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(AccentBlue.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.CalendarMonth, null,
                modifier = Modifier.size(18.dp),
                tint = AccentBlue
            )
        }
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(
                text = "Üzvlük tarixi",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = memberSince,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
        }
    }
}


// ═══════════════════════════════════════════════════════════════════
// PREMIUM BANNER — iOS premiumBanner (client only)
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun PremiumBannerSection(onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                12.dp, RoundedCornerShape(16.dp),
                ambientColor = PremiumGradientStart.copy(alpha = 0.4f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(
                Brush.horizontalGradient(
                    listOf(PremiumGradientStart, PremiumGradientEnd.copy(alpha = 0.8f))
                )
            )
            .clickable(onClick = onClick)
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.2f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.AutoAwesome,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = Color.White
            )
        }

        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(3.dp)
        ) {
            Text(
                text = "Premium-a keçin",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            Text(
                text = "Bütün funksiyalara giriş əldə edin",
                fontSize = 12.sp,
                color = Color.White.copy(alpha = 0.8f)
            )
        }

        Icon(
            Icons.Filled.ChevronRight,
            contentDescription = null,
            modifier = Modifier.size(14.dp),
            tint = Color.White.copy(alpha = 0.7f)
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// TODAY HIGHLIGHTS — iOS todayHighlightsSection (client only)
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TodayHighlightsSection(
    todayWorkouts: Int,
    todayCalories: Int,
    todayMeals: Int
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Bugünkü nəticələr",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            TodayHighlightCard(
                icon = Icons.Filled.FitnessCenter,
                value = "$todayWorkouts",
                label = "Məşqlər",
                color = CoreViaPrimary
            )
            TodayHighlightCard(
                icon = Icons.Filled.Whatshot,
                value = "$todayCalories",
                label = "Kalori",
                color = CoreViaPrimary
            )
            TodayHighlightCard(
                icon = Icons.Filled.Restaurant,
                value = "$todayMeals",
                label = "Öğünlər",
                color = CoreViaSuccess
            )
        }
    }
}

@Composable
private fun TodayHighlightCard(
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = Modifier
            .width(110.dp)
            .shadow(6.dp, RoundedCornerShape(14.dp), ambientColor = color.copy(alpha = 0.08f))
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(vertical = 14.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(color.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, modifier = Modifier.size(20.dp), tint = color)
        }
        Text(
            text = value,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// WEEKLY PROGRESS — iOS weeklyProgressSection (client only)
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun WeeklyProgressSection(
    weekWorkouts: Int,
    weekWorkoutGoal: Int,
    weekCalories: Int,
    weekCalorieGoal: Int
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Həftəlik irəliləyiş",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            CircularProgressCard(
                modifier = Modifier.weight(1f),
                value = weekWorkouts,
                total = weekWorkoutGoal,
                label = "Məşqlər",
                color = CoreViaPrimary,
                icon = Icons.Filled.FitnessCenter
            )
            CircularProgressCard(
                modifier = Modifier.weight(1f),
                value = weekCalories,
                total = weekCalorieGoal,
                label = "Kalori",
                color = CoreViaPrimary,
                icon = Icons.Filled.Whatshot
            )
        }
    }
}

@Composable
private fun CircularProgressCard(
    modifier: Modifier = Modifier,
    value: Int,
    total: Int,
    label: String,
    color: Color,
    icon: ImageVector
) {
    val progress = if (total > 0) (value.toFloat() / total).coerceAtMost(1f) else 0f
    val animatedProgress by animateFloatAsState(
        targetValue = progress,
        animationSpec = tween(800),
        label = "ring"
    )

    Column(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Box(
            modifier = Modifier.size(70.dp),
            contentAlignment = Alignment.Center
        ) {
            androidx.compose.foundation.Canvas(modifier = Modifier.fillMaxSize()) {
                drawArc(
                    color = color.copy(alpha = 0.15f),
                    startAngle = 0f,
                    sweepAngle = 360f,
                    useCenter = false,
                    style = Stroke(width = 8.dp.toPx(), cap = StrokeCap.Round)
                )
                drawArc(
                    brush = Brush.linearGradient(listOf(color, color.copy(alpha = 0.6f))),
                    startAngle = -90f,
                    sweepAngle = animatedProgress * 360f,
                    useCenter = false,
                    style = Stroke(width = 8.dp.toPx(), cap = StrokeCap.Round)
                )
            }
            Icon(icon, null, modifier = Modifier.size(20.dp), tint = color)
        }

        Row(
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                text = "$value",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "/ $total",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// TEACHERS SECTION — iOS teachersSection (client only)
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun TeachersSection(
    onNavigateToTeachers: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = "Müəllimlərim",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                .clickable(onClick = onNavigateToTeachers)
                .padding(14.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(CoreViaPrimary.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.School,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = CoreViaPrimary
                )
            }

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                Text(
                    text = "Müəllim seç",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text = "Bütün müəllimlərə bax",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Icon(
                Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                modifier = Modifier.size(16.dp),
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// GOALS SECTION — iOS goalsSection (client only)
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun GoalsSection(
    age: Int?,
    weight: Float?,
    height: Float?,
    goal: String?,
    onEditProfile: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = "Məqsədlərim",
            fontSize = 15.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            GoalStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.CalendarMonth,
                value = "${age ?: 0}",
                label = "Yaş"
            )
            GoalStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.MonitorWeight,
                value = "${weight?.toInt() ?: 0} kq",
                label = "Çəki"
            )
            GoalStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Straighten,
                value = "${height?.toInt() ?: 0} sm",
                label = "Boy"
            )
        }

        if (goal != null) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                    .padding(horizontal = 10.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.TrackChanges,
                    contentDescription = null,
                    modifier = Modifier.size(13.dp),
                    tint = CoreViaPrimary
                )
                Text("Hədəf:", fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Text(
                    text = goal,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }
        }

        if (age == null || weight == null || height == null || goal == null) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(CoreViaPrimary.copy(alpha = 0.08f))
                    .border(1.dp, CoreViaPrimary.copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                    .clickable(onClick = onEditProfile)
                    .padding(10.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.Info,
                    contentDescription = null,
                    modifier = Modifier.size(15.dp),
                    tint = CoreViaPrimary
                )
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(1.dp)
                ) {
                    Text(
                        text = "Profili tamamlayın",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = "Daha yaxşı tövsiyələr alın",
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Icon(
                    Icons.Filled.ChevronRight,
                    contentDescription = null,
                    modifier = Modifier.size(12.dp),
                    tint = TextTertiary
                )
            }
        }
    }
}

@Composable
private fun GoalStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(10.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(horizontal = 10.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, null, modifier = Modifier.size(14.dp), tint = CoreViaPrimary)
        Column(verticalArrangement = Arrangement.spacedBy(1.dp)) {
            Text(
                text = value,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = label,
                fontSize = 10.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// SETTINGS SECTION — iOS settingsSection (shared)
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun SettingsSectionProfile(
    isPremium: Boolean,
    isTrainer: Boolean = false,
    onNotifications: () -> Unit,
    onPremium: () -> Unit,
    onAbout: () -> Unit,
    onSettings: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Tənzimləmələr",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            ProfileSettingsRow(
                icon = Icons.Filled.Notifications,
                title = "Bildirişlər",
                badge = "Aktiv",
                badgeColor = CoreViaSuccess,
                iconColor = CoreViaSuccess,
                onClick = onNotifications
            )
            if (!isTrainer) {
                // Client-only settings
                ProfileSettingsRow(
                    icon = Icons.Filled.Lock,
                    title = "Təhlükəsizlik",
                    iconColor = CoreViaPrimary,
                    onClick = onSettings
                )
                ProfileSettingsRow(
                    icon = Icons.Filled.AutoAwesome,
                    title = "Premium",
                    badge = if (isPremium) "Aktiv" else null,
                    badgeColor = if (isPremium) CoreViaSuccess else CoreViaPrimaryDark,
                    iconColor = CoreViaPrimary,
                    onClick = onPremium
                )
            }
            ProfileSettingsRow(
                icon = Icons.Filled.Info,
                title = "Haqqında",
                iconColor = TextSecondary,
                onClick = onAbout
            )
            ProfileSettingsRow(
                icon = Icons.Filled.Delete,
                title = "Hesabı Sil",
                iconColor = CoreViaError,
                titleColor = CoreViaError,
                onClick = { /* delete account */ }
            )
        }
    }
}

@Composable
private fun ProfileSettingsRow(
    icon: ImageVector,
    title: String,
    badge: String? = null,
    badgeColor: Color = Color.Gray,
    iconColor: Color = CoreViaPrimary,
    titleColor: Color = MaterialTheme.colorScheme.onBackground,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .clickable(onClick = onClick)
            .padding(14.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, null, modifier = Modifier.size(20.dp), tint = iconColor)

        Text(
            text = title,
            modifier = Modifier.weight(1f),
            fontSize = 15.sp,
            color = titleColor
        )

        if (badge != null) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .background(badgeColor.copy(alpha = 0.2f))
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Text(
                    text = badge,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = badgeColor
                )
            }
        }

        Icon(
            Icons.AutoMirrored.Filled.KeyboardArrowRight,
            contentDescription = null,
            modifier = Modifier.size(16.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// LOGOUT BUTTON — iOS logoutButton (shared)
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun LogoutButton(onLogout: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .border(1.dp, CoreViaError, RoundedCornerShape(12.dp))
            .clickable(onClick = onLogout)
            .padding(16.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            Icons.AutoMirrored.Filled.Logout,
            contentDescription = null,
            modifier = Modifier.size(18.dp),
            tint = CoreViaError
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = "Çıxış",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = CoreViaError
        )
    }
}
