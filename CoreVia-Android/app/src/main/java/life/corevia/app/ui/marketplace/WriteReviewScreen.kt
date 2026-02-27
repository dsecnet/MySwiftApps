package life.corevia.app.ui.marketplace

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import life.corevia.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WriteReviewScreen(
    onBack: () -> Unit,
    viewModel: ProductDetailViewModel = hiltViewModel()
) {
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state.reviewSubmitted) {
        if (state.reviewSubmitted) onBack()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("R\u0259y Yaz", fontWeight = FontWeight.Bold) },
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
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            Spacer(modifier = Modifier.height(8.dp))

            // -- Product info --
            state.product?.let { product ->
                Text(
                    text = product.title,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = TextPrimary
                )
                Text(
                    text = product.displayPrice,
                    fontSize = 14.sp,
                    color = TextSecondary
                )
            }

            HorizontalDivider(color = TextSeparator)

            // -- Star Rating --
            Text(
                text = "Qiym\u0259tl\u0259ndirm\u0259",
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = TextSecondary
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                for (i in 1..5) {
                    Icon(
                        imageVector = Icons.Filled.Star,
                        contentDescription = "$i ulduz",
                        tint = if (i <= state.reviewRating) StarFilled else StarEmpty,
                        modifier = Modifier
                            .size(40.dp)
                            .clickable { viewModel.updateRating(i) }
                            .padding(4.dp)
                    )
                }
            }

            Text(
                text = "${state.reviewRating}/5",
                fontSize = 14.sp,
                color = TextSecondary,
                modifier = Modifier.align(Alignment.CenterHorizontally)
            )

            // -- Comment --
            Text(
                text = "R\u0259yiniz",
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = TextSecondary
            )

            OutlinedTextField(
                value = state.reviewComment,
                onValueChange = viewModel::updateComment,
                placeholder = { Text("R\u0259yinizi bura yazin...", color = TextHint) },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(150.dp),
                shape = RoundedCornerShape(12.dp),
                maxLines = 6,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = CoreViaPrimary,
                    unfocusedBorderColor = TextSeparator
                )
            )

            // -- Error --
            state.error?.let {
                Text(
                    text = it,
                    color = CoreViaError,
                    fontSize = 13.sp
                )
            }

            // -- Submit --
            Button(
                onClick = { viewModel.submitReview() },
                enabled = state.reviewComment.isNotBlank() && !state.isSubmitting,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CoreViaPrimary,
                    disabledContainerColor = CoreViaPrimary.copy(alpha = 0.4f)
                )
            ) {
                if (state.isSubmitting) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(22.dp),
                        color = Color.White,
                        strokeWidth = 2.dp
                    )
                } else {
                    Text(
                        "G\u00f6nd\u0259r",
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}
