package life.corevia.app.ui.navigation

import life.corevia.app.ui.theme.AppTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import life.corevia.app.data.api.TokenManager
import life.corevia.app.ui.auth.AuthViewModel
import life.corevia.app.ui.auth.ForgotPasswordScreen
import life.corevia.app.ui.auth.LoginScreen
import life.corevia.app.ui.auth.RegisterScreen
import life.corevia.app.ui.food.FoodScreen
import life.corevia.app.ui.food.FoodViewModel
import life.corevia.app.ui.home.HomeScreen
import life.corevia.app.ui.trainingplan.TrainingPlanScreen
import life.corevia.app.ui.trainingplan.TrainingPlanViewModel
import life.corevia.app.ui.workout.WorkoutScreen
import life.corevia.app.ui.workout.WorkoutViewModel

/**
 * iOS: ContentView + MainTabView + CustomTabBar
 * Android 1-ə-1 port — glassmorphism tab bar, trainer/client dinamik tab
 */

// ─── Route sabitləri ──────────────────────────────────────────────────────────
object Routes {
    const val LOGIN           = "login"
    const val REGISTER        = "register"
    const val HOME            = "home"
    const val WORKOUT         = "workout"
    const val FOOD            = "food"
    const val TRAINING_PLAN   = "training_plan"
    const val LIVE_TRACKING   = "live_tracking"
    const val PROFILE         = "profile"
    const val SETTINGS        = "settings"
    const val CHAT            = "chat"
    const val FORGOT_PASSWORD = "forgot_password"
    const val TRAINER_HOME    = "trainer_home"
    const val MY_STUDENTS     = "my_students"
    const val MEAL_PLAN       = "meal_plan"
    const val ACTIVITIES      = "activities"
}

// ─── Tab indeksləri (iOS selectedTab ilə eyni) ────────────────────────────────
private const val TAB_HOME     = 0
private const val TAB_WORKOUT  = 1   // trainer: training plans
private const val TAB_FOOD     = 2   // trainer: meal plans
private const val TAB_CHAT     = 3
private const val TAB_MORE     = 4   // activities / content

// ─── Ana composable ───────────────────────────────────────────────────────────
@Composable
fun AppNavigation(tokenManager: TokenManager) {
    val navController = rememberNavController()
    val startDestination = if (tokenManager.isLoggedIn) Routes.HOME else Routes.LOGIN

    val authViewModel: AuthViewModel           = viewModel()
    val workoutViewModel: WorkoutViewModel     = viewModel()
    val foodViewModel: FoodViewModel           = viewModel()
    val trainingPlanViewModel: TrainingPlanViewModel = viewModel()

    NavHost(
        navController    = navController,
        startDestination = startDestination,
        modifier         = Modifier.fillMaxSize()
    ) {
        // ── Auth ──────────────────────────────────────────────────────────────
        composable(Routes.LOGIN) {
            LoginScreen(
                onLoginSuccess             = { navController.navigateToMain() },
                onNavigateToRegister       = { navController.navigate(Routes.REGISTER) },
                onNavigateToForgotPassword = { navController.navigate(Routes.FORGOT_PASSWORD) },
                viewModel                  = authViewModel
            )
        }
        composable(Routes.REGISTER) {
            RegisterScreen(
                onRegisterSuccess = { navController.navigateToMain() },
                onNavigateToLogin = { navController.popBackStack() },
                viewModel         = authViewModel
            )
        }
        composable(Routes.FORGOT_PASSWORD) {
            ForgotPasswordScreen(onBack = { navController.popBackStack() })
        }

        // ── Main (iOS: MainTabView) ───────────────────────────────────────────
        composable(Routes.HOME) {
            MainTabView(
                navController        = navController,
                workoutViewModel     = workoutViewModel,
                foodViewModel        = foodViewModel,
                trainingPlanViewModel = trainingPlanViewModel,
                isTrainer            = false   // TODO: tokenManager-dan al
            )
        }
    }
}

