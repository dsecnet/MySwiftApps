package life.corevia.app.ui.tracking

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.*

/**
 * iOS LiveTrackingView.swift — Android 1-ə-1 port
 *
 * Layout (iOS ilə eyni):
 *  - Map section: 40% yuxarı, cornerRadius 20, shadow, padding
 *  - Stats section: 60% aşağı, secondaryBackground, cornerRadius 20
 *    - "Canlı İzləmə" title
 *    - 2×2 stat cards (Distance/Calories, Time/Speed) — cardBackground, font 32/36
 *    - Control buttons (Start green / Pause orange / Resume+Stop)
 */
@Composable
fun LiveTrackingScreen(
    viewModel: TrackingViewModel,
    onBack: () -> Unit
) {
    val isTracking by viewModel.isTracking.collectAsState()
    val isPaused by viewModel.isPaused.collectAsState()
    val elapsedSeconds by viewModel.elapsedSeconds.collectAsState()
    val distance by viewModel.distance.collectAsState()
    val currentSpeed by viewModel.currentSpeed.collectAsState()
    val calories by viewModel.calories.collectAsState()
    val activityType by viewModel.activityType.collectAsState()
    val route by viewModel.route.collectAsState()

    val activityTypes = listOf("running", "walking", "cycling")
    val activityLabels = mapOf("running" to "Qaçış", "walking" to "Gəzinti", "cycling" to "Velosiped")
    val activityEmojis = mapOf("running" to "🏃", "walking" to "🚶", "cycling" to "🚴")

    // Default Baku coordinates
    val defaultLocation = LatLng(40.4093, 49.8671)
    val cameraTarget = if (route.isNotEmpty()) {
        LatLng(route.last().latitude, route.last().longitude)
    } else defaultLocation

    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(cameraTarget, 16f)
    }

    // Update camera when route changes (iOS: userTrackingMode = .follow)
    LaunchedEffect(route.size) {
        if (route.isNotEmpty()) {
            val last = route.last()
            cameraPositionState.position = CameraPosition.fromLatLngZoom(
                LatLng(last.latitude, last.longitude), 16f
            )
        }
    }

    Box(modifier = Modifier.fillMaxSize().background(AppTheme.Colors.background)) {
        Column(modifier = Modifier.fillMaxSize()) {

            // ─── Back Button (top-left overlay) ─────────────────────────
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .padding(top = 50.dp, bottom = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = AppTheme.Colors.accent)
                }
                Spacer(Modifier.width(8.dp))
                Text("GPS İzləmə", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = AppTheme.Colors.primaryText)
            }

            // ─── Activity type selector (yalnız tracking olmadıqda) ─────
            if (!isTracking) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    activityTypes.forEach { type ->
                        FilterChip(
                            selected = activityType == type,
                            onClick = { viewModel.setActivityType(type) },
                            label = { Text("${activityEmojis[type]} ${activityLabels[type]}", fontSize = 13.sp) },
                            modifier = Modifier.weight(1f),
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = AppTheme.Colors.accent,
                                selectedLabelColor = Color.White,
                                containerColor = AppTheme.Colors.cardBackground,
                                labelColor = AppTheme.Colors.secondaryText
                            )
                        )
                    }
                }
                Spacer(Modifier.height(8.dp))
            }

            // ═════════════════════════════════════════════════════════════
            // iOS: Map section — 40% height, cornerRadius(20), shadow, padding
            // MapViewWithRoute: showsUserLocation=true, userTrackingMode=.follow
            // Polyline: systemBlue.opacity(0.7), lineWidth 5
            // ═════════════════════════════════════════════════════════════
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(0.4f)
                    .padding(horizontal = 16.dp)
                    .shadow(5.dp, RoundedCornerShape(20.dp))
                    .clip(RoundedCornerShape(20.dp))
            ) {
                GoogleMap(
                    modifier = Modifier.fillMaxSize(),
                    cameraPositionState = cameraPositionState,
                    properties = MapProperties(
                        isMyLocationEnabled = false,
                        mapType = MapType.NORMAL
                    ),
                    uiSettings = MapUiSettings(
                        zoomControlsEnabled = false,
                        myLocationButtonEnabled = false,
                        compassEnabled = false,
                        mapToolbarEnabled = false
                    )
                ) {
                    // iOS: MKPolyline — systemBlue.withAlphaComponent(0.7), lineWidth 5
                    if (route.size > 1) {
                        Polyline(
                            points = route.map { LatLng(it.latitude, it.longitude) },
                            color = Color(0xFF2196F3).copy(alpha = 0.7f),
                            width = 5f
                        )
                    }

                    // Current position marker
                    if (route.isNotEmpty()) {
                        val last = route.last()
                        Marker(
                            state = MarkerState(position = LatLng(last.latitude, last.longitude)),
                            title = activityLabels[activityType] ?: "Aktivlik"
                        )
                    } else {
                        Marker(state = MarkerState(position = defaultLocation), title = "Başlanğıc")
                    }
                }

                // Activity type badge (top-left overlay)
                if (isTracking) {
                    Box(
                        modifier = Modifier.align(Alignment.TopStart).padding(12.dp)
                            .background(AppTheme.Colors.accent, RoundedCornerShape(20.dp))
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(activityEmojis[activityType] ?: "🏃", fontSize = 12.sp)
                            Text(activityLabels[activityType] ?: "", fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = Color.White)
                        }
                    }

                    // Live indicator (top-right)
                    if (!isPaused) {
                        Box(
                            modifier = Modifier.align(Alignment.TopEnd).padding(12.dp)
                                .background(Color.Red, RoundedCornerShape(20.dp))
                                .padding(horizontal = 10.dp, vertical = 4.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                Box(Modifier.size(8.dp).background(Color.White, CircleShape))
                                Text("CANLI", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.White)
                            }
                        }
                    }
                }
            }

            // ═════════════════════════════════════════════════════════════
            // iOS: Stats section — 60%, secondaryBackground, cornerRadius 20
            // Large stat cards: icon 32sp, value 36sp bold, label 14sp
            // Background: cardBackground, cornerRadius 16
            // ═════════════════════════════════════════════════════════════
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(0.6f)
                    .background(
                        AppTheme.Colors.secondaryBackground,
                        RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
                    )
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // iOS: "Canlı İzləmə" title, .system(size: 22, weight: .bold)
                Text(
                    text = "Canlı İzləmə",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )

                // iOS: Distance & Calories row — HStack(spacing: 16)
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    LiveStatCard(
                        modifier = Modifier.weight(1f),
                        emoji = "🏃",
                        value = viewModel.formatDistance(distance),
                        label = "Kilometr",
                        color = Color(0xFF2196F3) // iOS: .blue
                    )
                    LiveStatCard(
                        modifier = Modifier.weight(1f),
                        emoji = "🔥",
                        value = "$calories",
                        label = "Kalori",
                        color = Color(0xFFFF9800) // iOS: .orange
                    )
                }

                // iOS: Time & Speed row — HStack(spacing: 16)
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    LiveStatCard(
                        modifier = Modifier.weight(1f),
                        emoji = "⏱",
                        value = viewModel.formatTime(elapsedSeconds),
                        label = "Vaxt",
                        color = Color(0xFF4CAF50) // iOS: .green
                    )
                    LiveStatCard(
                        modifier = Modifier.weight(1f),
                        emoji = "⚡",
                        value = viewModel.formatSpeed(currentSpeed),
                        label = "km/s",
                        color = Color(0xFF9C27B0) // iOS: .purple
                    )
                }

                if (isPaused) {
                    Text(
                        "⏸ Fasilə", fontSize = 14.sp, color = AppTheme.Colors.warning,
                        fontWeight = FontWeight.SemiBold, modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center
                    )
                }

                Spacer(Modifier.weight(1f))

                // ─── Control Buttons (iOS: HStack inside stats section) ──
                when {
                    !isTracking -> {
                        // iOS: green start button
                        Button(
                            onClick = { viewModel.startTracking() },
                            modifier = Modifier.fillMaxWidth().height(64.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4CAF50)),
                            shape = RoundedCornerShape(16.dp)
                        ) {
                            Icon(Icons.Filled.PlayArrow, null, Modifier.size(28.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("Başla", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    isPaused -> {
                        // iOS: resume (green) + stop (red)
                        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                            Button(
                                onClick = { viewModel.resumeTracking() },
                                modifier = Modifier.weight(1f).height(64.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4CAF50)),
                                shape = RoundedCornerShape(16.dp)
                            ) {
                                Icon(Icons.Filled.PlayArrow, null, Modifier.size(24.dp))
                                Spacer(Modifier.width(4.dp))
                                Text("Davam et", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                            }
                            Button(
                                onClick = { viewModel.stopTracking() },
                                modifier = Modifier.weight(1f).height(64.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.error),
                                shape = RoundedCornerShape(16.dp)
                            ) {
                                Icon(Icons.Filled.Close, null, Modifier.size(24.dp))
                                Spacer(Modifier.width(4.dp))
                                Text("Bitir", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }

                    else -> {
                        // iOS: pause (orange)
                        Button(
                            onClick = { viewModel.pauseTracking() },
                            modifier = Modifier.fillMaxWidth().height(64.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.warning),
                            shape = RoundedCornerShape(16.dp)
                        ) {
                            Text("⏸", fontSize = 24.sp)
                            Spacer(Modifier.width(8.dp))
                            Text("Fasilə", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                // iOS: bottom padding for safe area
                Spacer(Modifier.height(20.dp))
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// iOS: Large stat card — icon 32sp, value 36sp bold, label 14sp
// Background: cardBackground, cornerRadius 16
// ═══════════════════════════════════════════════════════════════════════════════
@Composable
private fun LiveStatCard(
    modifier: Modifier = Modifier,
    emoji: String,
    value: String,
    label: String,
    color: Color
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground)
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // iOS: Image(systemName:).font(.system(size: 32))
        Text(emoji, fontSize = 32.sp)
        // iOS: .font(.system(size: 36, weight: .bold))
        Text(
            text = value,
            fontSize = 36.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center,
            maxLines = 1
        )
        // iOS: .font(.system(size: 14))
        Text(
            text = label,
            fontSize = 14.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}
