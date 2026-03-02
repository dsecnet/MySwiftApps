package life.corevia.app.ui.route

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.RouteResponse
import life.corevia.app.ui.components.CoreViaFilterChip
import life.corevia.app.ui.theme.*

@Composable
fun RouteTrackingScreen(
    viewModel: RouteViewModel = hiltViewModel(),
    onNavigateToRouteDetail: ((RouteResponse) -> Unit)? = null
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    var showStartSheet by remember { mutableStateOf(false) }
    var showLocationDenied by remember { mutableStateOf(false) }
    var pendingActivityType by remember { mutableStateOf<ActivityType?>(null) }

    // Activity Recognition permission (step counter - Android 10+)
    val activityPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { _ ->
        // Start tracking after activity permission result (granted or not)
        pendingActivityType?.let { type ->
            viewModel.startTracking(type)
            pendingActivityType = null
        }
    }

    val locationPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val fineGranted = permissions[Manifest.permission.ACCESS_FINE_LOCATION] == true
        if (fineGranted && pendingActivityType != null) {
            // Request ACTIVITY_RECOGNITION for step counter (Android 10+)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                activityPermissionLauncher.launch(Manifest.permission.ACTIVITY_RECOGNITION)
            } else {
                viewModel.startTracking(pendingActivityType!!)
                pendingActivityType = null
            }
        } else if (!fineGranted) {
            showLocationDenied = true
        }
    }

    fun requestTrackingStart(type: ActivityType) {
        pendingActivityType = type
        locationPermissionLauncher.launch(
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        )
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        if (uiState.isPremium) {
            // Premium content
            Box {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(rememberScrollState())
                        .padding(bottom = 100.dp)
                        .padding(horizontal = 20.dp)
                ) {
                    Spacer(modifier = Modifier.height(56.dp))

                    // Header
                    HeaderSection()

                    Spacer(modifier = Modifier.height(20.dp))

                    // Weekly Stats
                    WeeklyStatsSection(
                        distanceKm = uiState.weeklyStats.totalDistanceKm,
                        durationSeconds = uiState.weeklyStats.totalDurationSeconds,
                        calories = uiState.weeklyStats.totalCalories,
                        formatMinutes = viewModel::formatMinutes
                    )

                    Spacer(modifier = Modifier.height(20.dp))

                    // Active Tracking
                    AnimatedVisibility(visible = uiState.isTracking) {
                        Column {
                            ActiveTrackingSection(
                                activeType = uiState.activeType,
                                elapsedSeconds = uiState.elapsedSeconds,
                                distanceKm = uiState.distanceKm,
                                livePace = uiState.livePace,
                                formatElapsedTime = viewModel::formatElapsedTime,
                                onStop = { viewModel.stopTracking() }
                            )
                            Spacer(modifier = Modifier.height(20.dp))
                        }
                    }

                    // Filter
                    FilterSection(
                        selectedFilter = uiState.selectedFilter,
                        onFilterChanged = { viewModel.setFilter(it) }
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Activity List
                    ActivityListSection(
                        isLoading = uiState.isLoading,
                        routes = uiState.filteredRoutes,
                        formatDate = viewModel::formatDate,
                        formatDuration = viewModel::formatDuration,
                        onRouteClick = onNavigateToRouteDetail
                    )
                }

                // FAB — Start Activity
                if (!uiState.isTracking) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.BottomEnd)
                            .padding(end = 20.dp, bottom = 20.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(60.dp)
                                .shadow(12.dp, CircleShape, ambientColor = CoreViaPrimary.copy(alpha = 0.4f))
                                .clip(CircleShape)
                                .background(
                                    Brush.linearGradient(
                                        listOf(CoreViaPrimary, CoreViaPrimary.copy(alpha = 0.7f))
                                    )
                                )
                                .clickable { showStartSheet = true },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                Icons.Filled.PlayArrow,
                                contentDescription = "Başlat",
                                modifier = Modifier.size(28.dp),
                                tint = Color.White
                            )
                        }
                    }
                }
            }
        } else {
            // Locked content
            LockedActivitiesContent(
                onUnlockClick = { /* navigate to premium */ }
            )
        }
    }

    // Start Activity Bottom Sheet
    if (showStartSheet) {
        StartActivitySheet(
            onDismiss = { showStartSheet = false },
            onStart = { type ->
                showStartSheet = false
                requestTrackingStart(type)
            }
        )
    }

    // Location Denied Dialog
    if (showLocationDenied) {
        AlertDialog(
            onDismissRequest = { showLocationDenied = false },
            title = { Text("Lokasiya icazəsi lazımdır") },
            text = { Text("Marşrut izləmək üçün lokasiya icazəsi verin.") },
            confirmButton = {
                TextButton(onClick = {
                    showLocationDenied = false
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", context.packageName, null)
                    }
                    context.startActivity(intent)
                }) { Text("Ayarlar") }
            },
            dismissButton = {
                TextButton(onClick = { showLocationDenied = false }) { Text("Bağla") }
            }
        )
    }
}