// ─── iOS: MainTabView ─────────────────────────────────────────────────────────
@Composable
fun MainTabView(
    navController: NavHostController,
    workoutViewModel: WorkoutViewModel,
    foodViewModel: FoodViewModel,
    trainingPlanViewModel: TrainingPlanViewModel,
    isTrainer: Boolean = false
) {
    var selectedTab by remember { mutableStateOf(TAB_HOME) }

    Box(modifier = Modifier.fillMaxSize()) {

        // ── Tab content (iOS switch selectedTab) ──────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 80.dp)   // tab bar üçün yer
        ) {
            when (selectedTab) {
                TAB_HOME -> {
                    HomeScreen(
                        onNavigateToWorkout      = { selectedTab = TAB_WORKOUT },
                        onNavigateToFood         = { selectedTab = TAB_FOOD },
                        onNavigateToTrainingPlan = { selectedTab = TAB_WORKOUT },
                        onNavigateToLiveTracking = { selectedTab = TAB_MORE },
                        workoutViewModel         = workoutViewModel
                    )
                }
                TAB_WORKOUT -> {
                    if (isTrainer) {
                        TrainingPlanScreen(viewModel = trainingPlanViewModel)
                    } else {
                        WorkoutScreen(
                            onNavigateToLiveTracking = { selectedTab = TAB_MORE },
                            viewModel                = workoutViewModel
                        )
                    }
                }
                TAB_FOOD -> {
                    if (isTrainer) {
                        PlaceholderScreen("Qida Planları", "🍽️")
                    } else {
                        FoodScreen(viewModel = foodViewModel)
                    }
                }
                TAB_CHAT -> {
                    PlaceholderScreen("Mesajlar", "💬")
                }
                TAB_MORE -> {
                    if (isTrainer) {
                        PlaceholderScreen("Kontent", "📄")
                    } else {
                        PlaceholderScreen("Aktivliklər", "🏃")
                    }
                }
                5 -> PlaceholderScreen("Profil", "👤")
            }
        }

        // ── iOS: CustomTabBar ─────────────────────────────────────────────────
        CoreViaTabBar(
            selectedTab = selectedTab,
            isTrainer   = isTrainer,
            onTabSelect = { selectedTab = it },
            modifier    = Modifier.align(Alignment.BottomCenter)
        )
    }
}

// ─── iOS: CustomTabBar ────────────────────────────────────────────────────────
// Glassmorphism + animated selected circle + "More" sheet
@Composable
fun CoreViaTabBar(
    selectedTab: Int,
    isTrainer: Boolean,
    onTabSelect: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    var showMoreSheet by remember { mutableStateOf(false) }

    // iOS: HStack tab bar
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 0.dp)
            .padding(bottom = 8.dp)
            .shadow(10.dp, RoundedCornerShape(24.dp), ambientColor = Color.Black.copy(alpha = 0.1f))
            .background(
                brush = Brush.linearGradient(
                    colors = listOf(
                        AppTheme.Colors.accent.copy(alpha = 0.05f),
                        Color.Transparent
                    )
                ),
                shape = RoundedCornerShape(24.dp)
            )
            .background(
                // glassmorphism — dark semi-transparent
                color = Color(0xFF1C1C1E).copy(alpha = 0.95f),
                shape = RoundedCornerShape(24.dp)
            )
            .padding(horizontal = 8.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceAround
    ) {
        // Tab 0: Home
        TabBarItem(
            icon       = Icons.Filled.Home,
            label      = "Əsas",
            isSelected = selectedTab == TAB_HOME,
            onClick    = { onTabSelect(TAB_HOME) }
        )

        // Tab 1: Workout / Plans
        TabBarItem(
            icon       = Icons.Filled.Star,
            label      = if (isTrainer) "Planlar" else "Məşq",
            isSelected = selectedTab == TAB_WORKOUT,
            onClick    = { onTabSelect(TAB_WORKOUT) }
        )

        // Tab 2: Food / Meal Plans
        TabBarItem(
            icon       = Icons.Filled.Favorite,
            label      = if (isTrainer) "Qida Plan" else "Qida",
            isSelected = selectedTab == TAB_FOOD,
            onClick    = { onTabSelect(TAB_FOOD) }
        )

        // Tab 3: Chat
        TabBarItem(
            icon       = Icons.Filled.Email,
            label      = "Mesajlar",
            isSelected = selectedTab == TAB_CHAT,
            onClick    = { onTabSelect(TAB_CHAT) }
        )

        // Tab 4: More (iOS: TabBarMoreButton with sheet)
        TabBarMoreButton(
            isSelected = selectedTab >= TAB_MORE,
            onClick    = { showMoreSheet = true }
        )
    }

    // iOS: MoreMenuSheet — .sheet(isPresented:)
    if (showMoreSheet) {
        MoreMenuSheet(
            isTrainer   = isTrainer,
            onDismiss   = { showMoreSheet = false },
            onActivities = {
                showMoreSheet = false
                onTabSelect(TAB_MORE)
            },
            onProfile   = {
                showMoreSheet = false
                onTabSelect(5)
            }
        )
    }
}

