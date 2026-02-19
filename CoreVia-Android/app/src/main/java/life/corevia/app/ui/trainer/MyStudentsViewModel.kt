package life.corevia.app.ui.trainer

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.UserResponse
import life.corevia.app.data.repository.UserRepository

/**
 * iOS MyStudentsView.swift → Android MyStudentsViewModel
 */
class MyStudentsViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = UserRepository.getInstance(application)

    private val _students = MutableStateFlow<List<UserResponse>>(emptyList())
    val students: StateFlow<List<UserResponse>> = _students.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    val filteredStudents: List<UserResponse>
        get() {
            val query = _searchQuery.value.lowercase()
            if (query.isBlank()) return _students.value
            return _students.value.filter {
                it.name.lowercase().contains(query) ||
                (it.goal?.lowercase()?.contains(query) == true)
            }
        }

    init {
        loadStudents()
    }

    fun loadStudents() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getMyStudents().fold(
                onSuccess = { _students.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun setSearchQuery(query: String) { _searchQuery.value = query }
    fun clearError() { _errorMessage.value = null }
}
