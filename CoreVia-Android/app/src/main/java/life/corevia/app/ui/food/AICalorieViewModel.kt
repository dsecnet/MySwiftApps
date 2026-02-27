package life.corevia.app.ui.food

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

/**
 * AICalorieViewModel — food-specific AI calorie analysis ViewModel
 *
 * Manages the AI image analysis flow:
 * 1. User selects/captures image
 * 2. Image is sent to AI for analysis
 * 3. Results (food name, calories, macros) are displayed
 * 4. User can save results to food diary
 *
 * Complements ui/aicalorie/AICalorieViewModel for this package's screens.
 */

data class FoodAICalorieUiState(
    val selectedImage: Bitmap? = null,
    val isAnalyzing: Boolean = false,
    val result: AICalorieResult? = null,
    val isSaving: Boolean = false,
    val savedMessage: String? = null,
    val error: String? = null
) {
    val hasResult: Boolean get() = result != null
    val totalCalories: Int get() = result?.totalCalories?.toInt() ?: 0
    val totalProtein: Int get() = result?.totalProtein?.toInt() ?: 0
    val totalCarbs: Int get() = result?.totalCarbs?.toInt() ?: 0
    val totalFat: Int get() = result?.totalFat?.toInt() ?: 0
    val confidencePercent: Int get() = ((result?.confidence ?: 0.0) * 100).toInt()
    val detectedFoods: List<DetectedFood> get() = result?.foods ?: emptyList()
}

@HiltViewModel
class FoodAICalorieViewModel @Inject constructor(
    private val aiCalorieRepository: AICalorieRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(FoodAICalorieUiState())
    val uiState: StateFlow<FoodAICalorieUiState> = _uiState.asStateFlow()

    // ─── Image Selection ─────────────────────────────────────────────

    fun setImage(bitmap: Bitmap) {
        _uiState.value = _uiState.value.copy(
            selectedImage = bitmap,
            result = null,
            error = null,
            savedMessage = null
        )
    }

    // ─── Analyze Image ───────────────────────────────────────────────

    fun analyzeImage() {
        val bitmap = _uiState.value.selectedImage ?: return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isAnalyzing = true, error = null)

            // Compress to JPEG bytes
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
                        error = result.message ?: "Analiz uğursuz oldu"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    // ─── Save Single Food Result ─────────────────────────────────────

    fun saveResult(food: DetectedFood) {
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
                        error = "Qida saxlanıla bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    // ─── Save All Foods ──────────────────────────────────────────────

    fun saveAllResults() {
        val result = _uiState.value.result ?: return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSaving = true, savedMessage = null)
            val mealType = aiCalorieRepository.estimateMealType()

            var savedCount = 0
            for (food in result.foods) {
                when (aiCalorieRepository.saveAsFood(food, mealType)) {
                    is NetworkResult.Success -> savedCount++
                    else -> {}
                }
            }

            _uiState.value = _uiState.value.copy(
                isSaving = false,
                savedMessage = "$savedCount yemək qida siyahısına əlavə edildi"
            )
        }
    }

    // ─── Reset ───────────────────────────────────────────────────────

    fun reset() {
        _uiState.value = FoodAICalorieUiState()
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }

    fun clearSavedMessage() {
        _uiState.value = _uiState.value.copy(savedMessage = null)
    }
}
