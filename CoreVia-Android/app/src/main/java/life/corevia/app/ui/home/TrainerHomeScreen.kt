package life.corevia.app.ui.home

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.DashboardStudentSummary
import life.corevia.app.data.models.DashboardStatsSummary

/**
 * iOS TrainerHomeView.swift — Android 1-ə-1 port
 *
 * Bölmələr (iOS ilə eyni sıra):
 *  1. Header: Avatar + greeting + name + refresh button
 *  2. Stats Cards: 2x2 grid (subscribers, active, earnings, plans)
 *  3. Student Progress: student list with avatars
 *  4. Stats Summary: 3 SummaryRow
 *  5. Empty Students: when no students
 */
@Composable
fun TrainerHomeScreen(
    userName: String = "",
    userInitial: String = "",
    viewModel: TrainerHomeViewModel = viewModel()
) {
    val stats by viewModel.stats.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val scrollState = rememberScrollState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        // iOS: ScrollView(showsIndicators: false) { VStack(spacing: 20) { ... } .padding() }
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(scrollState)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            // ── 1. Header Section (iOS: headerSection) ──────────────────────────
            TrainerHeaderSection(
                userName    = userName,
                userInitial = userInitial,
                onRefresh   = { viewModel.fetchStats() }
            )

            // ── 2. Stats Cards (iOS: statsCardsSection — 2x2 grid) ─────────────
            TrainerStatsCardsSection(
                totalSubscribers = stats?.totalSubscribers ?: 0,
                activeStudents   = stats?.activeStudents ?: 0,
                currency         = stats?.currency ?: "₼",
                monthlyEarnings  = stats?.monthlyEarnings ?: 0.0,
                totalPlans       = (stats?.totalTrainingPlans ?: 0) + (stats?.totalMealPlans ?: 0)
            )

            // ── 3/4/5. Student Progress + Stats Summary OR Empty State ──────────
            val students = stats?.students ?: emptyList()
            if (stats != null) {
                if (students.isEmpty()) {
                    // iOS: emptyStudentsSection
                    TrainerEmptyStudentsSection()
                } else {
                    // iOS: studentProgressSection
                    TrainerStudentProgressSection(students = students)

                    // iOS: statsSummarySection
                    stats?.statsSummary?.let { summary ->
                        TrainerStatsSummarySection(summary = summary)
                    }
                }
            }

            Spacer(modifier = Modifier.height(100.dp)) // Tab bar üçün yer
        }

        // iOS: loading overlay — ProgressView when isLoading && stats == nil
        if (isLoading && stats == null) {
            CircularProgressIndicator(
                modifier = Modifier.align(Alignment.Center),
                color    = AppTheme.Colors.accent
            )
        }
    }
}

// ─── iOS: headerSection ──────────────────────────────────────────────────────
@Composable
private fun TrainerHeaderSection(
    userName: String,
    userInitial: String,
    onRefresh: () -> Unit
) {
    Row(
        modifier              = Modifier.fillMaxWidth(),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        // iOS: ZStack { Circle gradient + Text(initial) }  — 56x56
        Box(
            modifier = Modifier
                .size(56.dp)
                .background(
                    brush = Brush.linearGradient(
                        colors = listOf(
                            AppTheme.Colors.accent.copy(alpha = 0.3f),
                            AppTheme.Colors.accent
                        )
                    ),
                    shape = CircleShape
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text       = (userInitial.ifEmpty { userName.take(1) }).uppercase(),
                fontSize   = 24.sp,
                fontWeight = FontWeight.Bold,
                color      = Color.White
            )
        }

        // iOS: VStack(alignment: .leading, spacing: 4) { greeting + name }
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text     = "Salam 👋",
                fontSize = 14.sp,
                color    = AppTheme.Colors.secondaryText
            )
            Text(
                text       = userName.ifEmpty { "Məşqçi" },
                fontSize   = 22.sp,
                fontWeight = FontWeight.Bold,
                color      = AppTheme.Colors.primaryText
            )
        }

        // iOS: Button → arrow.clockwise in circle
        Box(
            modifier = Modifier
                .size(40.dp)
                .background(AppTheme.Colors.secondaryBackground, CircleShape)
                .clip(CircleShape)
                .clickable { onRefresh() },
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector        = Icons.Outlined.Refresh,
                contentDescription = "Yenilə",
                modifier           = Modifier.size(16.dp),
                tint               = AppTheme.Colors.secondaryText
            )
        }
    }
}

