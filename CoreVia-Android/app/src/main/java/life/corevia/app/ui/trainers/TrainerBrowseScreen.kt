package life.corevia.app.ui.trainers

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
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
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.data.model.TrainerCategory
import life.corevia.app.data.model.TrainerResponse
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrainerBrowseScreen(
    onBack: () -> Unit,
    onTrainerClick: (String) -> Unit = {},
    viewModel: TrainerBrowseViewModel = hiltViewModel()
) {
    val state by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Trenerlər", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Geri")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(horizontal = 20.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Search ──
            item {
                OutlinedTextField(
                    value = state.searchQuery,
                    onValueChange = viewModel::updateSearch,
                    placeholder = { Text("Trener axtar...", color = TextHint) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(14.dp),
                    singleLine = true,
                    leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null, tint = TextSecondary) },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CoreViaPrimary,
                        unfocusedBorderColor = TextSeparator
                    )
                )
            }

            // ── Stats ──
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    StatBadge("${state.trainerCount} Trener", CatFitness, Modifier.weight(1f))
                    StatBadge(
                        if (state.avgRating > 0) "%.1f Ortalama".format(state.avgRating) else "—",
                        StarFilled,
                        Modifier.weight(1f)
                    )
                }
            }

            // ── Category Filter ──
            item {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    item {
                        FilterChip(
                            selected = state.selectedCategory == null,
                            onClick = { viewModel.selectCategory(null) },
                            label = { Text("Hamisi") },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = CoreViaPrimary,
                                selectedLabelColor = Color.White
                            )
                        )
                    }
                    items(TrainerCategory.entries.toList()) { cat ->
                        FilterChip(
                            selected = state.selectedCategory == cat,
                            onClick = { viewModel.selectCategory(cat) },
                            label = { Text(cat.displayName) },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = cat.color,
                                selectedLabelColor = Color.White
                            )
                        )
                    }
                }
            }

            // ── Loading ──
            if (state.isLoading) {
                item {
                    Box(modifier = Modifier.fillMaxWidth().padding(40.dp), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = CoreViaPrimary)
                    }
                }
            }

            // ── Empty ──
            if (!state.isLoading && state.filteredTrainers.isEmpty()) {
                item {
                    Column(
                        modifier = Modifier.fillMaxWidth().padding(60.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(Icons.Filled.PersonSearch, contentDescription = null, modifier = Modifier.size(48.dp), tint = TextHint)
                        Spacer(modifier = Modifier.height(12.dp))
                        Text("Trener tapilmadi", fontSize = 16.sp, color = TextSecondary, textAlign = TextAlign.Center)
                    }
                }
            }

            // ── Trainer Cards ──
            items(state.filteredTrainers) { trainer ->
                TrainerCard(
                    trainer = trainer,
                    isAssigning = state.assigningTrainerId == trainer.id,
                    onAssign = { viewModel.assignTrainer(trainer.id) },
                    onClick = { onTrainerClick(trainer.id) }
                )
            }

            item { Spacer(modifier = Modifier.height(20.dp)) }
        }

        // Success snackbar
        if (state.assignSuccess) {
            LaunchedEffect(Unit) {
                viewModel.clearError()
            }
        }
    }
}

@Composable
private fun StatBadge(text: String, color: Color, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = color.copy(alpha = 0.1f))
    ) {
        Text(
            text = text,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
            fontWeight = FontWeight.SemiBold,
            fontSize = 14.sp,
            color = color
        )
    }
}

@Composable
private fun TrainerCard(
    trainer: TrainerResponse,
    isAssigning: Boolean,
    onAssign: () -> Unit,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(modifier = Modifier.padding(16.dp)) {
            // Avatar
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            listOf(
                                trainer.detectedCategory.color,
                                trainer.detectedCategory.color.copy(alpha = 0.6f)
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = trainer.initials,
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(trainer.fullName, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = TextPrimary)
                    if (trainer.isVerified) {
                        Spacer(modifier = Modifier.width(4.dp))
                        Icon(Icons.Filled.Verified, contentDescription = "Verified", tint = CoreViaInfo, modifier = Modifier.size(16.dp))
                    }
                }

                trainer.specialization?.let {
                    Text(it, fontSize = 13.sp, color = TextSecondary, maxLines = 1, overflow = TextOverflow.Ellipsis)
                }

                Spacer(modifier = Modifier.height(6.dp))

                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    // Rating
                    trainer.rating?.let { rating ->
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Filled.Star, contentDescription = null, tint = StarFilled, modifier = Modifier.size(14.dp))
                            Spacer(modifier = Modifier.width(2.dp))
                            Text("%.1f".format(rating), fontSize = 12.sp, color = TextSecondary)
                        }
                    }
                    // Experience
                    trainer.experienceYears?.let { exp ->
                        Text("$exp il", fontSize = 12.sp, color = TextSecondary)
                    }
                    // Price
                    trainer.displayPrice.let { if (it.isNotEmpty()) Text(it, fontSize = 12.sp, color = CoreViaPrimary, fontWeight = FontWeight.SemiBold) }
                }
            }

            // Assign button
            FilledTonalButton(
                onClick = onAssign,
                enabled = !isAssigning,
                shape = RoundedCornerShape(10.dp),
                colors = ButtonDefaults.filledTonalButtonColors(containerColor = CoreViaPrimary.copy(alpha = 0.1f)),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
            ) {
                if (isAssigning) {
                    CircularProgressIndicator(modifier = Modifier.size(16.dp), strokeWidth = 2.dp, color = CoreViaPrimary)
                } else {
                    Text("Sec", fontSize = 12.sp, color = CoreViaPrimary, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}
