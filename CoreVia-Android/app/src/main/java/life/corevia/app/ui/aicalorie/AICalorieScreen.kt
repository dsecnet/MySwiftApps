package life.corevia.app.ui.aicalorie

import android.graphics.Bitmap
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.AICalorieResult
import life.corevia.app.data.model.DetectedFood
import life.corevia.app.ui.theme.*
import java.io.File

@Composable
fun AICalorieScreen(
    onBack: () -> Unit,
    viewModel: AICalorieViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    // Camera URI
    var cameraUri by remember { mutableStateOf<Uri?>(null) }

    // Gallery picker
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let {
            try {
                val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    val source = ImageDecoder.createSource(context.contentResolver, it)
                    ImageDecoder.decodeBitmap(source) { decoder, _, _ ->
                        decoder.allocator = ImageDecoder.ALLOCATOR_SOFTWARE
                        decoder.isMutableRequired = true
                    }
                } else {
                    @Suppress("DEPRECATION")
                    MediaStore.Images.Media.getBitmap(context.contentResolver, it)
                }
                viewModel.setSelectedImage(bitmap)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    // Camera launcher
    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicture()
    ) { success ->
        if (success) {
            cameraUri?.let { uri ->
                try {
                    val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        val source = ImageDecoder.createSource(context.contentResolver, uri)
                        ImageDecoder.decodeBitmap(source) { decoder, _, _ ->
                            decoder.allocator = ImageDecoder.ALLOCATOR_SOFTWARE
                            decoder.isMutableRequired = true
                        }
                    } else {
                        @Suppress("DEPRECATION")
                        MediaStore.Images.Media.getBitmap(context.contentResolver, uri)
                    }
                    viewModel.setSelectedImage(bitmap)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 20.dp)
        ) {
            Column(
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Spacer(modifier = Modifier.height(48.dp))

                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.surfaceVariant)
                            .clickable(onClick = onBack),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Filled.ArrowBack, null,
                            modifier = Modifier.size(18.dp),
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }
                    Column {
                        Text(
                            text = "AI Kalori Analizi",
                            fontSize = 22.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        Text(
                            text = "Yeməyin şəklini çəkin, AI analiz etsin",
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // Header Card
                HeaderInfoCard()

                // Photo Section
                if (uiState.selectedImage != null) {
                    // Show selected image
                    SelectedImageView(
                        bitmap = uiState.selectedImage!!,
                        onReset = viewModel::resetAnalysis
                    )
                } else {
                    // Camera / Gallery buttons
                    PhotoPickerSection(
                        onCamera = {
                            val photoFile = File(context.cacheDir, "food_photo_${System.currentTimeMillis()}.jpg")
                            val uri = FileProvider.getUriForFile(
                                context,
                                "${context.packageName}.provider",
                                photoFile
                            )
                            cameraUri = uri
                            cameraLauncher.launch(uri)
                        },
                        onGallery = {
                            galleryLauncher.launch("image/*")
                        }
                    )
                }

                // Analyze Button
                if (uiState.selectedImage != null && uiState.result == null && !uiState.isAnalyzing) {
                    AnalyzeButton(onClick = viewModel::analyzeFood)
                }

                // Loading
                if (uiState.isAnalyzing) {
                    AnalyzingView()
                }

                // Result
                uiState.result?.let { result ->
                    ResultView(
                        result = result,
                        isSaving = uiState.isSaving,
                        onSaveFood = viewModel::saveFood,
                        onSaveAll = viewModel::saveAllFoods
                    )
                }

                // Saved message
                uiState.savedMessage?.let { message ->
                    SavedMessageView(
                        message = message,
                        onDismiss = viewModel::clearSavedMessage
                    )
                }

                // Error
                uiState.errorMessage?.let { error ->
                    ErrorView(
                        error = error,
                        onDismiss = viewModel::clearError
                    )
                }
            }
        }
    }
}

// ─── Header Info Card ───────────────────────────────────────────────

@Composable
private fun HeaderInfoCard() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(CoreViaPrimary.copy(alpha = 0.08f))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Icon(
            Icons.Filled.CameraAlt, null,
            modifier = Modifier.size(40.dp),
            tint = CoreViaPrimary
        )
        Text(
            text = "Yeməyinizin şəklini çəkin",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = "AI avtomatik olaraq yeməkləri tanıyacaq və kalori, protein, karbohidrat və yağ dəyərlərini hesablayacaq",
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}

// ─── Photo Picker ───────────────────────────────────────────────────

@Composable
private fun PhotoPickerSection(onCamera: () -> Unit, onGallery: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        PhotoOptionCard(
            modifier = Modifier.weight(1f),
            icon = Icons.Filled.CameraAlt,
            title = "Kamera",
            onClick = onCamera
        )
        PhotoOptionCard(
            modifier = Modifier.weight(1f),
            icon = Icons.Filled.PhotoLibrary,
            title = "Qalereya",
            onClick = onGallery
        )
    }
}