// ─── Header ─────────────────────────────────────────────────────────

@Composable
private fun HeaderSection() {
    Column(modifier = Modifier.fillMaxWidth()) {
        Text(
            text = "Hərəkətlər",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "GPS ilə marşrutunuzu izləyin",
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ─── Weekly Stats ───────────────────────────────────────────────────

@Composable
private fun WeeklyStatsSection(
    distanceKm: Double,
    durationSeconds: Int,
    calories: Int,
    formatMinutes: (Int) -> String
) {
    Column {
        Text(
            text = "Bu həftə",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Spacer(modifier = Modifier.height(12.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            ActivityStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.LocationOn,
                value = String.format("%.1f km", distanceKm),
                label = "Məsafə",
                color = CoreViaPrimary
            )
            ActivityStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.Schedule,
                value = formatMinutes(durationSeconds / 60),
                label = "Müddət",
                color = CoreViaPrimary
            )
            ActivityStatCard(
                modifier = Modifier.weight(1f),
                icon = Icons.Filled.LocalFireDepartment,
                value = "$calories",
                label = "Kalori",
                color = CoreViaPrimary
            )
        }
    }
}

@Composable
private fun ActivityStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(vertical = 14.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(18.dp),
            tint = color
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface,
            maxLines = 1
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ─── Active Tracking Section ────────────────────────────────────────

@Composable
private fun ActiveTrackingSection(
    activeType: ActivityType,
    elapsedSeconds: Int,
    distanceKm: Double,
    livePace: String,
    formatElapsedTime: (Int) -> String,
    onStop: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .border(2.dp, activeType.color.copy(alpha = 0.5f), RoundedCornerShape(16.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Header row
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = activeType.icon,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                tint = activeType.color
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = activeType.displayName,
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurface
            )
            Spacer(modifier = Modifier.weight(1f))
            Box(
                modifier = Modifier
                    .size(10.dp)
                    .clip(CircleShape)
                    .background(CoreViaPrimary)
            )
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = "Aktiv",
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                color = CoreViaPrimary
            )
        }

        // Stats row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            TrackingStat(
                value = formatElapsedTime(elapsedSeconds),
                label = "Vaxt"
            )
            TrackingStat(
                value = String.format("%.2f", distanceKm),
                label = "km"
            )
            TrackingStat(
                value = livePace,
                label = "dəq/km"
            )
        }

        // Stop button
        Button(
            onClick = onStop,
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
        ) {
            Icon(
                Icons.Filled.Stop,
                contentDescription = null,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "Dayandır",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun TrackingStat(value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            fontFamily = FontFamily.Monospace,
            color = MaterialTheme.colorScheme.onSurface
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ─── Filter Section ─────────────────────────────────────────────────

@Composable
private fun FilterSection(
    selectedFilter: ActivityType?,
    onFilterChanged: (ActivityType?) -> Unit
) {
    Column {
        Text(
            text = "Tarixçə",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Spacer(modifier = Modifier.height(12.dp))

        LazyRow(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            item {
                CoreViaFilterChip(
                    title = "Hamısı",
                    isSelected = selectedFilter == null,
                    color = CoreViaPrimary,
                    onClick = { onFilterChanged(null) }
                )
            }
            items(ActivityType.entries) { type ->
                CoreViaFilterChip(
                    title = type.displayName,
                    icon = type.icon,
                    isSelected = selectedFilter == type,
                    color = type.color,
                    onClick = { onFilterChanged(type) }
                )
            }
        }
    }
}

// ─── Activity List Section ──────────────────────────────────────────

@Composable
private fun ActivityListSection(
    isLoading: Boolean,
    routes: List<RouteResponse>,
    formatDate: (String?) -> String,
    formatDuration: (Int) -> String,
    onRouteClick: ((RouteResponse) -> Unit)?
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        if (isLoading) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 40.dp),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = CoreViaPrimary)
            }
        } else if (routes.isEmpty()) {
            // Empty state
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 40.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(
                    Icons.Filled.DirectionsWalk,
                    contentDescription = null,
                    modifier = Modifier.size(40.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = "Hərəkət tapılmadı",
                    fontSize = 15.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Başlamaq üçün + düyməsinə basın",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
                )
            }
        } else {
            routes.forEach { route ->
                RouteActivityCard(
                    route = route,
                    formatDate = formatDate,
                    formatDuration = formatDuration,
                    onClick = { onRouteClick?.invoke(route) }
                )
            }
        }
    }
}

@Composable
private fun RouteActivityCard(
    route: RouteResponse,
    formatDate: (String?) -> String,
    formatDuration: (Int) -> String,
    onClick: () -> Unit
) {
    val activityType = ActivityType.fromValue(route.activityType)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surface)
            .clickable(onClick = onClick)
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        // Activity icon
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(activityType.color.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = activityType.icon,
                contentDescription = null,
                modifier = Modifier.size(22.dp),
                tint = activityType.color
            )
        }

        // Info
        Column(modifier = Modifier.weight(1f)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = activityType.displayName,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = formatDate(route.startedAt),
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Spacer(modifier = Modifier.height(6.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                StatLabel(Icons.Filled.LocationOn, String.format("%.2f km", route.distanceKm))
                StatLabel(Icons.Filled.Schedule, formatDuration(route.durationSeconds))
                route.caloriesBurned?.let { cal ->
                    StatLabel(Icons.Filled.LocalFireDepartment, "$cal kcal")
                }
            }
        }

        // Chevron
        Icon(
            Icons.Filled.ChevronRight,
            contentDescription = null,
            modifier = Modifier.size(16.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun StatLabel(icon: ImageVector, text: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(3.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(12.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = text,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ─── Start Activity Bottom Sheet ────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun StartActivitySheet(
    onDismiss: () -> Unit,
    onStart: (ActivityType) -> Unit
) {
    var selectedType by remember { mutableStateOf(ActivityType.RUNNING) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            Text(
                text = "Hərəkətə Başla",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface
            )

            // Activity type selector
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                ActivityType.entries.forEach { type ->
                    val isSelected = selectedType == type
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(14.dp))
                            .background(
                                if (isSelected) type.color.copy(alpha = 0.08f) else Color.Transparent
                            )
                            .then(
                                if (isSelected) Modifier.border(
                                    2.dp,
                                    type.color,
                                    RoundedCornerShape(14.dp)
                                ) else Modifier
                            )
                            .clickable { selectedType = type }
                            .padding(vertical = 12.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Box(
                            modifier = Modifier
                                .size(64.dp)
                                .clip(CircleShape)
                                .background(
                                    if (isSelected) type.color.copy(alpha = 0.2f)
                                    else MaterialTheme.colorScheme.surfaceVariant
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = type.icon,
                                contentDescription = null,
                                modifier = Modifier.size(28.dp),
                                tint = if (isSelected) type.color
                                else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        Spacer(modifier = Modifier.height(10.dp))
                        Text(
                            text = type.displayName,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = if (isSelected) MaterialTheme.colorScheme.onSurface
                            else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            // Start button
            Button(
                onClick = { onStart(selectedType) },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp)
                    .shadow(
                        10.dp,
                        RoundedCornerShape(16.dp),
                        ambientColor = selectedType.color.copy(alpha = 0.4f)
                    ),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = selectedType.color
                )
            ) {
                Icon(
                    Icons.Filled.PlayArrow,
                    contentDescription = null,
                    modifier = Modifier.size(22.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = "Başla",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// ─── Locked Activities Content ──────────────────────────────────────

@Composable
private fun LockedActivitiesContent(
    onUnlockClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp)
            .padding(bottom = 100.dp)
    ) {
        Spacer(modifier = Modifier.height(56.dp))
        HeaderSection()
        Spacer(modifier = Modifier.height(20.dp))

        // Blurred stats placeholder
        Box(modifier = Modifier.fillMaxWidth()) {
            WeeklyStatsSection(
                distanceKm = 0.0,
                durationSeconds = 0,
                calories = 0,
                formatMinutes = { "0 dəq" }
            )
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Lock overlay
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .clickable(onClick = onUnlockClick)
        ) {
            // Placeholder cards
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                repeat(3) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(14.dp))
                            .background(MaterialTheme.colorScheme.surface)
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(14.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(48.dp)
                                .clip(CircleShape)
                                .background(Color.Gray.copy(alpha = 0.1f))
                        )
                        Column {
                            Box(
                                modifier = Modifier
                                    .size(120.dp, 14.dp)
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(Color.Gray.copy(alpha = 0.15f))
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                            Box(
                                modifier = Modifier
                                    .size(180.dp, 12.dp)
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(Color.Gray.copy(alpha = 0.1f))
                            )
                        }
                    }
                }
            }

            // Lock overlay content
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 30.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(60.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                listOf(CoreViaPrimaryDark, CoreViaPrimary)
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.Lock,
                        contentDescription = null,
                        modifier = Modifier.size(26.dp),
                        tint = Color.White
                    )
                }

                Text(
                    text = "GPS Marşrut İzləmə",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )

                Text(
                    text = "Premium ilə GPS marşrut izləmə, statistikalar və daha çox",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(horizontal = 20.dp)
                )

                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(14.dp))
                        .background(
                            Brush.horizontalGradient(
                                listOf(CoreViaPrimaryDark, CoreViaPrimary)
                            )
                        )
                        .padding(horizontal = 24.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        Icons.Filled.AutoAwesome,
                        contentDescription = null,
                        modifier = Modifier.size(14.dp),
                        tint = Color.White
                    )
                    Text(
                        text = "Premium-a keç",
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = Color.White
                    )
                }
            }
        }
    }
}
