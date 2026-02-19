package life.corevia.app.ui.trainers

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.TrainerRepository

/**
 * iOS TrainerManager + ReviewManager-in Android ViewModel ekvivalenti.
 */
class TrainersViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = TrainerRepository.getInstance(application)

    // ─── State ──────────────────────────────────────────────────────────────────
    private val _trainers = MutableStateFlow<List<UserResponse>>(emptyList())
    val trainers: StateFlow<List<UserResponse>> = _trainers.asStateFlow()

    private val _selectedTrainer = MutableStateFlow<UserResponse?>(null)
    val selectedTrainer: StateFlow<UserResponse?> = _selectedTrainer.asStateFlow()

    private val _reviews = MutableStateFlow<List<TrainerReview>>(emptyList())
    val reviews: StateFlow<List<TrainerReview>> = _reviews.asStateFlow()

    private val _reviewSummary = MutableStateFlow<ReviewSummary?>(null)
    val reviewSummary: StateFlow<ReviewSummary?> = _reviewSummary.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    // Sheet states
    private val _showAddReview = MutableStateFlow(false)
    val showAddReview: StateFlow<Boolean> = _showAddReview.asStateFlow()

    // Search
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    val filteredTrainers: List<UserResponse>
        get() {
            val query = _searchQuery.value.lowercase()
            return if (query.isBlank()) _trainers.value
            else _trainers.value.filter { it.name.lowercase().contains(query) }
        }

    init {
        loadTrainers()
    }

    // ─── Actions ────────────────────────────────────────────────────────────────

    fun loadTrainers() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getTrainers().fold(
                onSuccess = { _trainers.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun selectTrainer(trainer: UserResponse) {
        _selectedTrainer.value = trainer
        loadReviews(trainer.id)
    }

    fun loadReviews(trainerId: String) {
        viewModelScope.launch {
            repository.getReviews(trainerId).fold(
                onSuccess = { _reviews.value = it },
                onFailure = { /* sessiz */ }
            )
            repository.getReviewSummary(trainerId).fold(
                onSuccess = { _reviewSummary.value = it },
                onFailure = { /* sessiz */ }
            )
        }
    }

    fun assignTrainer(trainerId: String) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.assignTrainer(trainerId).fold(
                onSuccess = { _successMessage.value = "Müəllim seçildi!" },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun unassignTrainer() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.unassignTrainer().fold(
                onSuccess = { _successMessage.value = "Müəllim ayrıldı" },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun createReview(rating: Int, comment: String?) {
        val trainerId = _selectedTrainer.value?.id ?: return
        viewModelScope.launch {
            _isLoading.value = true
            repository.createReview(trainerId, CreateReviewRequest(rating, comment)).fold(
                onSuccess = { newReview ->
                    _reviews.value = _reviews.value + newReview
                    _showAddReview.value = false
                    _successMessage.value = "Rəy göndərildi"
                    loadReviews(trainerId)
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun clearSelectedTrainer() {
        _selectedTrainer.value = null
        _reviews.value = emptyList()
        _reviewSummary.value = null
    }

    fun setSearchQuery(query: String) { _searchQuery.value = query }
    fun setShowAddReview(show: Boolean) { _showAddReview.value = show }
    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
