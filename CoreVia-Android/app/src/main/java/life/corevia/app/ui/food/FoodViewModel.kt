package life.corevia.app.ui.food

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.FoodRepository
import java.time.LocalDate

/**
 * iOS FoodManager.swift (@MainActor ObservableObject) →
 * Android FoodViewModel
 */
class FoodViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = FoodRepository.getInstance(application)

    // iOS: @Published var foodEntries: [FoodEntry] = []
    private val _foodEntries = MutableStateFlow<List<FoodEntry>>(emptyList())
    val foodEntries: StateFlow<List<FoodEntry>> = _foodEntries.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    // iOS: @Published var showAddFood = false
    private val _showAddFood = MutableStateFlow(false)
    val showAddFood: StateFlow<Boolean> = _showAddFood.asStateFlow()

    // iOS: @AppStorage("dailyCalorieGoal") var dailyCalorieGoal = 2000
    private val _calorieGoal = MutableStateFlow(2000)
    val calorieGoal: StateFlow<Int> = _calorieGoal.asStateFlow()

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
    }

    // iOS: func loadFoodEntries() async
    fun loadFoodEntries() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getFoodEntries().fold(
                onSuccess = { _foodEntries.value = it },
                onFailure = { _errorMessage.value = it.message }
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
                },
                onFailure = { _errorMessage.value = it.message }
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
                },
                onFailure = { _errorMessage.value = it.message }
            )
        }
    }

    fun setCalorieGoal(goal: Int)    { _calorieGoal.value = goal }
    fun setShowAddFood(show: Boolean) { _showAddFood.value = show }
    fun clearError()                  { _errorMessage.value = null }
}
