package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;
import life.corevia.app.data.repository.TrainerDashboardRepository;

@ScopeMetadata("javax.inject.Singleton")
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
public final class RepositoryModule_ProvideTrainerDashboardRepositoryFactory implements Factory<TrainerDashboardRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public RepositoryModule_ProvideTrainerDashboardRepositoryFactory(
      Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public TrainerDashboardRepository get() {
    return provideTrainerDashboardRepository(apiServiceProvider.get());
  }

  public static RepositoryModule_ProvideTrainerDashboardRepositoryFactory create(
      Provider<ApiService> apiServiceProvider) {
    return new RepositoryModule_ProvideTrainerDashboardRepositoryFactory(apiServiceProvider);
  }

  public static TrainerDashboardRepository provideTrainerDashboardRepository(
      ApiService apiService) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideTrainerDashboardRepository(apiService));
  }
}
