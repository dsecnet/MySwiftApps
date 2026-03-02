package life.corevia.app;

import android.app.Activity;
import android.app.Service;
import android.content.SharedPreferences;
import android.view.View;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.SavedStateHandle;
import androidx.lifecycle.ViewModel;
import dagger.hilt.android.ActivityRetainedLifecycle;
import dagger.hilt.android.ViewModelLifecycle;
import dagger.hilt.android.internal.builders.ActivityComponentBuilder;
import dagger.hilt.android.internal.builders.ActivityRetainedComponentBuilder;
import dagger.hilt.android.internal.builders.FragmentComponentBuilder;
import dagger.hilt.android.internal.builders.ServiceComponentBuilder;
import dagger.hilt.android.internal.builders.ViewComponentBuilder;
import dagger.hilt.android.internal.builders.ViewModelComponentBuilder;
import dagger.hilt.android.internal.builders.ViewWithFragmentComponentBuilder;
import dagger.hilt.android.internal.lifecycle.DefaultViewModelFactories;
import dagger.hilt.android.internal.lifecycle.DefaultViewModelFactories_InternalFactoryFactory_Factory;
import dagger.hilt.android.internal.managers.ActivityRetainedComponentManager_LifecycleModule_ProvideActivityRetainedLifecycleFactory;
import dagger.hilt.android.internal.managers.SavedStateHandleHolder;
import dagger.hilt.android.internal.modules.ApplicationContextModule;
import dagger.hilt.android.internal.modules.ApplicationContextModule_ProvideContextFactory;
import dagger.internal.DaggerGenerated;
import dagger.internal.DoubleCheck;
import dagger.internal.LazyClassKeyMap;
import dagger.internal.MapBuilder;
import dagger.internal.Preconditions;
import dagger.internal.Provider;
import java.util.Collections;
import java.util.Map;
import java.util.Set;
import javax.annotation.processing.Generated;
import kotlinx.serialization.json.Json;
import life.corevia.app.data.local.FoodDatabaseService;
import life.corevia.app.data.local.OnDeviceFoodAnalyzer;
import life.corevia.app.data.local.TokenManager;
import life.corevia.app.data.remote.ApiService;
import life.corevia.app.data.repository.AICalorieRepository;
import life.corevia.app.data.repository.AnalyticsRepository;
import life.corevia.app.data.repository.AuthRepository;
import life.corevia.app.data.repository.ChatRepository;
import life.corevia.app.data.repository.ContentRepository;
import life.corevia.app.data.repository.FoodRepository;
import life.corevia.app.data.repository.LiveSessionRepository;
import life.corevia.app.data.repository.MarketplaceRepository;
import life.corevia.app.data.repository.MealPlanRepository;
import life.corevia.app.data.repository.OnboardingRepository;
import life.corevia.app.data.repository.PremiumRepository;
import life.corevia.app.data.repository.RouteRepository;
import life.corevia.app.data.repository.SocialRepository;
import life.corevia.app.data.repository.SurveyRepository;
import life.corevia.app.data.repository.TrainerDashboardRepository;
import life.corevia.app.data.repository.TrainerRepository;
import life.corevia.app.data.repository.TrainingPlanRepository;
import life.corevia.app.data.repository.WorkoutRepository;
import life.corevia.app.di.AppModule_ProvideSharedPreferencesFactory;
import life.corevia.app.di.NetworkModule_ProvideApiServiceFactory;
import life.corevia.app.di.NetworkModule_ProvideJsonFactory;
import life.corevia.app.di.NetworkModule_ProvideOkHttpClientFactory;
import life.corevia.app.di.NetworkModule_ProvideRetrofitFactory;
import life.corevia.app.di.RepositoryModule_ProvideAICalorieRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideAuthRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideChatRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideContentRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideFoodRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideMealPlanRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideOnboardingRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideRouteRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideSurveyRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideTrainerDashboardRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideTrainerRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideTrainingPlanRepositoryFactory;
import life.corevia.app.di.RepositoryModule_ProvideWorkoutRepositoryFactory;
import life.corevia.app.ui.aicalorie.AICalorieViewModel;
import life.corevia.app.ui.aicalorie.AICalorieViewModel_HiltModules;
import life.corevia.app.ui.aicalorie.AICalorieViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.aicalorie.AICalorieViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.analytics.AnalyticsDashboardViewModel;
import life.corevia.app.ui.analytics.AnalyticsDashboardViewModel_HiltModules;
import life.corevia.app.ui.analytics.AnalyticsDashboardViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.analytics.AnalyticsDashboardViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.auth.ForgotPasswordViewModel;
import life.corevia.app.ui.auth.ForgotPasswordViewModel_HiltModules;
import life.corevia.app.ui.auth.ForgotPasswordViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.auth.ForgotPasswordViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.auth.LoginViewModel;
import life.corevia.app.ui.auth.LoginViewModel_HiltModules;
import life.corevia.app.ui.auth.LoginViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.auth.LoginViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.auth.RegisterViewModel;
import life.corevia.app.ui.auth.RegisterViewModel_HiltModules;
import life.corevia.app.ui.auth.RegisterViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.auth.RegisterViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.auth.TrainerVerificationViewModel;
import life.corevia.app.ui.auth.TrainerVerificationViewModel_HiltModules;
import life.corevia.app.ui.auth.TrainerVerificationViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.auth.TrainerVerificationViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.chat.ChatDetailViewModel;
import life.corevia.app.ui.chat.ChatDetailViewModel_HiltModules;
import life.corevia.app.ui.chat.ChatDetailViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.chat.ChatDetailViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.chat.ConversationsViewModel;
import life.corevia.app.ui.chat.ConversationsViewModel_HiltModules;
import life.corevia.app.ui.chat.ConversationsViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.chat.ConversationsViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.content.ContentViewModel;
import life.corevia.app.ui.content.ContentViewModel_HiltModules;
import life.corevia.app.ui.content.ContentViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.content.ContentViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.food.AddFoodViewModel;
import life.corevia.app.ui.food.AddFoodViewModel_HiltModules;
import life.corevia.app.ui.food.AddFoodViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.food.AddFoodViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.food.FoodAICalorieViewModel;
import life.corevia.app.ui.food.FoodAICalorieViewModel_HiltModules;
import life.corevia.app.ui.food.FoodAICalorieViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.food.FoodAICalorieViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.food.FoodViewModel;
import life.corevia.app.ui.food.FoodViewModel_HiltModules;
import life.corevia.app.ui.food.FoodViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.food.FoodViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.home.HomeViewModel;
import life.corevia.app.ui.home.HomeViewModel_HiltModules;
import life.corevia.app.ui.home.HomeViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.home.HomeViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.home.TrainerHomeViewModel;
import life.corevia.app.ui.home.TrainerHomeViewModel_HiltModules;
import life.corevia.app.ui.home.TrainerHomeViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.home.TrainerHomeViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.livesession.LiveSessionDetailViewModel;
import life.corevia.app.ui.livesession.LiveSessionDetailViewModel_HiltModules;
import life.corevia.app.ui.livesession.LiveSessionDetailViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.livesession.LiveSessionDetailViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.livesession.LiveSessionViewModel;
import life.corevia.app.ui.livesession.LiveSessionViewModel_HiltModules;
import life.corevia.app.ui.livesession.LiveSessionViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.livesession.LiveSessionViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.marketplace.MarketplaceViewModel;
import life.corevia.app.ui.marketplace.MarketplaceViewModel_HiltModules;
import life.corevia.app.ui.marketplace.MarketplaceViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.marketplace.MarketplaceViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.marketplace.ProductDetailViewModel;
import life.corevia.app.ui.marketplace.ProductDetailViewModel_HiltModules;
import life.corevia.app.ui.marketplace.ProductDetailViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.marketplace.ProductDetailViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.onboarding.OnboardingViewModel;
import life.corevia.app.ui.onboarding.OnboardingViewModel_HiltModules;
import life.corevia.app.ui.onboarding.OnboardingViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.onboarding.OnboardingViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.plans.MealPlanViewModel;
import life.corevia.app.ui.plans.MealPlanViewModel_HiltModules;
import life.corevia.app.ui.plans.MealPlanViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.plans.MealPlanViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.plans.TrainingPlanViewModel;
import life.corevia.app.ui.plans.TrainingPlanViewModel_HiltModules;
import life.corevia.app.ui.plans.TrainingPlanViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.plans.TrainingPlanViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.premium.PremiumViewModel;
import life.corevia.app.ui.premium.PremiumViewModel_HiltModules;
import life.corevia.app.ui.premium.PremiumViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.premium.PremiumViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.profile.ProfileViewModel;
import life.corevia.app.ui.profile.ProfileViewModel_HiltModules;
import life.corevia.app.ui.profile.ProfileViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.profile.ProfileViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.route.RouteViewModel;
import life.corevia.app.ui.route.RouteViewModel_HiltModules;
import life.corevia.app.ui.route.RouteViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.route.RouteViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.settings.SettingsViewModel;
import life.corevia.app.ui.settings.SettingsViewModel_HiltModules;
import life.corevia.app.ui.settings.SettingsViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.settings.SettingsViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.social.CommentsViewModel;
import life.corevia.app.ui.social.CommentsViewModel_HiltModules;
import life.corevia.app.ui.social.CommentsViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.social.CommentsViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.social.CreatePostViewModel;
import life.corevia.app.ui.social.CreatePostViewModel_HiltModules;
import life.corevia.app.ui.social.CreatePostViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.social.CreatePostViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.social.SocialFeedViewModel;
import life.corevia.app.ui.social.SocialFeedViewModel_HiltModules;
import life.corevia.app.ui.social.SocialFeedViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.social.SocialFeedViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.survey.DailySurveyViewModel;
import life.corevia.app.ui.survey.DailySurveyViewModel_HiltModules;
import life.corevia.app.ui.survey.DailySurveyViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.survey.DailySurveyViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.trainerhub.CreateProductViewModel;
import life.corevia.app.ui.trainerhub.CreateProductViewModel_HiltModules;
import life.corevia.app.ui.trainerhub.CreateProductViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.trainerhub.CreateProductViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.trainerhub.CreateSessionViewModel;
import life.corevia.app.ui.trainerhub.CreateSessionViewModel_HiltModules;
import life.corevia.app.ui.trainerhub.CreateSessionViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.trainerhub.CreateSessionViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.trainerhub.TrainerProductsViewModel;
import life.corevia.app.ui.trainerhub.TrainerProductsViewModel_HiltModules;
import life.corevia.app.ui.trainerhub.TrainerProductsViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.trainerhub.TrainerProductsViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.trainerhub.TrainerSessionsViewModel;
import life.corevia.app.ui.trainerhub.TrainerSessionsViewModel_HiltModules;
import life.corevia.app.ui.trainerhub.TrainerSessionsViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.trainerhub.TrainerSessionsViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.trainers.TrainerBrowseViewModel;
import life.corevia.app.ui.trainers.TrainerBrowseViewModel_HiltModules;
import life.corevia.app.ui.trainers.TrainerBrowseViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.trainers.TrainerBrowseViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.workout.AddWorkoutViewModel;
import life.corevia.app.ui.workout.AddWorkoutViewModel_HiltModules;
import life.corevia.app.ui.workout.AddWorkoutViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.workout.AddWorkoutViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import life.corevia.app.ui.workout.WorkoutViewModel;
import life.corevia.app.ui.workout.WorkoutViewModel_HiltModules;
import life.corevia.app.ui.workout.WorkoutViewModel_HiltModules_BindsModule_Binds_LazyMapKey;
import life.corevia.app.ui.workout.WorkoutViewModel_HiltModules_KeyModule_Provide_LazyMapKey;
import okhttp3.OkHttpClient;
import retrofit2.Retrofit;

