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
public final class LiveSessionRepository_Factory implements Factory<LiveSessionRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public LiveSessionRepository_Factory(Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public LiveSessionRepository get() {
    return newInstance(apiServiceProvider.get());
  }

  public static LiveSessionRepository_Factory create(Provider<ApiService> apiServiceProvider) {
    return new LiveSessionRepository_Factory(apiServiceProvider);
  }

  public static LiveSessionRepository newInstance(ApiService apiService) {
    return new LiveSessionRepository(apiService);
  }
}
