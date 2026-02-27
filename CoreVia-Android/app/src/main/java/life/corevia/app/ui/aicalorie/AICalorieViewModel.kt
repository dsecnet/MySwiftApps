package life.corevia.app.ui.aicalorie

import android.graphics.Bitmap
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.AICalorieResult
import life.corevia.app.data.model.DetectedFood
import life.corevia.app.data.repository.AICalorieRepository
import life.corevia.app.util.NetworkResult
import java.io.ByteArrayOutputStream
import javax.inject.Inject

data class AICalorieUiState(
    val selectedImage: Bitmap? = null,
    val result: AICalorieResult? = null,
    val isAnalyzing: Boolean = false,
    val isSaving: Boolean = false,
    val savedMessage: String? = null,
    val errorMessage: String? = null
)

@HiltViewModel
class AICalorieViewModel @Inject constructor(
    private val aiCalorieRepository: AICalorieRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AICalorieUiState())
    val uiState: StateFlow<AICalorieUiState> = _uiState.asStateFlow()

    fun setSelectedImage(bitmap: Bitmap) {
        _uiState.value = _uiState.value.copy(
            selectedImage = bitmap,
            result = null,
            errorMessage = null,
            savedMessage = null
        )
    }

    fun analyzeFood() {
        val bitmap = _uiState.value.selectedImage ?: return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isAnalyzing = true, errorMessage = null)

            // Compress bitmap to JPEG bytes
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, 80, stream)
            val imageBytes = stream.toByteArray()

            when (val result = aiCalorieRepository.analyzeFood(imageBytes)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        result = result.data,
                        isAnalyzing = false
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isAnalyzing = false,
                        errorMessage = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun saveFood(food: DetectedFood) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSaving = true, savedMessage = null)
            val mealType = aiCalorieRepository.estimateMealType()

            when (aiCalorieRepository.saveAsFood(food, mealType)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSaving = false,
                        savedMessage = "${food.name} qida siyahısına əlavə edildi"
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isSaving = false,
                        errorMessage = "Qida saxlanıla bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun saveAllFoods() {
        val result = _uiState.value.result ?: return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSaving = true, savedMessage = null)
            val mealType = aiCalorieRepository.estimateMealType()

            var successCount = 0
            for (food in result.foods) {
                when (aiCalorieRepository.saveAsFood(food, mealType)) {
                    is NetworkResult.Success -> successCount++
                    else -> {}
                }
            }

            _uiState.value = _uiState.value.copy(
                isSaving = false,
                savedMessage = "$successCount yemək qida siyahısına əlavə edildi"
            )
        }
    }

    fun resetAnalysis() {
        _uiState.value = AICalorieUiState()
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }

    fun clearSavedMessage() {
        _uiState.value = _uiState.value.copy(savedMessage = null)
    }
}
