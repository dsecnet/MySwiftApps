package life.corevia.app.ui.food

import android.Manifest
import android.content.Context
import android.net.Uri
import android.os.Environment
import life.corevia.app.ui.theme.AppTheme
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import life.corevia.app.data.models.MealType
import java.io.File
import java.io.FileOutputStream

/**
 * iOS AddFoodView.swift — Android 1-e-1 port (BottomSheet)
 *
 * Yeni bolmeler:
 *  - Camera section (AI food photo analysis) — TAM IMPLEMENT
 *  - Quick Add: 6 preset foods
 *  - Meal type selector
 *  - Food name + calories + macros + notes
 *  - Save button
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddFoodSheet(
    onDismiss: () -> Unit,
    isPremium: Boolean = true,
    onSave: (
        name: String,
        calories: Int,
        protein: Double?,
        carbs: Double?,
        fats: Double?,
        mealType: String,
        notes: String?
    ) -> Unit,
    onAnalyzeImage: ((File) -> Unit)? = null,
    isAnalyzing: Boolean = false
) {
    var name by remember { mutableStateOf("") }
    var caloriesText by remember { mutableStateOf("") }
    var proteinText by remember { mutableStateOf("") }
    var carbsText by remember { mutableStateOf("") }
    var fatsText by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var selectedMealType by remember { mutableStateOf(MealType.LUNCH.value) }

    val context = LocalContext.current

    // Camera photo URI
    var photoUri by remember { mutableStateOf<Uri?>(null) }

    // Camera launcher
    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicture()
    ) { success ->
        if (success && photoUri != null) {
            val file = uriToFile(context, photoUri!!)
            if (file != null) {
                onAnalyzeImage?.invoke(file)
            }
        }
    }

    // Gallery launcher
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri ->
        uri?.let {
            val file = uriToFile(context, it)
            if (file != null) {
                onAnalyzeImage?.invoke(file)
            }
        }
    }

    // Camera permission launcher
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            val file = createImageFile(context)
            photoUri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.provider",
                file
            )
            cameraLauncher.launch(photoUri!!)
        }
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppTheme.Colors.background,
        dragHandle = {
            Box(
                modifier = Modifier
                    .padding(vertical = 8.dp)
                    .size(width = 40.dp, height = 4.dp)
                    .background(AppTheme.Colors.separator, RoundedCornerShape(2.dp))
            )
        }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Title ──────────────────────────────────────────────────────────
            Text(
                text = "Qida Elave Et",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Camera AI Analysis
            // ═══════════════════════════════════════════════════════════════════
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = AppTheme.Colors.secondaryBackground
                )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Camera icon circle
                    Box(
                        modifier = Modifier
                            .size(70.dp)
                            .clip(CircleShape)
                            .background(
                                Brush.linearGradient(
                                    colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accent.copy(alpha = 0.6f))
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        if (isAnalyzing) {
                            CircularProgressIndicator(
                                color = Color.White,
                                modifier = Modifier.size(28.dp),
                                strokeWidth = 2.dp
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Outlined.CameraAlt,
                                contentDescription = null,
                                tint = Color.White,
                                modifier = Modifier.size(32.dp)
                            )
                        }
                    }

                    Text(
                        text = if (isAnalyzing) "AI analiz edir..." else "AI ile qida analizi",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = AppTheme.Colors.primaryText
                    )
                    Text(
                        text = if (isAnalyzing) "Claude AI sekli analiz edir, gozleyin..."
                               else "Yemeyin seklini cekin, AI kalori ve makrolari teyin etsin",
                        fontSize = 13.sp,
                        color = AppTheme.Colors.secondaryText,
                        textAlign = TextAlign.Center
                    )

                    if (!isAnalyzing) {
                        // Camera button
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .background(AppTheme.Colors.accent)
                                .clickable {
                                    permissionLauncher.launch(Manifest.permission.CAMERA)
                                }
                                .padding(horizontal = 20.dp, vertical = 10.dp)
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Icon(Icons.Outlined.CameraAlt, null, tint = Color.White, modifier = Modifier.size(16.dp))
                                Text("Sekil cek", color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                            }
                        }

                        // Gallery button
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .border(1.dp, AppTheme.Colors.accent, RoundedCornerShape(12.dp))
                                .clickable {
                                    galleryLauncher.launch("image/*")
                                }
                                .padding(horizontal = 20.dp, vertical = 8.dp)
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Icon(Icons.Outlined.PhotoLibrary, null, tint = AppTheme.Colors.accent, modifier = Modifier.size(16.dp))
                                Text("Qalereyadan sec", color = AppTheme.Colors.accent, fontWeight = FontWeight.Medium, fontSize = 13.sp)
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Quick Add
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Suretli elave",
                    fontSize = 14.sp,
                    color = AppTheme.Colors.secondaryText
                )

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "\uD83E\uDD5A",
                            name = "Yumurta",
                            calories = 78,
                            onClick = {
                                name = "Yumurta"
                                caloriesText = "78"
                                proteinText = "6"
                                carbsText = "0.6"
                                fatsText = "5"
                            }
                        )
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "\uD83C\uDF4C",
                            name = "Banan",
                            calories = 89,
                            onClick = {
                                name = "Banan"
                                caloriesText = "89"
                                proteinText = "1.1"
                                carbsText = "23"
                                fatsText = "0.3"
                            }
                        )
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "\uD83C\uDF57",
                            name = "Toyuq",
                            calories = 239,
                            onClick = {
                                name = "Toyuq dosu"
                                caloriesText = "239"
                                proteinText = "27"
                                carbsText = "0"
                                fatsText = "14"
                            }
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "\uD83C\uDF4E",
                            name = "Alma",
                            calories = 52,
                            onClick = {
                                name = "Alma"
                                caloriesText = "52"
                                proteinText = "0.3"
                                carbsText = "14"
                                fatsText = "0.2"
                            }
                        )
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "\uD83E\uDD63",
                            name = "Yulaf",
                            calories = 154,
                            onClick = {
                                name = "Yulaf ezmesi"
                                caloriesText = "154"
                                proteinText = "5"
                                carbsText = "27"
                                fatsText = "2.6"
                            }
                        )
                        QuickAddButton(
                            modifier = Modifier.weight(1f),
                            emoji = "\uD83E\uDDC3",
                            name = "Sire",
                            calories = 112,
                            onClick = {
                                name = "Portagal siresi"
                                caloriesText = "112"
                                proteinText = "2"
                                carbsText = "26"
                                fatsText = "0.5"
                            }
                        )
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Meal Type Selector
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Ogun", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    MealType.entries.forEach { meal ->
                        val emoji = when (meal) {
                            MealType.BREAKFAST -> "\u2600\uFE0F"
                            MealType.LUNCH -> "\u2600\uFE0F"
                            MealType.DINNER -> "\uD83C\uDF19"
                            MealType.SNACK -> "\uD83C\uDF7F"
                        }
                        val label = when (meal) {
                            MealType.BREAKFAST -> "Seher"
                            MealType.LUNCH -> "Nahar"
                            MealType.DINNER -> "Axsam"
                            MealType.SNACK -> "Ara"
                        }
                        val isSelected = selectedMealType == meal.value
                        Column(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(12.dp))
                                .background(
                                    if (isSelected) AppTheme.Colors.success
                                    else AppTheme.Colors.secondaryBackground
                                )
                                .border(
                                    width = if (isSelected) 2.dp else 1.dp,
                                    color = if (isSelected) AppTheme.Colors.success else AppTheme.Colors.separator,
                                    shape = RoundedCornerShape(12.dp)
                                )
                                .clickable { selectedMealType = meal.value }
                                .padding(vertical = 10.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(2.dp)
                        ) {
                            Text(emoji, fontSize = 18.sp)
                            Text(
                                text = label,
                                color = if (isSelected) Color.White else AppTheme.Colors.secondaryText,
                                fontSize = 11.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                            )
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Food Name
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Qida adi", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value = name,
                    onValueChange = { if (it.length <= 200) name = it },
                    placeholder = { Text("mes: Toyuq dosu", color = AppTheme.Colors.tertiaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = foodTextFieldColors(),
                    singleLine = true
                )
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Calories
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Kalori *", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value = caloriesText,
                    onValueChange = {
                        val filtered = it.filter { c -> c.isDigit() }
                        if ((filtered.toIntOrNull() ?: 0) <= 10000) caloriesText = filtered
                    },
                    placeholder = { Text("mes: 250", color = AppTheme.Colors.tertiaryText) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = foodTextFieldColors(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Macros
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Makrolar (isteye bagli)", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = proteinText,
                        onValueChange = { proteinText = it },
                        label = { Text("Protein", color = AppTheme.Colors.tertiaryText, fontSize = 11.sp) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = foodTextFieldColors(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        singleLine = true,
                        suffix = { Text("g", color = AppTheme.Colors.secondaryText, fontSize = 11.sp) }
                    )
                    OutlinedTextField(
                        value = carbsText,
                        onValueChange = { carbsText = it },
                        label = { Text("Karbo", color = AppTheme.Colors.tertiaryText, fontSize = 11.sp) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = foodTextFieldColors(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        singleLine = true,
                        suffix = { Text("g", color = AppTheme.Colors.secondaryText, fontSize = 11.sp) }
                    )
                    OutlinedTextField(
                        value = fatsText,
                        onValueChange = { fatsText = it },
                        label = { Text("Yag", color = AppTheme.Colors.tertiaryText, fontSize = 11.sp) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = foodTextFieldColors(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        singleLine = true,
                        suffix = { Text("g", color = AppTheme.Colors.secondaryText, fontSize = 11.sp) }
                    )
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Notes
            // ═══════════════════════════════════════════════════════════════════
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Qeydler (isteye bagli)", color = AppTheme.Colors.secondaryText, fontSize = 14.sp)
                OutlinedTextField(
                    value = notes,
                    onValueChange = { if (it.length <= 1000) notes = it },
                    placeholder = { Text("Elave qeydler...", color = AppTheme.Colors.tertiaryText) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(min = 80.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = foodTextFieldColors(),
                    minLines = 3,
                    maxLines = 5
                )
            }

            // ═══════════════════════════════════════════════════════════════════
            // SECTION: Save Button
            // ═══════════════════════════════════════════════════════════════════
            val isValid = name.isNotBlank() && caloriesText.isNotBlank()
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp)
                    .then(
                        if (isValid) Modifier.shadow(
                            8.dp, RoundedCornerShape(12.dp),
                            spotColor = AppTheme.Colors.success.copy(alpha = 0.4f)
                        ) else Modifier
                    )
                    .background(
                        brush = Brush.horizontalGradient(
                            colors = listOf(AppTheme.Colors.success, AppTheme.Colors.success.copy(alpha = 0.8f))
                        ),
                        shape = RoundedCornerShape(12.dp),
                        alpha = if (isValid) 1f else 0.5f
                    )
                    .clip(RoundedCornerShape(12.dp))
                    .then(
                        if (isValid) Modifier.clickable {
                            val calories = caloriesText.toIntOrNull() ?: return@clickable
                            onSave(
                                name.trim(),
                                calories,
                                proteinText.toDoubleOrNull(),
                                carbsText.toDoubleOrNull(),
                                fatsText.toDoubleOrNull(),
                                selectedMealType,
                                notes.trim().ifEmpty { null }
                            )
                        } else Modifier
                    )
                    .padding(vertical = 14.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Saxla",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }
    }
}

// ── Helper: Create temp image file for camera ──────────────────────────────
private fun createImageFile(context: Context): File {
    val dir = File(context.cacheDir, "camera_photos")
    if (!dir.exists()) dir.mkdirs()
    return File.createTempFile("food_", ".jpg", dir)
}

// ── Helper: Copy URI content to a temp file ────────────────────────────────
private fun uriToFile(context: Context, uri: Uri): File? {
    return try {
        val inputStream = context.contentResolver.openInputStream(uri) ?: return null
        val file = createImageFile(context)
        FileOutputStream(file).use { output ->
            inputStream.copyTo(output)
        }
        inputStream.close()
        file
    } catch (e: Exception) {
        null
    }
}

// ── QuickAddButton ────────────────────────────────────────────────────────
@Composable
private fun QuickAddButton(
    modifier: Modifier = Modifier,
    emoji: String,
    name: String,
    calories: Int,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(AppTheme.Colors.secondaryBackground)
            .border(1.dp, AppTheme.Colors.separator, RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(vertical = 10.dp, horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(2.dp)
    ) {
        Text(emoji, fontSize = 24.sp)
        Text(
            text = name,
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
            color = AppTheme.Colors.primaryText,
            maxLines = 1
        )
        Text(
            text = "$calories kal",
            fontSize = 10.sp,
            color = AppTheme.Colors.secondaryText
        )
    }
}

// ── TextField Colors ────────────────────────────────────────────────────────
@Composable
private fun foodTextFieldColors() = OutlinedTextFieldDefaults.colors(
    focusedBorderColor = AppTheme.Colors.success,
    unfocusedBorderColor = AppTheme.Colors.separator,
    focusedTextColor = AppTheme.Colors.primaryText,
    unfocusedTextColor = AppTheme.Colors.primaryText,
    cursorColor = AppTheme.Colors.success
)
