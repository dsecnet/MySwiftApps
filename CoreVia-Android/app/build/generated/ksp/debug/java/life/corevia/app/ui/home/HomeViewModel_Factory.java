package life.corevia.app.ui.home;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;
import life.corevia.app.data.repository.AuthRepository;
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
public final class HomeViewModel_Factory implements Factory<HomeViewModel> {
  private final Provider<TokenManager> tokenManagerProvider;

  private final Provider<WorkoutRepository> workoutRepositoryProvider;

  private final Provider<AuthRepository> authRepositoryProvider;

  public HomeViewModel_Factory(Provider<TokenManager> tokenManagerProvider,
      Provider<WorkoutRepository> workoutRepositoryProvider,
      Provider<AuthRepository> authRepositoryProvider) {
    this.tokenManagerProvider = tokenManagerProvider;
    this.workoutRepositoryProvider = workoutRepositoryProvider;
    this.authRepositoryProvider = authRepositoryProvider;
  }

  @Override
  public HomeViewModel get() {
    return newInstance(tokenManagerProvider.get(), workoutRepositoryProvider.get(), authRepositoryProvider.get());
  }

  public static HomeViewModel_Factory create(Provider<TokenManager> tokenManagerProvider,
      Provider<WorkoutRepository> workoutRepositoryProvider,
      Provider<AuthRepository> authRepositoryProvider) {
    return new HomeViewModel_Factory(tokenManagerProvider, workoutRepositoryProvider, authRepositoryProvider);
  }

  public static HomeViewModel newInstance(TokenManager tokenManager,
      WorkoutRepository workoutRepository, AuthRepository authRepository) {
    return new HomeViewModel(tokenManager, workoutRepository, authRepository);
  }
}
