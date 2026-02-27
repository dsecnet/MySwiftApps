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
public final class AnalyticsRepository_Factory implements Factory<AnalyticsRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public AnalyticsRepository_Factory(Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public AnalyticsRepository get() {
    return newInstance(apiServiceProvider.get());
  }

  public static AnalyticsRepository_Factory create(Provider<ApiService> apiServiceProvider) {
    return new AnalyticsRepository_Factory(apiServiceProvider);
  }

  public static AnalyticsRepository newInstance(ApiService apiService) {
    return new AnalyticsRepository(apiService);
  }
}
