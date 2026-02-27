package life.corevia.app.data.repository;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
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
public final class FoodImageRepository_Factory implements Factory<FoodImageRepository> {
  private final Provider<OkHttpClient> okHttpClientProvider;

  public FoodImageRepository_Factory(Provider<OkHttpClient> okHttpClientProvider) {
    this.okHttpClientProvider = okHttpClientProvider;
  }

  @Override
  public FoodImageRepository get() {
    return newInstance(okHttpClientProvider.get());
  }

  public static FoodImageRepository_Factory create(Provider<OkHttpClient> okHttpClientProvider) {
    return new FoodImageRepository_Factory(okHttpClientProvider);
  }

  public static FoodImageRepository newInstance(OkHttpClient okHttpClient) {
    return new FoodImageRepository(okHttpClient);
  }
}
