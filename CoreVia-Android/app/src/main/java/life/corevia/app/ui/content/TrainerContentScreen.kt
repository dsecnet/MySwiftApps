package life.corevia.app.ui.content

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.Article
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.ContentResponse
import java.text.SimpleDateFormat
import java.util.Locale

/**
 * iOS TrainerContentView.swift — Android 1-e-1 port.
 *
 * Bolmeler:
 *  1. Header: Title + subtitle + plus button
 *  2. Content List: LazyColumn of ContentCards
 *  3. Empty State: icon + message + create button
 *  4. CreateContentSheet: ModalBottomSheet with title, body, premium toggle
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrainerContentScreen(
    viewModel: ContentViewModel = viewModel()
) {
    val contents by viewModel.myContents.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val successMessage by viewModel.successMessage.collectAsState()

    var showCreateSheet by remember { mutableStateOf(false) }
    var showDeleteDialog by remember { mutableStateOf<String?>(null) }

    val scrollState = rememberScrollState()

    // Success snackbar
    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearSuccess()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(scrollState)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            // ── 1. Header Section (iOS: headerSection) ─────────────────────────────
            ContentHeaderSection(
                onCreateClick = { showCreateSheet = true }
            )

            // ── Error Message ──────────────────────────────────────────────────────
            errorMessage?.let { msg ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppTheme.Colors.error.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.ErrorOutline,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp),
                        tint = AppTheme.Colors.error
                    )
                    Text(
                        text = msg,
                        fontSize = 13.sp,
                        color = AppTheme.Colors.error,
                        modifier = Modifier.weight(1f)
                    )
                    Icon(
                        imageVector = Icons.Outlined.Close,
                        contentDescription = "Bagla",
                        modifier = Modifier
                            .size(18.dp)
                            .clip(CircleShape)
                            .clickable { viewModel.clearError() },
                        tint = AppTheme.Colors.error
                    )
                }
            }

            // ── Success Message ────────────────────────────────────────────────────
            successMessage?.let { msg ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(AppTheme.Colors.success.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.CheckCircle,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp),
                        tint = AppTheme.Colors.success
                    )
                    Text(
                        text = msg,
                        fontSize = 13.sp,
                        color = AppTheme.Colors.success
                    )
                }
            }

            // ── 2/3. Content List or Empty State ───────────────────────────────────
            if (isLoading && contents.isEmpty()) {
                // Loading state
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 60.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(
                        color = AppTheme.Colors.accent,
                        modifier = Modifier.size(40.dp)
                    )
                }
            } else if (contents.isEmpty()) {
                // iOS: emptyContentSection
                ContentEmptySection(
                    onCreateClick = { showCreateSheet = true }
                )
            } else {
                // iOS: ScrollView { LazyVStack { ForEach(contents) { ContentCard } } }
                contents.forEach { content ->
                    ContentCard(
                        content = content,
                        isOwner = true,
                        onDelete = { showDeleteDialog = content.id }
                    )
                }
            }

            Spacer(modifier = Modifier.height(100.dp))
        }
    }

    // ── Delete Confirmation Dialog ─────────────────────────────────────────────
    showDeleteDialog?.let { contentId ->
        AlertDialog(
            onDismissRequest = { showDeleteDialog = null },
            containerColor = AppTheme.Colors.secondaryBackground,
            title = {
                Text(
                    text = "Kontenti sil",
                    color = AppTheme.Colors.primaryText,
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Text(
                    text = "Bu kontenti silmek isteyirsiniz? Bu emeliyyat geri qaytarila bilmez.",
                    color = AppTheme.Colors.secondaryText
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        viewModel.deleteContent(contentId)
                        showDeleteDialog = null
                    }
                ) {
                    Text("Sil", color = AppTheme.Colors.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteDialog = null }) {
                    Text("Legv et", color = AppTheme.Colors.secondaryText)
                }
            }
        )
    }

    // ── Create Content Sheet (iOS: CreateContentSheet) ─────────────────────────
    if (showCreateSheet) {
        CreateContentSheet(
            onDismiss = { showCreateSheet = false },
            onCreate = { title, body, isPremium ->
                viewModel.createContent(title, body, isPremium)
                showCreateSheet = false
            }
        )
    }
}

// ─── iOS: Header Section ───────────────────────────────────────────────────────
@Composable
private fun ContentHeaderSection(
    onCreateClick: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = "Kontent",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = AppTheme.Colors.primaryText
            )
            Text(
                text = "Kontentinizi yaradin ve idare edin",
                fontSize = 14.sp,
                color = AppTheme.Colors.secondaryText
            )
        }

        // iOS: Button(action: showCreateSheet) { plus.circle.fill }
        Box(
            modifier = Modifier
                .size(44.dp)
                .background(
                    brush = Brush.linearGradient(
                        colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                    ),
                    shape = CircleShape
                )
                .clip(CircleShape)
                .clickable { onCreateClick() },
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Outlined.Add,
                contentDescription = "Kontent yarat",
                modifier = Modifier.size(22.dp),
                tint = Color.White
            )
        }
    }
}

// ─── iOS: ContentCard ──────────────────────────────────────────────────────────
@Composable
private fun ContentCard(
    content: ContentResponse,
    isOwner: Boolean = true,
    onDelete: () -> Unit = {}
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(16.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // iOS: HStack { avatar + name + date + Spacer + premium badge }
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            // Trainer avatar
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(
                        brush = Brush.linearGradient(
                            colors = listOf(
                                AppTheme.Colors.accent.copy(alpha = 0.3f),
                                AppTheme.Colors.accent
                            )
                        ),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = content.trainerName.take(1).uppercase(),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }

            // Name + date
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                Text(
                    text = content.trainerName.ifEmpty { "Mesqci" },
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AppTheme.Colors.primaryText,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = formatContentDate(content.createdAt),
                    fontSize = 11.sp,
                    color = AppTheme.Colors.tertiaryText
                )
            }

            // Premium badge
            if (content.isPremiumOnly) {
                Row(
                    modifier = Modifier
                        .background(
                            AppTheme.Colors.accent.copy(alpha = 0.15f),
                            RoundedCornerShape(8.dp)
                        )
                        .padding(horizontal = 8.dp, vertical = 4.dp),
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Star,
                        contentDescription = null,
                        modifier = Modifier.size(12.dp),
                        tint = AppTheme.Colors.accent
                    )
                    Text(
                        text = "Premium",
                        fontSize = 10.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = AppTheme.Colors.accent
                    )
                }
            }
        }

        // iOS: Title
        Text(
            text = content.title,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = AppTheme.Colors.primaryText
        )

        // iOS: Body text (optional)
        content.body?.let { body ->
            if (body.isNotBlank()) {
                Text(
                    text = body,
                    fontSize = 14.sp,
                    color = AppTheme.Colors.secondaryText,
                    lineHeight = 20.sp
                )
            }
        }

        // iOS: Delete button (only for owner)
        if (isOwner) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                Row(
                    modifier = Modifier
                        .background(
                            AppTheme.Colors.error.copy(alpha = 0.1f),
                            RoundedCornerShape(8.dp)
                        )
                        .clip(RoundedCornerShape(8.dp))
                        .clickable { onDelete() }
                        .padding(horizontal = 12.dp, vertical = 6.dp),
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Delete,
                        contentDescription = "Sil",
                        modifier = Modifier.size(14.dp),
                        tint = AppTheme.Colors.error
                    )
                    Text(
                        text = "Sil",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = AppTheme.Colors.error
                    )
                }
            }
        }
    }
}

// ─── iOS: Empty Content Section ────────────────────────────────────────────────
@Composable
private fun ContentEmptySection(
    onCreateClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(16.dp))
            .padding(horizontal = 20.dp, vertical = 40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // iOS: Image(systemName: "doc.text") — large icon
        Box(
            modifier = Modifier
                .size(80.dp)
                .background(
                    AppTheme.Colors.accent.copy(alpha = 0.1f),
                    CircleShape
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Outlined.Article,
                contentDescription = null,
                modifier = Modifier.size(36.dp),
                tint = AppTheme.Colors.accent.copy(alpha = 0.6f)
            )
        }

        Text(
            text = "Hec bir kontent yoxdur",
            fontSize = 17.sp,
            fontWeight = FontWeight.SemiBold,
            color = AppTheme.Colors.primaryText
        )

        Text(
            text = "Telebeleriniz ucun kontent yaradaraq baslayin. Meqaleler, gosterisler ve diger mezmunlar paylasa bilersiniz.",
            fontSize = 13.sp,
            color = AppTheme.Colors.secondaryText,
            textAlign = TextAlign.Center,
            lineHeight = 18.sp
        )

        // iOS: Button("Kontent yarat")
        Button(
            onClick = onCreateClick,
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = AppTheme.Colors.accent
            )
        ) {
            Icon(
                imageVector = Icons.Outlined.Add,
                contentDescription = null,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "Kontent yarat",
                fontWeight = FontWeight.SemiBold,
                fontSize = 15.sp
            )
        }
    }
}

// ─── iOS: CreateContentSheet ───────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CreateContentSheet(
    onDismiss: () -> Unit,
    onCreate: (title: String, body: String?, isPremiumOnly: Boolean) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var body by remember { mutableStateOf("") }
    var isPremiumOnly by remember { mutableStateOf(true) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = AppTheme.Colors.background,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppTheme.Colors.secondaryText) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .padding(bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // iOS: Navigation title + Cancel button
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                TextButton(onClick = onDismiss) {
                    Text("Legv et", color = AppTheme.Colors.secondaryText)
                }
                Text(
                    text = "Yeni Kontent",
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppTheme.Colors.primaryText
                )
                // Spacer for balance
                Box(modifier = Modifier.width(60.dp))
            }

            // iOS: Title field
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Baslik",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium,
                    color = AppTheme.Colors.secondaryText
                )
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    placeholder = { Text("Kontent basligini daxil edin", color = AppTheme.Colors.placeholderText) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedContainerColor = AppTheme.Colors.secondaryBackground,
                        unfocusedContainerColor = AppTheme.Colors.secondaryBackground,
                        cursorColor = AppTheme.Colors.accent,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText
                    ),
                    singleLine = true
                )
            }

            // iOS: Body field (TextEditor, height: 150)
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Mezmun",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium,
                    color = AppTheme.Colors.secondaryText
                )
                OutlinedTextField(
                    value = body,
                    onValueChange = { body = it },
                    placeholder = { Text("Kontent mezmununu daxil edin (istege bagli)", color = AppTheme.Colors.placeholderText) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(150.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AppTheme.Colors.accent,
                        unfocusedBorderColor = AppTheme.Colors.separator,
                        focusedContainerColor = AppTheme.Colors.secondaryBackground,
                        unfocusedContainerColor = AppTheme.Colors.secondaryBackground,
                        cursorColor = AppTheme.Colors.accent,
                        focusedTextColor = AppTheme.Colors.primaryText,
                        unfocusedTextColor = AppTheme.Colors.primaryText
                    ),
                    maxLines = 8
                )
            }

            // iOS: Premium Toggle — crown icon + toggle
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppTheme.Colors.secondaryBackground, RoundedCornerShape(12.dp))
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Icon(
                    imageVector = Icons.Outlined.Star,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = AppTheme.Colors.accent
                )
                Text(
                    text = "Yalniz Premium",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Medium,
                    color = AppTheme.Colors.primaryText,
                    modifier = Modifier.weight(1f)
                )
                Switch(
                    checked = isPremiumOnly,
                    onCheckedChange = { isPremiumOnly = it },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = Color.White,
                        checkedTrackColor = AppTheme.Colors.accent,
                        uncheckedThumbColor = AppTheme.Colors.secondaryText,
                        uncheckedTrackColor = AppTheme.Colors.cardBackground
                    )
                )
            }

            // iOS: Submit button
            Button(
                onClick = {
                    onCreate(title, body.ifBlank { null }, isPremiumOnly)
                },
                enabled = title.isNotBlank(),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = AppTheme.Colors.accent,
                    disabledContainerColor = AppTheme.Colors.accent.copy(alpha = 0.3f)
                )
            ) {
                Text(
                    text = "Yarat",
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp,
                    color = if (title.isNotBlank()) Color.White else Color.White.copy(alpha = 0.5f)
                )
            }
        }
    }
}

// ─── Helper: Format date ───────────────────────────────────────────────────────
private fun formatContentDate(dateStr: String?): String {
    if (dateStr.isNullOrBlank()) return ""
    return try {
        val inputFormats = listOf(
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS", Locale.getDefault()),
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault()),
            SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        )
        val outputFormat = SimpleDateFormat("dd MMM yyyy, HH:mm", Locale.getDefault())
        for (fmt in inputFormats) {
            try {
                val date = fmt.parse(dateStr)
                if (date != null) return outputFormat.format(date)
            } catch (_: Exception) { }
        }
        dateStr.take(10)
    } catch (_: Exception) {
        dateStr.take(10)
    }
}
