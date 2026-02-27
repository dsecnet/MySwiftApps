package life.corevia.app;

import dagger.Binds;
import dagger.Component;
import dagger.Module;
import dagger.Subcomponent;
import dagger.hilt.android.components.ActivityComponent;
import dagger.hilt.android.components.ActivityRetainedComponent;
import dagger.hilt.android.components.FragmentComponent;
import dagger.hilt.android.components.ServiceComponent;
import dagger.hilt.android.components.ViewComponent;
import dagger.hilt.android.components.ViewModelComponent;
import dagger.hilt.android.components.ViewWithFragmentComponent;
import dagger.hilt.android.flags.FragmentGetContextFix;
import dagger.hilt.android.flags.HiltWrapper_FragmentGetContextFix_FragmentGetContextFixModule;
import dagger.hilt.android.internal.builders.ActivityComponentBuilder;
import dagger.hilt.android.internal.builders.ActivityRetainedComponentBuilder;
import dagger.hilt.android.internal.builders.FragmentComponentBuilder;
import dagger.hilt.android.internal.builders.ServiceComponentBuilder;
import dagger.hilt.android.internal.builders.ViewComponentBuilder;
import dagger.hilt.android.internal.builders.ViewModelComponentBuilder;
import dagger.hilt.android.internal.builders.ViewWithFragmentComponentBuilder;
import dagger.hilt.android.internal.lifecycle.DefaultViewModelFactories;
import dagger.hilt.android.internal.lifecycle.HiltViewModelFactory;
import dagger.hilt.android.internal.lifecycle.HiltWrapper_DefaultViewModelFactories_ActivityModule;
import dagger.hilt.android.internal.lifecycle.HiltWrapper_HiltViewModelFactory_ActivityCreatorEntryPoint;
import dagger.hilt.android.internal.lifecycle.HiltWrapper_HiltViewModelFactory_ViewModelModule;
import dagger.hilt.android.internal.managers.ActivityComponentManager;
import dagger.hilt.android.internal.managers.FragmentComponentManager;
import dagger.hilt.android.internal.managers.HiltWrapper_ActivityRetainedComponentManager_ActivityRetainedComponentBuilderEntryPoint;
import dagger.hilt.android.internal.managers.HiltWrapper_ActivityRetainedComponentManager_ActivityRetainedLifecycleEntryPoint;
import dagger.hilt.android.internal.managers.HiltWrapper_ActivityRetainedComponentManager_LifecycleModule;
import dagger.hilt.android.internal.managers.HiltWrapper_SavedStateHandleModule;
import dagger.hilt.android.internal.managers.ServiceComponentManager;
import dagger.hilt.android.internal.managers.ViewComponentManager;
import dagger.hilt.android.internal.modules.ApplicationContextModule;
import dagger.hilt.android.internal.modules.HiltWrapper_ActivityModule;
import dagger.hilt.android.scopes.ActivityRetainedScoped;
import dagger.hilt.android.scopes.ActivityScoped;
import dagger.hilt.android.scopes.FragmentScoped;
import dagger.hilt.android.scopes.ServiceScoped;
import dagger.hilt.android.scopes.ViewModelScoped;
import dagger.hilt.android.scopes.ViewScoped;
import dagger.hilt.components.SingletonComponent;
import dagger.hilt.internal.GeneratedComponent;
import dagger.hilt.migration.DisableInstallInCheck;
import javax.annotation.processing.Generated;
import javax.inject.Singleton;
import life.corevia.app.di.AppModule;
import life.corevia.app.di.NetworkModule;
import life.corevia.app.di.RepositoryModule;
import life.corevia.app.ui.aicalorie.AICalorieViewModel_HiltModules;
import life.corevia.app.ui.analytics.AnalyticsDashboardViewModel_HiltModules;
import life.corevia.app.ui.auth.ForgotPasswordViewModel_HiltModules;
import life.corevia.app.ui.auth.LoginViewModel_HiltModules;
import life.corevia.app.ui.auth.RegisterViewModel_HiltModules;
import life.corevia.app.ui.auth.TrainerVerificationViewModel_HiltModules;
import life.corevia.app.ui.chat.ChatDetailViewModel_HiltModules;
import life.corevia.app.ui.chat.ConversationsViewModel_HiltModules;
import life.corevia.app.ui.content.ContentViewModel_HiltModules;
import life.corevia.app.ui.food.AddFoodViewModel_HiltModules;
import life.corevia.app.ui.food.FoodAICalorieViewModel_HiltModules;
import life.corevia.app.ui.food.FoodViewModel_HiltModules;
import life.corevia.app.ui.home.HomeViewModel_HiltModules;
import life.corevia.app.ui.home.TrainerHomeViewModel_HiltModules;
import life.corevia.app.ui.livesession.LiveSessionDetailViewModel_HiltModules;
import life.corevia.app.ui.livesession.LiveSessionViewModel_HiltModules;
import life.corevia.app.ui.marketplace.MarketplaceViewModel_HiltModules;
import life.corevia.app.ui.marketplace.ProductDetailViewModel_HiltModules;
import life.corevia.app.ui.onboarding.OnboardingViewModel_HiltModules;
import life.corevia.app.ui.plans.MealPlanViewModel_HiltModules;
import life.corevia.app.ui.plans.TrainingPlanViewModel_HiltModules;
import life.corevia.app.ui.premium.PremiumViewModel_HiltModules;
import life.corevia.app.ui.profile.ProfileViewModel_HiltModules;
import life.corevia.app.ui.route.RouteViewModel_HiltModules;
import life.corevia.app.ui.settings.SettingsViewModel_HiltModules;
import life.corevia.app.ui.social.CommentsViewModel_HiltModules;
import life.corevia.app.ui.social.CreatePostViewModel_HiltModules;
import life.corevia.app.ui.social.SocialFeedViewModel_HiltModules;
import life.corevia.app.ui.survey.DailySurveyViewModel_HiltModules;
import life.corevia.app.ui.trainerhub.CreateProductViewModel_HiltModules;
import life.corevia.app.ui.trainerhub.CreateSessionViewModel_HiltModules;
import life.corevia.app.ui.trainerhub.TrainerProductsViewModel_HiltModules;
import life.corevia.app.ui.trainerhub.TrainerSessionsViewModel_HiltModules;
import life.corevia.app.ui.trainers.TrainerBrowseViewModel_HiltModules;
import life.corevia.app.ui.workout.AddWorkoutViewModel_HiltModules;
import life.corevia.app.ui.workout.WorkoutViewModel_HiltModules;

