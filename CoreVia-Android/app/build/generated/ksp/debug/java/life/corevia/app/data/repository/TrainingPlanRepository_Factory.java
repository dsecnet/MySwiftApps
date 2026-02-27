package life.corevia.app.data.repository;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;

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
public final class TrainingPlanRepository_Factory implements Factory<TrainingPlanRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public TrainingPlanRepository_Factory(Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public TrainingPlanRepository get() {
    return newInstance(apiServiceProvider.get());
  }

  public static TrainingPlanRepository_Factory create(Provider<ApiService> apiServiceProvider) {
    return new TrainingPlanRepository_Factory(apiServiceProvider);
  }

  public static TrainingPlanRepository newInstance(ApiService apiService) {
    return new TrainingPlanRepository(apiService);
  }
}