// ─── iOS: statsCardsSection — 2x2 grid ──────────────────────────────────────
@Composable
private fun TrainerStatsCardsSection(
    totalSubscribers: Int,
    activeStudents: Int,
    currency: String,
    monthlyEarnings: Double,
    totalPlans: Int
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        // iOS: HStack(spacing: 12) — row 1
        Row(
            modifier              = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            DashboardStatCard(
                modifier = Modifier.weight(1f),
                icon     = Icons.Outlined.People,
                value    = "$totalSubscribers",
                label    = "Ümumi Abunəçilər",
                color    = AppTheme.Colors.accent
            )
            DashboardStatCard(
                modifier = Modifier.weight(1f),
                icon     = Icons.Outlined.PersonSearch,
                value    = "$activeStudents",
                label    = "Aktiv Tələbələr",
                color    = AppTheme.Colors.accent
            )
        }

        // iOS: HStack(spacing: 12) — row 2
        Row(
            modifier              = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            DashboardStatCard(
                modifier = Modifier.weight(1f),
                icon     = Icons.Outlined.CreditCard,
                value    = "$currency ${monthlyEarnings.toInt()}",
                label    = "Aylıq Gəlir",
                color    = AppTheme.Colors.accent
            )
            DashboardStatCard(
                modifier = Modifier.weight(1f),
                icon     = Icons.Outlined.Description,
                value    = "$totalPlans",
                label    = "Ümumi Planlar",
                color    = AppTheme.Colors.accentDark
            )
        }
    }
}

// ─── iOS: DashboardStatCard ──────────────────────────────────────────────────
@Composable
private fun DashboardStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .shadow(
                elevation   = 8.dp,
                shape       = RoundedCornerShape(14.dp),
                ambientColor = color.copy(alpha = 0.08f),
                spotColor   = color.copy(alpha = 0.08f)
            )
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
            .padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // iOS: HStack { ZStack { Circle + Image } Spacer() }
        Row(modifier = Modifier.fillMaxWidth()) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .background(color.copy(alpha = 0.15f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector        = icon,
                    contentDescription = null,
                    modifier           = Modifier.size(18.dp),
                    tint               = color
                )
            }
        }

        // iOS: Text(value).font(.system(size: 24, weight: .black))
        Text(
            text       = value,
            fontSize   = 24.sp,
            fontWeight = FontWeight.Black,
            color      = AppTheme.Colors.primaryText,
            maxLines   = 1
        )

        // iOS: Text(label).font(.system(size: 12))
        Text(
            text     = label,
            fontSize = 12.sp,
            color    = AppTheme.Colors.secondaryText,
            maxLines = 2
        )
    }
}

// ─── iOS: emptyStudentsSection ───────────────────────────────────────────────
@Composable
private fun TrainerEmptyStudentsSection() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(16.dp))
            .padding(horizontal = 20.dp, vertical = 30.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // iOS: Image(systemName: "person.2.slash").font(.system(size: 44))
        Icon(
            imageVector        = Icons.Outlined.PersonOff,
            contentDescription = null,
            modifier           = Modifier.size(44.dp),
            tint               = AppTheme.Colors.secondaryText.copy(alpha = 0.5f)
        )

        Text(
            text       = "Tələbə yoxdur",
            fontSize   = 17.sp,
            fontWeight = FontWeight.SemiBold,
            color      = AppTheme.Colors.primaryText
        )

        Text(
            text      = "Hazırda sizə təyin olunmuş tələbə yoxdur. Tələbələr sizə abunə olduqda burada görünəcək.",
            fontSize  = 13.sp,
            color     = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center
        )
    }
}

// ─── iOS: studentProgressSection ─────────────────────────────────────────────
@Composable
private fun TrainerStudentProgressSection(students: List<DashboardStudentSummary>) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        // iOS: HStack { title + Spacer + student count }
        Row(
            modifier              = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment     = Alignment.CenterVertically
        ) {
            Text(
                text       = "Tələbə İnkişafı",
                fontSize   = 18.sp,
                fontWeight = FontWeight.Bold,
                color      = AppTheme.Colors.primaryText
            )
            Text(
                text     = "${students.size} tələbə",
                fontSize = 13.sp,
                color    = AppTheme.Colors.secondaryText
            )
        }

        // iOS: ForEach(students) { DashboardStudentRow }
        students.forEach { student ->
            DashboardStudentRow(student = student)
        }
    }
}