@DaggerGenerated
@Generated(
    value = "dagger.internal.codegen.ComponentProcessor",
    comments = "https://dagger.dev"
)
@SuppressWarnings({
    "unchecked",
    "rawtypes",
    "KotlinInternal",
    "KotlinInternalInJava",
    "cast",
    "deprecation",
    "nullness:initialization.field.uninitialized"
})
public final class DaggerCoreViaApp_HiltComponents_SingletonC {
  private DaggerCoreViaApp_HiltComponents_SingletonC() {
  }

  public static Builder builder() {
    return new Builder();
  }

  public static final class Builder {
    private ApplicationContextModule applicationContextModule;

    private Builder() {
    }

    public Builder applicationContextModule(ApplicationContextModule applicationContextModule) {
      this.applicationContextModule = Preconditions.checkNotNull(applicationContextModule);
      return this;
    }

    public CoreViaApp_HiltComponents.SingletonC build() {
      Preconditions.checkBuilderRequirement(applicationContextModule, ApplicationContextModule.class);
      return new SingletonCImpl(applicationContextModule);
    }
  }

  private static final class ActivityRetainedCBuilder implements CoreViaApp_HiltComponents.ActivityRetainedC.Builder {
    private final SingletonCImpl singletonCImpl;

    private SavedStateHandleHolder savedStateHandleHolder;

    private ActivityRetainedCBuilder(SingletonCImpl singletonCImpl) {
      this.singletonCImpl = singletonCImpl;
    }

    @Override
    public ActivityRetainedCBuilder savedStateHandleHolder(
        SavedStateHandleHolder savedStateHandleHolder) {
      this.savedStateHandleHolder = Preconditions.checkNotNull(savedStateHandleHolder);
      return this;
    }

