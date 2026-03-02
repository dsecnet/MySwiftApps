package life.corevia.app.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import life.corevia.app.ui.auth.ForgotPasswordScreen
import life.corevia.app.ui.auth.LoginScreen
import life.corevia.app.ui.chat.ConversationsScreen
import life.corevia.app.ui.food.FoodScreen
import life.corevia.app.ui.home.HomeScreen
import life.corevia.app.ui.premium.PremiumScreen
import life.corevia.app.ui.profile.EditProfileScreen
import life.corevia.app.ui.profile.ProfileScreen
import life.corevia.app.ui.route.RouteTrackingScreen
import life.corevia.app.ui.settings.SettingsScreen
import life.corevia.app.ui.workout.WorkoutScreen
import life.corevia.app.ui.route.GPSTrackingScreen
import life.corevia.app.ui.social.SocialFeedScreen
import life.corevia.app.ui.survey.DailySurveyScreen
import life.corevia.app.ui.plans.MealPlanScreen
import life.corevia.app.ui.plans.AddMealPlanScreen
import life.corevia.app.ui.aicalorie.AICalorieScreen
import life.corevia.app.ui.theme.*
import androidx.compose.ui.graphics.Color
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavType
import androidx.navigation.navArgument
import life.corevia.app.ui.auth.LoginViewModel
import life.corevia.app.ui.auth.RegisterScreen
import life.corevia.app.ui.chat.ChatDetailScreen
import life.corevia.app.ui.food.AddFoodScreen
import life.corevia.app.ui.home.TrainerHomeScreen
import life.corevia.app.ui.onboarding.OnboardingScreen
import life.corevia.app.ui.plans.AddTrainingPlanScreen
import life.corevia.app.ui.plans.TrainingPlanScreen
import life.corevia.app.ui.trainers.TrainerBrowseScreen
import life.corevia.app.ui.analytics.AnalyticsDashboardScreen
import life.corevia.app.ui.analytics.OverallStatsScreen
import life.corevia.app.ui.food.AICalorieHistoryScreen
import life.corevia.app.ui.marketplace.MarketplaceScreen
import life.corevia.app.ui.marketplace.WriteReviewScreen
import life.corevia.app.ui.social.CommentsScreen
import life.corevia.app.ui.social.CreatePostScreen
import life.corevia.app.ui.workout.AddWorkoutScreen
import life.corevia.app.ui.livesession.LiveSessionListScreen
import life.corevia.app.ui.livesession.LiveSessionDetailScreen
import life.corevia.app.ui.livesession.LiveWorkoutScreen
import life.corevia.app.ui.trainerhub.TrainerHubScreen
import life.corevia.app.ui.trainerhub.CreateProductScreen
import life.corevia.app.ui.trainerhub.CreateLiveSessionScreen
import life.corevia.app.ui.content.TrainerContentScreen
import life.corevia.app.ui.marketplace.ProductDetailScreen
import life.corevia.app.ui.auth.TrainerVerificationScreen
import life.corevia.app.ui.food.AICalorieResultScreen

sealed class Screen(val route: String) {
    data object Login : Screen("login")
    data object Register : Screen("register")
    data object ForgotPassword : Screen("forgot_password")
    data object Home : Screen("home")
    data object Workout : Screen("workout")
    data object Food : Screen("food")
    data object Messages : Screen("messages")
    data object More : Screen("more")
    data object Activities : Screen("activities")
    data object GPSTracking : Screen("gps_tracking")
    data object Social : Screen("social")
    data object Profile : Screen("profile")
    data object Premium : Screen("premium")
    data object Settings : Screen("settings")
    data object DailySurvey : Screen("daily_survey")
    data object MealPlans : Screen("meal_plans")
    data object AddMealPlan : Screen("add_meal_plan")
    data object AICalorie : Screen("ai_calorie")
    data object EditProfile : Screen("edit_profile")
    data object AddWorkout : Screen("add_workout")
    data object AddFood : Screen("add_food")
    data object ChatDetail : Screen("chat_detail/{userId}/{userName}") {
        fun createRoute(userId: String, userName: String) = "chat_detail/$userId/$userName"
    }
    data object TrainingPlans : Screen("training_plans")
    data object AddTrainingPlan : Screen("add_training_plan")
    data object TrainerBrowse : Screen("trainer_browse")
    data object Onboarding : Screen("onboarding")
    data object Analytics : Screen("analytics")
    data object OverallStats : Screen("overall_stats")
    data object CreatePost : Screen("create_post")
    data object Comments : Screen("comments/{postId}") {
        fun createRoute(postId: String) = "comments/$postId"
    }
    data object Marketplace : Screen("marketplace")
    data object WriteReview : Screen("write_review/{productId}") {
        fun createRoute(productId: String) = "write_review/$productId"
    }
    data object AICalorieHistory : Screen("ai_calorie_history")