// ─── iOS: TabBarItem ──────────────────────────────────────────────────────────
@Composable
fun TabBarItem(
    icon: ImageVector,
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }

    Column(
        modifier = Modifier
            .clickable(
                interactionSource = interactionSource,
                indication        = null
            ) { onClick() }
            .padding(horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // iOS: ZStack { Circle + Image }
        Box(
            modifier = Modifier
                .size(40.dp),
            contentAlignment = Alignment.Center
        ) {
            // iOS: if isSelected → Circle().fill(accent)
            if (isSelected) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .background(AppTheme.Colors.accent, CircleShape)
                )
            }
            Icon(
                imageVector = icon,
                contentDescription = label,
                modifier = Modifier.size(if (isSelected) 20.dp else 18.dp),
                tint = if (isSelected) Color.White else AppTheme.Colors.secondaryText
            )
        }

        // iOS: Text label
        Text(
            text       = label,
            fontSize   = 10.sp,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
            color      = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.tertiaryText
        )
    }
}

// ─── iOS: TabBarMoreButton ────────────────────────────────────────────────────
@Composable
fun TabBarMoreButton(
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }

    Column(
        modifier = Modifier
            .clickable(
                interactionSource = interactionSource,
                indication        = null
            ) { onClick() }
            .padding(horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier.size(40.dp),
            contentAlignment = Alignment.Center
        ) {
            if (isSelected) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .background(
                            brush = Brush.linearGradient(
                                colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                            ),
                            shape = CircleShape
                        )
                )
            }
            Icon(
                imageVector        = Icons.Filled.MoreVert,
                contentDescription = "Daha çox",
                modifier           = Modifier.size(if (isSelected) 20.dp else 18.dp),
                tint               = if (isSelected) Color.White else AppTheme.Colors.secondaryText
            )
        }
        Text(
            text       = "Daha çox",
            fontSize   = 10.sp,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
            color      = if (isSelected) AppTheme.Colors.accent else AppTheme.Colors.tertiaryText
        )
    }
}

