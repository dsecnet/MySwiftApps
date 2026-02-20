package life.corevia.app.ui.profile

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.outlined.Logout
import androidx.compose.material.icons.outlined.*
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
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.DashboardStudentSummary
import life.corevia.app.ui.home.TrainerHomeViewModel
// TrainingPlan/MealPlan VM-lər artıq profile-da istifadə olunmur (esas sehifede var)

/**
 * iOS TrainerProfileView.swift — Android 1-ə-1 port
 *
 * Sections (iOS sırası ilə):
 *  1. profileHeader (avatar, ad, email, müəllim badge, verification, qiymət, edit)
 *  2. profileCompletionSection (dairəvi progress, 8 sahə)
 *  3. statsSection (2 sıra × 3 stat card)
 *  4. studentsSection (tələbə siyahısı, empty state, bütün tələbələr button)
 *  5. specialtySection (ixtisas tag-ları + bio)
 *  6. memberSinceSection (tarix)
 *  7. settingsSection (bildirişlər, təhlükəsizlik, haqqında)
 *  8. logoutButton
 */
@Composable
fun TrainerProfileScreen(
    onNavigateToSettings: () -> Unit,
    onNavigateToMyStudents: () -> Unit,
    onLogout: () -> Unit,
    profileViewModel: ProfileViewModel = viewModel(),
    trainerHomeViewModel: TrainerHomeViewModel = viewModel()
) {
    val user by profileViewModel.user.collectAsState()
    val isLoading by profileViewModel.isLoading.collectAsState()
    val errorMessage by profileViewModel.errorMessage.collectAsState()
    val successMessage by profileViewModel.successMessage.collectAsState()
    val stats by trainerHomeViewModel.stats.collectAsState()
    val trainerCompletion = profileViewModel.trainerProfileCompletion

    var showEditSheet by remember { mutableStateOf(false) }
    var showLogoutDialog by remember { mutableStateOf(false) }

    // iOS: .onAppear { Task { await dashboard.fetchStats() } }
    LaunchedEffect(Unit) {
        trainerHomeViewModel.fetchStats()
    }

    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            kotlinx.coroutines.delay(2000)
            profileViewModel.clearSuccess()
        }
    }
    LaunchedEffect(errorMessage) {
        if (errorMessage != null) {
            kotlinx.coroutines.delay(5000)
            profileViewModel.clearError()
        }
    }

    // Logout dialog
    if (showLogoutDialog) {
        AlertDialog(
            onDismissRequest = { showLogoutDialog = false },
            containerColor = AppTheme.Colors.secondaryBackground,
            title = { Text("Çıxış", color = Color.White) },
            text = { Text("Hesabdan çıxmaq istədiyinizdən əminsiniz?", color = AppTheme.Colors.secondaryText) },
            confirmButton = {
                TextButton(onClick = { showLogoutDialog = false; onLogout() }) {
                    Text("Çıxış", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showLogoutDialog = false }) {
                    Text("Ləğv et", color = AppTheme.Colors.secondaryText)
                }
            }
        )
    }

    // Error state
    if (errorMessage != null && user == null) {
        Box(
            modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Text("⚠️", fontSize = 48.sp)
                Text(errorMessage ?: "Xəta baş verdi", color = AppTheme.Colors.error, fontSize = 16.sp)
                Button(
                    onClick = { profileViewModel.loadUser() },
                    colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text("Yenidən cəhd et", color = Color.White, fontWeight = FontWeight.SemiBold)
                }
            }
        }
        return
    }

    // Loading state
    if (isLoading && user == null) {
        Box(
            modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                CircularProgressIndicator(color = AppTheme.Colors.accent)
                Text("Profil yüklənir...", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
            }
        }
        return
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp)
            .padding(top = 8.dp, bottom = 100.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {

        // ═══ 1. PROFILE HEADER ══════════════════════════════════════════════
        Column(
            modifier = Modifier.fillMaxWidth().padding(top = 48.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            // iOS: 120dp avatar with gradient + camera button
            Box {
                Box(
                    modifier = Modifier
                        .size(120.dp)
                        .shadow(20.dp, CircleShape, spotColor = AppTheme.Colors.accent.copy(alpha = 0.3f))
                        .background(
                            Brush.linearGradient(listOf(AppTheme.Colors.accent.copy(alpha = 0.3f), AppTheme.Colors.accent)),
                            CircleShape
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    // iOS: person.2.fill icon when no image
                    Icon(Icons.Outlined.Groups, null, tint = Color.White, modifier = Modifier.size(50.dp))
                }
                // Camera button — bottom end
                Box(
                    modifier = Modifier.align(Alignment.BottomEnd).size(36.dp)
                        .shadow(8.dp, CircleShape, spotColor = AppTheme.Colors.accent.copy(alpha = 0.5f))
                        .clip(CircleShape).background(AppTheme.Colors.accent),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Outlined.CameraAlt, null, tint = Color.White, modifier = Modifier.size(16.dp))
                }
            }

            Spacer(Modifier.height(10.dp))

            // iOS: name (24sp bold)
            Text(
                user?.name ?: "Yüklənir...",
                fontSize = 24.sp, fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )

            // iOS: email (14sp secondary)
            Text(user?.email ?: "", fontSize = 14.sp, color = AppTheme.Colors.secondaryText)

            // iOS: "Müəllim" type badge
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(AppTheme.Colors.accent.copy(alpha = 0.1f))
                    .padding(horizontal = 12.dp, vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(Icons.Outlined.Groups, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(12.dp))
                Text("Müəllim", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.accent)
            }

            // iOS: Verification badge
            VerificationBadge(status = user?.verificationStatus)

            // iOS: Price per session
            val price = user?.pricePerSession
            if (price != null && price > 0) {
                Text(
                    "${String.format("%.0f", price)} ₼ / seans",
                    fontSize = 13.sp, fontWeight = FontWeight.Medium,
                    color = AppTheme.Colors.accent
                )
            }

            // iOS: Edit button
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(20.dp))
                    .background(AppTheme.Colors.accent.copy(alpha = 0.1f))
                    .clickable { showEditSheet = true }
                    .padding(horizontal = 16.dp, vertical = 8.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Icon(Icons.Outlined.Edit, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(14.dp))
                    Text("Redaktə et", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.accent)
                }
            }
        }

        // ═══ 2. PROFILE COMPLETION (only if <100%) ═════════════════════════
        if (trainerCompletion < 1f) {
            Row(
                modifier = Modifier.fillMaxWidth()
                    .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // iOS: Circular progress indicator (56dp)
                Box(Modifier.size(56.dp), contentAlignment = Alignment.Center) {
                    Canvas(Modifier.size(56.dp)) {
                        drawCircle(
                            color = AppTheme.Colors.separator,
                            style = Stroke(width = 6.dp.toPx())
                        )
                    }
                    Canvas(Modifier.size(56.dp)) {
                        drawArc(
                            color = AppTheme.Colors.accent,
                            startAngle = -90f,
                            sweepAngle = 360f * trainerCompletion,
                            useCenter = false,
                            style = Stroke(width = 6.dp.toPx(), cap = StrokeCap.Round)
                        )
                    }
                    Text(
                        "${(trainerCompletion * 100).toInt()}%",
                        fontSize = 14.sp, fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.accent
                    )
                }

                Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("Profil tamamlama", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                    Text("Profilinizi tamamlayın", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)
                }

                IconButton(onClick = { showEditSheet = true }) {
                    Icon(Icons.Outlined.Edit, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(28.dp))
                }
            }
        }

        // ═══ 3. STATS SECTION ══════════════════════════════════════════════
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Text("Statistika", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)

            // Row 1: Subscribers, Active Students, Experience
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                TrainerStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Outlined.Groups,
                    value = "${stats?.totalSubscribers ?: 0}",
                    label = "Abunəçilər",
                    color = AppTheme.Colors.accent
                )
                TrainerStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Outlined.PersonSearch,
                    value = "${stats?.activeStudents ?: 0}",
                    label = "Aktiv tələbələr",
                    color = AppTheme.Colors.success
                )
                TrainerStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Outlined.CalendarMonth,
                    value = "${user?.experience ?: 0} il",
                    label = "Təcrübə",
                    color = AppTheme.Colors.accent
                )
            }

            // Row 2: Avg Workouts/Week, Total Workouts, Rating (only if statsSummary)
            if (stats?.statsSummary != null) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    TrainerStatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Outlined.LocalFireDepartment,
                        value = String.format("%.1f", stats?.statsSummary?.avgStudentWorkoutsPerWeek ?: 0.0),
                        label = "Ort. məşq/həftə",
                        color = AppTheme.Colors.accent
                    )
                    TrainerStatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Outlined.FitnessCenter,
                        value = "${stats?.statsSummary?.totalWorkoutsAllStudents ?: 0}",
                        label = "Ümumi məşqlər",
                        color = AppTheme.Colors.accent
                    )
                    TrainerStatCard(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Outlined.Star,
                        value = String.format("%.1f", user?.rating ?: 0.0),
                        label = "Reytinq",
                        color = AppTheme.Colors.starFilled
                    )
                }
            }
        }

        // ═══ 4. STUDENTS SECTION ═══════════════════════════════════════════
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Text("Aktiv tələbələr", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                Spacer(Modifier.weight(1f))
                Text(
                    "${stats?.activeStudents ?: 0} nəfər",
                    fontSize = 14.sp, color = AppTheme.Colors.secondaryText
                )
            }

            val studentsList = stats?.students ?: emptyList()
            if (studentsList.isEmpty()) {
                // Empty state
                Row(
                    modifier = Modifier.fillMaxWidth()
                        .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Icon(Icons.Outlined.PersonOff, null, tint = AppTheme.Colors.tertiaryText, modifier = Modifier.size(24.dp))
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text("Hələ tələbəniz yoxdur", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.secondaryText)
                        Text("Tələbələr sizi seçdikdə burada görünəcək", fontSize = 13.sp, color = AppTheme.Colors.tertiaryText)
                    }
                }
            } else {
                // Show first 3 students
                studentsList.take(3).forEach { student ->
                    StudentProfileRow(student = student)
                }
            }

            // "Bütün tələbələr" button
            Row(
                modifier = Modifier.fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(AppTheme.Colors.secondaryBackground)
                    .clickable { onNavigateToMyStudents() }
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Outlined.Groups, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(12.dp))
                Text("Bütün tələbələr", fontSize = 15.sp, color = AppTheme.Colors.accent, modifier = Modifier.weight(1f))
                Icon(Icons.AutoMirrored.Outlined.KeyboardArrowRight, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(14.dp))
            }
        }

        // ═══ 7. SPECIALTY & BIO SECTION ════════════════════════════════════
        val specialtyTags = parseSpecialtyTags(user?.specialization)
        val hasBio = !user?.bio.isNullOrBlank()
        val hasSpecialty = !user?.specialization.isNullOrBlank()

        if (hasSpecialty || hasBio) {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("İxtisas və bio", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)

                // Specialty tags
                if (hasSpecialty) {
                    Column(
                        modifier = Modifier.fillMaxWidth()
                            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Text("İxtisaslar", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.secondaryText)

                        // FlowRow for tags (Compose Foundation 1.4+)
                        @OptIn(ExperimentalLayoutApi::class)
                        FlowRow(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            specialtyTags.forEach { tag ->
                                Row(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(20.dp))
                                        .background(tag.color.copy(alpha = 0.12f))
                                        .padding(horizontal = 14.dp, vertical = 8.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                                ) {
                                    Icon(tag.icon, null, tint = tag.color, modifier = Modifier.size(12.dp))
                                    Text(tag.displayName, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = tag.color)
                                }
                            }
                        }
                    }
                }

                // Bio
                if (hasBio) {
                    Column(
                        modifier = Modifier.fillMaxWidth()
                            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text("Haqqında", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
                        Text(
                            user?.bio ?: "",
                            fontSize = 14.sp, color = AppTheme.Colors.secondaryText,
                            lineHeight = 20.sp
                        )
                    }
                }
            }
        }

        // ═══ 8. MEMBER SINCE ══════════════════════════════════════════════
        if (user?.createdAt != null) {
            Row(
                Modifier.fillMaxWidth()
                    .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
                    .padding(14.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Box(
                    Modifier.size(44.dp).clip(CircleShape)
                        .background(AppTheme.Colors.accent.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Outlined.CalendarMonth, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(18.dp))
                }
                Column {
                    Text("Üzv olma tarixi", fontSize = 13.sp, color = AppTheme.Colors.secondaryText)
                    Text(
                        user?.createdAt?.take(10) ?: "",
                        fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText
                    )
                }
            }
        }

        // ═══ 9. SETTINGS SECTION ═══════════════════════════════════════════
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text("Tənzimləmələr", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)
            Spacer(Modifier.height(4.dp))
            ProfileSettingsRow(Icons.Outlined.Notifications, "Bildirişlər", onClick = onNavigateToSettings)
            ProfileSettingsRow(Icons.Outlined.Lock, "Təhlükəsizlik", onClick = onNavigateToSettings)
            ProfileSettingsRow(Icons.Outlined.Info, "Haqqında", onClick = onNavigateToSettings)
        }

        // ═══ 10. LOGOUT BUTTON ═════════════════════════════════════════════
        OutlinedButton(
            onClick = { showLogoutDialog = true },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = AppTheme.Colors.error),
            border = ButtonDefaults.outlinedButtonBorder(enabled = true).copy(
                brush = androidx.compose.ui.graphics.SolidColor(AppTheme.Colors.error)
            )
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.padding(vertical = 4.dp)
            ) {
                Icon(Icons.AutoMirrored.Outlined.Logout, null, tint = AppTheme.Colors.error, modifier = Modifier.size(18.dp))
                Text("Çıxış", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.error)
            }
        }
    }

    // Edit profile sheet
    if (showEditSheet) {
        EditProfileSheet(
            user = user,
            onDismiss = { showEditSheet = false },
            onSave = { request -> profileViewModel.updateProfile(request); showEditSheet = false }
        )
    }
}

