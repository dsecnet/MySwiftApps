package life.corevia.app.ui.route

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.os.Looper
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DirectionsBike
import androidx.compose.material.icons.filled.DirectionsRun
import androidx.compose.material.icons.filled.DirectionsWalk
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import life.corevia.app.data.model.RouteCreateRequest
import life.corevia.app.data.model.RouteResponse
import life.corevia.app.data.model.RouteStatsResponse
import life.corevia.app.data.model.WorkoutCreateRequest
import life.corevia.app.data.repository.AuthRepository
import life.corevia.app.data.repository.RouteRepository
import life.corevia.app.data.repository.WorkoutRepository
import life.corevia.app.ui.theme.ActivityCycling
import life.corevia.app.ui.theme.ActivityRunning
import life.corevia.app.ui.theme.ActivityWalking
import life.corevia.app.util.NetworkResult
import timber.log.Timber
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.inject.Inject

// Activity type enum
enum class ActivityType(
    val value: String,
    val displayName: String,
    val icon: ImageVector,
    val color: Color
) {
    WALKING("walking", "Yeriyiş", Icons.Filled.DirectionsWalk, ActivityWalking),
    RUNNING("running", "Qaçış", Icons.Filled.DirectionsRun, ActivityRunning),
    CYCLING("cycling", "Velosiped", Icons.Filled.DirectionsBike, ActivityCycling);

    companion object {
        fun fromValue(value: String): ActivityType {
            return entries.find { it.value == value } ?: RUNNING
        }
    }
}

data class RouteUiState(
    val isLoading: Boolean = false,
    val routes: List<RouteResponse> = emptyList(),
    val weeklyStats: RouteStatsResponse = RouteStatsResponse(),
    val selectedFilter: ActivityType? = null,
    val isTracking: Boolean = false,
    val isPaused: Boolean = false,
    val activeType: ActivityType = ActivityType.RUNNING,
    val elapsedSeconds: Int = 0,
    val distanceKm: Double = 0.0,
    val isPremium: Boolean = true,
    val error: String? = null,
    val currentLat: Double? = null,
    val currentLng: Double? = null,
    val trackPoints: List<Pair<Double, Double>> = emptyList(),
    val userWeight: Float = 70f,
    val steps: Int = 0,
    val isSaving: Boolean = false,
    val saveError: String? = null
) {
    val filteredRoutes: List<RouteResponse>
        get() = if (selectedFilter != null) {
            routes.filter { it.activityType == selectedFilter.value }
        } else {
            routes
        }

    val livePace: String
        get() {
            if (distanceKm < 0.01 || elapsedSeconds <= 0) return "--:--"
            val paceMinPerKm = (elapsedSeconds.toDouble() / 60.0) / distanceKm
            val mins = paceMinPerKm.toInt()
            val secs = ((paceMinPerKm - mins) * 60).toInt()
            return String.format("%d:%02d /km", mins, secs)
        }

    val liveSpeedKmH: Double
        get() {
            if (elapsedSeconds <= 0) return 0.0
            return distanceKm / (elapsedSeconds / 3600.0)
        }

    val liveCalories: Int
        get() {
            val hours = elapsedSeconds / 3600.0
            val speedKmH = if (elapsedSeconds > 0) distanceKm / hours else 0.0
            val metValue = when (activeType) {
                ActivityType.WALKING -> when {
                    speedKmH < 3.0 -> 2.0
                    speedKmH < 5.0 -> 3.5
                    speedKmH < 6.5 -> 4.3
                    else -> 5.0
                }
                ActivityType.RUNNING -> when {
                    speedKmH < 8.0 -> 8.3
                    speedKmH < 10.0 -> 9.8
                    speedKmH < 12.0 -> 11.0
                    else -> 12.8
                }
                ActivityType.CYCLING -> when {
                    speedKmH < 16.0 -> 4.0
                    speedKmH < 20.0 -> 6.8
                    else -> 8.0
                }
            }
            val metCalories = (metValue * userWeight * hours).toInt()
            val stepCalories = (steps * 0.04).toInt()
            return maxOf(metCalories, stepCalories, 0)
        }
}

