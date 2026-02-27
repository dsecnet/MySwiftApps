package life.corevia.app.ui.trainers

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.TrainerCategory
import life.corevia.app.data.model.TrainerResponse
import life.corevia.app.data.repository.TrainerRepository
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

data class TrainerBrowseUiState(
    val trainers: List<TrainerResponse> = emptyList(),
    val searchQuery: String = "",
    val selectedCategory: TrainerCategory? = null, // null = All
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val assigningTrainerId: String? = null,
    val assignSuccess: Boolean = false
) {
    val filteredTrainers: List<TrainerResponse>
        get() {
            var list = trainers
            if (selectedCategory != null) {
                list = list.filter { it.detectedCategory == selectedCategory }
            }
            if (searchQuery.isNotBlank()) {
                val q = searchQuery.lowercase()
                list = list.filter {
                    it.fullName.lowercase().contains(q) ||
                            (it.specialization?.lowercase()?.contains(q) == true)
                }
            }
            return list
        }

    val trainerCount: Int get() = filteredTrainers.size
    val avgRating: Double
        get() {
            val rated = filteredTrainers.filter { (it.rating ?: 0.0) > 0 }
            return if (rated.isEmpty()) 0.0 else rated.mapNotNull { it.rating }.average()
        }
}

@HiltViewModel
class TrainerBrowseViewModel @Inject constructor(
    private val trainerRepository: TrainerRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(TrainerBrowseUiState())
    val uiState: StateFlow<TrainerBrowseUiState> = _uiState.asStateFlow()

    init {
        loadTrainers()
    }

    fun loadTrainers() {
        _uiState.value = _uiState.value.copy(isLoading = true)
        viewModelScope.launch {
            when (val result = trainerRepository.fetchTrainers()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        trainers = result.data ?: emptyList()
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun updateSearch(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
    }

    fun selectCategory(category: TrainerCategory?) {
        _uiState.value = _uiState.value.copy(selectedCategory = category)
    }

    fun assignTrainer(trainerId: String) {
        _uiState.value = _uiState.value.copy(assigningTrainerId = trainerId)
        viewModelScope.launch {
            when (val result = trainerRepository.assignTrainer(trainerId)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        assigningTrainerId = null,
                        assignSuccess = true
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        assigningTrainerId = null,
                        errorMessage = result.message
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }
}