@Generated("dagger.hilt.processor.internal.root.RootProcessor")
public final class CoreViaApp_HiltComponents {
  private CoreViaApp_HiltComponents() {
  }

  @Module(
      subcomponents = ServiceC.class
  )
  @DisableInstallInCheck
  @Generated("dagger.hilt.processor.internal.root.RootProcessor")
  abstract interface ServiceCBuilderModule {
    @Binds
    ServiceComponentBuilder bind(ServiceC.Builder builder);
  }

  @Module(
      subcomponents = ActivityRetainedC.class
  )
  @DisableInstallInCheck
  @Generated("dagger.hilt.processor.internal.root.RootProcessor")
  abstract interface ActivityRetainedCBuilderModule {
    @Binds
    ActivityRetainedComponentBuilder bind(ActivityRetainedC.Builder builder);
  }

  @Module(
      subcomponents = ActivityC.class
  )
  @DisableInstallInCheck
  @Generated("dagger.hilt.processor.internal.root.RootProcessor")
  abstract interface ActivityCBuilderModule {
    @Binds
    ActivityComponentBuilder bind(ActivityC.Builder builder);
  }

  @Module(
      subcomponents = ViewModelC.class
  )
  @DisableInstallInCheck
  @Generated("dagger.hilt.processor.internal.root.RootProcessor")
  abstract interface ViewModelCBuilderModule {
    @Binds
    ViewModelComponentBuilder bind(ViewModelC.Builder builder);
  }

  @Module(
      subcomponents = ViewC.class
  )
  @DisableInstallInCheck
  @Generated("dagger.hilt.processor.internal.root.RootProcessor")
  abstract interface ViewCBuilderModule {
    @Binds
    ViewComponentBuilder bind(ViewC.Builder builder);
  }

  @Module(
      subcomponents = FragmentC.class
  )
  @DisableInstallInCheck
  @Generated("dagger.hilt.processor.internal.root.RootProcessor")
  abstract interface FragmentCBuilderModule {
    @Binds
    FragmentComponentBuilder bind(FragmentC.Builder builder);
  }

  @Module(
      subcomponents = ViewWithFragmentC.class
  )
  @DisableInstallInCheck
  @Generated("dagger.hilt.processor.internal.root.RootProcessor")
  abstract interface ViewWithFragmentCBuilderModule {
    @Binds
    ViewWithFragmentComponentBuilder bind(ViewWithFragmentC.Builder builder);
  }

