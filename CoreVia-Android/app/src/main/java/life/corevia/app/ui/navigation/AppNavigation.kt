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
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.outlined.Chat
import androidx.compose.material.icons.automirrored.outlined.List
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
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
import life.corevia.app.ui.activities.ActivitiesScreen
import life.corevia.app.ui.activities.ActivitiesViewModel
import life.corevia.app.ui.auth.AuthViewModel
import life.corevia.app.ui.auth.ForgotPasswordScreen
import life.corevia.app.ui.auth.LoginScreen
import life.corevia.app.ui.auth.RegisterScreen
import life.corevia.app.ui.food.FoodScreen
import life.corevia.app.ui.food.FoodViewModel
import life.corevia.app.ui.home.HomeScreen
import life.corevia.app.ui.home.TrainerHomeScreen
import life.corevia.app.ui.home.TrainerHomeViewModel
import life.corevia.app.ui.mealplan.AddMealPlanScreen
import life.corevia.app.ui.mealplan.EditMealPlanScreen
import life.corevia.app.ui.mealplan.MealPlanScreen
import life.corevia.app.ui.mealplan.MealPlanViewModel
import life.corevia.app.ui.profile.ProfileScreen
import life.corevia.app.ui.profile.ProfileViewModel
import life.corevia.app.ui.profile.TrainerProfileScreen
import life.corevia.app.ui.settings.SettingsScreen
import life.corevia.app.ui.trainer.MyStudentsScreen
import life.corevia.app.ui.trainer.MyStudentsViewModel
import life.corevia.app.ui.trainingplan.AddTrainingPlanScreen
import life.corevia.app.ui.trainingplan.EditTrainingPlanScreen
import life.corevia.app.ui.trainingplan.TrainingPlanScreen
import life.corevia.app.ui.trainingplan.TrainingPlanViewModel
import life.corevia.app.ui.workout.WorkoutScreen
import life.corevia.app.ui.workout.WorkoutViewModel
import life.corevia.app.ui.chat.ChatViewModel
import life.corevia.app.ui.chat.ConversationsScreen
import life.corevia.app.ui.chat.ChatDetailScreen
import life.corevia.app.ui.notifications.NotificationsViewModel
import life.corevia.app.ui.notifications.NotificationsScreen
import life.corevia.app.ui.analytics.AnalyticsViewModel
import life.corevia.app.ui.analytics.AnalyticsScreen
import life.corevia.app.ui.social.SocialViewModel
import life.corevia.app.ui.social.SocialFeedScreen
import life.corevia.app.ui.social.UserProfileScreen
import life.corevia.app.ui.social.AchievementsScreen
import life.corevia.app.ui.premium.PremiumViewModel
import life.corevia.app.ui.premium.PremiumScreen
import life.corevia.app.ui.trainers.TrainersViewModel
import life.corevia.app.ui.trainers.TrainersScreen
import life.corevia.app.ui.trainers.TrainerDetailScreen
import life.corevia.app.ui.onboarding.OnboardingScreen
import life.corevia.app.ui.onboarding.OnboardingViewModel
import life.corevia.app.ui.livesession.LiveSessionsViewModel
import life.corevia.app.ui.livesession.LiveSessionsScreen
import life.corevia.app.ui.livesession.LiveSessionDetailScreen
import life.corevia.app.ui.marketplace.MarketplaceViewModel
import life.corevia.app.ui.marketplace.MarketplaceScreen
import life.corevia.app.ui.marketplace.ProductDetailScreen
import life.corevia.app.ui.news.NewsViewModel
import life.corevia.app.ui.news.NewsScreen
import life.corevia.app.ui.news.NewsDetailScreen
import life.corevia.app.ui.tracking.TrackingViewModel
import life.corevia.app.ui.tracking.LiveTrackingScreen
import life.corevia.app.ui.content.ContentViewModel
import life.corevia.app.ui.content.TrainerContentScreen

/**
 * iOS: ContentView + MainTabView + CustomTabBar
 * 1-ə-1 iOS port:
 *
 * CLIENT Tab Bar: Home | Workout | Food | Chat | More(Activities, Profile)
 * TRAINER Tab Bar: Home | Plans | Meal Plans | Chat | More(Content, Profile)
 *
 * Feature-lara HomeView Quick Actions-dan daxil olunur (iOS kimi):
 *   Social Feed, Marketplace, Live Sessions → Home quick action buttons
 *   Statistics/Analytics → Home quick action sheet
 *   GPS Tracking → Workout screen button (premium only)
 *   Settings → Profile → Settings
 *   Notifications → Profile → Settings → Notifications
 */

