package life.corevia.app.data.repository;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;
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
public final class ContentRepository_Factory implements Factory<ContentRepository> {
  private final Provider<ApiService> apiServiceProvider;

  private final Provider<OkHttpClient> okHttpClientProvider;

  public ContentRepository_Factory(Provider<ApiService> apiServiceProvider,
      Provider<OkHttpClient> okHttpClientProvider) {
    this.apiServiceProvider = apiServiceProvider;
    this.okHttpClientProvider = okHttpClientProvider;
  }

  @Override
  public ContentRepository get() {
    return newInstance(apiServiceProvider.get(), okHttpClientProvider.get());
  }

  public static ContentRepository_Factory create(Provider<ApiService> apiServiceProvider,
      Provider<OkHttpClient> okHttpClientProvider) {
    return new ContentRepository_Factory(apiServiceProvider, okHttpClientProvider);
  }

  public static ContentRepository newInstance(ApiService apiService, OkHttpClient okHttpClient) {
    return new ContentRepository(apiService, okHttpClient);
  }
}
