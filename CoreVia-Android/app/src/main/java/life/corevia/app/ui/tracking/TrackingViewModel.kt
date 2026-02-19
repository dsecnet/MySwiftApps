package life.corevia.app.ui.tracking

import android.app.Application
import android.os.SystemClock
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.models.TrackingPoint
import life.corevia.app.data.models.TrackingSession

class TrackingViewModel(application: Application) : AndroidViewModel(application) {

    private val _isTracking = MutableStateFlow(false)
    val isTracking: StateFlow<Boolean> = _isTracking.asStateFlow()

    private val _isPaused = MutableStateFlow(false)
    val isPaused: StateFlow<Boolean> = _isPaused.asStateFlow()

    private val _elapsedSeconds = MutableStateFlow(0L)
    val elapsedSeconds: StateFlow<Long> = _elapsedSeconds.asStateFlow()

    private val _distance = MutableStateFlow(0.0) // meters
    val distance: StateFlow<Double> = _distance.asStateFlow()

    private val _currentSpeed = MutableStateFlow(0.0) // m/s
    val currentSpeed: StateFlow<Double> = _currentSpeed.asStateFlow()

    private val _calories = MutableStateFlow(0)
    val calories: StateFlow<Int> = _calories.asStateFlow()

    private val _activityType = MutableStateFlow("running")
    val activityType: StateFlow<String> = _activityType.asStateFlow()

    private val _route = MutableStateFlow<List<TrackingPoint>>(emptyList())
    val route: StateFlow<List<TrackingPoint>> = _route.asStateFlow()

    private val _sessions = MutableStateFlow<List<TrackingSession>>(emptyList())
    val sessions: StateFlow<List<TrackingSession>> = _sessions.asStateFlow()

    private var timerJob: Job? = null
    private var startTimeMillis: Long = 0L
    private var pausedElapsed: Long = 0L

    fun setActivityType(type: String) { _activityType.value = type }

    fun startTracking() {
        _isTracking.value = true
        _isPaused.value = false
        _elapsedSeconds.value = 0
        _distance.value = 0.0
        _currentSpeed.value = 0.0
        _calories.value = 0
        _route.value = emptyList()
        startTimeMillis = SystemClock.elapsedRealtime()
        pausedElapsed = 0
        startTimer()
    }

    fun pauseTracking() {
        _isPaused.value = true
        pausedElapsed = _elapsedSeconds.value
        timerJob?.cancel()
    }

    fun resumeTracking() {
        _isPaused.value = false
        startTimeMillis = SystemClock.elapsedRealtime()
        startTimer()
    }

    fun stopTracking() {
        timerJob?.cancel()
        _isTracking.value = false
        _isPaused.value = false

        // Save session locally
        val session = TrackingSession(
            activityType = _activityType.value,
            duration = _elapsedSeconds.value.toInt(),
            distance = _distance.value,
            avgSpeed = if (_elapsedSeconds.value > 0) _distance.value / _elapsedSeconds.value else 0.0,
            caloriesBurned = _calories.value,
            route = _route.value
        )
        _sessions.value = _sessions.value + session
    }

    private fun startTimer() {
        timerJob?.cancel()
        timerJob = viewModelScope.launch {
            while (true) {
                delay(1000)
                val elapsed = pausedElapsed + (SystemClock.elapsedRealtime() - startTimeMillis) / 1000
                _elapsedSeconds.value = elapsed
                updateCalories(elapsed)
            }
        }
    }

    private fun updateCalories(seconds: Long) {
        val minutes = seconds / 60.0
        val calPerMin = when (_activityType.value) {
            "running" -> 11.0
            "cycling" -> 8.0
            "walking" -> 5.0
            else -> 7.0
        }
        _calories.value = (minutes * calPerMin).toInt()
    }

    // Called from location updates (future: LocationTrackingService)
    fun onLocationUpdate(lat: Double, lng: Double, altitude: Double?, speed: Double?) {
        val point = TrackingPoint(lat, lng, altitude, speed)
        val currentRoute = _route.value
        _route.value = currentRoute + point

        speed?.let { _currentSpeed.value = it }

        // Calculate distance from last point
        if (currentRoute.isNotEmpty()) {
            val last = currentRoute.last()
            val dist = haversineDistance(last.latitude, last.longitude, lat, lng)
            _distance.value += dist
        }
    }

    private fun haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val r = 6371000.0 // Earth radius in meters
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        val a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2)
        val c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        return r * c
    }

    fun formatTime(seconds: Long): String {
        val h = seconds / 3600
        val m = (seconds % 3600) / 60
        val s = seconds % 60
        return if (h > 0) String.format("%d:%02d:%02d", h, m, s) else String.format("%02d:%02d", m, s)
    }

    fun formatDistance(meters: Double): String {
        return if (meters >= 1000) String.format("%.2f km", meters / 1000)
        else String.format("%.0f m", meters)
    }

    fun formatSpeed(metersPerSec: Double): String {
        val kmh = metersPerSec * 3.6
        return String.format("%.1f km/s", kmh)
    }

    fun formatPace(metersPerSec: Double): String {
        if (metersPerSec <= 0) return "--:--"
        val minPerKm = 1000.0 / metersPerSec / 60.0
        val mins = minPerKm.toInt()
        val secs = ((minPerKm - mins) * 60).toInt()
        return String.format("%d:%02d /km", mins, secs)
    }
}