// ─── Route sabitləri ──────────────────────────────────────────────────────────
object Routes {
    const val LOGIN           = "login"
    const val REGISTER        = "register"
    const val HOME            = "home"
    const val FORGOT_PASSWORD = "forgot_password"
    const val ONBOARDING      = "onboarding"
}

// ─── Tab indeksləri (iOS selectedTab ilə eyni) ────────────────────────────────
// iOS CustomTabBar: 0-3 = tab bar tabs, 4 = activities/content, 5 = profile
private const val TAB_HOME     = 0
private const val TAB_WORKOUT  = 1   // client: WorkoutView | trainer: TrainingPlanView
private const val TAB_FOOD     = 2   // client: FoodView    | trainer: MealPlanView
private const val TAB_CHAT     = 3
private const val TAB_MORE     = 4   // client: ActivitiesView | trainer: TrainerContentView
private const val TAB_PROFILE  = 5

// Sub-screens (iOS: NavigationLink/sheet-dən açılır)
private const val TAB_SETTINGS         = 6
private const val TAB_MY_STUDENTS      = 7
private const val TAB_ADD_TRAINING     = 8
private const val TAB_ADD_MEAL         = 9
private const val TAB_CHAT_DETAIL      = 10
private const val TAB_NOTIFICATIONS    = 11
private const val TAB_ANALYTICS        = 12
private const val TAB_SOCIAL           = 13
private const val TAB_PREMIUM          = 14
private const val TAB_TRAINERS         = 15
private const val TAB_TRAINER_DETAIL   = 16
private const val TAB_LIVE_SESSIONS    = 17
private const val TAB_LIVE_SESSION_DETAIL = 18
private const val TAB_MARKETPLACE      = 19
private const val TAB_PRODUCT_DETAIL   = 20
private const val TAB_NEWS             = 21
private const val TAB_NEWS_DETAIL      = 22
private const val TAB_TRACKING         = 23
private const val TAB_EDIT_TRAINING    = 24
private const val TAB_EDIT_MEAL        = 25
private const val TAB_USER_PROFILE     = 26
private const val TAB_ACHIEVEMENTS     = 27

