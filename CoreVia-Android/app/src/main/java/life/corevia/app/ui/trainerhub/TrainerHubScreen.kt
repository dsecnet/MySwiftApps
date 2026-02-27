package life.corevia.app.ui.trainerhub

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import life.corevia.app.ui.theme.*

/**
 * iOS TrainerHubView equivalent
 * Məşqçi Hub — Sessiyalar | Marketplace segmented tabs
 */

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrainerHubScreen(
    onBack: () -> Unit = {},
    onNavigateToCreateSession: () -> Unit = {},
    onNavigateToCreateProduct: () -> Unit = {}
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabTitles = listOf("Sessiyalar", "Marketplace")

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Məşqçi Hub",
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Geri"
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
                .background(MaterialTheme.colorScheme.background)
                .padding(padding)
        ) {
            // ── Segmented Button Row — iOS style ──
            SingleChoiceSegmentedButtonRow(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = Layout.paddingM, vertical = Layout.spacingS)
            ) {
                tabTitles.forEachIndexed { index, title ->
                    SegmentedButton(
                        selected = selectedTab == index,
                        onClick = { selectedTab = index },
                        shape = SegmentedButtonDefaults.itemShape(
                            index = index,
                            count = tabTitles.size,
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
                            text = title,
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 14.sp
                        )
                    }
                }
            }

            // ── Content — swap based on selected tab ──
            when (selectedTab) {
                0 -> TrainerSessionsContent(
                    onNavigateToCreateSession = onNavigateToCreateSession
                )
                1 -> TrainerProductsContent(
                    onNavigateToCreateProduct = onNavigateToCreateProduct
                )
            }
        }
    }
}
