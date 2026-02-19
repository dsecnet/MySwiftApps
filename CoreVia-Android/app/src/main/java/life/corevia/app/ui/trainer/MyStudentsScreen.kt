package life.corevia.app.ui.trainer

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import life.corevia.app.data.models.UserResponse

/**
 * iOS MyStudentsView.swift — Android 1-ə-1 port
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MyStudentsScreen(
    onBack: () -> Unit,
    onNavigateToAddTrainingPlan: (String?) -> Unit = {},
    onNavigateToAddMealPlan: (String?) -> Unit = {},
    viewModel: MyStudentsViewModel = viewModel()
) {
    val students by viewModel.students.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()
    val filteredStudents = viewModel.filteredStudents

    var selectedStudent by remember { mutableStateOf<UserResponse?>(null) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background)
    ) {
        Spacer(modifier = Modifier.height(56.dp))

        // ─── Header ─────────────────────────────────────────────────────────
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, "Geri", tint = Color.White)
            }
            Text(
                text = "Studentlərim",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                modifier = Modifier.weight(1f)
            )
            // Student count badge
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = AppTheme.Colors.accent.copy(alpha = 0.2f)
            ) {
                Text(
                    text = "${students.size}",
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                    color = AppTheme.Colors.accent,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // ─── Search ─────────────────────────────────────────────────────────
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { viewModel.setSearchQuery(it) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            placeholder = { Text("Student axtar...", color = AppTheme.Colors.placeholderText) },
            leadingIcon = {
                Icon(Icons.Default.Search, null, tint = AppTheme.Colors.secondaryText)
            },
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = AppTheme.Colors.accent,
                unfocusedBorderColor = AppTheme.Colors.separator,
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White,
                cursorColor = AppTheme.Colors.accent
            ),
            shape = RoundedCornerShape(12.dp),
            singleLine = true
        )

        Spacer(modifier = Modifier.height(12.dp))

        // ─── Student list ───────────────────────────────────────────────────
        if (isLoading && students.isEmpty()) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = AppTheme.Colors.accent)
            }
        } else if (filteredStudents.isEmpty()) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(text = "👤", fontSize = 48.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = if (students.isEmpty()) "Hələ student yoxdur" else "Nəticə tapılmadı",
                        color = AppTheme.Colors.secondaryText,
                        fontSize = 16.sp
                    )
                }
            }
        } else {
            LazyColumn(
                contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(filteredStudents, key = { it.id }) { student ->
                    StudentCard(
                        student = student,
                        onClick = { selectedStudent = student }
                    )
                }
                item { Spacer(modifier = Modifier.height(80.dp)) }
            }
        }
    }

    // ─── Student Detail Sheet ───────────────────────────────────────────────
    selectedStudent?.let { student ->
        StudentDetailSheet(
            student = student,
            onDismiss = { selectedStudent = null },
            onCreateTrainingPlan = {
                selectedStudent = null
                onNavigateToAddTrainingPlan(student.id)
            },
            onCreateMealPlan = {
                selectedStudent = null
                onNavigateToAddMealPlan(student.id)
            }
        )
    }
}

@Composable
fun StudentCard(
    student: UserResponse,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Avatar
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .background(
                        brush = Brush.linearGradient(
                            listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                        ),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = student.name.firstOrNull()?.uppercase() ?: "?",
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp
                )
            }

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = student.name,
                    color = Color.White,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 15.sp
                )
                Text(
                    text = student.goal?.let {
                        when (it) {
                            "weight_loss" -> "Çəki itkisi"
                            "weight_gain" -> "Çəki artımı"
                            "muscle_gain" -> "Əzələ artımı"
                            "general_fitness" -> "Ümumi fitness"
                            else -> it
                        }
                    } ?: "Məqsəd təyin edilməyib",
                    color = AppTheme.Colors.secondaryText,
                    fontSize = 13.sp
                )
            }

            Icon(
                imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = AppTheme.Colors.tertiaryText,
                modifier = Modifier.size(16.dp)
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StudentDetailSheet(
    student: UserResponse,
    onDismiss: () -> Unit,
    onCreateTrainingPlan: () -> Unit,
    onCreateMealPlan: () -> Unit
) {
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
                .padding(bottom = 40.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Avatar
            Box(
                modifier = Modifier
                    .size(72.dp)
                    .background(
                        brush = Brush.linearGradient(
                            listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                        ),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = student.name.firstOrNull()?.uppercase() ?: "?",
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 28.sp
                )
            }
            Spacer(modifier = Modifier.height(12.dp))
            Text(text = student.name, color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Text(text = student.email, color = AppTheme.Colors.secondaryText, fontSize = 14.sp)

            Spacer(modifier = Modifier.height(20.dp))

            // Stats
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    StudentStatItem("Yaş", student.age?.toString() ?: "—")
                    StudentStatItem("Çəki", student.weight?.let { "${it.toInt()} kg" } ?: "—")
                    StudentStatItem("Boy", student.height?.let { "${it.toInt()} cm" } ?: "—")
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Məqsəd
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = AppTheme.Colors.secondaryBackground)
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(text = "🎯", fontSize = 20.sp)
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(text = "Məqsəd", color = AppTheme.Colors.secondaryText, fontSize = 12.sp)
                        Text(
                            text = student.goal?.let {
                                when (it) {
                                    "weight_loss" -> "Çəki itkisi"
                                    "weight_gain" -> "Çəki artımı"
                                    "muscle_gain" -> "Əzələ artımı"
                                    "general_fitness" -> "Ümumi fitness"
                                    else -> it
                                }
                            } ?: "Təyin edilməyib",
                            color = Color.White,
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 15.sp
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Action buttons
            Button(
                onClick = onCreateTrainingPlan,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.accent),
                shape = RoundedCornerShape(12.dp)
            ) {
                Icon(Icons.Default.Star, null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Məşq Planı Yarat", fontWeight = FontWeight.SemiBold)
            }

            Spacer(modifier = Modifier.height(8.dp))

            Button(
                onClick = onCreateMealPlan,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AppTheme.Colors.success),
                shape = RoundedCornerShape(12.dp)
            ) {
                Icon(Icons.Default.Favorite, null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Qida Planı Yarat", fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

@Composable
fun StudentStatItem(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = value, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 18.sp)
        Text(text = label, color = AppTheme.Colors.secondaryText, fontSize = 12.sp)
    }
}
