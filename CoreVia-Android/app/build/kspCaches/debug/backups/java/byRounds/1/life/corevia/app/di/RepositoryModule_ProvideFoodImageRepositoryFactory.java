package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.FoodImageRepository;
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
public final class RepositoryModule_ProvideFoodImageRepositoryFactory implements Factory<FoodImageRepository> {
  private final Provider<OkHttpClient> okHttpClientProvider;

  public RepositoryModule_ProvideFoodImageRepositoryFactory(
      Provider<OkHttpClient> okHttpClientProvider) {
    this.okHttpClientProvider = okHttpClientProvider;
  }

  @Override
  public FoodImageRepository get() {
    return provideFoodImageRepository(okHttpClientProvider.get());
  }

  public static RepositoryModule_ProvideFoodImageRepositoryFactory create(
      Provider<OkHttpClient> okHttpClientProvider) {
    return new RepositoryModule_ProvideFoodImageRepositoryFactory(okHttpClientProvider);
  }

  public static FoodImageRepository provideFoodImageRepository(OkHttpClient okHttpClient) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideFoodImageRepository(okHttpClient));
  }
}
