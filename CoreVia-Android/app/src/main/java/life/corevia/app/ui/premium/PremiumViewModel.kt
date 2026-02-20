package life.corevia.app.ui.premium

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.api.ErrorParser
import life.corevia.app.data.models.*
import life.corevia.app.data.repository.PremiumRepository

/**
 * iOS PremiumManager.swift-in Android ViewModel ekvivalenti.
 */
class PremiumViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = PremiumRepository.getInstance(application)

    // ─── State ──────────────────────────────────────────────────────────────────
    private val _status = MutableStateFlow<PremiumStatus?>(null)
    val status: StateFlow<PremiumStatus?> = _status.asStateFlow()

    private val _plans = MutableStateFlow<List<PremiumPlan>>(emptyList())
    val plans: StateFlow<List<PremiumPlan>> = _plans.asStateFlow()

    private val _history = MutableStateFlow<List<SubscriptionHistory>>(emptyList())
    val history: StateFlow<List<SubscriptionHistory>> = _history.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _successMessage = MutableStateFlow<String?>(null)
    val successMessage: StateFlow<String?> = _successMessage.asStateFlow()

    init {
        loadStatus()
        loadPlans()
    }

    fun loadStatus() {
        viewModelScope.launch {
            repository.getStatus().fold(
                onSuccess = { _status.value = it },
                onFailure = { /* sessiz */ }
            )
        }
    }

    fun loadPlans() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getPlans().fold(
                onSuccess = { _plans.value = it },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    // iOS: activatePremium() — POST /api/v1/premium/activate (body yoxdur)
    fun activatePremium() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.activate().fold(
                onSuccess = {
                    _successMessage.value = "Premium uğurla aktivləşdirildi!"
                    loadStatus()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun subscribe(planId: String) {
        viewModelScope.launch {
            _isLoading.value = true
            repository.subscribe(SubscribeRequest(planId)).fold(
                onSuccess = {
                    _successMessage.value = "Abunəlik uğurla aktivləşdirildi!"
                    loadStatus()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun cancel() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.cancel().fold(
                onSuccess = {
                    _successMessage.value = "Abunəlik ləğv edildi"
                    loadStatus()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun restore() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.restore().fold(
                onSuccess = {
                    _successMessage.value = "Abunəlik bərpa edildi!"
                    loadStatus()
                },
                onFailure = { _errorMessage.value = ErrorParser.parseMessage(it as Exception) }
            )
            _isLoading.value = false
        }
    }

    fun loadHistory() {
        viewModelScope.launch {
            repository.getHistory().fold(
                onSuccess = { _history.value = it },
                onFailure = { /* sessiz */ }
            )
        }
    }

    fun clearError() { _errorMessage.value = null }
    fun clearSuccess() { _successMessage.value = null }
}