@Composable
private fun PhotoOptionCard(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    title: String,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .clickable(onClick = onClick)
            .padding(vertical = 30.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Icon(
            icon, null,
            modifier = Modifier.size(32.dp),
            tint = CoreViaPrimary
        )
        Text(
            text = title,
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}

// ─── Selected Image ─────────────────────────────────────────────────

@Composable
private fun SelectedImageView(bitmap: Bitmap, onReset: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Image(
            bitmap = bitmap.asImageBitmap(),
            contentDescription = null,
            modifier = Modifier
                .fillMaxWidth()
                .height(250.dp)
                .clip(RoundedCornerShape(14.dp)),
            contentScale = ContentScale.Crop
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .background(MaterialTheme.colorScheme.surfaceVariant)
                    .clickable(onClick = onReset)
                    .padding(horizontal = 14.dp, vertical = 8.dp)
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Refresh, null,
                        modifier = Modifier.size(14.dp),
                        tint = CoreViaPrimary
                    )
                    Text(
                        text = "Şəkili dəyiş",
                        fontSize = 13.sp,
                        color = CoreViaPrimary,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }
    }
}

// ─── Analyze Button ─────────────────────────────────────────────────

@Composable
private fun AnalyzeButton(onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .height(52.dp),
        shape = RoundedCornerShape(14.dp),
        colors = ButtonDefaults.buttonColors(containerColor = CoreViaPrimary)
    ) {
        Icon(Icons.Filled.AutoAwesome, null, modifier = Modifier.size(20.dp))
        Spacer(modifier = Modifier.width(8.dp))
        Text("AI ilə analiz et", fontSize = 16.sp, fontWeight = FontWeight.Bold)
    }
}

// ─── Analyzing View ─────────────────────────────────────────────────

