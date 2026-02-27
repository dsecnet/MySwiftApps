package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;
import life.corevia.app.data.repository.ContentRepository;
import okhttp3.OkHttpClient;

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
public final class RepositoryModule_ProvideContentRepositoryFactory implements Factory<ContentRepository> {
  private final Provider<ApiService> apiServiceProvider;

  private final Provider<OkHttpClient> okHttpClientProvider;

  public RepositoryModule_ProvideContentRepositoryFactory(Provider<ApiService> apiServiceProvider,
      Provider<OkHttpClient> okHttpClientProvider) {
    this.apiServiceProvider = apiServiceProvider;
    this.okHttpClientProvider = okHttpClientProvider;
  }

  @Override
  public ContentRepository get() {
    return provideContentRepository(apiServiceProvider.get(), okHttpClientProvider.get());
  }

  public static RepositoryModule_ProvideContentRepositoryFactory create(
      Provider<ApiService> apiServiceProvider, Provider<OkHttpClient> okHttpClientProvider) {
    return new RepositoryModule_ProvideContentRepositoryFactory(apiServiceProvider, okHttpClientProvider);
  }

  public static ContentRepository provideContentRepository(ApiService apiService,
      OkHttpClient okHttpClient) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideContentRepository(apiService, okHttpClient));
  }
}
