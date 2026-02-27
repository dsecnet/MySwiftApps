package life.corevia.app.ui.survey

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.DailySurveyRequest
import life.corevia.app.data.repository.SurveyRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class DailySurveyUiState(
    val energyLevel: Int = 3,
    val sleepHours: Double = 7.0,
    val sleepQuality: Int = 3,
    val stressLevel: Int = 3,
    val muscleSoreness: Int = 3,
    val mood: Int = 3,
    val waterGlasses: Int = 8,
    val notes: String = "",
    val isLoading: Boolean = false,
    val isCompleted: Boolean = false,
    val isSubmitting: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class DailySurveyViewModel @Inject constructor(
    private val surveyRepository: SurveyRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(DailySurveyUiState())
    val uiState: StateFlow<DailySurveyUiState> = _uiState.asStateFlow()

    init {
        checkTodayStatus()
    }

    private fun checkTodayStatus() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            when (val result = surveyRepository.getTodayStatus()) {
                is NetworkResult.Success -> {
                    val status = result.data
                    if (status.isCompleted && status.survey != null) {
                        val s = status.survey
                        _uiState.value = _uiState.value.copy(
                            energyLevel = s.energyLevel,
                            sleepHours = s.sleepHours,
                            sleepQuality = s.sleepQuality,
                            stressLevel = s.stressLevel,
                            muscleSoreness = s.muscleSoreness,
                            mood = s.mood,
                            waterGlasses = s.waterGlasses,
                            notes = s.notes ?: "",
                            isCompleted = true,
                            isLoading = false
                        )
                    } else {
                        _uiState.value = _uiState.value.copy(isLoading = false)
                    }
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(isLoading = false)
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun setEnergyLevel(value: Int) {
        _uiState.value = _uiState.value.copy(energyLevel = value)
    }

    fun setSleepHours(value: Double) {
        _uiState.value = _uiState.value.copy(sleepHours = value)
    }

    fun setSleepQuality(value: Int) {
        _uiState.value = _uiState.value.copy(sleepQuality = value)
    }

    fun setStressLevel(value: Int) {
        _uiState.value = _uiState.value.copy(stressLevel = value)
    }

    fun setMuscleSoreness(value: Int) {
        _uiState.value = _uiState.value.copy(muscleSoreness = value)
    }

    fun setMood(value: Int) {
        _uiState.value = _uiState.value.copy(mood = value)
    }

    fun setWaterGlasses(value: Int) {
        _uiState.value = _uiState.value.copy(waterGlasses = value.coerceIn(0, 30))
    }

    fun setNotes(value: String) {
        _uiState.value = _uiState.value.copy(notes = value)
    }

    fun submitSurvey(onSuccess: () -> Unit) {
        viewModelScope.launch {
            val state = _uiState.value
            _uiState.value = state.copy(isSubmitting = true, error = null)

            val request = DailySurveyRequest(
                energyLevel = state.energyLevel,
                sleepHours = state.sleepHours,
                sleepQuality = state.sleepQuality,
                stressLevel = state.stressLevel,
                muscleSoreness = state.muscleSoreness,
                mood = state.mood,
                waterGlasses = state.waterGlasses,
                notes = state.notes.ifBlank { null }
            )

            when (surveyRepository.submitDailySurvey(request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        isCompleted = true
                    )
                    onSuccess()
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        error = "Sorğu göndərilə bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}