  @Component(
      modules = {
          AppModule.class,
          ApplicationContextModule.class,
          ActivityRetainedCBuilderModule.class,
          ServiceCBuilderModule.class,
          HiltWrapper_FragmentGetContextFix_FragmentGetContextFixModule.class,
          NetworkModule.class,
          RepositoryModule.class
      }
  )
  @Singleton
  public abstract static class SingletonC implements FragmentGetContextFix.FragmentGetContextFixEntryPoint,
      HiltWrapper_ActivityRetainedComponentManager_ActivityRetainedComponentBuilderEntryPoint,
      ServiceComponentManager.ServiceComponentBuilderEntryPoint,
      SingletonComponent,
      GeneratedComponent,
      CoreViaApp_GeneratedInjector {
  }

  @Subcomponent
  @ServiceScoped
  public abstract static class ServiceC implements ServiceComponent,
      GeneratedComponent {
    @Subcomponent.Builder
    abstract interface Builder extends ServiceComponentBuilder {
    }
  }

  @Subcomponent(
      modules = {
          AICalorieViewModel_HiltModules.KeyModule.class,
          AddFoodViewModel_HiltModules.KeyModule.class,
          AddWorkoutViewModel_HiltModules.KeyModule.class,
          AnalyticsDashboardViewModel_HiltModules.KeyModule.class,
          ChatDetailViewModel_HiltModules.KeyModule.class,
          CommentsViewModel_HiltModules.KeyModule.class,
          ContentViewModel_HiltModules.KeyModule.class,
          ConversationsViewModel_HiltModules.KeyModule.class,
          ActivityCBuilderModule.class,
          ViewModelCBuilderModule.class,
          CreatePostViewModel_HiltModules.KeyModule.class,
          CreateProductViewModel_HiltModules.KeyModule.class,
          CreateSessionViewModel_HiltModules.KeyModule.class,
          DailySurveyViewModel_HiltModules.KeyModule.class,
          FoodAICalorieViewModel_HiltModules.KeyModule.class,
          FoodViewModel_HiltModules.KeyModule.class,
          ForgotPasswordViewModel_HiltModules.KeyModule.class,
          HiltWrapper_ActivityRetainedComponentManager_LifecycleModule.class,
          HiltWrapper_SavedStateHandleModule.class,
          HomeViewModel_HiltModules.KeyModule.class,
          LiveSessionDetailViewModel_HiltModules.KeyModule.class,
          LiveSessionViewModel_HiltModules.KeyModule.class,
          LoginViewModel_HiltModules.KeyModule.class,
          MarketplaceViewModel_HiltModules.KeyModule.class,
          MealPlanViewModel_HiltModules.KeyModule.class,
          OnboardingViewModel_HiltModules.KeyModule.class,
          PremiumViewModel_HiltModules.KeyModule.class,
          ProductDetailViewModel_HiltModules.KeyModule.class,
          ProfileViewModel_HiltModules.KeyModule.class,
          RegisterViewModel_HiltModules.KeyModule.class,
          RouteViewModel_HiltModules.KeyModule.class,
          SettingsViewModel_HiltModules.KeyModule.class,
          SocialFeedViewModel_HiltModules.KeyModule.class,
          TrainerBrowseViewModel_HiltModules.KeyModule.class,
          TrainerHomeViewModel_HiltModules.KeyModule.class,
          TrainerProductsViewModel_HiltModules.KeyModule.class,
          TrainerSessionsViewModel_HiltModules.KeyModule.class,
          TrainerVerificationViewModel_HiltModules.KeyModule.class,
          TrainingPlanViewModel_HiltModules.KeyModule.class,
          WorkoutViewModel_HiltModules.KeyModule.class
      }
  )
  @ActivityRetainedScoped
  public abstract static class ActivityRetainedC implements ActivityRetainedComponent,
      ActivityComponentManager.ActivityComponentBuilderEntryPoint,
      HiltWrapper_ActivityRetainedComponentManager_ActivityRetainedLifecycleEntryPoint,
      GeneratedComponent {
    @Subcomponent.Builder
    abstract interface Builder extends ActivityRetainedComponentBuilder {
    }
  }