@HiltViewModel
class RouteViewModel @Inject constructor(
    private val routeRepository: RouteRepository,
    private val workoutRepository: WorkoutRepository,
    private val authRepository: AuthRepository,
    @ApplicationContext private val context: Context
) : ViewModel() {

    private val _uiState = MutableStateFlow(RouteUiState())
    val uiState: StateFlow<RouteUiState> = _uiState.asStateFlow()

    private var fusedLocationClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(context)

    private var locationCallback: LocationCallback? = null
    private var trackingStartTime: Date? = null
    private var startCoordinate: Pair<Double, Double>? = null
    private var endCoordinate: Pair<Double, Double>? = null
    private val coordinates = mutableListOf<List<Double>>()
    private var lastLocation: Location? = null
    private var timerJob: kotlinx.coroutines.Job? = null

    // Step counter sensor
    private var sensorManager: SensorManager? = null
    private var stepSensor: Sensor? = null
    private var initialStepCount: Int = -1

    private val sensorListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent?) {
            event?.let {
                if (it.sensor.type == Sensor.TYPE_STEP_COUNTER) {
                    val totalSteps = it.values[0].toInt()
                    if (initialStepCount < 0) {
                        initialStepCount = totalSteps
                    }
                    val currentSteps = totalSteps - initialStepCount
                    _uiState.value = _uiState.value.copy(steps = currentSteps)
                }
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    }

    init {
        loadData()
        loadUserWeight()
    }

    private fun loadUserWeight() {
        viewModelScope.launch {
            when (val result = authRepository.fetchCurrentUser()) {
                is NetworkResult.Success -> {
                    val weight = result.data.weight ?: 70f
                    _uiState.value = _uiState.value.copy(userWeight = weight)
                }
                is NetworkResult.Error -> {}
                is NetworkResult.Loading -> {}
            }
        }
    }

    private fun registerStepSensor() {
        try {
            if (sensorManager == null) {
                sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
            }
            stepSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
            if (stepSensor == null) {
                Timber.w("Step counter sensor mövcud deyil bu cihazda")
                return
            }
            stepSensor?.let { sensor ->
                sensorManager?.registerListener(
                    sensorListener,
                    sensor,
                    SensorManager.SENSOR_DELAY_UI
                )
            }
        } catch (e: Exception) {
            Timber.e("Step sensor qeydiyyat xətası: ${e.message}")
        }
    }

    private fun unregisterStepSensor() {
        try {
            sensorManager?.unregisterListener(sensorListener)
        } catch (e: Exception) {
            Timber.e("Step sensor ləğv xətası: ${e.message}")
        }
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            launch { loadRoutes() }
            launch { loadWeeklyStats() }
        }
    }

    private suspend fun loadRoutes() {
        when (val result = routeRepository.getRoutes()) {
            is NetworkResult.Success -> {
                _uiState.value = _uiState.value.copy(
                    routes = result.data,
                    isLoading = false
                )
            }
            is NetworkResult.Error -> {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = result.message
                )
            }
            is NetworkResult.Loading -> {}
        }
    }

    private suspend fun loadWeeklyStats() {
        when (val result = routeRepository.getWeeklyStats()) {
            is NetworkResult.Success -> {
                _uiState.value = _uiState.value.copy(weeklyStats = result.data)
            }
            is NetworkResult.Error -> {}
            is NetworkResult.Loading -> {}
        }
    }

    fun setFilter(type: ActivityType?) {
        _uiState.value = _uiState.value.copy(selectedFilter = type)
    }

    @SuppressLint("MissingPermission")
    fun startTracking(type: ActivityType) {
        _uiState.value = _uiState.value.copy(
            isTracking = true,
            activeType = type,
            elapsedSeconds = 0,
            distanceKm = 0.0,
            steps = 0,
            trackPoints = emptyList()
        )
        trackingStartTime = Date()
        coordinates.clear()
        startCoordinate = null
        endCoordinate = null
        lastLocation = null
        initialStepCount = -1

        // Register step counter sensor
        registerStepSensor()

        // Start location updates
        val locationRequest = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY, 2000L
        ).setMinUpdateDistanceMeters(10f).build()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                result.lastLocation?.let { location ->
                    processLocation(location)
                }
            }
        }

        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            locationCallback!!,
            Looper.getMainLooper()
        )

        // Start timer
        timerJob = viewModelScope.launch {
            while (true) {
                kotlinx.coroutines.delay(1000)
                _uiState.value = _uiState.value.copy(
                    elapsedSeconds = _uiState.value.elapsedSeconds + 1
                )
            }
        }
    }

    private fun processLocation(location: Location) {
        // Filter very bad accuracy
        if (location.accuracy > 50f) return
        // Filter old locations
        val age = System.currentTimeMillis() - location.time
        if (age > 10_000) return

        val coord = listOf(
            location.latitude,
            location.longitude,
            location.altitude,
            location.time.toDouble()
        )

        if (startCoordinate == null) {
            startCoordinate = Pair(location.latitude, location.longitude)
        }

        // Calculate distance delta
        lastLocation?.let { last ->
            val delta = last.distanceTo(location)
            if (delta in 3f..100f) {
                val newDist = _uiState.value.distanceKm + (delta / 1000.0)
                _uiState.value = _uiState.value.copy(distanceKm = newDist)
            }
        }

        endCoordinate = Pair(location.latitude, location.longitude)
        lastLocation = location
        coordinates.add(coord)

        // Update UI state with current position and track points
        _uiState.value = _uiState.value.copy(
            currentLat = location.latitude,
            currentLng = location.longitude,
            trackPoints = _uiState.value.trackPoints + Pair(location.latitude, location.longitude)
        )
    }

    @SuppressLint("MissingPermission")
    fun pauseTracking() {
        timerJob?.cancel()
        timerJob = null
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
        locationCallback = null
        unregisterStepSensor()
        _uiState.value = _uiState.value.copy(isPaused = true)
    }

    @SuppressLint("MissingPermission")
    fun resumeTracking() {
        _uiState.value = _uiState.value.copy(isPaused = false)

        // Resume step counter sensor
        registerStepSensor()

        // Resume location updates
        val locationRequest = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY, 2000L
        ).setMinUpdateDistanceMeters(10f).build()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                result.lastLocation?.let { location ->
                    processLocation(location)
                }
            }
        }

        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            locationCallback!!,
            Looper.getMainLooper()
        )

        // Resume timer
        timerJob = viewModelScope.launch {
            while (true) {
                kotlinx.coroutines.delay(1000)
                _uiState.value = _uiState.value.copy(
                    elapsedSeconds = _uiState.value.elapsedSeconds + 1
                )
            }
        }
    }

    fun stopTracking() {
        // Stop without saving (used for "Ləğv et" / cancel)
        timerJob?.cancel()
        timerJob = null
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
        locationCallback = null
        unregisterStepSensor()
        initialStepCount = -1
        _uiState.value = _uiState.value.copy(
            isTracking = false,
            isPaused = false,
            elapsedSeconds = 0,
            distanceKm = 0.0,
            steps = 0,
            trackPoints = emptyList()
        )
        coordinates.clear()
        startCoordinate = null
        endCoordinate = null
        lastLocation = null
    }

    fun finishAndSaveTracking(onSaved: () -> Unit) {
        // Stop timer
        timerJob?.cancel()
        timerJob = null

        // Stop location updates
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
        locationCallback = null

        // Stop step counter sensor
        unregisterStepSensor()
        initialStepCount = -1

        val state = _uiState.value
        _uiState.value = state.copy(isSaving = true, saveError = null)

        // Save and WAIT for completion before navigating back
        viewModelScope.launch {
            val success = saveRoute(state)
            _uiState.value = _uiState.value.copy(
                isTracking = false,
                isPaused = false,
                isSaving = false,
                saveError = if (!success) "Məşq yadda saxlanıla bilmədi" else null
            )
            onSaved()
        }
    }

    private suspend fun saveRoute(state: RouteUiState): Boolean {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
        val isoDateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())

        // Save route to routes API (only if we have GPS coordinates)
        if (startCoordinate != null) {
            val coordsJson = try {
                Json.encodeToString(
                    kotlinx.serialization.builtins.ListSerializer(
                        kotlinx.serialization.builtins.ListSerializer(
                            kotlinx.serialization.serializer<Double>()
                        )
                    ),
                    coordinates
                )
            } catch (_: Exception) { "[]" }

            val request = RouteCreateRequest(
                activityType = state.activeType.value,
                startLatitude = startCoordinate!!.first,
                startLongitude = startCoordinate!!.second,
                endLatitude = endCoordinate?.first,
                endLongitude = endCoordinate?.second,
                coordinatesJson = coordsJson,
                distanceKm = state.distanceKm,
                durationSeconds = state.elapsedSeconds,
                caloriesBurned = state.liveCalories,
                startedAt = dateFormat.format(trackingStartTime ?: Date()),
                finishedAt = dateFormat.format(Date())
            )
            try {
                routeRepository.saveRoute(request)
            } catch (e: Exception) {
                Timber.e("Route save error: ${e.message}")
            }
        }

        // ALWAYS create a workout entry so it shows in Məşq list
        val durationMinutes = if (state.elapsedSeconds >= 60) state.elapsedSeconds / 60 else 1
        val workoutRequest = WorkoutCreateRequest(
            title = "GPS ${state.activeType.displayName} – ${String.format("%.2f", state.distanceKm)} km",
            category = "cardio",
            duration = durationMinutes,
            caloriesBurned = if (state.liveCalories > 0) state.liveCalories else (durationMinutes * 5),
            notes = "${viewModel_formatDuration(state.elapsedSeconds)} · GPS ilə izlənildi",
            date = isoDateFormat.format(Date())
        )

        val result = workoutRepository.createWorkout(workoutRequest)
        return when (result) {
            is NetworkResult.Success -> {
                Timber.d("Workout saved successfully: ${result.data.id}")
                true
            }
            is NetworkResult.Error -> {
                Timber.e("Workout save FAILED: ${result.message} (code: ${result.code})")
                false
            }
            is NetworkResult.Loading -> false
        }
    }

    private fun viewModel_formatDuration(seconds: Int): String {
        val mins = seconds / 60
        val secs = seconds % 60
        return if (mins > 0) "${mins} dəq ${secs} san" else "${secs} san"
    }

    @SuppressLint("MissingPermission")
    fun requestCurrentLocation() {
        fusedLocationClient.lastLocation.addOnSuccessListener { location ->
            location?.let {
                _uiState.value = _uiState.value.copy(
                    currentLat = it.latitude,
                    currentLng = it.longitude
                )
            }
        }
    }

    fun estimateCalories(): Int {
        val state = _uiState.value
        val hours = state.elapsedSeconds / 3600.0
        val speedKmH = if (state.elapsedSeconds > 0) state.distanceKm / hours else 0.0
        val metValue = when (state.activeType) {
            ActivityType.WALKING -> when {
                speedKmH < 3.0 -> 2.0
                speedKmH < 5.0 -> 3.5
                speedKmH < 6.5 -> 4.3
                else -> 5.0
            }
            ActivityType.RUNNING -> when {
                speedKmH < 8.0 -> 8.3
                speedKmH < 10.0 -> 9.8
                speedKmH < 12.0 -> 11.0
                else -> 12.8
            }
            ActivityType.CYCLING -> when {
                speedKmH < 16.0 -> 4.0
                speedKmH < 20.0 -> 6.8
                else -> 8.0
            }
        }
        val metCalories = (metValue * state.userWeight * hours).toInt()
        val stepCalories = (state.steps * 0.04).toInt()
        return maxOf(metCalories, stepCalories, 0)
    }

    fun formatElapsedTime(seconds: Int): String {
        val hrs = seconds / 3600
        val mins = (seconds % 3600) / 60
        val secs = seconds % 60
        return if (hrs > 0) {
            String.format("%d:%02d:%02d", hrs, mins, secs)
        } else {
            String.format("%02d:%02d", mins, secs)
        }
    }

    fun formatDuration(seconds: Int): String {
        val hrs = seconds / 3600
        val mins = (seconds % 3600) / 60
        val secs = seconds % 60
        return if (hrs > 0) {
            String.format("%d:%02d:%02d", hrs, mins, secs)
        } else {
            String.format("%d:%02d", mins, secs)
        }
    }

    fun formatMinutes(totalMinutes: Int): String {
        return if (totalMinutes >= 60) {
            "${totalMinutes / 60}s ${totalMinutes % 60}d"
        } else {
            "$totalMinutes dəq"
        }
    }

    fun formatDate(dateString: String?): String {
        if (dateString == null) return ""
        return try {
            val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            val outputFormat = SimpleDateFormat("dd MMM, HH:mm", Locale("az"))
            val date = inputFormat.parse(dateString)
            outputFormat.format(date ?: Date())
        } catch (e: Exception) {
            dateString
        }
    }

    override fun onCleared() {
        super.onCleared()
        timerJob?.cancel()
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
        unregisterStepSensor()
    }
}
