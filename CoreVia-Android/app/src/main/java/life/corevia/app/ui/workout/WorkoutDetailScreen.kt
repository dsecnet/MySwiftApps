package life.corevia.app.ui.workout

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaIconBadge
import life.corevia.app.ui.theme.CoreViaSectionHeader
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import life.corevia.app.ui.theme.coreViaCard
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.DirectionsRun
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.Workout

/**
 * Workout Detail Screen — iOS WorkoutDetailView 1-ə-1 port
 *
 * Bölmələr:
 *  1. Back button + Title
 *  2. Info row: Duration, Calories, Category
 *  3. Notes section (if notes exist)
 *  4. Completion toggle button
 *  5. Edit button
 *  6. Delete button (with confirmation dialog)
 */
@Composable
fun WorkoutDetailScreen(
    workout: Workout,
    onBack: () -> Unit,
    onToggleComplete: (String) -> Unit,
    onDelete: (String) -> Unit,
    onEdit: () -> Unit
) {
    var showDeleteDialog by remember { mutableStateOf(false) }

    // iOS: categoryColor
    val categoryColor = when (workout.category.lowercase()) {
        "strength"   -> AppTheme.Colors.accent
        "cardio"     -> AppTheme.Colors.accentDark
        "flexibility" -> AppTheme.Colors.accent
        "endurance"  -> AppTheme.Colors.accentDark
        else         -> AppTheme.Colors.accent
    }

    val categoryLabel = when (workout.category.lowercase()) {
        "strength"   -> "Güc"
        "cardio"     -> "Kardio"
        "flexibility" -> "Elastik"
        "endurance"  -> "Dözüm"
        else         -> workout.category
    }

    val categoryIcon = when (workout.category.lowercase()) {
        "strength"   -> Icons.Outlined.FitnessCenter
        "cardio"     -> Icons.AutoMirrored.Outlined.DirectionsRun
        "flexibility" -> Icons.Outlined.SelfImprovement
        "endurance"  -> Icons.Outlined.Speed
        else         -> Icons.Outlined.FitnessCenter
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.success) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp)
    ) {
        Spacer(modifier = Modifier.height(56.dp))

        // ── 1. Back button ─────────────────────────────────────────────────────
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Icon(
                imageVector        = Icons.Outlined.ArrowBack,
                contentDescription = "Geri",
                modifier = Modifier
                    .size(28.dp)
                    .clickable { onBack() },
                tint = AppTheme.Colors.primaryText
            )
            Text(
                text       = "Məşq Detalları",
                fontSize   = 17.sp,
                fontWeight = FontWeight.SemiBold,
                color      = AppTheme.Colors.primaryText
            )
        }

        Spacer(modifier = Modifier.height(20.dp))

        // ── 2. Title + Category icon ───────────────────────────────────────────
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Category icon circle
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .background(categoryColor.copy(alpha = 0.2f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = categoryIcon,
                    contentDescription = null,
                    modifier = Modifier.size(26.dp),
                    tint = categoryColor
                )
            }

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text       = workout.title,
                    fontSize   = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.primaryText
                )
                Text(
                    text     = categoryLabel,
                    fontSize = 14.sp,
                    color    = AppTheme.Colors.secondaryText
                )
            }

            // Completion status badge
            if (workout.isCompleted) {
                CoreViaIconBadge(
                    icon = Icons.Outlined.CheckCircle,
                    tintColor = AppTheme.Colors.success,
                    size = 36.dp,
                    iconSize = 18.dp
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // ── 3. Info row: Duration, Calories, Category ──────────────────────────
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .coreViaCard()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            // Duration
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                CoreViaIconBadge(
                    icon = Icons.Outlined.Schedule,
                    tintColor = AppTheme.Colors.accent,
                    size = 36.dp,
                    iconSize = 18.dp
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text       = "${workout.duration}",
                    fontSize   = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.primaryText
                )
                Text(
                    text     = "dəq",
                    fontSize = 11.sp,
                    color    = AppTheme.Colors.secondaryText
                )
            }

            // Calories
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                CoreViaIconBadge(
                    icon = Icons.Outlined.LocalFireDepartment,
                    tintColor = Color(0xFFFF9500),
                    size = 36.dp,
                    iconSize = 18.dp
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text       = "${workout.caloriesBurned ?: 0}",
                    fontSize   = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.primaryText
                )
                Text(
                    text     = "kal",
                    fontSize = 11.sp,
                    color    = AppTheme.Colors.secondaryText
                )
            }

            // Category
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                CoreViaIconBadge(
                    icon = categoryIcon,
                    tintColor = categoryColor,
                    size = 36.dp,
                    iconSize = 18.dp
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text       = categoryLabel,
                    fontSize   = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color      = AppTheme.Colors.primaryText
                )
                Text(
                    text     = "Kateqoriya",
                    fontSize = 11.sp,
                    color    = AppTheme.Colors.secondaryText
                )
            }
        }

        // ── 4. Notes section ───────────────────────────────────────────────────
        if (!workout.notes.isNullOrBlank()) {
            Spacer(modifier = Modifier.height(16.dp))

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .coreViaCard()
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    CoreViaIconBadge(
                        icon = Icons.Outlined.Notes,
                        tintColor = AppTheme.Colors.accent,
                        size = 28.dp,
                        iconSize = 14.dp
                    )
                    Text(
                        text       = "Qeydlər",
                        fontSize   = 15.sp,
                        fontWeight = FontWeight.SemiBold,
                        color      = AppTheme.Colors.primaryText
                    )
                }
                Text(
                    text     = workout.notes,
                    fontSize = 14.sp,
                    color    = AppTheme.Colors.secondaryText,
                    lineHeight = 20.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // ── 5. Completion toggle button ────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(
                    8.dp, RoundedCornerShape(14.dp),
                    spotColor = (if (workout.isCompleted) AppTheme.Colors.accent else AppTheme.Colors.success).copy(alpha = 0.3f)
                )
                .background(
                    brush = Brush.horizontalGradient(
                        colors = if (workout.isCompleted) {
                            listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.8f))
                        } else {
                            listOf(AppTheme.Colors.success, AppTheme.Colors.success.copy(alpha = 0.8f))
                        }
                    ),
                    shape = RoundedCornerShape(14.dp)
                )
                .clip(RoundedCornerShape(14.dp))
                .clickable { onToggleComplete(workout.id) }
                .padding(16.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = if (workout.isCompleted) Icons.Outlined.Replay else Icons.Outlined.CheckCircle,
                    contentDescription = null,
                    tint = Color.White
                )
                Text(
                    text       = if (workout.isCompleted) "Tamamlanmamış et" else "Tamamlandı olaraq işarələ",
                    fontWeight = FontWeight.Bold,
                    color      = Color.White
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // ── 6. Edit button ─────────────────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(
                    8.dp, RoundedCornerShape(14.dp),
                    spotColor = AppTheme.Colors.accent.copy(alpha = 0.3f)
                )
                .background(
                    brush = Brush.horizontalGradient(
                        colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.8f))
                    ),
                    shape = RoundedCornerShape(14.dp)
                )
                .clip(RoundedCornerShape(14.dp))
                .clickable { onEdit() }
                .padding(16.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Outlined.Edit,
                    contentDescription = null,
                    tint = Color.White
                )
                Text(
                    text       = "Redaktə et",
                    fontWeight = FontWeight.Bold,
                    color      = Color.White
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // ── 7. Delete button ───────────────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .coreViaCard(accentColor = AppTheme.Colors.error, cornerRadius = 14.dp)
                .clip(RoundedCornerShape(14.dp))
                .clickable { showDeleteDialog = true }
                .padding(16.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Outlined.Delete,
                    contentDescription = null,
                    tint = AppTheme.Colors.error
                )
                Text(
                    text       = "Sil",
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.error
                )
            }
        }

        Spacer(modifier = Modifier.height(100.dp))
    }
    } // CoreViaAnimatedBackground

    // ── Delete confirmation dialog ─────────────────────────────────────────────
    if (showDeleteDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteDialog = false },
            containerColor   = AppTheme.Colors.cardBackground,
            title = {
                Text(
                    text       = "Məşqi sil?",
                    fontWeight = FontWeight.Bold,
                    color      = AppTheme.Colors.primaryText
                )
            },
            text = {
                Text(
                    text  = "\"${workout.title}\" məşqini silmək istədiyinizə əminsiniz? Bu əməliyyat geri qaytarıla bilməz.",
                    color = AppTheme.Colors.secondaryText
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showDeleteDialog = false
                        onDelete(workout.id)
                    }
                ) {
                    Text(
                        text       = "Sil",
                        color      = AppTheme.Colors.error,
                        fontWeight = FontWeight.Bold
                    )
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteDialog = false }) {
                    Text(
                        text  = "Ləğv et",
                        color = AppTheme.Colors.secondaryText
                    )
                }
            }
        )
    }
}