// ─── Ana composable ───────────────────────────────────────────────────────────
@Composable
fun AppNavigation(tokenManager: TokenManager) {
    val navController = rememberNavController()
    val startDestination = when {
        !tokenManager.isLoggedIn -> Routes.LOGIN
        !tokenManager.hasCompletedOnboarding -> Routes.ONBOARDING
        else -> Routes.HOME
    }

    val authViewModel: AuthViewModel                   = viewModel()

    // 401 auto-logout: token expired + refresh fail → login ekranına yönləndir
    val context = androidx.compose.ui.platform.LocalContext.current
    LaunchedEffect(Unit) {
        life.corevia.app.data.api.ApiClient.getInstance(context).onUnauthorized = {
            authViewModel.logout()
            navController.navigate(Routes.LOGIN) {
                popUpTo(0) { inclusive = true }
            }
        }
    }
    val workoutViewModel: WorkoutViewModel             = viewModel()
    val foodViewModel: FoodViewModel                   = viewModel()
    val trainingPlanViewModel: TrainingPlanViewModel   = viewModel()
    val mealPlanViewModel: MealPlanViewModel           = viewModel()
    val profileViewModel: ProfileViewModel             = viewModel()
    val activitiesViewModel: ActivitiesViewModel       = viewModel()
    val chatViewModel: ChatViewModel                   = viewModel()
    val notificationsViewModel: NotificationsViewModel = viewModel()
    val analyticsViewModel: AnalyticsViewModel         = viewModel()
    val socialViewModel: SocialViewModel               = viewModel()
    val premiumViewModel: PremiumViewModel             = viewModel()
    val trainersViewModel: TrainersViewModel           = viewModel()
    val liveSessionsViewModel: LiveSessionsViewModel   = viewModel()
    val marketplaceViewModel: MarketplaceViewModel     = viewModel()
    val newsViewModel: NewsViewModel                   = viewModel()
    val trackingViewModel: TrackingViewModel           = viewModel()
    val contentViewModel: ContentViewModel             = viewModel()
    val onboardingViewModel: OnboardingViewModel       = viewModel()

    NavHost(
        navController    = navController,
        startDestination = startDestination,
        modifier         = Modifier.fillMaxSize()
    ) {
        // ── Auth ──────────────────────────────────────────────────────────────
        composable(Routes.LOGIN) {
            LoginScreen(
                onLoginSuccess             = { navController.navigateAfterAuth(tokenManager) },
                onNavigateToRegister       = { navController.navigate(Routes.REGISTER) },
                onNavigateToForgotPassword = { navController.navigate(Routes.FORGOT_PASSWORD) },
                viewModel                  = authViewModel
            )
        }
        composable(Routes.REGISTER) {
            RegisterScreen(
                onRegisterSuccess = { navController.navigateAfterAuth(tokenManager) },
                onNavigateToLogin = {
                    authViewModel.resetToIdle()
                    navController.popBackStack()
                },
                viewModel         = authViewModel
            )
        }
        composable(Routes.FORGOT_PASSWORD) {
            ForgotPasswordScreen(onBack = { navController.popBackStack() })
        }

        // ── Onboarding ──────────────────────────────────────────────────────
        composable(Routes.ONBOARDING) {
            OnboardingScreen(
                viewModel = onboardingViewModel,
                isTrainer = tokenManager.isTrainer,
                onComplete = {
                    navController.navigateToMain()
                }
            )
        }

        // ── Main (iOS: MainTabView) ───────────────────────────────────────────
        composable(Routes.HOME) {
            // iOS kimi: userType TokenManager-dan dərhal oxunur (API gözləmədən).
            // Login zamanı saxlanılır, app açılanda dərhal doğru tip göstərilir.
            val isTrainer = tokenManager.isTrainer

            // Logout → re-login sonrası ViewModel-ləri yenidən yüklə
            LaunchedEffect(tokenManager.accessToken) {
                profileViewModel.loadUser()
                foodViewModel.loadFoodEntries()
                workoutViewModel.loadWorkouts()
                chatViewModel.loadConversations()
            }

            MainTabView(
                navController         = navController,
                workoutViewModel      = workoutViewModel,
                foodViewModel         = foodViewModel,
                trainingPlanViewModel = trainingPlanViewModel,
                mealPlanViewModel     = mealPlanViewModel,
                profileViewModel      = profileViewModel,
                activitiesViewModel   = activitiesViewModel,
                chatViewModel         = chatViewModel,
                notificationsViewModel = notificationsViewModel,
                analyticsViewModel    = analyticsViewModel,
                socialViewModel       = socialViewModel,
                premiumViewModel      = premiumViewModel,
                trainersViewModel     = trainersViewModel,
                liveSessionsViewModel = liveSessionsViewModel,
                marketplaceViewModel  = marketplaceViewModel,
                newsViewModel         = newsViewModel,
                trackingViewModel     = trackingViewModel,
                contentViewModel      = contentViewModel,
                isTrainer             = isTrainer,
                onLogout = {
                    authViewModel.logout()
                    navController.navigate(Routes.LOGIN) {
                        popUpTo(0) { inclusive = true }
                    }
                }
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
    mealPlanViewModel: MealPlanViewModel,
    profileViewModel: ProfileViewModel,
    activitiesViewModel: ActivitiesViewModel,
    chatViewModel: ChatViewModel,
    notificationsViewModel: NotificationsViewModel,
    analyticsViewModel: AnalyticsViewModel,
    socialViewModel: SocialViewModel,
    premiumViewModel: PremiumViewModel,
    trainersViewModel: TrainersViewModel,
    liveSessionsViewModel: LiveSessionsViewModel,
    marketplaceViewModel: MarketplaceViewModel,
    newsViewModel: NewsViewModel,
    trackingViewModel: TrackingViewModel,
    contentViewModel: ContentViewModel,
    isTrainer: Boolean = false,
    onLogout: () -> Unit = {}
) {
    var selectedTab by remember { mutableStateOf(TAB_HOME) }

    val myStudentsViewModel: MyStudentsViewModel = viewModel()
    val trainerHomeViewModel: TrainerHomeViewModel = viewModel()
    val students by myStudentsViewModel.students.collectAsState()

    // iOS: Trainer üçün user adı
    val user by profileViewModel.user.collectAsState()

    var preSelectedStudentId by remember { mutableStateOf<String?>(null) }

    Box(modifier = Modifier.fillMaxSize()) {

        // ── Tab content (iOS switch selectedTab) ──────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 80.dp)
        ) {
            when (selectedTab) {
                TAB_HOME -> {
                    if (isTrainer) {
                        // iOS: TrainerHomeView
                        TrainerHomeScreen(
                            userName    = user?.name ?: "",
                            userInitial = user?.name?.take(1) ?: "",
                            viewModel   = trainerHomeViewModel
                        )
                    } else {
                        // iOS: HomeView
                        HomeScreen(
                            userName                 = user?.name ?: "",
                            onNavigateToWorkout      = { selectedTab = TAB_WORKOUT },
                            onNavigateToFood         = { selectedTab = TAB_FOOD },
                            onNavigateToTrainingPlan = { selectedTab = TAB_WORKOUT },
                            onNavigateToLiveTracking = { selectedTab = TAB_TRACKING },
                            onNavigateToProfile      = { selectedTab = TAB_PROFILE },
                            onNavigateToActivities   = { selectedTab = TAB_MORE },
                            // iOS HomeView Quick Actions → feature screens
                            onNavigateToSocial       = { selectedTab = TAB_SOCIAL },
                            onNavigateToMarketplace  = { selectedTab = TAB_MARKETPLACE },
                            onNavigateToLiveSessions = { selectedTab = TAB_LIVE_SESSIONS },
                            onNavigateToAnalytics    = { selectedTab = TAB_ANALYTICS },
                            workoutViewModel         = workoutViewModel
                        )
                    }
                }
                TAB_WORKOUT -> {
                    if (isTrainer) {
                        TrainingPlanScreen(
                            isTrainer = true,
                            onNavigateToAddTrainingPlan = {
                                preSelectedStudentId = null
                                selectedTab = TAB_ADD_TRAINING
                            },
                            onNavigateToEditTrainingPlan = { plan ->
                                trainingPlanViewModel.selectPlan(plan)
                                selectedTab = TAB_EDIT_TRAINING
                            },
                            onDeletePlan = { planId -> trainingPlanViewModel.deletePlan(planId) },
                            viewModel = trainingPlanViewModel
                        )
                    } else {
                        WorkoutScreen(
                            onNavigateToLiveTracking = { selectedTab = TAB_TRACKING },
                            viewModel                = workoutViewModel
                        )
                    }
                }
                TAB_FOOD -> {
                    if (isTrainer) {
                        MealPlanScreen(
                            isTrainer = true,
                            onNavigateToAddMealPlan = {
                                preSelectedStudentId = null
                                selectedTab = TAB_ADD_MEAL
                            },
                            onNavigateToEditMealPlan = { plan ->
                                mealPlanViewModel.selectPlan(plan)
                                selectedTab = TAB_EDIT_MEAL
                            },
                            onDeletePlan = { planId -> mealPlanViewModel.deletePlan(planId) },
                            viewModel = mealPlanViewModel
                        )
                    } else {
                        FoodScreen(
                            viewModel = foodViewModel,
                            isPremium = user?.isPremium == true
                        )
                    }
                }
                TAB_CHAT -> {
                    ConversationsScreen(
                        viewModel = chatViewModel,
                        onOpenChat = { userId, userName ->
                            chatViewModel.openChat(userId, userName)
                            selectedTab = TAB_CHAT_DETAIL
                        }
                    )
                }
                TAB_CHAT_DETAIL -> {
                    ChatDetailScreen(
                        viewModel = chatViewModel,
                        onBack = {
                            chatViewModel.closeChat()
                            chatViewModel.loadConversations()
                            selectedTab = TAB_CHAT
                        }
                    )
                }
                TAB_MORE -> {
                    // iOS: Tab 4 = Activities (client) / Content (trainer)
                    if (isTrainer) {
                        TrainerContentScreen(viewModel = contentViewModel)
                    } else {
                        ActivitiesScreen(
                            viewModel = activitiesViewModel,
                            isPremium = user?.isPremium == true
                        )
                    }
                }
                TAB_PROFILE -> {
                    if (isTrainer) {
                        TrainerProfileScreen(
                            onNavigateToSettings = { selectedTab = TAB_SETTINGS },
                            onNavigateToMyStudents = { selectedTab = TAB_MY_STUDENTS },
                            onLogout = onLogout,
                            profileViewModel = profileViewModel,
                            trainerHomeViewModel = trainerHomeViewModel
                        )
                    } else {
                        ProfileScreen(
                            onNavigateToSettings = { selectedTab = TAB_SETTINGS },
                            onNavigateToPremium = { selectedTab = TAB_PREMIUM },
                            onLogout = onLogout,
                            viewModel = profileViewModel
                        )
                    }
                }
                TAB_SETTINGS -> {
                    SettingsScreen(
                        onBack = { selectedTab = TAB_PROFILE },
                        onLogout = onLogout
                    )
                }
                TAB_MY_STUDENTS -> {
                    MyStudentsScreen(
                        onBack = { selectedTab = TAB_HOME },
                        onNavigateToAddTrainingPlan = { studentId ->
                            preSelectedStudentId = studentId
                            selectedTab = TAB_ADD_TRAINING
                        },
                        onNavigateToAddMealPlan = { studentId ->
                            preSelectedStudentId = studentId
                            selectedTab = TAB_ADD_MEAL
                        },
                        viewModel = myStudentsViewModel
                    )
                }
                TAB_ADD_TRAINING -> {
                    AddTrainingPlanScreen(
                        onBack = {
                            selectedTab = if (isTrainer) TAB_WORKOUT else TAB_HOME
                            trainingPlanViewModel.loadPlans()
                        },
                        onSave = { request ->
                            trainingPlanViewModel.createPlan(request)
                            selectedTab = if (isTrainer) TAB_WORKOUT else TAB_HOME
                        },
                        students = if (isTrainer) students else emptyList(),
                        preSelectedStudentId = preSelectedStudentId
                    )
                }
                TAB_ADD_MEAL -> {
                    AddMealPlanScreen(
                        onBack = {
                            selectedTab = if (isTrainer) TAB_FOOD else TAB_HOME
                            mealPlanViewModel.loadPlans()
                        },
                        onSave = { request ->
                            mealPlanViewModel.createPlan(request)
                            selectedTab = if (isTrainer) TAB_FOOD else TAB_HOME
                        },
                        students = if (isTrainer) students else emptyList(),
                        preSelectedStudentId = preSelectedStudentId
                    )
                }
                TAB_NOTIFICATIONS -> {
                    NotificationsScreen(
                        viewModel = notificationsViewModel,
                        onBack = { selectedTab = TAB_PROFILE }
                    )
                }
                TAB_ANALYTICS -> {
                    AnalyticsScreen(
                        viewModel = analyticsViewModel,
                        onBack = { selectedTab = TAB_HOME }
                    )
                }
                TAB_SOCIAL -> {
                    SocialFeedScreen(
                        viewModel = socialViewModel,
                        onBack = { selectedTab = TAB_HOME },
                        onNavigateToUserProfile = { userId ->
                            socialViewModel.loadUserProfile(userId)
                            selectedTab = TAB_USER_PROFILE
                        },
                        onNavigateToAchievements = {
                            selectedTab = TAB_ACHIEVEMENTS
                        }
                    )
                }
                TAB_PREMIUM -> {
                    PremiumScreen(
                        viewModel = premiumViewModel,
                        onBack = { selectedTab = TAB_HOME }
                    )
                }
                TAB_TRAINERS -> {
                    TrainersScreen(
                        viewModel = trainersViewModel,
                        onBack = { selectedTab = TAB_HOME },
                        onTrainerSelected = { selectedTab = TAB_TRAINER_DETAIL }
                    )
                }
                TAB_TRAINER_DETAIL -> {
                    TrainerDetailScreen(
                        viewModel = trainersViewModel,
                        onBack = {
                            trainersViewModel.clearSelectedTrainer()
                            selectedTab = TAB_TRAINERS
                        }
                    )
                }
                TAB_LIVE_SESSIONS -> {
                    LiveSessionsScreen(
                        viewModel = liveSessionsViewModel,
                        onBack = { selectedTab = TAB_HOME },
                        onSessionSelected = { selectedTab = TAB_LIVE_SESSION_DETAIL }
                    )
                }
                TAB_LIVE_SESSION_DETAIL -> {
                    LiveSessionDetailScreen(
                        viewModel = liveSessionsViewModel,
                        onBack = {
                            liveSessionsViewModel.clearSelectedSession()
                            selectedTab = TAB_LIVE_SESSIONS
                        }
                    )
                }
                TAB_MARKETPLACE -> {
                    MarketplaceScreen(
                        viewModel = marketplaceViewModel,
                        onBack = { selectedTab = TAB_HOME },
                        onProductSelected = { selectedTab = TAB_PRODUCT_DETAIL }
                    )
                }
                TAB_PRODUCT_DETAIL -> {
                    ProductDetailScreen(
                        viewModel = marketplaceViewModel,
                        onBack = {
                            marketplaceViewModel.clearSelectedProduct()
                            selectedTab = TAB_MARKETPLACE
                        }
                    )
                }
                TAB_NEWS -> {
                    NewsScreen(
                        viewModel = newsViewModel,
                        onBack = { selectedTab = TAB_HOME },
                        onArticleSelected = { selectedTab = TAB_NEWS_DETAIL }
                    )
                }
                TAB_NEWS_DETAIL -> {
                    NewsDetailScreen(
                        viewModel = newsViewModel,
                        onBack = {
                            newsViewModel.clearSelectedArticle()
                            selectedTab = TAB_NEWS
                        }
                    )
                }
                TAB_TRACKING -> {
                    LiveTrackingScreen(
                        viewModel = trackingViewModel,
                        onBack = { selectedTab = TAB_HOME }
                    )
                }
                TAB_USER_PROFILE -> {
                    UserProfileScreen(
                        viewModel = socialViewModel,
                        onBack = {
                            socialViewModel.clearUserProfile()
                            selectedTab = TAB_SOCIAL
                        }
                    )
                }
                TAB_ACHIEVEMENTS -> {
                    AchievementsScreen(
                        viewModel = socialViewModel,
                        onBack = { selectedTab = TAB_SOCIAL }
                    )
                }
                TAB_EDIT_TRAINING -> {
                    val selectedPlan by trainingPlanViewModel.selectedPlan.collectAsState()
                    selectedPlan?.let { plan ->
                        EditTrainingPlanScreen(
                            plan = plan,
                            onBack = {
                                trainingPlanViewModel.clearSelectedPlan()
                                selectedTab = TAB_WORKOUT
                                trainingPlanViewModel.loadPlans()
                            },
                            onSave = { planId, request ->
                                trainingPlanViewModel.updatePlan(planId, request)
                                trainingPlanViewModel.clearSelectedPlan()
                                selectedTab = TAB_WORKOUT
                            },
                            students = if (isTrainer) students else emptyList()
                        )
                    } ?: run {
                        selectedTab = TAB_WORKOUT
                    }
                }
                TAB_EDIT_MEAL -> {
                    val selectedPlan by mealPlanViewModel.selectedPlan.collectAsState()
                    selectedPlan?.let { plan ->
                        EditMealPlanScreen(
                            plan = plan,
                            onBack = {
                                mealPlanViewModel.clearSelectedPlan()
                                selectedTab = TAB_FOOD
                                mealPlanViewModel.loadPlans()
                            },
                            onSave = { planId, request ->
                                mealPlanViewModel.updatePlan(planId, request)
                                mealPlanViewModel.clearSelectedPlan()
                                selectedTab = TAB_FOOD
                            },
                            students = if (isTrainer) students else emptyList()
                        )
                    } ?: run {
                        selectedTab = TAB_FOOD
                    }
                }
            }
        }

        // ── iOS: CustomTabBar ─────────────────────────────────────────────────
        // Yalnız əsas tab-larda göstər (sub-screen-lərdə gizlə, iOS kimi)
        if (selectedTab in listOf(TAB_HOME, TAB_WORKOUT, TAB_FOOD, TAB_CHAT, TAB_MORE, TAB_PROFILE)) {
            CoreViaTabBar(
                selectedTab = selectedTab,
                isTrainer   = isTrainer,
                onTabSelect = { selectedTab = it },
                modifier    = Modifier.align(Alignment.BottomCenter)
            )
        }
    }
}

// ─── iOS: CustomTabBar ────────────────────────────────────────────────────────
// Glassmorphism + animated selected circle + "More" sheet (iOS: cəmi 2 item!)
@Composable
fun CoreViaTabBar(
    selectedTab: Int,
    isTrainer: Boolean,
    onTabSelect: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    var showMoreSheet by remember { mutableStateOf(false) }

    // iOS: HStack tab bar with glassmorphism
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
                color = AppTheme.Colors.cardBackground.copy(alpha = 0.95f),
                shape = RoundedCornerShape(24.dp)
            )
            .padding(horizontal = 8.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceAround
    ) {
        // Tab 0: Home
        TabBarItem(
            icon       = Icons.Outlined.Home,
            label      = "Əsas",
            isSelected = selectedTab == TAB_HOME,
            onClick    = { onTabSelect(TAB_HOME) }
        )

        // Tab 1: Workout / Plans — iOS: figure.strengthtraining.traditional
        TabBarItem(
            icon       = Icons.Outlined.FitnessCenter,
            label      = if (isTrainer) "Planlar" else "Məşq",
            isSelected = selectedTab == TAB_WORKOUT,
            onClick    = { onTabSelect(TAB_WORKOUT) }
        )

        // Tab 2: Food / Meal Plans — iOS: fork.knife
        TabBarItem(
            icon       = Icons.Outlined.Restaurant,
            label      = if (isTrainer) "Qida Plan" else "Qida",
            isSelected = selectedTab == TAB_FOOD,
            onClick    = { onTabSelect(TAB_FOOD) }
        )

        // Tab 3: Chat — iOS: bubble.left.and.bubble.right
        TabBarItem(
            icon       = Icons.AutoMirrored.Outlined.Chat,
            label      = "Mesajlar",
            isSelected = selectedTab == TAB_CHAT,
            onClick    = { onTabSelect(TAB_CHAT) }
        )

        // Tab 4: More (iOS: sheet with only 2 items)
        TabBarMoreButton(
            isSelected = selectedTab >= TAB_MORE,
            onClick    = { showMoreSheet = true }
        )
    }

    // iOS: MoreMenuSheet — .sheet(isPresented:) — yalnız 2 item!
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
                onTabSelect(TAB_PROFILE)
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
            modifier = Modifier.size(40.dp),
            contentAlignment = Alignment.Center
        ) {
            if (isSelected) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .shadow(8.dp, CircleShape, spotColor = AppTheme.Colors.accent.copy(alpha = 0.4f))
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

        // iOS: Text label (10pt)
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
                        .shadow(8.dp, CircleShape, spotColor = AppTheme.Colors.accent.copy(alpha = 0.4f))
                        .background(
                            brush = Brush.linearGradient(
                                colors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark)
                            ),
                            shape = CircleShape
                        )
                )
            }
            Icon(
                imageVector        = Icons.Outlined.MoreHoriz,
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
// iOS kimi: YALNIZ 2 ITEM — Activities/Content + Profile
// Digər feature-lar HomeView Quick Actions-dan açılır
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
                // Blur halo
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
                // Inner circle
                Box(
                    modifier = Modifier
                        .size(70.dp)
                        .background(AppTheme.Colors.secondaryBackground, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector        = Icons.Outlined.MoreHoriz,
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

            // iOS: Item 1 — Activities (client) / Content (trainer)
            MoreMenuItem(
                icon        = if (isTrainer) Icons.AutoMirrored.Outlined.List else Icons.Outlined.PlayArrow,
                title       = if (isTrainer) "Kontent" else "Aktivliklər",
                description = if (isTrainer) "Kontent idarə et" else "Müəllim tapşırıqları",
                gradientColors = listOf(AppTheme.Colors.accent, AppTheme.Colors.accentDark),
                onClick     = onActivities
            )

            Spacer(modifier = Modifier.height(16.dp))

            // iOS: Item 2 — Profile
            MoreMenuItem(
                icon        = Icons.Outlined.Person,
                title       = "Profil",
                description = "Hesabınızı idarə edin",
                gradientColors = listOf(AppTheme.Colors.success, AppTheme.Colors.success.copy(alpha = 0.7f)),
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
            .background(AppTheme.Colors.secondaryBackground)
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
                        .background(AppTheme.Colors.cardBackground, CircleShape),
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
                imageVector        = Icons.AutoMirrored.Filled.KeyboardArrowRight,
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
                color      = AppTheme.Colors.primaryText,
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

/**
 * Login/Register uğurlu olduqda çağırılır.
 * Əgər istifadəçi onboarding-i tamamlamayıbsa → Onboarding ekranına yönləndirir.
 * Əks halda → HOME-a aparır.
 */
private fun NavHostController.navigateAfterAuth(tokenManager: TokenManager) {
    if (!tokenManager.hasCompletedOnboarding) {
        navigate(Routes.ONBOARDING) {
            popUpTo(0) { inclusive = true }
        }
    } else {
        navigateToMain()
    }
}
