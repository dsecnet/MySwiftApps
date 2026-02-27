package life.corevia.app.ui.premium

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.local.TokenManager
import life.corevia.app.data.repository.PremiumRepository
import life.corevia.app.util.NetworkResult
import timber.log.Timber
import javax.inject.Inject

data class PremiumFeature(
    val title: String,
    val description: String,
    val icon: String
)

data class PremiumUiState(
    val isPremium: Boolean = false,
    val isLoading: Boolean = false,
    val isActivating: Boolean = false,
    val error: String? = null,
    val planName: String = "Aylıq",
    val planPrice: String = "9.99 ₼/ay",
    val features: List<PremiumFeature> = listOf(
        PremiumFeature("GPS Marşrut İzləmə", "Real vaxtda GPS izləmə, məsafə, sürət və kalori statistikalar", "route"),
        PremiumFeature("AI Trainer Chat", "Şəxsi AI məşqçi ilə söhbət, fərdi məşq planları", "chat"),
        PremiumFeature("Şəkillə Qida Analizi", "Yeməyinizin şəklini çəkin, AI kalori və makroları hesablasın", "camera"),
        PremiumFeature("Professional Trainerlər", "Peşəkar trenerlərlə əlaqə, fərdi proqramlar", "trainer")
    ),
    val monthlyPrice: String = "9.99₼/ay",
    val yearlyPrice: String = "89.99₼/il"
)

@HiltViewModel
class PremiumViewModel @Inject constructor(
    private val tokenManager: TokenManager,
    private val premiumRepository: PremiumRepository
) : ViewModel() {
    private val _uiState = MutableStateFlow(PremiumUiState())
    val uiState: StateFlow<PremiumUiState> = _uiState.asStateFlow()

    init {
        checkPremiumStatus()
    }

    /** Backend-dən premium statusu yoxla */
    private fun checkPremiumStatus() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            when (val result = premiumRepository.getPremiumStatus()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isPremium = result.data,
                        isLoading = false
                    )
                    Timber.d("Premium status: ${result.data}")
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                    Timber.e("Premium status xətası: ${result.message}")
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    /** Premium aktivasiya et */
    fun activatePremium() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isActivating = true, error = null)
            when (val result = premiumRepository.activatePremium()) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isPremium = true,
                        isActivating = false
                    )
                    Timber.d("Premium uğurla aktivləşdirildi")
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isActivating = false,
                        error = result.message
                    )
                    Timber.e("Premium aktivasiya xətası: ${result.message}")
                }
                is NetworkResult.Loading -> {}
            }
        }
    }

    fun refreshPremiumStatus() {
        checkPremiumStatus()
    }
}