// ═══ Verification Badge ═════════════════════════════════════════════════════
@Composable
private fun VerificationBadge(status: String?) {
    val (icon, text, color) = when (status) {
        "verified" -> Triple(Icons.Outlined.Verified, "Doğrulanıb", AppTheme.Colors.badgeVerified)
        "pending" -> Triple(Icons.Outlined.HourglassEmpty, "Gözləmədə", AppTheme.Colors.badgePending)
        else -> Triple(Icons.Outlined.Cancel, "Rədd edilib", AppTheme.Colors.badgeRejected)
    }

    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(10.dp))
            .background(color.copy(alpha = 0.12f))
            .padding(horizontal = 12.dp, vertical = 5.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Icon(icon, null, tint = color, modifier = Modifier.size(12.dp))
        Text(text, fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = color)
    }
}

// ═══ TrainerStatCard ════════════════════════════════════════════════════════
@Composable
private fun TrainerStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
            .padding(vertical = 16.dp, horizontal = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(icon, null, tint = color, modifier = Modifier.size(20.dp))
        Text(
            value, fontSize = 16.sp, fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText, textAlign = TextAlign.Center,
            maxLines = 1, overflow = TextOverflow.Ellipsis
        )
        Text(
            label, fontSize = 11.sp, color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center, maxLines = 1, overflow = TextOverflow.Ellipsis
        )
    }
}

