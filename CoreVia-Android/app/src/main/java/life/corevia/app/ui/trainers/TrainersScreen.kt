package life.corevia.app.ui.trainers

import life.corevia.app.ui.theme.AppTheme
import life.corevia.app.ui.theme.CoreViaAnimatedBackground
import life.corevia.app.ui.theme.coreViaCard
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material.icons.automirrored.outlined.KeyboardArrowRight
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.data.models.UserResponse

/**
 * iOS: TrainersListView.swift — axtaris + filter chips + sort + trainer kartlari
 */
@Composable
fun TrainersScreen(
    viewModel: TrainersViewModel,
    onBack: () -> Unit,
    onTrainerSelected: (UserResponse) -> Unit
) {
    val trainers by viewModel.trainers.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()

    // Filter & Sort state
    var selectedSpecialty by remember { mutableStateOf<String?>(null) }
    var selectedSort by remember { mutableStateOf("rating") } // rating, price, experience

    val specialties = listOf(
        null to "Hamisi",
        "fitness" to "Fitness",
        "yoga" to "Yoga",
        "cardio" to "Kardio",
        "nutrition" to "Qidalanma",
        "strength" to "Guc"
    )

    val sortOptions = listOf(
        "rating" to "Reytinq",
        "price" to "Qiymet",
        "experience" to "Tecrube"
    )

    // Apply filters and sorting
    val filtered = remember(trainers, searchQuery, selectedSpecialty, selectedSort) {
        var result = if (searchQuery.isBlank()) trainers
        else trainers.filter { it.name.lowercase().contains(searchQuery.lowercase()) }

        // Filter by specialty
        if (selectedSpecialty != null) {
            result = result.filter {
                it.specialization?.lowercase()?.contains(selectedSpecialty!!.lowercase()) == true
            }
        }

        // Sort
        when (selectedSort) {
            "rating" -> result.sortedByDescending { it.rating ?: 0.0 }
            "price" -> result.sortedBy { it.pricePerSession ?: Double.MAX_VALUE }
            "experience" -> result.sortedByDescending { it.experience ?: 0 }
            else -> result
        }
    }

    CoreViaAnimatedBackground(accentColor = AppTheme.Colors.accent) {
    Box(
        modifier = Modifier
            .fillMaxSize()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // ── Header ──────────────────────────────────────────────────────────
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(
                                AppTheme.Colors.accent.copy(alpha = 0.15f),
                                Color.Transparent
                            )
                        )
                    )
                    .padding(horizontal = 16.dp)
                    .padding(top = 50.dp, bottom = 12.dp)
            ) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = onBack) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Outlined.ArrowBack,
                                contentDescription = "Geri",
                                tint = AppTheme.Colors.accent
                            )
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Muellimlər",
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Bold,
                            color = AppTheme.Colors.primaryText
                        )
                        Spacer(modifier = Modifier.weight(1f))
                        Text(
                            text = "${filtered.size} muellim",
                            fontSize = 13.sp,
                            color = AppTheme.Colors.secondaryText
                        )
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Search
                    OutlinedTextField(
                        value = searchQuery,
                        onValueChange = { viewModel.setSearchQuery(it) },
                        modifier = Modifier.fillMaxWidth(),
                        placeholder = {
                            Text("Muellim axtar...", color = AppTheme.Colors.placeholderText)
                        },
                        leadingIcon = {
                            Icon(
                                imageVector = Icons.Outlined.Search,
                                contentDescription = null,
                                tint = AppTheme.Colors.secondaryText
                            )
                        },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = AppTheme.Colors.primaryText,
                            unfocusedTextColor = AppTheme.Colors.primaryText,
                            cursorColor = AppTheme.Colors.accent,
                            focusedBorderColor = AppTheme.Colors.accent,
                            unfocusedBorderColor = AppTheme.Colors.separator,
                            focusedContainerColor = AppTheme.Colors.cardBackground,
                            unfocusedContainerColor = AppTheme.Colors.cardBackground
                        ),
                        shape = RoundedCornerShape(16.dp),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    // Specialty filter chips
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(rememberScrollState()),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        specialties.forEach { (value, label) ->
                            FilterChip(
                                selected = selectedSpecialty == value,
                                onClick = { selectedSpecialty = value },
                                label = { Text(label, fontSize = 13.sp) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = AppTheme.Colors.accent,
                                    selectedLabelColor = Color.White,
                                    containerColor = AppTheme.Colors.cardBackground,
                                    labelColor = AppTheme.Colors.secondaryText
                                ),
                                shape = RoundedCornerShape(12.dp)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    // Sort options
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.Sort,
                            contentDescription = null,
                            tint = AppTheme.Colors.secondaryText,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = "Siralama:",
                            fontSize = 13.sp,
                            color = AppTheme.Colors.secondaryText
                        )
                        sortOptions.forEach { (value, label) ->
                            val isSelected = selectedSort == value
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(
                                        if (isSelected) AppTheme.Colors.accent.copy(alpha = 0.15f)
                                        else Color.Transparent
                                    )
                                    .clickable { selectedSort = value }
                                    .padding(horizontal = 10.dp, vertical = 5.dp)
                            ) {
                                Text(
                                    text = label,
                                    fontSize = 12.sp,
                                    color = if (isSelected) AppTheme.Colors.accent
                                           else AppTheme.Colors.tertiaryText,
                                    fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
                                )
                            }
                        }
                    }
                }
            }

            // ── Content ─────────────────────────────────────────────────────────
            when {
                isLoading && trainers.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = AppTheme.Colors.accent)
                    }
                }
                filtered.isEmpty() -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(
                                imageVector = Icons.Outlined.FitnessCenter,
                                contentDescription = null,
                                tint = AppTheme.Colors.tertiaryText,
                                modifier = Modifier.size(64.dp)
                            )
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(
                                text = if (searchQuery.isNotBlank() || selectedSpecialty != null)
                                    "Netice tapilmadi" else "Muellim yoxdur",
                                color = AppTheme.Colors.primaryText,
                                fontSize = 18.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                            if (selectedSpecialty != null) {
                                Spacer(modifier = Modifier.height(8.dp))
                                TextButton(onClick = { selectedSpecialty = null }) {
                                    Text("Filtri sifirla", color = AppTheme.Colors.accent)
                                }
                            }
                        }
                    }
                }
                else -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        items(filtered, key = { it.id }) { trainer ->
                            ImprovedTrainerCard(
                                trainer = trainer,
                                onClick = {
                                    viewModel.selectTrainer(trainer)
                                    onTrainerSelected(trainer)
                                }
                            )
                        }
                        item { Spacer(modifier = Modifier.height(80.dp)) }
                    }
                }
            }
        }
    }
    } // CoreViaAnimatedBackground
}

