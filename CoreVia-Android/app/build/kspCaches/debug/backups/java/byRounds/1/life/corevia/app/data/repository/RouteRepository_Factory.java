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
public final class RouteRepository_Factory implements Factory<RouteRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public RouteRepository_Factory(Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public RouteRepository get() {
    return newInstance(apiServiceProvider.get());
  }

  public static RouteRepository_Factory create(Provider<ApiService> apiServiceProvider) {
    return new RouteRepository_Factory(apiServiceProvider);
  }

  public static RouteRepository newInstance(ApiService apiService) {
    return new RouteRepository(apiService);
  }
}