    @Override
    public CoreViaApp_HiltComponents.ActivityRetainedC build() {
      Preconditions.checkBuilderRequirement(savedStateHandleHolder, SavedStateHandleHolder.class);
      return new ActivityRetainedCImpl(singletonCImpl, savedStateHandleHolder);
    }
  }

  private static final class ActivityCBuilder implements CoreViaApp_HiltComponents.ActivityC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private Activity activity;

    private ActivityCBuilder(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
    }

    @Override
    public ActivityCBuilder activity(Activity activity) {
      this.activity = Preconditions.checkNotNull(activity);
      return this;
    }

    @Override
    public CoreViaApp_HiltComponents.ActivityC build() {
      Preconditions.checkBuilderRequirement(activity, Activity.class);
      return new ActivityCImpl(singletonCImpl, activityRetainedCImpl, activity);
    }
  }

  private static final class FragmentCBuilder implements CoreViaApp_HiltComponents.FragmentC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private Fragment fragment;

    private FragmentCBuilder(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, ActivityCImpl activityCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;
    }

    @Override
    public FragmentCBuilder fragment(Fragment fragment) {
      this.fragment = Preconditions.checkNotNull(fragment);
      return this;
    }

    @Override
    public CoreViaApp_HiltComponents.FragmentC build() {
      Preconditions.checkBuilderRequirement(fragment, Fragment.class);
      return new FragmentCImpl(singletonCImpl, activityRetainedCImpl, activityCImpl, fragment);
    }
  }

  private static final class ViewWithFragmentCBuilder implements CoreViaApp_HiltComponents.ViewWithFragmentC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private final FragmentCImpl fragmentCImpl;

    private View view;

    private ViewWithFragmentCBuilder(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, ActivityCImpl activityCImpl,
        FragmentCImpl fragmentCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;
      this.fragmentCImpl = fragmentCImpl;
    }

    @Override
    public ViewWithFragmentCBuilder view(View view) {
      this.view = Preconditions.checkNotNull(view);
      return this;
    }

    @Override
    public CoreViaApp_HiltComponents.ViewWithFragmentC build() {
      Preconditions.checkBuilderRequirement(view, View.class);
      return new ViewWithFragmentCImpl(singletonCImpl, activityRetainedCImpl, activityCImpl, fragmentCImpl, view);
    }
  }

  private static final class ViewCBuilder implements CoreViaApp_HiltComponents.ViewC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private View view;

    private ViewCBuilder(SingletonCImpl singletonCImpl, ActivityRetainedCImpl activityRetainedCImpl,
        ActivityCImpl activityCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;
    }

    @Override
    public ViewCBuilder view(View view) {
      this.view = Preconditions.checkNotNull(view);
      return this;
    }

    @Override
    public CoreViaApp_HiltComponents.ViewC build() {
      Preconditions.checkBuilderRequirement(view, View.class);
      return new ViewCImpl(singletonCImpl, activityRetainedCImpl, activityCImpl, view);
    }
  }

  private static final class ViewModelCBuilder implements CoreViaApp_HiltComponents.ViewModelC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private SavedStateHandle savedStateHandle;

    private ViewModelLifecycle viewModelLifecycle;

    private ViewModelCBuilder(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
    }

    @Override
    public ViewModelCBuilder savedStateHandle(SavedStateHandle handle) {
      this.savedStateHandle = Preconditions.checkNotNull(handle);
      return this;
    }

    @Override
    public ViewModelCBuilder viewModelLifecycle(ViewModelLifecycle viewModelLifecycle) {
      this.viewModelLifecycle = Preconditions.checkNotNull(viewModelLifecycle);
      return this;
    }

    @Override
    public CoreViaApp_HiltComponents.ViewModelC build() {
      Preconditions.checkBuilderRequirement(savedStateHandle, SavedStateHandle.class);
      Preconditions.checkBuilderRequirement(viewModelLifecycle, ViewModelLifecycle.class);
      return new ViewModelCImpl(singletonCImpl, activityRetainedCImpl, savedStateHandle, viewModelLifecycle);
    }
  }

  private static final class ServiceCBuilder implements CoreViaApp_HiltComponents.ServiceC.Builder {
    private final SingletonCImpl singletonCImpl;

    private Service service;

    private ServiceCBuilder(SingletonCImpl singletonCImpl) {
      this.singletonCImpl = singletonCImpl;
    }

    @Override
    public ServiceCBuilder service(Service service) {
      this.service = Preconditions.checkNotNull(service);
      return this;
    }

    @Override
    public CoreViaApp_HiltComponents.ServiceC build() {
      Preconditions.checkBuilderRequirement(service, Service.class);
      return new ServiceCImpl(singletonCImpl, service);
    }
  }

  private static final class ViewWithFragmentCImpl extends CoreViaApp_HiltComponents.ViewWithFragmentC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private final FragmentCImpl fragmentCImpl;

    private final ViewWithFragmentCImpl viewWithFragmentCImpl = this;

    private ViewWithFragmentCImpl(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, ActivityCImpl activityCImpl,
        FragmentCImpl fragmentCImpl, View viewParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;
      this.fragmentCImpl = fragmentCImpl;


    }
  }

  private static final class FragmentCImpl extends CoreViaApp_HiltComponents.FragmentC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private final FragmentCImpl fragmentCImpl = this;

    private FragmentCImpl(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, ActivityCImpl activityCImpl,
        Fragment fragmentParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;


    }

    @Override
    public DefaultViewModelFactories.InternalFactoryFactory getHiltInternalFactoryFactory() {
      return activityCImpl.getHiltInternalFactoryFactory();
    }

    @Override
    public ViewWithFragmentComponentBuilder viewWithFragmentComponentBuilder() {
      return new ViewWithFragmentCBuilder(singletonCImpl, activityRetainedCImpl, activityCImpl, fragmentCImpl);
    }
  }

  private static final class ViewCImpl extends CoreViaApp_HiltComponents.ViewC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private final ViewCImpl viewCImpl = this;

    private ViewCImpl(SingletonCImpl singletonCImpl, ActivityRetainedCImpl activityRetainedCImpl,
        ActivityCImpl activityCImpl, View viewParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;


    }
  }

  private static final class ActivityCImpl extends CoreViaApp_HiltComponents.ActivityC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl = this;

    private ActivityCImpl(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, Activity activityParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;


    }

    @Override
    public DefaultViewModelFactories.InternalFactoryFactory getHiltInternalFactoryFactory() {
      return DefaultViewModelFactories_InternalFactoryFactory_Factory.newInstance(getViewModelKeys(), new ViewModelCBuilder(singletonCImpl, activityRetainedCImpl));
    }

    @Override
    public Map<Class<?>, Boolean> getViewModelKeys() {
      return LazyClassKeyMap.<Boolean>of(MapBuilder.<String, Boolean>newMapBuilder(36).put(AICalorieViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, AICalorieViewModel_HiltModules.KeyModule.provide()).put(AddFoodViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, AddFoodViewModel_HiltModules.KeyModule.provide()).put(AddWorkoutViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, AddWorkoutViewModel_HiltModules.KeyModule.provide()).put(AnalyticsDashboardViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, AnalyticsDashboardViewModel_HiltModules.KeyModule.provide()).put(ChatDetailViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, ChatDetailViewModel_HiltModules.KeyModule.provide()).put(CommentsViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, CommentsViewModel_HiltModules.KeyModule.provide()).put(ContentViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, ContentViewModel_HiltModules.KeyModule.provide()).put(ConversationsViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, ConversationsViewModel_HiltModules.KeyModule.provide()).put(CreatePostViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, CreatePostViewModel_HiltModules.KeyModule.provide()).put(CreateProductViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, CreateProductViewModel_HiltModules.KeyModule.provide()).put(CreateSessionViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, CreateSessionViewModel_HiltModules.KeyModule.provide()).put(DailySurveyViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, DailySurveyViewModel_HiltModules.KeyModule.provide()).put(FoodAICalorieViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, FoodAICalorieViewModel_HiltModules.KeyModule.provide()).put(FoodViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, FoodViewModel_HiltModules.KeyModule.provide()).put(ForgotPasswordViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, ForgotPasswordViewModel_HiltModules.KeyModule.provide()).put(HomeViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, HomeViewModel_HiltModules.KeyModule.provide()).put(LiveSessionDetailViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, LiveSessionDetailViewModel_HiltModules.KeyModule.provide()).put(LiveSessionViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, LiveSessionViewModel_HiltModules.KeyModule.provide()).put(LoginViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, LoginViewModel_HiltModules.KeyModule.provide()).put(MarketplaceViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, MarketplaceViewModel_HiltModules.KeyModule.provide()).put(MealPlanViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, MealPlanViewModel_HiltModules.KeyModule.provide()).put(OnboardingViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, OnboardingViewModel_HiltModules.KeyModule.provide()).put(PremiumViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, PremiumViewModel_HiltModules.KeyModule.provide()).put(ProductDetailViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, ProductDetailViewModel_HiltModules.KeyModule.provide()).put(ProfileViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, ProfileViewModel_HiltModules.KeyModule.provide()).put(RegisterViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, RegisterViewModel_HiltModules.KeyModule.provide()).put(RouteViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, RouteViewModel_HiltModules.KeyModule.provide()).put(SettingsViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, SettingsViewModel_HiltModules.KeyModule.provide()).put(SocialFeedViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, SocialFeedViewModel_HiltModules.KeyModule.provide()).put(TrainerBrowseViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, TrainerBrowseViewModel_HiltModules.KeyModule.provide()).put(TrainerHomeViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, TrainerHomeViewModel_HiltModules.KeyModule.provide()).put(TrainerProductsViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, TrainerProductsViewModel_HiltModules.KeyModule.provide()).put(TrainerSessionsViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, TrainerSessionsViewModel_HiltModules.KeyModule.provide()).put(TrainerVerificationViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, TrainerVerificationViewModel_HiltModules.KeyModule.provide()).put(TrainingPlanViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, TrainingPlanViewModel_HiltModules.KeyModule.provide()).put(WorkoutViewModel_HiltModules_KeyModule_Provide_LazyMapKey.lazyClassKeyName, WorkoutViewModel_HiltModules.KeyModule.provide()).build());
    }

    @Override
    public ViewModelComponentBuilder getViewModelComponentBuilder() {
      return new ViewModelCBuilder(singletonCImpl, activityRetainedCImpl);
    }

    @Override
    public FragmentComponentBuilder fragmentComponentBuilder() {
      return new FragmentCBuilder(singletonCImpl, activityRetainedCImpl, activityCImpl);
    }

    @Override
    public ViewComponentBuilder viewComponentBuilder() {
      return new ViewCBuilder(singletonCImpl, activityRetainedCImpl, activityCImpl);
    }

    @Override
    public void injectMainActivity(MainActivity arg0) {
    }
  }

  private static final class ViewModelCImpl extends CoreViaApp_HiltComponents.ViewModelC {
    private final SavedStateHandle savedStateHandle;

    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ViewModelCImpl viewModelCImpl = this;

    private Provider<AICalorieViewModel> aICalorieViewModelProvider;

    private Provider<AddFoodViewModel> addFoodViewModelProvider;

    private Provider<AddWorkoutViewModel> addWorkoutViewModelProvider;

    private Provider<AnalyticsDashboardViewModel> analyticsDashboardViewModelProvider;

    private Provider<ChatDetailViewModel> chatDetailViewModelProvider;

    private Provider<CommentsViewModel> commentsViewModelProvider;

    private Provider<ContentViewModel> contentViewModelProvider;

    private Provider<ConversationsViewModel> conversationsViewModelProvider;

    private Provider<CreatePostViewModel> createPostViewModelProvider;

    private Provider<CreateProductViewModel> createProductViewModelProvider;

    private Provider<CreateSessionViewModel> createSessionViewModelProvider;

    private Provider<DailySurveyViewModel> dailySurveyViewModelProvider;

    private Provider<FoodAICalorieViewModel> foodAICalorieViewModelProvider;

    private Provider<FoodViewModel> foodViewModelProvider;

    private Provider<ForgotPasswordViewModel> forgotPasswordViewModelProvider;

    private Provider<HomeViewModel> homeViewModelProvider;

    private Provider<LiveSessionDetailViewModel> liveSessionDetailViewModelProvider;

    private Provider<LiveSessionViewModel> liveSessionViewModelProvider;

    private Provider<LoginViewModel> loginViewModelProvider;

    private Provider<MarketplaceViewModel> marketplaceViewModelProvider;

    private Provider<MealPlanViewModel> mealPlanViewModelProvider;

    private Provider<OnboardingViewModel> onboardingViewModelProvider;

    private Provider<PremiumViewModel> premiumViewModelProvider;

    private Provider<ProductDetailViewModel> productDetailViewModelProvider;

    private Provider<ProfileViewModel> profileViewModelProvider;

    private Provider<RegisterViewModel> registerViewModelProvider;

    private Provider<RouteViewModel> routeViewModelProvider;

    private Provider<SettingsViewModel> settingsViewModelProvider;

    private Provider<SocialFeedViewModel> socialFeedViewModelProvider;

    private Provider<TrainerBrowseViewModel> trainerBrowseViewModelProvider;

    private Provider<TrainerHomeViewModel> trainerHomeViewModelProvider;

    private Provider<TrainerProductsViewModel> trainerProductsViewModelProvider;

    private Provider<TrainerSessionsViewModel> trainerSessionsViewModelProvider;

    private Provider<TrainerVerificationViewModel> trainerVerificationViewModelProvider;

    private Provider<TrainingPlanViewModel> trainingPlanViewModelProvider;

    private Provider<WorkoutViewModel> workoutViewModelProvider;

    private ViewModelCImpl(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, SavedStateHandle savedStateHandleParam,
        ViewModelLifecycle viewModelLifecycleParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.savedStateHandle = savedStateHandleParam;
      initialize(savedStateHandleParam, viewModelLifecycleParam);
      initialize2(savedStateHandleParam, viewModelLifecycleParam);

    }

    @SuppressWarnings("unchecked")
    private void initialize(final SavedStateHandle savedStateHandleParam,
        final ViewModelLifecycle viewModelLifecycleParam) {
      this.aICalorieViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 0);
      this.addFoodViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 1);
      this.addWorkoutViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 2);
      this.analyticsDashboardViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 3);
      this.chatDetailViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 4);
      this.commentsViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 5);
      this.contentViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 6);
      this.conversationsViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 7);
      this.createPostViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 8);
      this.createProductViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 9);
      this.createSessionViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 10);
      this.dailySurveyViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 11);
      this.foodAICalorieViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 12);
      this.foodViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 13);
      this.forgotPasswordViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 14);
      this.homeViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 15);
      this.liveSessionDetailViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 16);
      this.liveSessionViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 17);
      this.loginViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 18);
      this.marketplaceViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 19);
      this.mealPlanViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 20);
      this.onboardingViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 21);
      this.premiumViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 22);
      this.productDetailViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 23);
      this.profileViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 24);
    }

    @SuppressWarnings("unchecked")
    private void initialize2(final SavedStateHandle savedStateHandleParam,
        final ViewModelLifecycle viewModelLifecycleParam) {
      this.registerViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 25);
      this.routeViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 26);
      this.settingsViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 27);
      this.socialFeedViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 28);
      this.trainerBrowseViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 29);
      this.trainerHomeViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 30);
      this.trainerProductsViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 31);
      this.trainerSessionsViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 32);
      this.trainerVerificationViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 33);
      this.trainingPlanViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 34);
      this.workoutViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 35);
    }

    @Override
    public Map<Class<?>, javax.inject.Provider<ViewModel>> getHiltViewModelMap() {
      return LazyClassKeyMap.<javax.inject.Provider<ViewModel>>of(MapBuilder.<String, javax.inject.Provider<ViewModel>>newMapBuilder(36).put(AICalorieViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) aICalorieViewModelProvider)).put(AddFoodViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) addFoodViewModelProvider)).put(AddWorkoutViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) addWorkoutViewModelProvider)).put(AnalyticsDashboardViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) analyticsDashboardViewModelProvider)).put(ChatDetailViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) chatDetailViewModelProvider)).put(CommentsViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) commentsViewModelProvider)).put(ContentViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) contentViewModelProvider)).put(ConversationsViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) conversationsViewModelProvider)).put(CreatePostViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) createPostViewModelProvider)).put(CreateProductViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) createProductViewModelProvider)).put(CreateSessionViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) createSessionViewModelProvider)).put(DailySurveyViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) dailySurveyViewModelProvider)).put(FoodAICalorieViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) foodAICalorieViewModelProvider)).put(FoodViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) foodViewModelProvider)).put(ForgotPasswordViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) forgotPasswordViewModelProvider)).put(HomeViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) homeViewModelProvider)).put(LiveSessionDetailViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) liveSessionDetailViewModelProvider)).put(LiveSessionViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) liveSessionViewModelProvider)).put(LoginViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) loginViewModelProvider)).put(MarketplaceViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) marketplaceViewModelProvider)).put(MealPlanViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) mealPlanViewModelProvider)).put(OnboardingViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) onboardingViewModelProvider)).put(PremiumViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) premiumViewModelProvider)).put(ProductDetailViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) productDetailViewModelProvider)).put(ProfileViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) profileViewModelProvider)).put(RegisterViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) registerViewModelProvider)).put(RouteViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) routeViewModelProvider)).put(SettingsViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) settingsViewModelProvider)).put(SocialFeedViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) socialFeedViewModelProvider)).put(TrainerBrowseViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) trainerBrowseViewModelProvider)).put(TrainerHomeViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) trainerHomeViewModelProvider)).put(TrainerProductsViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) trainerProductsViewModelProvider)).put(TrainerSessionsViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) trainerSessionsViewModelProvider)).put(TrainerVerificationViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) trainerVerificationViewModelProvider)).put(TrainingPlanViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) trainingPlanViewModelProvider)).put(WorkoutViewModel_HiltModules_BindsModule_Binds_LazyMapKey.lazyClassKeyName, ((Provider) workoutViewModelProvider)).build());
    }

    @Override
    public Map<Class<?>, Object> getHiltViewModelAssistedMap() {
      return Collections.<Class<?>, Object>emptyMap();
    }

    private static final class SwitchingProvider<T> implements Provider<T> {
      private final SingletonCImpl singletonCImpl;

      private final ActivityRetainedCImpl activityRetainedCImpl;

      private final ViewModelCImpl viewModelCImpl;

      private final int id;

      SwitchingProvider(SingletonCImpl singletonCImpl, ActivityRetainedCImpl activityRetainedCImpl,
          ViewModelCImpl viewModelCImpl, int id) {
        this.singletonCImpl = singletonCImpl;
        this.activityRetainedCImpl = activityRetainedCImpl;
        this.viewModelCImpl = viewModelCImpl;
        this.id = id;
      }

      @SuppressWarnings("unchecked")
      @Override
      public T get() {
        switch (id) {
          case 0: // life.corevia.app.ui.aicalorie.AICalorieViewModel 
          return (T) new AICalorieViewModel(singletonCImpl.provideAICalorieRepositoryProvider.get());

          case 1: // life.corevia.app.ui.food.AddFoodViewModel 
          return (T) new AddFoodViewModel(singletonCImpl.provideFoodRepositoryProvider.get());

          case 2: // life.corevia.app.ui.workout.AddWorkoutViewModel 
          return (T) new AddWorkoutViewModel(singletonCImpl.provideWorkoutRepositoryProvider.get());

          case 3: // life.corevia.app.ui.analytics.AnalyticsDashboardViewModel 
          return (T) new AnalyticsDashboardViewModel(singletonCImpl.analyticsRepositoryProvider.get());

          case 4: // life.corevia.app.ui.chat.ChatDetailViewModel 
          return (T) new ChatDetailViewModel(viewModelCImpl.savedStateHandle, singletonCImpl.provideChatRepositoryProvider.get());

          case 5: // life.corevia.app.ui.social.CommentsViewModel 
          return (T) new CommentsViewModel(viewModelCImpl.savedStateHandle, singletonCImpl.socialRepositoryProvider.get());

          case 6: // life.corevia.app.ui.content.ContentViewModel 
          return (T) new ContentViewModel(singletonCImpl.provideContentRepositoryProvider.get());

          case 7: // life.corevia.app.ui.chat.ConversationsViewModel 
          return (T) new ConversationsViewModel(singletonCImpl.provideChatRepositoryProvider.get());

          case 8: // life.corevia.app.ui.social.CreatePostViewModel 
          return (T) new CreatePostViewModel(singletonCImpl.socialRepositoryProvider.get());

          case 9: // life.corevia.app.ui.trainerhub.CreateProductViewModel 
          return (T) new CreateProductViewModel(singletonCImpl.marketplaceRepositoryProvider.get());

          case 10: // life.corevia.app.ui.trainerhub.CreateSessionViewModel 
          return (T) new CreateSessionViewModel(singletonCImpl.liveSessionRepositoryProvider.get());

          case 11: // life.corevia.app.ui.survey.DailySurveyViewModel 
          return (T) new DailySurveyViewModel(singletonCImpl.provideSurveyRepositoryProvider.get());

          case 12: // life.corevia.app.ui.food.FoodAICalorieViewModel 
          return (T) new FoodAICalorieViewModel(singletonCImpl.provideAICalorieRepositoryProvider.get());

          case 13: // life.corevia.app.ui.food.FoodViewModel 
          return (T) new FoodViewModel(singletonCImpl.provideFoodRepositoryProvider.get());

          case 14: // life.corevia.app.ui.auth.ForgotPasswordViewModel 
          return (T) new ForgotPasswordViewModel(singletonCImpl.provideAuthRepositoryProvider.get());

          case 15: // life.corevia.app.ui.home.HomeViewModel 
          return (T) new HomeViewModel(singletonCImpl.tokenManagerProvider.get(), singletonCImpl.provideWorkoutRepositoryProvider.get(), singletonCImpl.provideAuthRepositoryProvider.get());

          case 16: // life.corevia.app.ui.livesession.LiveSessionDetailViewModel 
          return (T) new LiveSessionDetailViewModel(viewModelCImpl.savedStateHandle, singletonCImpl.liveSessionRepositoryProvider.get());

          case 17: // life.corevia.app.ui.livesession.LiveSessionViewModel 
          return (T) new LiveSessionViewModel(singletonCImpl.liveSessionRepositoryProvider.get());

          case 18: // life.corevia.app.ui.auth.LoginViewModel 
          return (T) new LoginViewModel(singletonCImpl.provideAuthRepositoryProvider.get());

          case 19: // life.corevia.app.ui.marketplace.MarketplaceViewModel 
          return (T) new MarketplaceViewModel(singletonCImpl.marketplaceRepositoryProvider.get());

          case 20: // life.corevia.app.ui.plans.MealPlanViewModel 
          return (T) new MealPlanViewModel(singletonCImpl.provideMealPlanRepositoryProvider.get());

          case 21: // life.corevia.app.ui.onboarding.OnboardingViewModel 
          return (T) new OnboardingViewModel(singletonCImpl.provideOnboardingRepositoryProvider.get());

          case 22: // life.corevia.app.ui.premium.PremiumViewModel 
          return (T) new PremiumViewModel(singletonCImpl.tokenManagerProvider.get(), singletonCImpl.premiumRepositoryProvider.get());

          case 23: // life.corevia.app.ui.marketplace.ProductDetailViewModel 
          return (T) new ProductDetailViewModel(viewModelCImpl.savedStateHandle, singletonCImpl.marketplaceRepositoryProvider.get());

          case 24: // life.corevia.app.ui.profile.ProfileViewModel 
          return (T) new ProfileViewModel(singletonCImpl.tokenManagerProvider.get(), singletonCImpl.provideAuthRepositoryProvider.get(), singletonCImpl.provideTrainerDashboardRepositoryProvider.get(), singletonCImpl.provideWorkoutRepositoryProvider.get(), singletonCImpl.provideFoodRepositoryProvider.get());

          case 25: // life.corevia.app.ui.auth.RegisterViewModel 
          return (T) new RegisterViewModel(singletonCImpl.provideAuthRepositoryProvider.get());

          case 26: // life.corevia.app.ui.route.RouteViewModel 
          return (T) new RouteViewModel(singletonCImpl.provideRouteRepositoryProvider.get(), singletonCImpl.provideWorkoutRepositoryProvider.get(), singletonCImpl.provideAuthRepositoryProvider.get(), ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule));

          case 27: // life.corevia.app.ui.settings.SettingsViewModel 
          return (T) new SettingsViewModel(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule), singletonCImpl.tokenManagerProvider.get(), singletonCImpl.provideSharedPreferencesProvider.get());

          case 28: // life.corevia.app.ui.social.SocialFeedViewModel 
          return (T) new SocialFeedViewModel(singletonCImpl.socialRepositoryProvider.get());

          case 29: // life.corevia.app.ui.trainers.TrainerBrowseViewModel 
          return (T) new TrainerBrowseViewModel(singletonCImpl.provideTrainerRepositoryProvider.get());

          case 30: // life.corevia.app.ui.home.TrainerHomeViewModel 
          return (T) new TrainerHomeViewModel(singletonCImpl.tokenManagerProvider.get(), singletonCImpl.provideTrainerDashboardRepositoryProvider.get(), singletonCImpl.provideAuthRepositoryProvider.get());

          case 31: // life.corevia.app.ui.trainerhub.TrainerProductsViewModel 
          return (T) new TrainerProductsViewModel(singletonCImpl.marketplaceRepositoryProvider.get());

          case 32: // life.corevia.app.ui.trainerhub.TrainerSessionsViewModel 
          return (T) new TrainerSessionsViewModel(singletonCImpl.liveSessionRepositoryProvider.get());

          case 33: // life.corevia.app.ui.auth.TrainerVerificationViewModel 
          return (T) new TrainerVerificationViewModel(singletonCImpl.provideAuthRepositoryProvider.get());

          case 34: // life.corevia.app.ui.plans.TrainingPlanViewModel 
          return (T) new TrainingPlanViewModel(singletonCImpl.provideTrainingPlanRepositoryProvider.get(), singletonCImpl.provideTrainerRepositoryProvider.get());

          case 35: // life.corevia.app.ui.workout.WorkoutViewModel 
          return (T) new WorkoutViewModel(singletonCImpl.provideWorkoutRepositoryProvider.get());

          default: throw new AssertionError(id);
        }
      }
    }
  }

  private static final class ActivityRetainedCImpl extends CoreViaApp_HiltComponents.ActivityRetainedC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl = this;

    private Provider<ActivityRetainedLifecycle> provideActivityRetainedLifecycleProvider;

    private ActivityRetainedCImpl(SingletonCImpl singletonCImpl,
        SavedStateHandleHolder savedStateHandleHolderParam) {
      this.singletonCImpl = singletonCImpl;

      initialize(savedStateHandleHolderParam);

    }

    @SuppressWarnings("unchecked")
    private void initialize(final SavedStateHandleHolder savedStateHandleHolderParam) {
      this.provideActivityRetainedLifecycleProvider = DoubleCheck.provider(new SwitchingProvider<ActivityRetainedLifecycle>(singletonCImpl, activityRetainedCImpl, 0));
    }

    @Override
    public ActivityComponentBuilder activityComponentBuilder() {
      return new ActivityCBuilder(singletonCImpl, activityRetainedCImpl);
    }

    @Override
    public ActivityRetainedLifecycle getActivityRetainedLifecycle() {
      return provideActivityRetainedLifecycleProvider.get();
    }

    private static final class SwitchingProvider<T> implements Provider<T> {
      private final SingletonCImpl singletonCImpl;

      private final ActivityRetainedCImpl activityRetainedCImpl;

      private final int id;

      SwitchingProvider(SingletonCImpl singletonCImpl, ActivityRetainedCImpl activityRetainedCImpl,
          int id) {
        this.singletonCImpl = singletonCImpl;
        this.activityRetainedCImpl = activityRetainedCImpl;
        this.id = id;
      }

      @SuppressWarnings("unchecked")
      @Override
      public T get() {
        switch (id) {
          case 0: // dagger.hilt.android.ActivityRetainedLifecycle 
          return (T) ActivityRetainedComponentManager_LifecycleModule_ProvideActivityRetainedLifecycleFactory.provideActivityRetainedLifecycle();

          default: throw new AssertionError(id);
        }
      }
    }
  }

  private static final class ServiceCImpl extends CoreViaApp_HiltComponents.ServiceC {
    private final SingletonCImpl singletonCImpl;

    private final ServiceCImpl serviceCImpl = this;

    private ServiceCImpl(SingletonCImpl singletonCImpl, Service serviceParam) {
      this.singletonCImpl = singletonCImpl;


    }
  }

  private static final class SingletonCImpl extends CoreViaApp_HiltComponents.SingletonC {
    private final ApplicationContextModule applicationContextModule;

    private final SingletonCImpl singletonCImpl = this;

    private Provider<TokenManager> tokenManagerProvider;

    private Provider<OkHttpClient> provideOkHttpClientProvider;

    private Provider<Json> provideJsonProvider;

    private Provider<Retrofit> provideRetrofitProvider;

    private Provider<ApiService> provideApiServiceProvider;

    private Provider<FoodDatabaseService> foodDatabaseServiceProvider;

    private Provider<OnDeviceFoodAnalyzer> onDeviceFoodAnalyzerProvider;

    private Provider<AICalorieRepository> provideAICalorieRepositoryProvider;

    private Provider<FoodRepository> provideFoodRepositoryProvider;

    private Provider<WorkoutRepository> provideWorkoutRepositoryProvider;

    private Provider<AnalyticsRepository> analyticsRepositoryProvider;

    private Provider<ChatRepository> provideChatRepositoryProvider;

    private Provider<SocialRepository> socialRepositoryProvider;

    private Provider<ContentRepository> provideContentRepositoryProvider;

    private Provider<MarketplaceRepository> marketplaceRepositoryProvider;

    private Provider<LiveSessionRepository> liveSessionRepositoryProvider;

    private Provider<SurveyRepository> provideSurveyRepositoryProvider;

    private Provider<AuthRepository> provideAuthRepositoryProvider;

    private Provider<MealPlanRepository> provideMealPlanRepositoryProvider;

    private Provider<SharedPreferences> provideSharedPreferencesProvider;

    private Provider<OnboardingRepository> provideOnboardingRepositoryProvider;

    private Provider<PremiumRepository> premiumRepositoryProvider;

    private Provider<TrainerDashboardRepository> provideTrainerDashboardRepositoryProvider;

    private Provider<RouteRepository> provideRouteRepositoryProvider;

    private Provider<TrainerRepository> provideTrainerRepositoryProvider;

    private Provider<TrainingPlanRepository> provideTrainingPlanRepositoryProvider;

    private SingletonCImpl(ApplicationContextModule applicationContextModuleParam) {
      this.applicationContextModule = applicationContextModuleParam;
      initialize(applicationContextModuleParam);
      initialize2(applicationContextModuleParam);

    }

    @SuppressWarnings("unchecked")
    private void initialize(final ApplicationContextModule applicationContextModuleParam) {
      this.tokenManagerProvider = DoubleCheck.provider(new SwitchingProvider<TokenManager>(singletonCImpl, 4));
      this.provideOkHttpClientProvider = DoubleCheck.provider(new SwitchingProvider<OkHttpClient>(singletonCImpl, 3));
      this.provideJsonProvider = DoubleCheck.provider(new SwitchingProvider<Json>(singletonCImpl, 5));
      this.provideRetrofitProvider = DoubleCheck.provider(new SwitchingProvider<Retrofit>(singletonCImpl, 2));
      this.provideApiServiceProvider = DoubleCheck.provider(new SwitchingProvider<ApiService>(singletonCImpl, 1));
      this.foodDatabaseServiceProvider = DoubleCheck.provider(new SwitchingProvider<FoodDatabaseService>(singletonCImpl, 7));
      this.onDeviceFoodAnalyzerProvider = DoubleCheck.provider(new SwitchingProvider<OnDeviceFoodAnalyzer>(singletonCImpl, 6));
      this.provideAICalorieRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<AICalorieRepository>(singletonCImpl, 0));
      this.provideFoodRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<FoodRepository>(singletonCImpl, 8));
      this.provideWorkoutRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<WorkoutRepository>(singletonCImpl, 9));
      this.analyticsRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<AnalyticsRepository>(singletonCImpl, 10));
      this.provideChatRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<ChatRepository>(singletonCImpl, 11));
      this.socialRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<SocialRepository>(singletonCImpl, 12));
      this.provideContentRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<ContentRepository>(singletonCImpl, 13));
      this.marketplaceRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<MarketplaceRepository>(singletonCImpl, 14));
      this.liveSessionRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<LiveSessionRepository>(singletonCImpl, 15));
      this.provideSurveyRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<SurveyRepository>(singletonCImpl, 16));
      this.provideAuthRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<AuthRepository>(singletonCImpl, 17));
      this.provideMealPlanRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<MealPlanRepository>(singletonCImpl, 18));
      this.provideSharedPreferencesProvider = DoubleCheck.provider(new SwitchingProvider<SharedPreferences>(singletonCImpl, 20));
      this.provideOnboardingRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<OnboardingRepository>(singletonCImpl, 19));
      this.premiumRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<PremiumRepository>(singletonCImpl, 21));
      this.provideTrainerDashboardRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<TrainerDashboardRepository>(singletonCImpl, 22));
      this.provideRouteRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<RouteRepository>(singletonCImpl, 23));
      this.provideTrainerRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<TrainerRepository>(singletonCImpl, 24));
    }

    @SuppressWarnings("unchecked")
    private void initialize2(final ApplicationContextModule applicationContextModuleParam) {
      this.provideTrainingPlanRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<TrainingPlanRepository>(singletonCImpl, 25));
    }

    @Override
    public Set<Boolean> getDisableFragmentGetContextFix() {
      return Collections.<Boolean>emptySet();
    }

    @Override
    public ActivityRetainedComponentBuilder retainedComponentBuilder() {
      return new ActivityRetainedCBuilder(singletonCImpl);
    }

    @Override
    public ServiceComponentBuilder serviceComponentBuilder() {
      return new ServiceCBuilder(singletonCImpl);
    }

    @Override
    public void injectCoreViaApp(CoreViaApp arg0) {
    }

    private static final class SwitchingProvider<T> implements Provider<T> {
      private final SingletonCImpl singletonCImpl;

      private final int id;

      SwitchingProvider(SingletonCImpl singletonCImpl, int id) {
        this.singletonCImpl = singletonCImpl;
        this.id = id;
      }

      @SuppressWarnings("unchecked")
      @Override
      public T get() {
        switch (id) {
          case 0: // life.corevia.app.data.repository.AICalorieRepository 
          return (T) RepositoryModule_ProvideAICalorieRepositoryFactory.provideAICalorieRepository(singletonCImpl.provideApiServiceProvider.get(), singletonCImpl.provideOkHttpClientProvider.get(), singletonCImpl.provideJsonProvider.get(), singletonCImpl.onDeviceFoodAnalyzerProvider.get());

          case 1: // life.corevia.app.data.remote.ApiService 
          return (T) NetworkModule_ProvideApiServiceFactory.provideApiService(singletonCImpl.provideRetrofitProvider.get());

          case 2: // retrofit2.Retrofit 
          return (T) NetworkModule_ProvideRetrofitFactory.provideRetrofit(singletonCImpl.provideOkHttpClientProvider.get(), singletonCImpl.provideJsonProvider.get());

          case 3: // okhttp3.OkHttpClient 
          return (T) NetworkModule_ProvideOkHttpClientFactory.provideOkHttpClient(singletonCImpl.tokenManagerProvider.get());

          case 4: // life.corevia.app.data.local.TokenManager 
          return (T) new TokenManager(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule));

          case 5: // kotlinx.serialization.json.Json 
          return (T) NetworkModule_ProvideJsonFactory.provideJson();

          case 6: // life.corevia.app.data.local.OnDeviceFoodAnalyzer 
          return (T) new OnDeviceFoodAnalyzer(singletonCImpl.foodDatabaseServiceProvider.get());

          case 7: // life.corevia.app.data.local.FoodDatabaseService 
          return (T) new FoodDatabaseService(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule));

          case 8: // life.corevia.app.data.repository.FoodRepository 
          return (T) RepositoryModule_ProvideFoodRepositoryFactory.provideFoodRepository(singletonCImpl.provideApiServiceProvider.get());

          case 9: // life.corevia.app.data.repository.WorkoutRepository 
          return (T) RepositoryModule_ProvideWorkoutRepositoryFactory.provideWorkoutRepository(singletonCImpl.provideApiServiceProvider.get());

          case 10: // life.corevia.app.data.repository.AnalyticsRepository 
          return (T) new AnalyticsRepository(singletonCImpl.provideApiServiceProvider.get());

          case 11: // life.corevia.app.data.repository.ChatRepository 
          return (T) RepositoryModule_ProvideChatRepositoryFactory.provideChatRepository(singletonCImpl.provideApiServiceProvider.get());

          case 12: // life.corevia.app.data.repository.SocialRepository 
          return (T) new SocialRepository(singletonCImpl.provideApiServiceProvider.get());

          case 13: // life.corevia.app.data.repository.ContentRepository 
          return (T) RepositoryModule_ProvideContentRepositoryFactory.provideContentRepository(singletonCImpl.provideApiServiceProvider.get(), singletonCImpl.provideOkHttpClientProvider.get());

          case 14: // life.corevia.app.data.repository.MarketplaceRepository 
          return (T) new MarketplaceRepository(singletonCImpl.provideApiServiceProvider.get());

          case 15: // life.corevia.app.data.repository.LiveSessionRepository 
          return (T) new LiveSessionRepository(singletonCImpl.provideApiServiceProvider.get());

          case 16: // life.corevia.app.data.repository.SurveyRepository 
          return (T) RepositoryModule_ProvideSurveyRepositoryFactory.provideSurveyRepository(singletonCImpl.provideApiServiceProvider.get());

          case 17: // life.corevia.app.data.repository.AuthRepository 
          return (T) RepositoryModule_ProvideAuthRepositoryFactory.provideAuthRepository(singletonCImpl.provideApiServiceProvider.get(), singletonCImpl.tokenManagerProvider.get());

          case 18: // life.corevia.app.data.repository.MealPlanRepository 
          return (T) RepositoryModule_ProvideMealPlanRepositoryFactory.provideMealPlanRepository(singletonCImpl.provideApiServiceProvider.get());

          case 19: // life.corevia.app.data.repository.OnboardingRepository 
          return (T) RepositoryModule_ProvideOnboardingRepositoryFactory.provideOnboardingRepository(singletonCImpl.provideApiServiceProvider.get(), singletonCImpl.provideSharedPreferencesProvider.get());

          case 20: // android.content.SharedPreferences 
          return (T) AppModule_ProvideSharedPreferencesFactory.provideSharedPreferences(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule));

          case 21: // life.corevia.app.data.repository.PremiumRepository 
          return (T) new PremiumRepository(singletonCImpl.provideApiServiceProvider.get());

          case 22: // life.corevia.app.data.repository.TrainerDashboardRepository 
          return (T) RepositoryModule_ProvideTrainerDashboardRepositoryFactory.provideTrainerDashboardRepository(singletonCImpl.provideApiServiceProvider.get());

          case 23: // life.corevia.app.data.repository.RouteRepository 
          return (T) RepositoryModule_ProvideRouteRepositoryFactory.provideRouteRepository(singletonCImpl.provideApiServiceProvider.get());

          case 24: // life.corevia.app.data.repository.TrainerRepository 
          return (T) RepositoryModule_ProvideTrainerRepositoryFactory.provideTrainerRepository(singletonCImpl.provideApiServiceProvider.get());

          case 25: // life.corevia.app.data.repository.TrainingPlanRepository 
          return (T) RepositoryModule_ProvideTrainingPlanRepositoryFactory.provideTrainingPlanRepository(singletonCImpl.provideApiServiceProvider.get());

          default: throw new AssertionError(id);
        }
      }
    }
  }
}
