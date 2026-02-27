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
public final class MealPlanRepository_Factory implements Factory<MealPlanRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public MealPlanRepository_Factory(Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public MealPlanRepository get() {
    return newInstance(apiServiceProvider.get());
  }

  public static MealPlanRepository_Factory create(Provider<ApiService> apiServiceProvider) {
    return new MealPlanRepository_Factory(apiServiceProvider);
  }

  public static MealPlanRepository newInstance(ApiService apiService) {
    return new MealPlanRepository(apiService);
  }
}