// ─── iOS: MoreMenuSheet ───────────────────────────────────────────────────────
// iOS: .sheet(isPresented:) { MoreMenuSheet } .presentationDetents([.medium])
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MoreMenuSheet(
    isTrainer: Boolean,
    onDismiss: () -> Unit,
    onActivities: () -> Unit,
    onProfile: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest    = onDismiss,
        sheetState          = rememberModalBottomSheetState(),
        containerColor      = AppTheme.Colors.background,
        dragHandle          = { BottomSheetDefaults.DragHandle(color = AppTheme.Colors.secondaryText) }
    ) {
        Column(
            modifier            = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .padding(bottom = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // iOS: Header — blur circle + "···" icon
            Spacer(modifier = Modifier.height(20.dp))
            Box(contentAlignment = Alignment.Center) {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .background(
                            brush = Brush.radialGradient(
                                colors = listOf(
                                    AppTheme.Colors.accent.copy(alpha = 0.2f),
                                    Color.Transparent
                                )
                            ),
                            shape = CircleShape
                        )
                        .blur(20.dp)
                )
                Box(
                    modifier = Modifier
                        .size(70.dp)
                        .background(
                            Color(0xFF2C2C2E),
                            CircleShape
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector        = Icons.Filled.MoreVert,
                        contentDescription = null,
                        modifier           = Modifier.size(28.dp),
                        tint               = AppTheme.Colors.accent
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text       = "Daha çox",
                fontSize   = 24.sp,
                fontWeight = FontWeight.Bold,
                color      = AppTheme.Colors.primaryText
            )
            Spacer(modifier = Modifier.height(24.dp))

            // iOS: Activities / Content menu item
            MoreMenuItem(
                icon        = if (isTrainer) Icons.Filled.List else Icons.Filled.PlayArrow,
                title       = if (isTrainer) "Kontent" else "Aktivliklər",
                description = if (isTrainer) "Kontent idarə et" else "GPS məşq izləmə",
                gradientColors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark),
                onClick     = onActivities
            )

            Spacer(modifier = Modifier.height(16.dp))

            // iOS: Profile menu item
            MoreMenuItem(
                icon        = Icons.Filled.Person,
                title       = "Profil",
                description = "Hesabınızı idarə edin",
                gradientColors = listOf(Color(0xFF34C759), Color(0xFF34C759).copy(alpha = 0.7f)),
                onClick     = onProfile
            )

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

// ─── iOS: MoreMenuItem ────────────────────────────────────────────────────────
@Composable
fun MoreMenuItem(
    icon: ImageVector,
    title: String,
    description: String,
    gradientColors: List<Color>,
    onClick: () -> Unit
) {
    var isPressed by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(Color(0xFF2C2C2E))
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = {
                        isPressed = true
                        tryAwaitRelease()
                        isPressed = false
                    },
                    onTap = { onClick() }
                )
            }
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // iOS: glassmorphism icon circle
            Box(contentAlignment = Alignment.Center) {
                Box(
                    modifier = Modifier
                        .size(60.dp)
                        .background(
                            brush = Brush.linearGradient(
                                colors = listOf(
                                    gradientColors[0].copy(alpha = 0.2f),
                                    gradientColors[1].copy(alpha = 0.1f)
                                )
                            ),
                            shape = CircleShape
                        )
                )
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .background(Color(0xFF3A3A3C), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector        = icon,
                        contentDescription = null,
                        modifier           = Modifier.size(24.dp),
                        tint               = gradientColors[0]
                    )
                }
            }

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text       = title,
                    fontSize   = 18.sp,
                    fontWeight = FontWeight.SemiBold,
                    color      = AppTheme.Colors.primaryText
                )
                Text(
                    text     = description,
                    fontSize = 13.sp,
                    color    = AppTheme.Colors.secondaryText
                )
            }

            Icon(
                imageVector        = Icons.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint               = AppTheme.Colors.tertiaryText,
                modifier           = Modifier.size(16.dp)
            )
        }
    }
}

// ─── Placeholder ──────────────────────────────────────────────────────────────
@Composable
fun PlaceholderScreen(title: String, emoji: String) {
    Box(
        modifier         = Modifier
            .fillMaxSize()
            .background(AppTheme.Colors.background),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(text = emoji, fontSize = 64.sp)
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text       = title,
                color      = Color.White,
                fontSize   = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text  = "Tezliklə...",
                color = AppTheme.Colors.secondaryText,
                fontSize = 14.sp
            )
        }
    }
}

// ─── Extension ────────────────────────────────────────────────────────────────
private fun NavHostController.navigateToMain() {
    navigate(Routes.HOME) {
        popUpTo(0) { inclusive = true }
    }
}
