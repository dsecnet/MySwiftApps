package life.corevia.app.ui.home;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;
import life.corevia.app.data.repository.AuthRepository;
import life.corevia.app.data.repository.TrainerDashboardRepository;

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
public final class TrainerHomeViewModel_Factory implements Factory<TrainerHomeViewModel> {
  private final Provider<TokenManager> tokenManagerProvider;

  private final Provider<TrainerDashboardRepository> trainerDashboardRepositoryProvider;

  private final Provider<AuthRepository> authRepositoryProvider;

  public TrainerHomeViewModel_Factory(Provider<TokenManager> tokenManagerProvider,
      Provider<TrainerDashboardRepository> trainerDashboardRepositoryProvider,
      Provider<AuthRepository> authRepositoryProvider) {
    this.tokenManagerProvider = tokenManagerProvider;
    this.trainerDashboardRepositoryProvider = trainerDashboardRepositoryProvider;
    this.authRepositoryProvider = authRepositoryProvider;
  }

  @Override
  public TrainerHomeViewModel get() {
    return newInstance(tokenManagerProvider.get(), trainerDashboardRepositoryProvider.get(), authRepositoryProvider.get());
  }

  public static TrainerHomeViewModel_Factory create(Provider<TokenManager> tokenManagerProvider,
      Provider<TrainerDashboardRepository> trainerDashboardRepositoryProvider,
      Provider<AuthRepository> authRepositoryProvider) {
    return new TrainerHomeViewModel_Factory(tokenManagerProvider, trainerDashboardRepositoryProvider, authRepositoryProvider);
  }

  public static TrainerHomeViewModel newInstance(TokenManager tokenManager,
      TrainerDashboardRepository trainerDashboardRepository, AuthRepository authRepository) {
    return new TrainerHomeViewModel(tokenManager, trainerDashboardRepository, authRepository);
  }
}
