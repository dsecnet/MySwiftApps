package life.corevia.app.ui.route

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.*
import life.corevia.app.ui.theme.*

@Composable
fun GPSTrackingScreen(
    activityType: ActivityType = ActivityType.RUNNING,
    viewModel: RouteViewModel = hiltViewModel(),
    onClose: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    var hasLocationPermission by remember { mutableStateOf(false) }
    var showLocationDenied by remember { mutableStateOf(false) }
    var permissionRequested by remember { mutableStateOf(false) }
    var showFinishDialog by remember { mutableStateOf(false) }

    val locationPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val fineGranted = permissions[Manifest.permission.ACCESS_FINE_LOCATION] == true
        hasLocationPermission = fineGranted
        if (fineGranted) {
            viewModel.requestCurrentLocation()
        } else {
            showLocationDenied = true
        }
    }

    // Request permission on first load
    LaunchedEffect(Unit) {
        if (!permissionRequested) {
            permissionRequested = true
            locationPermissionLauncher.launch(
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                )
            )
        }
    }

    // Map camera state
    val defaultLat = uiState.currentLat ?: 40.4093
    val defaultLng = uiState.currentLng ?: 49.8671
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(LatLng(defaultLat, defaultLng), 15f)
    }

    // Move camera when current location updates
    LaunchedEffect(uiState.currentLat, uiState.currentLng) {
        if (uiState.currentLat != null && uiState.currentLng != null) {
            cameraPositionState.animate(
                CameraUpdateFactory.newLatLngZoom(
                    LatLng(uiState.currentLat!!, uiState.currentLng!!),
                    16f
                ),
                500
            )
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // Top bar with X close button
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 8.dp, end = 8.dp, top = 48.dp, bottom = 8.dp)
        ) {
            IconButton(
                onClick = {
                    if (uiState.isTracking) {
                        // If tracking, show finish dialog first
                        showFinishDialog = true
                    } else {
                        onClose()
                    }
                }
            ) {
                Icon(
                    Icons.Filled.Close,
                    contentDescription = "Bağla",
                    modifier = Modifier.size(28.dp),
                    tint = MaterialTheme.colorScheme.onBackground
                )
            }
        }

        // Content
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp)
        ) {
            // Google Map
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(280.dp)
                    .clip(RoundedCornerShape(16.dp))
            ) {
                GoogleMap(
                    modifier = Modifier.fillMaxSize(),
                    cameraPositionState = cameraPositionState,
                    properties = MapProperties(
                        isMyLocationEnabled = hasLocationPermission
                    ),
                    uiSettings = MapUiSettings(
                        zoomControlsEnabled = false,
                        myLocationButtonEnabled = false,
                        mapToolbarEnabled = false
                    )
                ) {
                    // Draw route polyline
                    if (uiState.trackPoints.size >= 2) {
                        Polyline(
                            points = uiState.trackPoints.map { LatLng(it.first, it.second) },
                            color = activityType.color,
                            width = 6f
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // "Canlı İzləmə" title
            Text(
                text = "Canlı İzləmə",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(16.dp))

            // 2x2 Stat Cards Grid
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                GPSStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Filled.DirectionsRun,
                    iconColor = Color(0xFF2196F3),
                    value = String.format("%.2f", uiState.distanceKm),
                    label = "Kilometr"
                )
                GPSStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Filled.LocalFireDepartment,
                    iconColor = Color(0xFFFF9800),
                    value = "${uiState.liveCalories}",
                    label = "Kalori"
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                GPSStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Filled.Schedule,
                    iconColor = CoreViaSuccess,
                    value = viewModel.formatElapsedTime(uiState.elapsedSeconds),
                    label = "Vaxt"
                )
                GPSStatCard(
                    modifier = Modifier.weight(1f),
                    icon = Icons.Filled.Speed,
                    iconColor = Color(0xFF9C27B0),
                    value = String.format("%.1f", uiState.liveSpeedKmH),
                    label = "km/s"
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Action buttons
            if (!uiState.isTracking) {
                // "Başla" button
                Button(
                    onClick = {
                        if (hasLocationPermission) {
                            viewModel.startTracking(activityType)
                        } else {
                            locationPermissionLauncher.launch(
                                arrayOf(
                                    Manifest.permission.ACCESS_FINE_LOCATION,
                                    Manifest.permission.ACCESS_COARSE_LOCATION
                                )
                            )
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(64.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CoreViaSuccess
                    )
                ) {
                    Icon(
                        Icons.Filled.PlayArrow,
                        contentDescription = null,
                        modifier = Modifier.size(28.dp),
                        tint = Color.White
                    )
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(
                        text = "Başla",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            } else {
                // Tracking active: Pause + Bitir buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Pause / Resume button
                    Button(
                        onClick = {
                            if (uiState.isPaused) {
                                viewModel.resumeTracking()
                            } else {
                                viewModel.pauseTracking()
                            }
                        },
                        modifier = Modifier
                            .weight(1f)
                            .height(64.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = if (uiState.isPaused) CoreViaSuccess else Color(0xFFFF9800)
                        )
                    ) {
                        Icon(
                            if (uiState.isPaused) Icons.Filled.PlayArrow else Icons.Filled.Pause,
                            contentDescription = null,
                            modifier = Modifier.size(24.dp),
                            tint = Color.White
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = if (uiState.isPaused) "Davam" else "Pauza",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }

                    // Bitir (Finish) button — opens confirm dialog
                    Button(
                        onClick = { showFinishDialog = true },
                        modifier = Modifier
                            .weight(1f)
                            .height(64.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CoreViaPrimary
                        ),
                        enabled = !uiState.isSaving
                    ) {
                        if (uiState.isSaving) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(24.dp),
                                color = Color.White,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Icon(
                                Icons.Filled.Stop,
                                contentDescription = null,
                                modifier = Modifier.size(24.dp),
                                tint = Color.White
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "Bitir",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.White
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(40.dp))
        }
    }

    // ── Finish Confirmation Dialog (iOS-like) ────────────────────────────
    if (showFinishDialog) {
        AlertDialog(
            onDismissRequest = { showFinishDialog = false },
            containerColor = MaterialTheme.colorScheme.surface,
            shape = RoundedCornerShape(20.dp),
            title = {
                Text(
                    text = "Hərəkəti bitir",
                    fontWeight = FontWeight.Bold,
                    fontSize = 20.sp
                )
            },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text(
                        text = "Hərəkəti bitirmək və yadda saxlamaq istəyirsiniz?",
                        fontSize = 15.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )

                    // Summary card
                    if (uiState.isTracking) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                                .padding(14.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            SummaryRow(
                                icon = Icons.Filled.DirectionsRun,
                                label = "Məsafə",
                                value = String.format("%.2f km", uiState.distanceKm)
                            )
                            SummaryRow(
                                icon = Icons.Filled.Schedule,
                                label = "Vaxt",
                                value = viewModel.formatElapsedTime(uiState.elapsedSeconds)
                            )
                            SummaryRow(
                                icon = Icons.Filled.LocalFireDepartment,
                                label = "Kalori",
                                value = "${uiState.liveCalories} kcal"
                            )
                            SummaryRow(
                                icon = Icons.Filled.Speed,
                                label = "Sürət",
                                value = String.format("%.1f km/s", uiState.liveSpeedKmH)
                            )
                        }
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        showFinishDialog = false
                        viewModel.finishAndSaveTracking { onClose() }
                    },
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = CoreViaSuccess),
                    enabled = !uiState.isSaving
                ) {
                    if (uiState.isSaving) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(18.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(
                            Icons.Filled.Save,
                            contentDescription = null,
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("Yadda saxla", fontWeight = FontWeight.Bold)
                    }
                }
            },
            dismissButton = {
                TextButton(
                    onClick = {
                        showFinishDialog = false
                        // Stop without saving and close
                        viewModel.stopTracking()
                        onClose()
                    }
                ) {
                    Text(
                        "Ləğv et",
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        )
    }

    // Location Denied Dialog
    if (showLocationDenied) {
        AlertDialog(
            onDismissRequest = { showLocationDenied = false },
            title = { Text("Lokasiya icazəsi lazımdır") },
            text = { Text("GPS izləmə üçün lokasiya icazəsi verin.") },
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

@Composable
private fun SummaryRow(
    icon: ImageVector,
    label: String,
    value: String
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(16.dp),
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = label,
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Text(
            text = value,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}

@Composable
private fun GPSStatCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    iconColor: Color,
    value: String,
    label: String
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(vertical = 16.dp, horizontal = 12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(24.dp),
            tint = iconColor
        )
        Text(
            text = value,
            fontSize = 26.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
        )
        Text(
            text = label,
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
