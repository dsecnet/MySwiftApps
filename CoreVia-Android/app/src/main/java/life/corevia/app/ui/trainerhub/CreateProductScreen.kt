package life.corevia.app.ui.trainerhub

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import life.corevia.app.data.model.CreateProductRequest
import life.corevia.app.data.model.MarketplaceProductType
import life.corevia.app.data.repository.MarketplaceRepository
import life.corevia.app.ui.theme.*
import life.corevia.app.util.NetworkResult
import javax.inject.Inject

// ═══════════════════════════════════════════════════════════════════
// MARK: - UI State
// ═══════════════════════════════════════════════════════════════════

data class CreateProductUiState(
    val title: String = "",
    val description: String = "",
    val selectedProductType: MarketplaceProductType = MarketplaceProductType.WORKOUT_PLAN,
    val price: String = "",
    val currency: String = "AZN",
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val errorMessage: String? = null
) {
    val isFormValid: Boolean
        get() = title.isNotBlank() &&
                description.isNotBlank() &&
                price.toDoubleOrNull() != null &&
                (price.toDoubleOrNull() ?: 0.0) > 0
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ═══════════════════════════════════════════════════════════════════

@HiltViewModel
class CreateProductViewModel @Inject constructor(
    private val marketplaceRepository: MarketplaceRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CreateProductUiState())
    val uiState: StateFlow<CreateProductUiState> = _uiState.asStateFlow()

    fun updateTitle(title: String) {
        _uiState.value = _uiState.value.copy(title = title, errorMessage = null)
    }

    fun updateDescription(description: String) {
        _uiState.value = _uiState.value.copy(description = description, errorMessage = null)
    }

    fun updateProductType(type: MarketplaceProductType) {
        _uiState.value = _uiState.value.copy(selectedProductType = type)
    }

    fun updatePrice(price: String) {
        _uiState.value = _uiState.value.copy(price = price, errorMessage = null)
    }

    fun updateCurrency(currency: String) {
        _uiState.value = _uiState.value.copy(currency = currency)
    }

    fun createProduct() {
        val state = _uiState.value
        if (!state.isFormValid) {
            _uiState.value = state.copy(errorMessage = "Bütün sahələri düzgün doldurun")
            return
        }

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            val request = CreateProductRequest(
                title = state.title.trim(),
                description = state.description.trim(),
                productType = state.selectedProductType.value,
                price = state.price.toDoubleOrNull() ?: 0.0,
                currency = state.currency
            )
            when (marketplaceRepository.createProduct(request)) {
                is NetworkResult.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        isSaved = true
                    )
                }
                is NetworkResult.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = "Məhsul yaradıla bilmədi"
                    )
                }
                is NetworkResult.Loading -> {}
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Screen Composable
// ═══════════════════════════════════════════════════════════════════