@Composable
private fun AnalyzingView() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        CircularProgressIndicator(
            color = CoreViaPrimary,
            modifier = Modifier.size(40.dp),
            strokeWidth = 3.dp
        )
        Text(
            text = "AI yeməkləri analiz edir...",
            fontSize = 15.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ─── Result View ────────────────────────────────────────────────────

@Composable
private fun ResultView(
    result: AICalorieResult,
    isSaving: Boolean,
    onSaveFood: (DetectedFood) -> Unit,
    onSaveAll: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
        // Total Macros Card
        MacrosCard(result)

        // Detected Foods
        Text(
            text = "Aşkar edilən yeməklər",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )

        result.foods.forEach { food ->
            FoodItemRow(
                food = food,
                onSave = { onSaveFood(food) }
            )
        }

        // Save All button
        if (result.foods.size > 1) {
            Button(
                onClick = onSaveAll,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = CoreViaSuccess),
                enabled = !isSaving
            ) {
                if (isSaving) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(18.dp),
                        color = Color.White,
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(Icons.Filled.SaveAlt, null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        "Hamısını qida siyahısına əlavə et",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        // Confidence
        Row(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                Icons.Filled.Verified, null,
                modifier = Modifier.size(14.dp),
                tint = CoreViaSuccess
            )
            Text(
                text = "Dəqiqlik: ${(result.confidence * 100).toInt()}%",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ─── Macros Card ────────────────────────────────────────────────────

@Composable
private fun MacrosCard(result: AICalorieResult) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        // Total Calories
        Row(
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = "${result.totalCalories.toInt()}",
                fontSize = 40.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
            Text(
                text = "kcal",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(bottom = 6.dp)
            )
        }

        // Macros Grid
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            MacroItem(
                label = "Protein",
                value = "${result.totalProtein.toInt()}g",
                color = Color(0xFF2196F3)
            )
            MacroItem(
                label = "Karb",
                value = "${result.totalCarbs.toInt()}g",
                color = Color(0xFFFF9800)
            )
            MacroItem(
                label = "Yağ",
                value = "${result.totalFat.toInt()}g",
                color = Color(0xFF9C27B0)
            )
        }
    }
}

@Composable
private fun MacroItem(label: String, value: String, color: Color) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(color.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = value,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                color = color
            )
        }
        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// ─── Food Item Row ──────────────────────────────────────────────────

@Composable
private fun FoodItemRow(food: DetectedFood, onSave: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(14.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(CoreViaPrimary.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.Restaurant, null,
                modifier = Modifier.size(18.dp),
                tint = CoreViaPrimary
            )
        }
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = food.name,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "${food.portionGrams.toInt()}g",
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text("P:${food.protein.toInt()}g", fontSize = 11.sp, color = Color(0xFF2196F3))
                Text("K:${food.carbs.toInt()}g", fontSize = 11.sp, color = Color(0xFFFF9800))
                Text("Y:${food.fat.toInt()}g", fontSize = 11.sp, color = Color(0xFF9C27B0))
            }
        }
        Column(horizontalAlignment = Alignment.End) {
            Text(
                text = "${food.calories.toInt()} kcal",
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                color = CoreViaPrimary
            )
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .background(CoreViaSuccess.copy(alpha = 0.1f))
                    .clickable(onClick = onSave)
                    .padding(horizontal = 8.dp, vertical = 3.dp)
            ) {
                Text(
                    text = "Saxla",
                    fontSize = 10.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = CoreViaSuccess
                )
            }
        }
    }
}

// ─── Saved Message ──────────────────────────────────────────────────

@Composable
private fun SavedMessageView(message: String, onDismiss: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(CoreViaSuccess.copy(alpha = 0.1f))
            .padding(14.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            Icons.Filled.CheckCircle, null,
            modifier = Modifier.size(20.dp),
            tint = CoreViaSuccess
        )
        Text(
            text = message,
            fontSize = 13.sp,
            fontWeight = FontWeight.Medium,
            color = CoreViaSuccess,
            modifier = Modifier.weight(1f)
        )
        Icon(
            Icons.Filled.Close, null,
            modifier = Modifier
                .size(16.dp)
                .clickable(onClick = onDismiss),
            tint = CoreViaSuccess.copy(alpha = 0.5f)
        )
    }
}

// ─── Error View ─────────────────────────────────────────────────────

@Composable
private fun ErrorView(error: String, onDismiss: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(CoreViaError.copy(alpha = 0.08f))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Icon(
            Icons.Filled.Warning, null,
            modifier = Modifier.size(28.dp),
            tint = CoreViaError
        )
        Text(
            text = error,
            fontSize = 13.sp,
            color = CoreViaError,
            textAlign = TextAlign.Center
        )
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(8.dp))
                .background(CoreViaError)
                .clickable(onClick = onDismiss)
                .padding(horizontal = 20.dp, vertical = 8.dp)
        ) {
            Text(
                text = "Tamam",
                fontSize = 13.sp,
                fontWeight = FontWeight.SemiBold,
                color = Color.White
            )
        }
    }
}
