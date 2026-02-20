package life.corevia.app.ui.tracking

import android.Manifest
import android.content.pm.PackageManager
import life.corevia.app.ui.theme.AppTheme
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Polyline
import org.osmdroid.views.overlay.mylocation.GpsMyLocationProvider
import org.osmdroid.views.overlay.mylocation.MyLocationNewOverlay

/**
 * iOS LiveTrackingView.swift — Android 1-ə-1 port (osmdroid OpenStreetMap)
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

    // iOS: showsUserLocation = true → runtime permission lazımdır
    val context = LocalContext.current
    var hasLocationPermission by remember {
        mutableStateOf(
            ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        )
    }
    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted -> hasLocationPermission = granted }

    LaunchedEffect(Unit) {
        if (!hasLocationPermission) {
            permissionLauncher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
        }
    }

    val activityTypes = listOf("running", "walking", "cycling")
    val activityLabels = mapOf("running" to "Qaçış", "walking" to "Gəzinti", "cycling" to "Velosiped")
    val activityEmojis = mapOf("running" to "🏃", "walking" to "🚶", "cycling" to "🚴")

    // Default Baku coordinates
    val defaultLocation = GeoPoint(40.4093, 49.8671)

    // osmdroid config
    LaunchedEffect(Unit) {
        Configuration.getInstance().userAgentValue = context.packageName
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

            // ═══════════════════════════════════════════════════════════
            // iOS: Map section — 40% height, cornerRadius(20), shadow
            // OpenStreetMap (osmdroid) — API key lazım deyil
            // ═══════════════════════════════════════════════════════════
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(0.35f)
                    .padding(horizontal = 16.dp)
                    .shadow(5.dp, RoundedCornerShape(20.dp))
                    .clip(RoundedCornerShape(20.dp))
            ) {
                val polylineColor = Color(0xFF2196F3).copy(alpha = 0.7f).toArgb()

                AndroidView(
                    modifier = Modifier.fillMaxSize(),
                    factory = { ctx ->
                        MapView(ctx).apply {
                            setTileSource(TileSourceFactory.MAPNIK)
                            setMultiTouchControls(true)
                            controller.setZoom(16.0)
                            controller.setCenter(defaultLocation)

                            // iOS: showsUserLocation = true, userTrackingMode = .follow
                            if (hasLocationPermission) {
                                val locationOverlay = MyLocationNewOverlay(GpsMyLocationProvider(ctx), this)
                                locationOverlay.enableMyLocation()
                                locationOverlay.enableFollowLocation()
                                overlays.add(locationOverlay)
                            }

                            // Disable zoom buttons (iOS kimi clean UI)
                            zoomController.setVisibility(org.osmdroid.views.CustomZoomButtonsController.Visibility.NEVER)
                        }
                    },
                    update = { mapView ->
                        // Route polyline — iOS: systemBlue.opacity(0.7), lineWidth 5
                        // Remove old polylines
                        mapView.overlays.removeAll { it is Polyline }

                        if (route.size > 1) {
                            val polyline = Polyline().apply {
                                outlinePaint.color = polylineColor
                                outlinePaint.strokeWidth = 5f
                                setPoints(route.map { GeoPoint(it.latitude, it.longitude) })
                            }
                            mapView.overlays.add(polyline)
                        }

                        // Follow last point
                        if (route.isNotEmpty()) {
                            val last = route.last()
                            mapView.controller.animateTo(GeoPoint(last.latitude, last.longitude))
                        }

                        mapView.invalidate()
                    }
                )

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

            // ═══════════════════════════════════════════════════════════
            // iOS: Stats section — 60%, secondaryBackground, cornerRadius 20
            // ═══════════════════════════════════════════════════════════
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(0.65f)
                    .background(
                        AppTheme.Colors.secondaryBackground,
                        RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
                    )
                    .padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Text(
                    text = "Canlı İzləmə",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )

                // iOS: Distance & Calories row
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    LiveStatCard(
                        modifier = Modifier.weight(1f),
                        emoji = "🏃",
                        value = viewModel.formatDistance(distance),
                        label = "Kilometr",
                        color = Color(0xFF2196F3)
                    )
                    LiveStatCard(
                        modifier = Modifier.weight(1f),
                        emoji = "🔥",
                        value = "$calories",
                        label = "Kalori",
                        color = Color(0xFFFF9800)
                    )
                }

                // iOS: Time & Speed row
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    LiveStatCard(
                        modifier = Modifier.weight(1f),
                        emoji = "⏱",
                        value = viewModel.formatTime(elapsedSeconds),
                        label = "Vaxt",
                        color = Color(0xFF4CAF50)
                    )
                    LiveStatCard(
                        modifier = Modifier.weight(1f),
                        emoji = "⚡",
                        value = viewModel.formatSpeed(currentSpeed),
                        label = "km/s",
                        color = Color(0xFF9C27B0)
                    )
                }

                if (isPaused) {
                    Text(
                        "⏸ Fasilə", fontSize = 14.sp, color = AppTheme.Colors.warning,
                        fontWeight = FontWeight.SemiBold, modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center
                    )
                }

                // ─── Control Buttons ──
                when {
                    !isTracking -> {
                        Button(
                            onClick = { viewModel.startTracking() },
                            modifier = Modifier.fillMaxWidth().height(56.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4CAF50)),
                            shape = RoundedCornerShape(16.dp)
                        ) {
                            Icon(Icons.Outlined.PlayArrow, null, Modifier.size(28.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("Başla", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    isPaused -> {
                        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                            Button(
                                onClick = { viewModel.resumeTracking() },
                                modifier = Modifier.weight(1f).height(64.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4CAF50)),
                                shape = RoundedCornerShape(16.dp)
                            ) {
                                Icon(Icons.Outlined.PlayArrow, null, Modifier.size(24.dp))
                                Spacer(Modifier.width(4.dp))
                                Text("Davam et", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                            }
                            Button(
                                onClick = { viewModel.stopTracking() },
                                modifier = Modifier.weight(1f).height(64.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.error),
                                shape = RoundedCornerShape(16.dp)
                            ) {
                                Icon(Icons.Outlined.Close, null, Modifier.size(24.dp))
                                Spacer(Modifier.width(4.dp))
                                Text("Bitir", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }

                    else -> {
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

                Spacer(Modifier.height(40.dp))
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// iOS: Large stat card — icon 32sp, value 36sp bold, label 14sp
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
            .clip(RoundedCornerShape(14.dp))
            .background(AppTheme.Colors.cardBackground)
            .padding(10.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(emoji, fontSize = 22.sp)
        Text(
            text = value,
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText,
            textAlign = TextAlign.Center,
            maxLines = 1
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}