/**
 * iOS CreateProductView equivalent
 * Yeni Məhsul yaratma forması — TopAppBar, form fields, segmented type selector
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateProductScreen(
    onBack: () -> Unit,
    viewModel: CreateProductViewModel = hiltViewModel()
) {
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state.isSaved) {
        if (state.isSaved) onBack()
    }

    val currencies = listOf("AZN", "USD", "EUR", "TRY")

    Box(modifier = Modifier.fillMaxSize()) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Text("Yeni Məhsul", fontWeight = FontWeight.Bold, fontSize = 22.sp)
                    },
                    navigationIcon = {
                        IconButton(onClick = onBack) {
                            Icon(Icons.Filled.Close, contentDescription = "Ləğv et")
                        }
                    },
                    actions = {
                        TextButton(
                            onClick = { viewModel.createProduct() },
                            enabled = state.isFormValid && !state.isLoading
                        ) {
                            Text(
                                "Yarat",
                                fontWeight = FontWeight.Bold,
                                color = if (state.isFormValid && !state.isLoading)
                                    CoreViaPrimary else TextHint
                            )
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = Color.Transparent
                    )
                )
            }
        ) { padding ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                // ── Title ──
                CreateProductSectionLabel("Məhsul adı")
                OutlinedTextField(
                    value = state.title,
                    onValueChange = viewModel::updateTitle,
                    placeholder = { Text("məs: 12 Həftəlik Məşq Planı", color = TextHint) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = TextSeparator
                    )
                )

                // ── Description ──
                CreateProductSectionLabel("Təsvir")
                OutlinedTextField(
                    value = state.description,
                    onValueChange = viewModel::updateDescription,
                    placeholder = { Text("Məhsul haqqında ətraflı məlumat...", color = TextHint) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(120.dp),
                    shape = RoundedCornerShape(12.dp),
                    maxLines = 6,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = TextSeparator
                    )
                )

                // ── Product Type — Segmented ──
                CreateProductSectionLabel("Məhsul növü")
                SingleChoiceSegmentedButtonRow(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    val types = MarketplaceProductType.entries
                    types.forEachIndexed { index, type ->
                        SegmentedButton(
                            selected = state.selectedProductType == type,
                            onClick = { viewModel.updateProductType(type) },
                            shape = SegmentedButtonDefaults.itemShape(
                                index = index,
                                count = types.size,
                                baseShape = RoundedCornerShape(Layout.cornerRadiusM)
                            ),
                            colors = SegmentedButtonDefaults.colors(
                                activeContainerColor = CoreViaPrimary,
                                activeContentColor = Color.White,
                                inactiveContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                                inactiveContentColor = MaterialTheme.colorScheme.onSurfaceVariant
                            ),
                            icon = {}
                        ) {
                            Text(
                                text = type.displayName,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Medium,
                                maxLines = 1
                            )
                        }
                    }
                }

                // ── Price ──
                CreateProductSectionLabel("Qiymət")
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.Top
                ) {
                    OutlinedTextField(
                        value = state.price,
                        onValueChange = viewModel::updatePrice,
                        placeholder = { Text("0.00", color = TextHint) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        leadingIcon = {
                            Icon(
                                Icons.Filled.AttachMoney,
                                contentDescription = null,
                                tint = CoreViaPrimary
                            )
                        },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = CoreViaPrimary,
                            unfocusedBorderColor = TextSeparator
                        )
                    )

                    // Currency selector
                    Column {
                        currencies.forEach { curr ->
                            Row(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(
                                        if (state.currency == curr) CoreViaPrimary.copy(alpha = 0.1f)
                                        else Color.Transparent
                                    )
                                    .clickable { viewModel.updateCurrency(curr) }
                                    .padding(horizontal = 12.dp, vertical = 6.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                RadioButton(
                                    selected = state.currency == curr,
                                    onClick = { viewModel.updateCurrency(curr) },
                                    colors = RadioButtonDefaults.colors(
                                        selectedColor = CoreViaPrimary
                                    ),
                                    modifier = Modifier.size(18.dp)
                                )
                                Text(
                                    text = curr,
                                    fontSize = 13.sp,
                                    fontWeight = if (state.currency == curr) FontWeight.Bold else FontWeight.Normal,
                                    color = if (state.currency == curr) CoreViaPrimary
                                    else MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                    }
                }

                // ── Error Message ──
                state.errorMessage?.let { error ->
                    Text(
                        text = error,
                        color = CoreViaError,
                        fontSize = 13.sp,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                // ── Save Button ──
                Button(
                    onClick = { viewModel.createProduct() },
                    enabled = state.isFormValid && !state.isLoading,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CoreViaPrimary,
                        disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f)
                    )
                ) {
                    if (state.isLoading) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(22.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(Icons.Filled.Check, contentDescription = null, tint = Color.White)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Məhsul Yarat", fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))
            }
        }

        // ── Loading Overlay ──
        if (state.isLoading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.3f)),
                contentAlignment = Alignment.Center
            ) {
                Card(
                    shape = RoundedCornerShape(Layout.cornerRadiusL),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    ),
                    elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(32.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                        Text(
                            "Məhsul yaradılır...",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Section Label
// ═══════════════════════════════════════════════════════════════════

@Composable
private fun CreateProductSectionLabel(text: String) {
    Text(
        text = text,
        fontSize = 14.sp,
        fontWeight = FontWeight.Medium,
        color = TextSecondary
    )
}
