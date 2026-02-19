package life.corevia.app.ui.news

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.NewsArticle
import life.corevia.app.data.repository.NewsRepository

class NewsViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = NewsRepository.getInstance(application)

    private val _articles = MutableStateFlow<List<NewsArticle>>(emptyList())
    val articles: StateFlow<List<NewsArticle>> = _articles.asStateFlow()

    private val _selectedArticle = MutableStateFlow<NewsArticle?>(null)
    val selectedArticle: StateFlow<NewsArticle?> = _selectedArticle.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _selectedCategory = MutableStateFlow<String?>(null)
    val selectedCategory: StateFlow<String?> = _selectedCategory.asStateFlow()

    init { loadNews() }

    fun loadNews() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getNews().fold(
                onSuccess = { _articles.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun selectArticle(article: NewsArticle) { _selectedArticle.value = article }
    fun clearSelectedArticle() { _selectedArticle.value = null }

    fun selectCategory(category: String?) { _selectedCategory.value = category }

    val filteredArticles: List<NewsArticle>
        get() {
            val category = _selectedCategory.value
            return if (category != null) {
                _articles.value.filter { it.category == category }
            } else {
                _articles.value
            }
        }

    val featuredArticles: List<NewsArticle>
        get() = _articles.value.filter { it.isFeatured }

    fun clearError() { _errorMessage.value = null }
}
