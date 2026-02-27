package life.corevia.app.ui.content

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.ContentResponse
import life.corevia.app.ui.theme.*

/**
 * TrainerContentScreen — iOS TrainerContentView equivalent
 * Two modes:
 *   - Trainer view: own content list + create + delete
 *   - Student view: read-only content from a trainer
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrainerContentScreen(
    trainerId: String? = null,
    isTrainerMode: Boolean = false,
    onBack: () -> Unit = {},
    viewModel: ContentViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    // Load content on first composition
    LaunchedEffect(trainerId, isTrainerMode) {
        if (isTrainerMode) {
            viewModel.loadMyContent()
        } else if (!trainerId.isNullOrBlank()) {
            viewModel.loadTrainerContent(trainerId)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Məzmun",
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent
                )
            )
        },
        floatingActionButton = {
            if (isTrainerMode) {
                FloatingActionButton(
                    onClick = viewModel::toggleCreateSheet,
                    containerColor = CoreViaPrimary,
                    contentColor = Color.White,
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Icon(Icons.Filled.Add, contentDescription = "Yeni Məzmun")
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(padding)
        ) {
            when {
                // Loading
                uiState.isLoading && uiState.contents.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                    }
                }

                // Empty state
                !uiState.isLoading && uiState.contents.isEmpty() -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(40.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            Icons.Filled.Article, null,
                            modifier = Modifier.size(70.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = if (isTrainerMode) "Hələ məzmun yaratmamısınız"
                            else "Hələ məzmun yoxdur",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = if (isTrainerMode) "Yeni məzmun yaratmaq üçün + düyməsinə basın"
                            else "Bu trener hələ məzmun paylaşmayıb",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // Content list
                else -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState())
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        uiState.contents.forEach { content ->
                            ContentCard(
                                content = content,
                                isTrainerMode = isTrainerMode,
                                onDelete = { viewModel.deleteContent(content.id) }
                            )
                        }
                        // Bottom padding for FAB clearance
                        Spacer(modifier = Modifier.height(80.dp))
                    }
                }
            }
        }

        // ── Error Snackbar ──
        uiState.error?.let { error ->
            LaunchedEffect(error) {
                // Auto-clear after display
                kotlinx.coroutines.delay(3000)
                viewModel.clearError()
            }
        }
    }

    // ── Create Content Bottom Sheet ──
    if (uiState.showCreateSheet) {
        CreateContentSheet(
            title = uiState.createTitle,
            body = uiState.createBody,
            isPremiumOnly = uiState.createIsPremiumOnly,
            isCreating = uiState.isCreating,
            isValid = uiState.isCreateFormValid,
            onTitleChange = viewModel::updateCreateTitle,
            onBodyChange = viewModel::updateCreateBody,
            onTogglePremium = viewModel::togglePremiumOnly,
            onSubmit = viewModel::createContent,
            onDismiss = viewModel::toggleCreateSheet
        )
    }
}

// ─── Content Card ───────────────────────────────────────────────────

@Composable
private fun ContentCard(
    content: ContentResponse,
    isTrainerMode: Boolean,
    onDelete: () -> Unit
) {
    var showDeleteConfirm by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.05f),
                spotColor = Color.Black.copy(alpha = 0.05f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Top row: title + badges + delete
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Top
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                // Premium badge
                if (content.isPremiumOnly) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(AccentOrange.copy(alpha = 0.15f))
                            .padding(horizontal = 8.dp, vertical = 3.dp)
                    ) {
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(4.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Filled.Star, null,
                                modifier = Modifier.size(12.dp),
                                tint = AccentOrange
                            )
                            Text(
                                text = "Premium",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = AccentOrange
                            )
                        }
                    }
                }

                // Title
                Text(
                    text = content.title,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }

            // Delete button (only in trainer mode)
            if (isTrainerMode) {
                IconButton(
                    onClick = { showDeleteConfirm = true },
                    modifier = Modifier.size(32.dp)
                ) {
                    Icon(
                        Icons.Filled.Delete, null,
                        modifier = Modifier.size(18.dp),
                        tint = CoreViaError.copy(alpha = 0.7f)
                    )
                }
            }
        }

        // Body preview
        content.body?.let { body ->
            if (body.isNotBlank()) {
                Text(
                    text = body,
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis,
                    lineHeight = 20.sp
                )
            }
        }

        // Footer: trainer name + date
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Trainer info
            if (!isTrainerMode && content.trainerName.isNotBlank()) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.AccountCircle, null,
                        modifier = Modifier.size(14.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = content.trainerName,
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            } else {
                Spacer(modifier = Modifier.width(1.dp))
            }

            // Date
            if (content.createdAt.isNotBlank()) {
                Text(
                    text = formatContentDate(content.createdAt),
                    fontSize = 11.sp,
                    color = TextHint
                )
            }
        }
    }

    // Delete confirmation dialog
    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("Məzmunu sil", fontWeight = FontWeight.Bold) },
            text = { Text("\"${content.title}\" silinsin?") },
            confirmButton = {
                TextButton(onClick = {
                    showDeleteConfirm = false
                    onDelete()
                }) {
                    Text("Sil", color = CoreViaError, fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirm = false }) {
                    Text("Ləğv et")
                }
            }
        )
    }
}

// ─── Create Content Sheet ───────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CreateContentSheet(
    title: String,
    body: String,
    isPremiumOnly: Boolean,
    isCreating: Boolean,
    isValid: Boolean,
    onTitleChange: (String) -> Unit,
    onBodyChange: (String) -> Unit,
    onTogglePremium: () -> Unit,
    onSubmit: () -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                "Yeni Məzmun",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface
            )

            // Title
            OutlinedTextField(
                value = title,
                onValueChange = onTitleChange,
                label = { Text("Başlıq") },
                placeholder = { Text("Məzmunun başlığı", color = TextHint) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary,
                    unfocusedBorderColor = TextSeparator
                )
            )

            // Body
            OutlinedTextField(
                value = body,
                onValueChange = onBodyChange,
                label = { Text("Mətn") },
                placeholder = { Text("Məzmunun mətni...", color = TextHint) },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp),
                shape = RoundedCornerShape(12.dp),
                maxLines = 8,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary,
                    unfocusedBorderColor = TextSeparator
                )
            )

            // Premium toggle
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(
                        if (isPremiumOnly) AccentOrange.copy(alpha = 0.1f)
                        else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                    )
                    .clickable(onClick = onTogglePremium)
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Filled.Star, null,
                        modifier = Modifier.size(20.dp),
                        tint = if (isPremiumOnly) AccentOrange else TextSecondary
                    )
                    Column {
                        Text(
                            "Yalnız Premium",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Text(
                            "Yalnız premium üzvlər görəcək",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
                Switch(
                    checked = isPremiumOnly,
                    onCheckedChange = { onTogglePremium() },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = Color.White,
                        checkedTrackColor = AccentOrange
                    )
                )
            }

            // Submit
            Button(
                onClick = onSubmit,
                enabled = isValid && !isCreating,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CoreViaPrimary,
                    disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f)
                )
            ) {
                if (isCreating) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(22.dp),
                        color = Color.White,
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(Icons.Filled.Publish, null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        "Paylaş",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

// ─── Helpers ────────────────────────────────────────────────────────

private fun formatContentDate(isoDate: String): String {
    return try {
        val parts = isoDate.split("T")
        if (parts.isNotEmpty()) {
            val dateParts = parts[0].split("-")
            if (dateParts.size == 3) {
                "${dateParts[2]}.${dateParts[1]}.${dateParts[0]}"
            } else parts[0]
        } else isoDate
    } catch (_: Exception) {
        isoDate
    }
}