// ═══ StudentProfileRow ══════════════════════════════════════════════════════
@Composable
private fun StudentProfileRow(student: DashboardStudentSummary) {
    val avatarColor = AppTheme.Colors.avatarPalette[student.avatarColorIndex % AppTheme.Colors.avatarPalette.size]

    Row(
        modifier = Modifier.fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Avatar circle
        Box(
            Modifier.size(50.dp).clip(CircleShape)
                .background(avatarColor.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                student.initials,
                fontSize = 18.sp, fontWeight = FontWeight.Bold,
                color = avatarColor
            )
        }

        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(student.name, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppTheme.Colors.primaryText)

            if (!student.goal.isNullOrBlank()) {
                Text(
                    student.goal, fontSize = 13.sp, color = AppTheme.Colors.secondaryText,
                    maxLines = 1, overflow = TextOverflow.Ellipsis
                )
            }

            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Icon(Icons.Outlined.LocalFireDepartment, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(11.dp))
                Text(
                    "${student.thisWeekWorkouts} məşq bu həftə",
                    fontSize = 12.sp, fontWeight = FontWeight.Medium, color = AppTheme.Colors.accent
                )
            }
        }

        Icon(Icons.AutoMirrored.Outlined.KeyboardArrowRight, null, tint = AppTheme.Colors.secondaryText, modifier = Modifier.size(14.dp))
    }
}

