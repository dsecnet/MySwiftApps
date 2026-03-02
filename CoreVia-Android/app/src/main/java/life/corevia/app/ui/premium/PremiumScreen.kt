package life.corevia.app.ui.premium

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.ui.theme.*

/**
 * iOS PremiumView.swift equivalent
 * Premium aktiv/deaktiv vəziyyətinə görə fərqli görünüş
 */
@Composable
fun PremiumScreen(
    viewModel: PremiumViewModel = hiltViewModel(),
    onBack: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(bottom = 40.dp)
    ) {
        // ── Top Bar ──
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 16.dp, end = 16.dp, top = 50.dp, bottom = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "PREMIUM",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = "Bağla",
                modifier = Modifier.clickable(onClick = onBack),
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium,
                color = CoreViaPrimary
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        Column(
            modifier = Modifier.padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            if (uiState.isPremium) {
                // ══════════════════════════════════════════════════════════
                // PREMIUM AKTİV — iOS PremiumView (isPremium == true)
                // ══════════════════════════════════════════════════════════
                PremiumActiveHeader()
                PlanInfoCard(planName = uiState.planName, planPrice = uiState.planPrice)
                CancelPremiumButton()
            } else {
                // ══════════════════════════════════════════════════════════
                // PREMIUM DEAKTİV — Plan seçimi
                // ══════════════════════════════════════════════════════════
                PremiumInactiveHeader()
                PricingCard(
                    title = "Aylıq Plan",
                    price = uiState.monthlyPrice,
                    isPopular = false,
                    onClick = {}
                )
                PricingCard(
                    title = "İllik Plan",
                    price = uiState.yearlyPrice,
                    isPopular = true,
                    badge = "25% endirim",
                    onClick = {}
                )
            }

            // ── Premium Xüsusiyyətlər ──
            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "Premium Xüsusiyyətlər",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )

            uiState.features.forEach { feature ->
                PremiumFeatureCard(feature = feature)
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// PREMIUM AKTİV HEADER — iOS crown + gradient
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun PremiumActiveHeader() {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Crown icon with gradient circle
        Box(
            modifier = Modifier
                .size(100.dp)
                .shadow(
                    20.dp, CircleShape,
                    ambientColor = CoreViaPrimary.copy(alpha = 0.3f),
                    spotColor = CoreViaPrimary.copy(alpha = 0.3f)
                )
                .clip(CircleShape)
                .background(
                    Brush.linearGradient(
                        listOf(PremiumGradientStart, PremiumGradientEnd)
                    )
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.Star,
                contentDescription = null,
                modifier = Modifier.size(48.dp),
                tint = Color(0xFFFFD700) // Gold
            )
        }

        Text(
            text = "Premium Aktiv",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )

        Text(
            text = "Bütün premium funksiyalara tam giriş",
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// PLAN INFO CARD
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun PlanInfoCard(planName: String, planPrice: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "Plan:",
                fontSize = 15.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = planName,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "Qiymət:",
                fontSize = 15.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = planPrice,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// CANCEL PREMIUM BUTTON
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun CancelPremiumButton() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .border(1.dp, CoreViaError, RoundedCornerShape(12.dp))
            .clickable { /* show cancel alert */ }
            .padding(16.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "Premium-i ləğv et",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = CoreViaError
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// PREMIUM INACTIVE HEADER — non-premium state
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun PremiumInactiveHeader() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(
                Brush.verticalGradient(
                    listOf(PremiumGradientStart, PremiumGradientEnd)
                )
            )
            .padding(start = 20.dp, end = 20.dp, top = 32.dp, bottom = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Box(
            modifier = Modifier
                .size(72.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.2f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.Star,
                contentDescription = null,
                tint = Color(0xFFFFD700),
                modifier = Modifier.size(40.dp)
            )
        }

        Text(
            text = "CoreVia Premium",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )

        Text(
            text = "Bütün premium özəllikləri açın və\nfitness səyahətinizi sürətləndirin",
            fontSize = 14.sp,
            color = Color.White.copy(alpha = 0.8f),
            textAlign = TextAlign.Center,
            lineHeight = 20.sp
        )
    }
}

// ═══════════════════════════════════════════════════════════════════
// FEATURE CARD — iOS PremiumView feature rows
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun PremiumFeatureCard(feature: PremiumFeature) {
    val icon: ImageVector = when (feature.icon) {
        "route" -> Icons.Filled.Route
        "chat" -> Icons.AutoMirrored.Filled.Chat
        "camera" -> Icons.Filled.CameraAlt
        "trainer" -> Icons.Filled.People
        else -> Icons.Filled.Star
    }
    val color: Color = when (feature.icon) {
        "route" -> CoreViaSuccess
        "chat" -> CoreViaPrimary
        "camera" -> Color(0xFFFF9800)
        "trainer" -> AccentBlue
        else -> CoreViaPrimary
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            .padding(14.dp),
        horizontalArrangement = Arrangement.spacedBy(14.dp),
        verticalAlignment = Alignment.Top
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(14.dp))
                .background(color.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, tint = color, modifier = Modifier.size(24.dp))
        }

        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = feature.title,
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = feature.description,
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                lineHeight = 18.sp
            )
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// PRICING CARD — for non-premium plan selection
// ═══════════════════════════════════════════════════════════════════
@Composable
private fun PricingCard(
    title: String,
    price: String,
    isPopular: Boolean,
    badge: String? = null,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                if (isPopular) 8.dp else 4.dp,
                RoundedCornerShape(16.dp),
                ambientColor = if (isPopular) CoreViaPrimary.copy(alpha = 0.3f) else Color.Black.copy(alpha = 0.1f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(
                if (isPopular)
                    Brush.horizontalGradient(listOf(CoreViaPrimary, CoreViaPrimary.copy(alpha = 0.85f)))
                else
                    Brush.horizontalGradient(listOf(MaterialTheme.colorScheme.surface, MaterialTheme.colorScheme.surface))
            )
            .padding(20.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = title,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = if (isPopular) Color.White else MaterialTheme.colorScheme.onSurface
                    )
                    if (badge != null) {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(8.dp))
                                .background(Color(0xFFFFD700).copy(alpha = if (isPopular) 0.3f else 0.2f))
                                .padding(horizontal = 8.dp, vertical = 3.dp)
                        ) {
                            Text(
                                text = badge,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isPopular) Color(0xFFFFD700) else Color(0xFFFF9800)
                            )
                        }
                    }
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = price,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = if (isPopular) Color.White else CoreViaPrimary
                )
            }

            Button(
                onClick = onClick,
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (isPopular) Color.White else CoreViaPrimary
                )
            ) {
                Text(
                    text = "Seç",
                    fontWeight = FontWeight.Bold,
                    color = if (isPopular) CoreViaPrimary else Color.White
                )
            }
        }
    }
}
