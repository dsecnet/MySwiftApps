package life.corevia.app.ui.activities

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.MealPlan
import life.corevia.app.data.models.TrainingPlan
import life.corevia.app.data.repository.MealPlanRepository
import life.corevia.app.data.repository.TrainingPlanRepository

/**
 * iOS ActivitiesView.swift → Android ActivitiesViewModel
 * Client üçün assign olunmuş planları göstərir + "İcra etdim" funksiyası
 */
class ActivitiesViewModel(application: Application) : AndroidViewModel(application) {

    private val trainingPlanRepo = TrainingPlanRepository.getInstance(application)
    private val mealPlanRepo = MealPlanRepository.getInstance(application)

    private val _trainingPlans = MutableStateFlow<List<TrainingPlan>>(emptyList())
    val trainingPlans: StateFlow<List<TrainingPlan>> = _trainingPlans.asStateFlow()

    private val _mealPlans = MutableStateFlow<List<MealPlan>>(emptyList())
    val mealPlans: StateFlow<List<MealPlan>> = _mealPlans.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    // iOS: assignedTrainingPlans — only plans assigned by trainer (trainerId != null)
    // iOS ActivitiesView.swift: let assignedTraining = trainingPlanManager.plans.filter { $0.trainerId != nil }
    val assignedTrainingPlans: List<TrainingPlan>
        get() = _trainingPlans.value.filter { it.trainerId != null }

    val assignedMealPlans: List<MealPlan>
        get() = _mealPlans.value.filter { it.trainerId != null }

    init {
        loadAll()
    }

    fun loadAll() {
        _isLoading.value = true
        viewModelScope.launch(Dispatchers.IO) {
            // Paralel yüklə, hər ikisi bitənə qədər gözlə
            val trainingJob = async {
                trainingPlanRepo.getTrainingPlans().fold(
                    onSuccess = { _trainingPlans.value = it },
                    onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
                )
            }
            val mealJob = async {
                mealPlanRepo.getMealPlans().fold(
                    onSuccess = { _mealPlans.value = it },
                    onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
                )
            }
            awaitAll(trainingJob, mealJob)
            _isLoading.value = false
        }
    }

    // iOS: "İcra etdim" — training plan tamamla
    fun completeTrainingPlan(planId: String) {
        viewModelScope.launch {
            trainingPlanRepo.completeTrainingPlan(planId).fold(
                onSuccess = {
                    _successMessage.value = "Məşq planı tamamlandı! 🎉"
                    loadAll()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    // iOS: "İcra etdim" — meal plan tamamla
    fun completeMealPlan(planId: String) {
        viewModelScope.launch {
            mealPlanRepo.completeMealPlan(planId).fold(
                onSuccess = {
                    _successMessage.value = "Qida planı tamamlandı! 🎉"
                    loadAll()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
        }
    }

    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