    // ── New Routes ──
    data object LiveSessions : Screen("live_sessions")
    data object LiveSessionDetail : Screen("live_session_detail/{sessionId}") {
        fun createRoute(sessionId: String) = "live_session_detail/$sessionId"
    }
    data object LiveWorkout : Screen("live_workout/{sessionId}") {
        fun createRoute(sessionId: String) = "live_workout/$sessionId"
    }
    data object TrainerHub : Screen("trainer_hub")
    data object CreateProduct : Screen("create_product")
    data object CreateLiveSession : Screen("create_live_session")
    data object TrainerContent : Screen("trainer_content")
    data object ProductDetail : Screen("product_detail/{productId}") {
        fun createRoute(productId: String) = "product_detail/$productId"
    }
    data object TrainerVerification : Screen("trainer_verification")
    data object AICalorieResult : Screen("ai_calorie_result")
}

data class BottomNavItem(
    val screen: Screen,
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector
)

// Client bottom nav
val clientBottomNavItems = listOf(
    BottomNavItem(Screen.Home, "Əsas", Icons.Filled.Home, Icons.Outlined.Home),
    BottomNavItem(Screen.Workout, "Məşq", Icons.Filled.FitnessCenter, Icons.Outlined.FitnessCenter),
    BottomNavItem(Screen.Food, "Qida", Icons.Filled.Restaurant, Icons.Outlined.Restaurant),
    BottomNavItem(Screen.Messages, "Mesajlar", Icons.Filled.ChatBubble, Icons.Outlined.ChatBubble),
    BottomNavItem(Screen.More, "Daha çox", Icons.Filled.MoreHoriz, Icons.Outlined.MoreHoriz)
)