// ═══ Specialty Tags Parsing ════════════════════════════════════════════════
private data class SpecialtyTag(
    val displayName: String,
    val icon: ImageVector,
    val color: Color
)

private fun parseSpecialtyTags(specialization: String?): List<SpecialtyTag> {
    val spec = specialization?.lowercase() ?: return listOf(
        SpecialtyTag("Fitness", Icons.Outlined.FitnessCenter, AppTheme.Colors.catFitness)
    )
    val tags = mutableListOf<SpecialtyTag>()
    if (spec.contains("yoga")) tags.add(SpecialtyTag("Yoga", Icons.Outlined.SelfImprovement, AppTheme.Colors.catYoga))
    if (spec.contains("cardio") || spec.contains("kardio")) tags.add(SpecialtyTag("Kardio", Icons.Outlined.Favorite, AppTheme.Colors.catCardio))
    if (spec.contains("nutrition") || spec.contains("qidalanma")) tags.add(SpecialtyTag("Qidalanma", Icons.Outlined.Eco, AppTheme.Colors.catNutrition))
    if (spec.contains("strength") || spec.contains("guc") || spec.contains("güc")) tags.add(SpecialtyTag("Güc", Icons.Outlined.FitnessCenter, AppTheme.Colors.catStrength))
    if (spec.contains("fitness") || tags.isEmpty()) tags.add(0, SpecialtyTag("Fitness", Icons.Outlined.FitnessCenter, AppTheme.Colors.catFitness))
    return tags
}
