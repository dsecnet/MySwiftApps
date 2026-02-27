package life.corevia.app.ui.profile;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;
import life.corevia.app.data.repository.AuthRepository;
import life.corevia.app.data.repository.FoodRepository;
import life.corevia.app.data.repository.TrainerDashboardRepository;
import life.corevia.app.data.repository.WorkoutRepository;

@ScopeMetadata
@QualifierMetadata
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
public final class ProfileViewModel_Factory implements Factory<ProfileViewModel> {
  private final Provider<TokenManager> tokenManagerProvider;

  private final Provider<AuthRepository> authRepositoryProvider;

  private final Provider<TrainerDashboardRepository> trainerDashboardRepositoryProvider;

  private final Provider<WorkoutRepository> workoutRepositoryProvider;

  private final Provider<FoodRepository> foodRepositoryProvider;

  public ProfileViewModel_Factory(Provider<TokenManager> tokenManagerProvider,
      Provider<AuthRepository> authRepositoryProvider,
      Provider<TrainerDashboardRepository> trainerDashboardRepositoryProvider,
      Provider<WorkoutRepository> workoutRepositoryProvider,
      Provider<FoodRepository> foodRepositoryProvider) {
    this.tokenManagerProvider = tokenManagerProvider;
    this.authRepositoryProvider = authRepositoryProvider;
    this.trainerDashboardRepositoryProvider = trainerDashboardRepositoryProvider;
    this.workoutRepositoryProvider = workoutRepositoryProvider;
    this.foodRepositoryProvider = foodRepositoryProvider;
  }

  @Override
  public ProfileViewModel get() {
    return newInstance(tokenManagerProvider.get(), authRepositoryProvider.get(), trainerDashboardRepositoryProvider.get(), workoutRepositoryProvider.get(), foodRepositoryProvider.get());
  }

  public static ProfileViewModel_Factory create(Provider<TokenManager> tokenManagerProvider,
      Provider<AuthRepository> authRepositoryProvider,
      Provider<TrainerDashboardRepository> trainerDashboardRepositoryProvider,
      Provider<WorkoutRepository> workoutRepositoryProvider,
      Provider<FoodRepository> foodRepositoryProvider) {
    return new ProfileViewModel_Factory(tokenManagerProvider, authRepositoryProvider, trainerDashboardRepositoryProvider, workoutRepositoryProvider, foodRepositoryProvider);
  }

  public static ProfileViewModel newInstance(TokenManager tokenManager,
      AuthRepository authRepository, TrainerDashboardRepository trainerDashboardRepository,
      WorkoutRepository workoutRepository, FoodRepository foodRepository) {
    return new ProfileViewModel(tokenManager, authRepository, trainerDashboardRepository, workoutRepository, foodRepository);
  }
}