// Trainer bottom nav — iOS: Home, Plans, Meal Plans, Chat, More
val trainerBottomNavItems = listOf(
    BottomNavItem(Screen.Home, "Əsas", Icons.Filled.Dashboard, Icons.Outlined.Dashboard),
    BottomNavItem(Screen.TrainingPlans, "Planlar", Icons.Filled.FitnessCenter, Icons.Outlined.FitnessCenter),
    BottomNavItem(Screen.MealPlans, "Qida Planı", Icons.Filled.Restaurant, Icons.Outlined.Restaurant),
    BottomNavItem(Screen.Messages, "Mesajlar", Icons.Filled.ChatBubble, Icons.Outlined.ChatBubble),
    BottomNavItem(Screen.More, "Daha çox", Icons.Filled.MoreHoriz, Icons.Outlined.MoreHoriz)
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppNavigation() {
    // Check login status to determine start destination
    val loginViewModel: LoginViewModel = hiltViewModel()
    val loginState by loginViewModel.uiState.collectAsState()
    val startDestination = if (loginState.isLoggedIn) Screen.Home.route else Screen.Login.route

    // Determine user type for conditional UI
    val isTrainer = loginState.userType == "trainer"
    val bottomNavItems = if (isTrainer) trainerBottomNavItems else clientBottomNavItems

    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    // "Daha çox" bottom sheet state
    var showMoreSheet by remember { mutableStateOf(false) }
    val moreSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    // Bottom bar gizlənəcək ekranlar — yalnız login/auth ekranlarında gizlənir
    val hideBottomBarRoutes = listOf(Screen.Login.route, Screen.Register.route, Screen.ForgotPassword.route, Screen.Onboarding.route)
    val showBottomBar = currentDestination?.route !in hideBottomBarRoutes

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(
                    modifier = Modifier
                        .shadow(16.dp, RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp))
                        .clip(RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)),
                    containerColor = MaterialTheme.colorScheme.surface,
                    tonalElevation = 0.dp
                ) {
                    bottomNavItems.forEach { item ->
                        val selected = currentDestination?.hierarchy?.any { it.route == item.screen.route } == true
                        NavigationBarItem(
                            icon = {
                                Icon(
                                    if (selected) item.selectedIcon else item.unselectedIcon,
                                    contentDescription = item.label,
                                    modifier = Modifier.size(24.dp)
                                )
                            },
                            label = {
                                Text(
                                    item.label,
                                    fontSize = 11.sp,
                                    fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Normal
                                )
                            },
                            selected = selected,
                            onClick = {
                                if (item.screen == Screen.More) {
                                    // "Daha çox" — bottom sheet aç
                                    showMoreSheet = true
                                } else {
                                    navController.navigate(item.screen.route) {
                                        popUpTo(navController.graph.findStartDestination().id) {
                                            saveState = true
                                        }
                                        launchSingleTop = true
                                        restoreState = true
                                    }
                                }
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = Color.White,
                                selectedTextColor = CoreViaPrimary,
                                unselectedIconColor = TextSecondary,
                                unselectedTextColor = TextSecondary,
                                indicatorColor = CoreViaPrimary
                            )
                        )
                    }
                }
            }
        }
    ) { paddingValues ->

        // ── "Daha çox" Bottom Sheet ──────────────────────────────────
        if (showMoreSheet) {
            ModalBottomSheet(
                onDismissRequest = { showMoreSheet = false },
                sheetState = moreSheetState,
                shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp),
                containerColor = MaterialTheme.colorScheme.surface,
                dragHandle = {
                    Box(
                        modifier = Modifier
                            .padding(top = 12.dp, bottom = 8.dp)
                            .width(40.dp)
                            .height(4.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f))
                    )
                }
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp)
                        .padding(bottom = 40.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Header — iOS glassmorphism style
                    Box(
                        modifier = Modifier
                            .size(70.dp)
                            .clip(CircleShape)
                            .background(
                                Brush.linearGradient(
                                    listOf(
                                        CoreViaPrimary.copy(alpha = 0.15f),
                                        CoreViaPrimary.copy(alpha = 0.05f)
                                    )
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Filled.MoreHoriz,
                            contentDescription = null,
                            modifier = Modifier.size(28.dp),
                            tint = CoreViaPrimary
                        )
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = "Daha çox",
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    // iOS: Trainer → Trainer Hub + Profile
                    // iOS: Client → Activities + Profile
                    if (isTrainer) {
                        // Trainer Hub
                        MoreSheetItem(
                            icon = Icons.Filled.GridView,
                            title = "Trener Hub",
                            subtitle = "Sessiyalar, məhsullar idarə et",
                            gradientColors = listOf(CoreViaPrimary, CoreViaPrimary.copy(alpha = 0.7f)),
                            onClick = {
                                showMoreSheet = false
                                navController.navigate(Screen.TrainerHub.route)
                            }
                        )
                    } else {
                        // Activities
                        MoreSheetItem(
                            icon = Icons.Filled.DirectionsRun,
                            title = "Hərəkətlər",
                            subtitle = "GPS marşrut izləmə, statistikalar",
                            gradientColors = listOf(CoreViaPrimary, CoreViaPrimary.copy(alpha = 0.7f)),
                            onClick = {
                                showMoreSheet = false
                                navController.navigate(Screen.Activities.route)
                            }
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Profile — həm trainer, həm client
                    MoreSheetItem(
                        icon = Icons.Filled.Person,
                        title = "Profil",
                        subtitle = "Hesab məlumatları, tənzimləmələr",
                        gradientColors = listOf(CoreViaSuccess, CoreViaSuccess.copy(alpha = 0.7f)),
                        onClick = {
                            showMoreSheet = false
                            navController.navigate(Screen.Profile.route)
                        }
                    )
                }
            }
        }

        NavHost(
            navController = navController,
            startDestination = startDestination,
            modifier = Modifier.padding(
                bottom = if (showBottomBar) paddingValues.calculateBottomPadding() else 0.dp
            )
        ) {
            composable(Screen.Login.route) {
                LoginScreen(
                    onLoginSuccess = {
                        navController.navigate(Screen.Home.route) {
                            popUpTo(Screen.Login.route) { inclusive = true }
                        }
                    },
                    onNavigateToRegister = {
                        navController.navigate(Screen.Register.route)
                    },
                    onNavigateToForgotPassword = {
                        navController.navigate(Screen.ForgotPassword.route)
                    }
                )
            }

            composable(Screen.Register.route) {
                RegisterScreen(
                    onBack = { navController.popBackStack() },
                    onRegisterSuccess = {
                        // Qeydiyyatdan sonra login ekranina qayit
                        navController.navigate(Screen.Login.route) {
                            popUpTo(Screen.Register.route) { inclusive = true }
                        }
                    }
                )
            }

            composable(Screen.ForgotPassword.route) {
                ForgotPasswordScreen(
                    onBack = { navController.popBackStack() },
                    onSendOtp = {}
                )
            }

            composable(Screen.Home.route) {
                if (isTrainer) {
                    // ── Trainer Dashboard ──
                    TrainerHomeScreen(
                        onNavigateToStudentDetail = { studentId ->
                            navController.navigate(Screen.ChatDetail.createRoute(studentId, studentId))
                        },
                        onNavigateToTrainingPlans = {
                            navController.navigate(Screen.Workout.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        onNavigateToMealPlans = {
                            navController.navigate(Screen.MealPlans.route)
                        },
                        onNavigateToMessages = {
                            navController.navigate(Screen.Messages.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                } else {
                    // ── Client Home ──
                    HomeScreen(
                        onNavigateToWorkout = {
                            navController.navigate(Screen.Workout.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        onNavigateToFood = {
                            navController.navigate(Screen.Food.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        onNavigateToRoute = {},
                        onNavigateToAIAnalysis = {
                            navController.navigate(Screen.AICalorie.route)
                        },
                        onNavigateToNotifications = {},
                        onNavigateToSocial = {
                            navController.navigate(Screen.Social.route)
                        },
                        onNavigateToMarketplace = {
                            navController.navigate(Screen.Marketplace.route)
                        },
                        onNavigateToLiveSession = {
                            navController.navigate(Screen.LiveSessions.route)
                        },
                        onNavigateToAnalytics = {
                            navController.navigate(Screen.Analytics.route)
                        },
                        onNavigateToSurvey = {
                            navController.navigate(Screen.DailySurvey.route)
                        }
                    )
                }
            }

            composable(Screen.Workout.route) {
                // Client only — Workout tracking
                WorkoutScreen(
                    onNavigateToGPS = {
                        navController.navigate(Screen.GPSTracking.route)
                    },
                    onNavigateToAddWorkout = {
                        navController.navigate(Screen.AddWorkout.route)
                    }
                )
            }

            // Trainer tab 1 — Training Plans (birbaşa tab kimi)
            composable(Screen.TrainingPlans.route) {
                TrainingPlanScreen(
                    onNavigateToAddPlan = {
                        navController.navigate(Screen.AddTrainingPlan.route)
                    },
                    onBack = { navController.popBackStack() }
                )
            }

            // Trainer tab 2 — Meal Plans (birbaşa tab kimi)
            composable(Screen.MealPlans.route) {
                MealPlanScreen(
                    onNavigateToAddPlan = {
                        navController.navigate(Screen.AddMealPlan.route)
                    },
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.Activities.route) {
                RouteTrackingScreen()
            }

            composable(Screen.GPSTracking.route) {
                GPSTrackingScreen(
                    onClose = { navController.popBackStack() }
                )
            }

            composable(Screen.Food.route) {
                FoodScreen(
                    onNavigateToMealPlans = {
                        navController.navigate(Screen.MealPlans.route)
                    },
                    onNavigateToAICalorie = {
                        navController.navigate(Screen.AICalorie.route)
                    },
                    onNavigateToAddFood = {
                        navController.navigate(Screen.AddFood.route)
                    }
                )
            }

            composable(Screen.Messages.route) {
                ConversationsScreen(
                    onConversationClick = { userId, userName ->
                        navController.navigate(Screen.ChatDetail.createRoute(userId, userName))
                    }
                )
            }

            composable(Screen.Profile.route) {
                ProfileScreen(
                    onNavigateToEditProfile = {
                        navController.navigate(Screen.EditProfile.route)
                    },
                    onNavigateToAnalytics = {
                        navController.navigate(Screen.Analytics.route)
                    },
                    onNavigateToNotifications = {},
                    onNavigateToPremium = {
                        navController.navigate(Screen.Premium.route)
                    },
                    onNavigateToTeachers = {
                        navController.navigate(Screen.TrainerBrowse.route)
                    },
                    onNavigateToSettings = {
                        navController.navigate(Screen.Settings.route)
                    },
                    onNavigateToAbout = {},
                    onLogout = {
                        navController.navigate(Screen.Login.route) {
                            popUpTo(0) { inclusive = true }
                        }
                    }
                )
            }

            composable(Screen.Premium.route) {
                PremiumScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.Settings.route) {
                SettingsScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.DailySurvey.route) {
                DailySurveyScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.AddMealPlan.route) {
                AddMealPlanScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.AICalorie.route) {
                AICalorieScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.EditProfile.route) {
                EditProfileScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            // ── New Routes ──────────────────────────────────────────

            composable(Screen.AddWorkout.route) {
                AddWorkoutScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.AddFood.route) {
                AddFoodScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(
                route = Screen.ChatDetail.route,
                arguments = listOf(
                    navArgument("userId") { type = NavType.StringType },
                    navArgument("userName") { type = NavType.StringType }
                )
            ) {
                ChatDetailScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.AddTrainingPlan.route) {
                AddTrainingPlanScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.TrainerBrowse.route) {
                TrainerBrowseScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.Onboarding.route) {
                OnboardingScreen(
                    onComplete = {
                        navController.navigate(Screen.Home.route) {
                            popUpTo(Screen.Onboarding.route) { inclusive = true }
                        }
                    }
                )
            }

            // ── ORTA Priority Routes ─────────────────────────────────

            composable(Screen.Social.route) {
                SocialFeedScreen(
                    onNavigateToCreatePost = {
                        navController.navigate(Screen.CreatePost.route)
                    },
                    onNavigateToComments = { postId ->
                        navController.navigate(Screen.Comments.createRoute(postId))
                    }
                )
            }

            composable(Screen.Analytics.route) {
                AnalyticsDashboardScreen(
                    onBack = { navController.popBackStack() },
                    onNavigateToOverallStats = {
                        navController.navigate(Screen.OverallStats.route)
                    }
                )
            }

            composable(Screen.OverallStats.route) {
                OverallStatsScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.CreatePost.route) {
                CreatePostScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(
                route = Screen.Comments.route,
                arguments = listOf(
                    navArgument("postId") { type = NavType.StringType }
                )
            ) {
                CommentsScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.Marketplace.route) {
                MarketplaceScreen(
                    onBack = { navController.popBackStack() },
                    onNavigateToProduct = { productId ->
                        navController.navigate(Screen.ProductDetail.createRoute(productId))
                    }
                )
            }

            composable(Screen.AICalorieHistory.route) {
                AICalorieHistoryScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(
                route = Screen.WriteReview.route,
                arguments = listOf(
                    navArgument("productId") { type = NavType.StringType }
                )
            ) {
                WriteReviewScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            // ── Live Sessions ─────────────────────────────────────

            composable(Screen.LiveSessions.route) {
                LiveSessionListScreen(
                    onBack = { navController.popBackStack() },
                    onNavigateToDetail = { sessionId ->
                        navController.navigate(Screen.LiveSessionDetail.createRoute(sessionId))
                    }
                )
            }

            composable(
                route = Screen.LiveSessionDetail.route,
                arguments = listOf(
                    navArgument("sessionId") { type = NavType.StringType }
                )
            ) { backStackEntry ->
                val sessionId = backStackEntry.arguments?.getString("sessionId") ?: ""
                LiveSessionDetailScreen(
                    sessionId = sessionId,
                    onBack = { navController.popBackStack() },
                    onNavigateToLiveWorkout = { id ->
                        navController.navigate(Screen.LiveWorkout.createRoute(id))
                    }
                )
            }

            composable(
                route = Screen.LiveWorkout.route,
                arguments = listOf(
                    navArgument("sessionId") { type = NavType.StringType }
                )
            ) { backStackEntry ->
                val sessionId = backStackEntry.arguments?.getString("sessionId") ?: ""
                LiveWorkoutScreen(
                    sessionId = sessionId,
                    onBack = { navController.popBackStack() },
                    onEndWorkout = { navController.popBackStack() }
                )
            }

            // ── Trainer Hub ────────────────────────────────────────

            composable(Screen.TrainerHub.route) {
                TrainerHubScreen(
                    onBack = { navController.popBackStack() },
                    onNavigateToCreateSession = {
                        navController.navigate(Screen.CreateLiveSession.route)
                    },
                    onNavigateToCreateProduct = {
                        navController.navigate(Screen.CreateProduct.route)
                    }
                )
            }

            composable(Screen.CreateProduct.route) {
                CreateProductScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            composable(Screen.CreateLiveSession.route) {
                CreateLiveSessionScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            // ── Trainer Content ────────────────────────────────────

            composable(Screen.TrainerContent.route) {
                TrainerContentScreen(
                    isTrainerMode = isTrainer,
                    onBack = { navController.popBackStack() }
                )
            }

            // ── Product Detail ─────────────────────────────────────

            composable(
                route = Screen.ProductDetail.route,
                arguments = listOf(
                    navArgument("productId") { type = NavType.StringType }
                )
            ) { backStackEntry ->
                val productId = backStackEntry.arguments?.getString("productId") ?: ""
                ProductDetailScreen(
                    onBack = { navController.popBackStack() },
                    onNavigateToWriteReview = {
                        navController.navigate(Screen.WriteReview.createRoute(productId))
                    }
                )
            }

            // ── Trainer Verification ───────────────────────────────

            composable(Screen.TrainerVerification.route) {
                TrainerVerificationScreen(
                    onBack = { navController.popBackStack() }
                )
            }

            // ── AI Calorie Result ──────────────────────────────────

            composable(Screen.AICalorieResult.route) {
                AICalorieResultScreen(
                    onBack = { navController.popBackStack() }
                )
            }
        }
    }
}

// ── "Daha çox" Sheet Item ────────────────────────────────────────
@Composable
private fun MoreSheetItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    gradientColors: List<Color>,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(
                Brush.linearGradient(
                    gradientColors.map { it.copy(alpha = 0.08f) }
                )
            )
            .clickable(onClick = onClick)
            .padding(20.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Icon circle with gradient
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(CircleShape)
                .background(Brush.linearGradient(gradientColors)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(26.dp),
                tint = Color.White
            )
        }

        // Text
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = title,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = subtitle,
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        // Arrow
        Icon(
            Icons.Filled.ChevronRight,
            contentDescription = null,
            modifier = Modifier.size(22.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
