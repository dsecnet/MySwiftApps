package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;
import life.corevia.app.data.repository.RouteRepository;

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
public final class RepositoryModule_ProvideRouteRepositoryFactory implements Factory<RouteRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public RepositoryModule_ProvideRouteRepositoryFactory(Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public RouteRepository get() {
    return provideRouteRepository(apiServiceProvider.get());
  }

  public static RepositoryModule_ProvideRouteRepositoryFactory create(
      Provider<ApiService> apiServiceProvider) {
    return new RepositoryModule_ProvideRouteRepositoryFactory(apiServiceProvider);
  }

  public static RouteRepository provideRouteRepository(ApiService apiService) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideRouteRepository(apiService));
  }
}