@Composable
fun ImprovedTrainerCard(
    trainer: UserResponse,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(AppTheme.Colors.cardBackground)
            .clickable(onClick = onClick)
            .padding(16.dp)
    ) {
        Row(
            verticalAlignment = Alignment.Top,
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Avatar
            Box(
                modifier = Modifier
                    .size(60.dp)
                    .background(
                        brush = Brush.linearGradient(
                            colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                        ),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                val initials = trainer.name
                    .split(" ")
                    .take(2)
                    .mapNotNull { it.firstOrNull()?.uppercaseChar() }
                    .joinToString("")
                Text(
                    text = initials.ifEmpty { "?" },
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 20.sp
                )
            }

            Column(modifier = Modifier.weight(1f)) {
                // Name + verified badge
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = trainer.name,
                        fontSize = 17.sp,
                        fontWeight = FontWeight.Bold,
                        color = AppTheme.Colors.primaryText
                    )
                    if (trainer.verificationStatus == "verified") {
                        Spacer(modifier = Modifier.width(6.dp))
                        Icon(
                            imageVector = Icons.Filled.Verified,
                            contentDescription = "Dogrulanib",
                            tint = AppTheme.Colors.badgeVerified,
                            modifier = Modifier.size(16.dp)
                        )
                    }
                }

                // Specialization
                if (!trainer.specialization.isNullOrBlank()) {
                    Text(
                        text = trainer.specialization,
                        fontSize = 13.sp,
                        color = AppTheme.Colors.accent,
                        fontWeight = FontWeight.Medium
                    )
                }

                Spacer(modifier = Modifier.height(6.dp))

                // Rating stars
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(2.dp)
                ) {
                    val rating = trainer.rating ?: 0.0
                    repeat(5) { index ->
                        Icon(
                            imageVector = when {
                                index < rating.toInt() -> Icons.Filled.Star
                                index.toDouble() < rating -> Icons.Filled.Star
                                else -> Icons.Outlined.Star
                            },
                            contentDescription = null,
                            tint = if (index < kotlin.math.ceil(rating).toInt()) AppTheme.Colors.starFilled
                                   else AppTheme.Colors.starEmpty,
                            modifier = Modifier.size(16.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = String.format("%.1f", rating),
                        fontSize = 13.sp,
                        color = AppTheme.Colors.secondaryText,
                        fontWeight = FontWeight.Medium
                    )
                }

                Spacer(modifier = Modifier.height(6.dp))

                // Info row: experience + price
                Row(
                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    // Experience
                    trainer.experience?.let { exp ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Outlined.WorkHistory,
                                contentDescription = null,
                                tint = AppTheme.Colors.tertiaryText,
                                modifier = Modifier.size(14.dp)
                            )
                            Text(
                                text = "$exp il",
                                fontSize = 12.sp,
                                color = AppTheme.Colors.secondaryText
                            )
                        }
                    }

                    // Price
                    trainer.pricePerSession?.let { price ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Outlined.Payments,
                                contentDescription = null,
                                tint = AppTheme.Colors.tertiaryText,
                                modifier = Modifier.size(14.dp)
                            )
                            Text(
                                text = "${price.toInt()} AZN/seans",
                                fontSize = 12.sp,
                                color = AppTheme.Colors.secondaryText
                            )
                        }
                    }
                }
            }

            Icon(
                imageVector = Icons.AutoMirrored.Outlined.KeyboardArrowRight,
                contentDescription = null,
                tint = AppTheme.Colors.tertiaryText,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
}