// ─── iOS: DashboardStudentRow ────────────────────────────────────────────────
@Composable
private fun DashboardStudentRow(student: DashboardStudentSummary) {
    val avatarColor = AppTheme.Colors.avatarPalette[student.avatarColorIndex]

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
            .border(
                width = 1.dp,
                color = avatarColor.copy(alpha = 0.1f),
                shape = RoundedCornerShape(14.dp)
            )
            .padding(12.dp),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        // iOS: ZStack { Circle gradient + Text(initials) } — 46x46
        Box(
            modifier = Modifier
                .size(46.dp)
                .background(
                    brush = Brush.linearGradient(
                        colors = listOf(
                            avatarColor.copy(alpha = 0.3f),
                            avatarColor
                        )
                    ),
                    shape = CircleShape
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text       = student.initials,
                fontSize   = 16.sp,
                fontWeight = FontWeight.Bold,
                color      = Color.White
            )
        }

        // iOS: VStack(alignment: .leading, spacing: 4) { name + HStack(weight, goal) }
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text       = student.name,
                fontSize   = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color      = AppTheme.Colors.primaryText,
                maxLines   = 1,
                overflow   = TextOverflow.Ellipsis
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment     = Alignment.CenterVertically
            ) {
                // iOS: weight + kg label
                student.weight?.let { weight ->
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(3.dp),
                        verticalAlignment     = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector        = Icons.Outlined.FitnessCenter,
                            contentDescription = null,
                            modifier           = Modifier.size(10.dp),
                            tint               = AppTheme.Colors.secondaryText
                        )
                        Text(
                            text     = "${weight.toInt()} kq",
                            fontSize = 11.sp,
                            color    = AppTheme.Colors.secondaryText
                        )
                    }
                }

                // iOS: goal badge
                student.goal?.let { goal ->
                    Text(
                        text       = goal,
                        fontSize   = 10.sp,
                        fontWeight = FontWeight.Medium,
                        color      = Color.White,
                        modifier   = Modifier
                            .background(
                                avatarColor.copy(alpha = 0.7f),
                                RoundedCornerShape(6.dp)
                            )
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
            }
        }

        // iOS: VStack(alignment: .trailing) { workoutCount + flame + "Bu həftə" }
        Column(horizontalAlignment = Alignment.End) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(3.dp),
                verticalAlignment     = Alignment.CenterVertically
            ) {
                Text(
                    text       = "${student.thisWeekWorkouts}",
                    fontSize   = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color      = if (student.thisWeekWorkouts > 0) AppTheme.Colors.success
                                 else AppTheme.Colors.secondaryText
                )
                Icon(
                    imageVector        = Icons.Outlined.LocalFireDepartment,
                    contentDescription = null,
                    modifier           = Modifier.size(12.dp),
                    tint               = if (student.thisWeekWorkouts > 0) AppTheme.Colors.accent
                                         else AppTheme.Colors.secondaryText.copy(alpha = 0.5f)
                )
            }
            Text(
                text     = "Bu həftə",
                fontSize = 10.sp,
                color    = AppTheme.Colors.secondaryText
            )
        }
    }
}

// ─── iOS: statsSummarySection ────────────────────────────────────────────────
@Composable
private fun TrainerStatsSummarySection(summary: DashboardStatsSummary) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        // iOS: HStack(spacing: 6) { chart.bar.fill icon + title }
        Row(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment     = Alignment.CenterVertically
        ) {
            Icon(
                imageVector        = Icons.Outlined.BarChart,
                contentDescription = null,
                modifier           = Modifier.size(18.dp),
                tint               = AppTheme.Colors.accent
            )
            Text(
                text       = "Statistika Xülasəsi",
                fontSize   = 18.sp,
                fontWeight = FontWeight.Bold,
                color      = AppTheme.Colors.primaryText
            )
        }

        // iOS: VStack(spacing: 10) { 3x SummaryRow } with background
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(14.dp))
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            SummaryRow(
                icon  = Icons.Outlined.FitnessCenter,
                label = "Ort. Məşq/Həftə",
                value = String.format("%.1f", summary.avgStudentWorkoutsPerWeek),
                color = AppTheme.Colors.accent
            )
            SummaryRow(
                icon  = Icons.Outlined.LocalFireDepartment,
                label = "Ümumi Məşqlər",
                value = "${summary.totalWorkoutsAllStudents}",
                color = AppTheme.Colors.accent
            )
            SummaryRow(
                icon  = Icons.Outlined.MonitorWeight,
                label = "Ort. Çəki",
                value = if (summary.avgStudentWeight > 0) "${String.format("%.1f", summary.avgStudentWeight)} kq" else "—",
                color = AppTheme.Colors.accent
            )
        }
    }
}

// ─── iOS: SummaryRow ─────────────────────────────────────────────────────────
@Composable
private fun SummaryRow(
    icon: ImageVector,
    label: String,
    value: String,
    color: Color
) {
    Row(
        modifier              = Modifier.fillMaxWidth(),
        verticalAlignment     = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // iOS: Image(systemName: icon).frame(width: 24)
        Icon(
            imageVector        = icon,
            contentDescription = null,
            modifier           = Modifier.size(16.dp),
            tint               = color
        )

        // iOS: Text(label).font(.system(size: 14))
        Text(
            text     = label,
            fontSize = 14.sp,
            color    = AppTheme.Colors.secondaryText,
            modifier = Modifier.weight(1f)
        )

        // iOS: Text(value).font(.system(size: 15, weight: .bold))
        Text(
            text       = value,
            fontSize   = 15.sp,
            fontWeight = FontWeight.Bold,
            color      = AppTheme.Colors.primaryText
        )
    }
}
