package life.corevia.app.ui.content

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.ContentCreateRequest
import life.corevia.app.data.models.ContentResponse
import life.corevia.app.data.repository.ContentRepository

/**
 * iOS ContentManager.swift — Android ViewModel ekvivalenti.
 * Trainer kontent idar+etm+si: fetch, create, delete.
 */
class ContentViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = ContentRepository.getInstance(application)

    private val _myContents = MutableStateFlow<List<ContentResponse>>(emptyList())
    val myContents: StateFlow<List<ContentResponse>> = _myContents.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    init {
        fetchMyContent()
    }

    fun fetchMyContent() {
        viewModelScope.launch(Dispatchers.IO) {
            withContext(Dispatchers.Main) { _isLoading.value = true }
            repository.getMyContent().fold(
                onSuccess = { withContext(Dispatchers.Main) { _myContents.value = it } },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun createContent(title: String, body: String?, isPremiumOnly: Boolean) {
        viewModelScope.launch(Dispatchers.IO) {
            withContext(Dispatchers.Main) { _isLoading.value = true }
            val request = ContentCreateRequest(
                title = title,
                body = body,
                contentType = "text",
                isPremiumOnly = isPremiumOnly
            )
            repository.createContent(request).fold(
                onSuccess = {
                    withContext(Dispatchers.Main) { _successMessage.value = "Kontent yaradildi" }
                    // Refresh list
                    repository.getMyContent().fold(
                        onSuccess = { list -> withContext(Dispatchers.Main) { _myContents.value = list } },
                        onFailure = { /* ignore refresh error */ }
                    )
                },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
            withContext(Dispatchers.Main) { _isLoading.value = false }
        }
    }

    fun deleteContent(contentId: String) {
        viewModelScope.launch(Dispatchers.IO) {
            repository.deleteContent(contentId).fold(
                onSuccess = {
                    withContext(Dispatchers.Main) {
                        _myContents.value = _myContents.value.filter { it.id != contentId }
                        _successMessage.value = "Kontent silindi"
                    }
                },
                onFailure = { withContext(Dispatchers.Main) { _errorMessage.value = ErrorParser.parseMessage(it as Exception) } }
            )
        }
    }

    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