  @Subcomponent(
      modules = {
          FragmentCBuilderModule.class,
          ViewCBuilderModule.class,
          HiltWrapper_ActivityModule.class,
          HiltWrapper_DefaultViewModelFactories_ActivityModule.class
      }
  )
  @ActivityScoped
  public abstract static class ActivityC implements ActivityComponent,
      DefaultViewModelFactories.ActivityEntryPoint,
      HiltWrapper_HiltViewModelFactory_ActivityCreatorEntryPoint,
      FragmentComponentManager.FragmentComponentBuilderEntryPoint,
      ViewComponentManager.ViewComponentBuilderEntryPoint,
      GeneratedComponent,
      MainActivity_GeneratedInjector {
    @Subcomponent.Builder
    abstract interface Builder extends ActivityComponentBuilder {
    }
  }

  @Subcomponent(
      modules = {
          AICalorieViewModel_HiltModules.BindsModule.class,
          AddFoodViewModel_HiltModules.BindsModule.class,
          AddWorkoutViewModel_HiltModules.BindsModule.class,
          AnalyticsDashboardViewModel_HiltModules.BindsModule.class,
          ChatDetailViewModel_HiltModules.BindsModule.class,
          CommentsViewModel_HiltModules.BindsModule.class,
          ContentViewModel_HiltModules.BindsModule.class,
          ConversationsViewModel_HiltModules.BindsModule.class,
          CreatePostViewModel_HiltModules.BindsModule.class,
          CreateProductViewModel_HiltModules.BindsModule.class,
          CreateSessionViewModel_HiltModules.BindsModule.class,
          DailySurveyViewModel_HiltModules.BindsModule.class,
          FoodAICalorieViewModel_HiltModules.BindsModule.class,
          FoodViewModel_HiltModules.BindsModule.class,
          ForgotPasswordViewModel_HiltModules.BindsModule.class,
          HiltWrapper_HiltViewModelFactory_ViewModelModule.class,
          HomeViewModel_HiltModules.BindsModule.class,
          LiveSessionDetailViewModel_HiltModules.BindsModule.class,
          LiveSessionViewModel_HiltModules.BindsModule.class,
          LoginViewModel_HiltModules.BindsModule.class,
          MarketplaceViewModel_HiltModules.BindsModule.class,
          MealPlanViewModel_HiltModules.BindsModule.class,
          OnboardingViewModel_HiltModules.BindsModule.class,
          PremiumViewModel_HiltModules.BindsModule.class,
          ProductDetailViewModel_HiltModules.BindsModule.class,
          ProfileViewModel_HiltModules.BindsModule.class,
          RegisterViewModel_HiltModules.BindsModule.class,
          RouteViewModel_HiltModules.BindsModule.class,
          SettingsViewModel_HiltModules.BindsModule.class,
          SocialFeedViewModel_HiltModules.BindsModule.class,
          TrainerBrowseViewModel_HiltModules.BindsModule.class,
          TrainerHomeViewModel_HiltModules.BindsModule.class,
          TrainerProductsViewModel_HiltModules.BindsModule.class,
          TrainerSessionsViewModel_HiltModules.BindsModule.class,
          TrainerVerificationViewModel_HiltModules.BindsModule.class,
          TrainingPlanViewModel_HiltModules.BindsModule.class,
          WorkoutViewModel_HiltModules.BindsModule.class
      }
  )
  @ViewModelScoped
  public abstract static class ViewModelC implements ViewModelComponent,
      HiltViewModelFactory.ViewModelFactoriesEntryPoint,
      GeneratedComponent {
    @Subcomponent.Builder
    abstract interface Builder extends ViewModelComponentBuilder {
    }
  }

  @Subcomponent
  @ViewScoped
  public abstract static class ViewC implements ViewComponent,
      GeneratedComponent {
    @Subcomponent.Builder
    abstract interface Builder extends ViewComponentBuilder {
    }
  }

  @Subcomponent(
      modules = ViewWithFragmentCBuilderModule.class
  )
  @FragmentScoped
  public abstract static class FragmentC implements FragmentComponent,
      DefaultViewModelFactories.FragmentEntryPoint,
      ViewComponentManager.ViewWithFragmentComponentBuilderEntryPoint,
      GeneratedComponent {
    @Subcomponent.Builder
    abstract interface Builder extends FragmentComponentBuilder {
    }
  }

  @Subcomponent
  @ViewScoped
  public abstract static class ViewWithFragmentC implements ViewWithFragmentComponent,
      GeneratedComponent {
    @Subcomponent.Builder
    abstract interface Builder extends ViewWithFragmentComponentBuilder {
    }
  }
}
