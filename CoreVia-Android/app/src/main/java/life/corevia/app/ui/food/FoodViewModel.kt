package life.corevia.app.ui.food

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.FoodRepository
import life.corevia.app.data.repository.UserRepository
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File
import java.time.LocalDate

/**
 * iOS FoodManager.swift (@MainActor ObservableObject) ->
 * Android FoodViewModel
 * UPDATED: updateFoodEntry + successMessage elave edildi
 */
class FoodViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = FoodRepository.getInstance(application)
    private val userRepository = UserRepository.getInstance(application)

    // iOS: @Published var foodEntries: [FoodEntry] = []
    private val _foodEntries = MutableStateFlow<List<FoodEntry>>(emptyList())
    val foodEntries: StateFlow<List<FoodEntry>> = _foodEntries.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    // iOS: @Published var showAddFood = false
    private val _showAddFood = MutableStateFlow(false)
    val showAddFood: StateFlow<Boolean> = _showAddFood.asStateFlow()

    // iOS: @AppStorage("dailyCalorieGoal") var dailyCalorieGoal = 2000
    private val _calorieGoal = MutableStateFlow(2000)
    val calorieGoal: StateFlow<Int> = _calorieGoal.asStateFlow()

    // AI Food Analysis states
    private val _analysisResult = MutableStateFlow<FoodAnalysisResult?>(null)
    val analysisResult: StateFlow<FoodAnalysisResult?> = _analysisResult.asStateFlow()

    private val _isAnalyzing = MutableStateFlow(false)
    val isAnalyzing: StateFlow<Boolean> = _isAnalyzing.asStateFlow()

    private val _showAnalysisResult = MutableStateFlow(false)
    val showAnalysisResult: StateFlow<Boolean> = _showAnalysisResult.asStateFlow()

    // ─── Computed Properties ──────────────────────────────────────────────────

    // iOS: var todayEntries: [FoodEntry]
    val todayEntries: List<FoodEntry>
        get() {
            val today = LocalDate.now().toString()
            return _foodEntries.value.filter { it.date.startsWith(today) }
        }

    // iOS: var totalCaloriesToday: Int
    val totalCaloriesToday: Int
        get() = todayEntries.sumOf { it.calories }

    // iOS: var totalProtein, totalCarbs, totalFats
    val totalProtein: Double get() = todayEntries.sumOf { it.protein ?: 0.0 }
    val totalCarbs: Double   get() = todayEntries.sumOf { it.carbs   ?: 0.0 }
    val totalFats: Double    get() = todayEntries.sumOf { it.fats    ?: 0.0 }

    // iOS: var calorieProgress: Double
    val calorieProgress: Float
        get() = if (_calorieGoal.value > 0)
            (totalCaloriesToday.toFloat() / _calorieGoal.value).coerceIn(0f, 1f)
        else 0f

    // ─── Actions ──────────────────────────────────────────────────────────────

    init {
        loadFoodEntries()
        loadCalorieGoalFromProfile()
    }

    /**
     * Load calorie goal from user profile.
     * Calculates based on weight using simplified Mifflin-St Jeor formula:
     * BMR ~ weight(kg) * 24, then adjust based on goal.
     * Falls back to 2000 if weight is not available.
     */
    private fun loadCalorieGoalFromProfile() {
        viewModelScope.launch {
            userRepository.getMe().fold(
                onSuccess = { user ->
                    val weight = user.weight
                    if (weight != null && weight > 0) {
                        val bmr = (weight * 24).toInt()
                        val goal = when (user.goal?.lowercase()) {
                            "weight_loss", "lose_weight", "cut" -> (bmr * 0.8).toInt()
                            "weight_gain", "gain_weight", "bulk" -> (bmr * 1.15).toInt()
                            else -> bmr
                        }
                        _calorieGoal.value = goal.coerceIn(1200, 5000)
                    }
                    // If weight is null, keep the default 2000
                },
                onFailure = { /* Keep default 2000 on failure */ }
            )
        }
    }

    // iOS: func loadFoodEntries() async
    fun loadFoodEntries() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getFoodEntries().fold(
                onSuccess = { _foodEntries.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // iOS: func addFoodEntry(name:calories:protein:carbs:fats:mealType:notes:)
    fun addFoodEntry(
        name: String,
        calories: Int,
        protein: Double?,
        carbs: Double?,
        fats: Double?,
        mealType: String,
        notes: String?
    ) {
        viewModelScope.launch {
            _isLoading.value = true
            val request = FoodEntryCreateRequest(
                name = name,
                calories = calories,
                protein = protein,
                carbs = carbs,
                fats = fats,
                mealType = mealType,
                date = LocalDate.now().toString(),
                notes = notes
            )
            repository.createFoodEntry(request).fold(
                onSuccess = {
                    _foodEntries.value = _foodEntries.value + it
                    _showAddFood.value = false
                    _successMessage.value = "Qida elave edildi"
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // iOS: func updateFoodEntry
    fun updateFoodEntry(
        id: String,
        name: String,
        calories: Int,
        protein: Double?,
        carbs: Double?,
        fats: Double?,
        mealType: String,
        notes: String?
    ) {
        viewModelScope.launch {
            _isLoading.value = true
            val request = FoodEntryCreateRequest(
                name = name,
                calories = calories,
                protein = protein,
                carbs = carbs,
                fats = fats,
                mealType = mealType,
                date = null,
                notes = notes
            )
            repository.updateFoodEntry(id, request).fold(
                onSuccess = { updated ->
                    _foodEntries.value = _foodEntries.value.map {
                        if (it.id == updated.id) updated else it
                    }
                    _successMessage.value = "Qida yenilendi"
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // iOS: func deleteFoodEntry(_ entry: FoodEntry)
    fun deleteFoodEntry(id: String) {
        viewModelScope.launch {
            repository.deleteFoodEntry(id).fold(
                onSuccess = {
                    _foodEntries.value = _foodEntries.value.filter { it.id != id }
                    _successMessage.value = "Qida silindi"
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    // AI Food Analysis — Sekli backend-e gonder, Claude analiz etsin
    fun analyzeFoodImage(imageFile: File) {
        viewModelScope.launch {
            _isAnalyzing.value = true
            _errorMessage.value = null

            try {
                val requestBody = imageFile.asRequestBody("image/jpeg".toMediaTypeOrNull())
                val filePart = MultipartBody.Part.createFormData("file", imageFile.name, requestBody)

                repository.analyzeFoodImage(filePart).fold(
                    onSuccess = { result ->
                        _analysisResult.value = result
                        _showAnalysisResult.value = true
                    },
                    onFailure = { e ->
                        _errorMessage.value = ErrorParser.parseMessage(e as Exception)
                    }
                )
            } catch (e: Exception) {
                _errorMessage.value = "Sekil gonderilemedi: ${e.message}"
            }

            _isAnalyzing.value = false
        }
    }

    // AI neticesi ile qida elave et
    fun addFoodFromAnalysis(result: FoodAnalysisResult, mealType: String) {
        addFoodEntry(
            name = result.foodName,
            calories = result.calories,
            protein = result.protein,
            carbs = result.carbs,
            fats = result.fats,
            mealType = mealType,
            notes = "AI analiz: ${result.portionSize ?: ""}"
        )
        _showAnalysisResult.value = false
        _analysisResult.value = null
    }

    fun dismissAnalysisResult() {
        _showAnalysisResult.value = false
        _analysisResult.value = null
    }

    fun setCalorieGoal(goal: Int)    { _calorieGoal.value = goal }
    fun setShowAddFood(show: Boolean) { _showAddFood.value = show }
    fun clearError()                  { _errorMessage.value = null }
    fun clearSuccess()                { _successMessage.value = null }
}
