package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;
import life.corevia.app.data.repository.WorkoutRepository;

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
public final class RepositoryModule_ProvideWorkoutRepositoryFactory implements Factory<WorkoutRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public RepositoryModule_ProvideWorkoutRepositoryFactory(Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public WorkoutRepository get() {
    return provideWorkoutRepository(apiServiceProvider.get());
  }

  public static RepositoryModule_ProvideWorkoutRepositoryFactory create(
      Provider<ApiService> apiServiceProvider) {
    return new RepositoryModule_ProvideWorkoutRepositoryFactory(apiServiceProvider);
  }

  public static WorkoutRepository provideWorkoutRepository(ApiService apiService) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideWorkoutRepository(apiService));
  }
}
