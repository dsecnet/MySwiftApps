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
public final class ProfileImageRepository_Factory implements Factory<ProfileImageRepository> {
  private final Provider<OkHttpClient> okHttpClientProvider;

  public ProfileImageRepository_Factory(Provider<OkHttpClient> okHttpClientProvider) {
    this.okHttpClientProvider = okHttpClientProvider;
  }

  @Override
  public ProfileImageRepository get() {
    return newInstance(okHttpClientProvider.get());
  }

  public static ProfileImageRepository_Factory create(Provider<OkHttpClient> okHttpClientProvider) {
    return new ProfileImageRepository_Factory(okHttpClientProvider);
  }

  public static ProfileImageRepository newInstance(OkHttpClient okHttpClient) {
    return new ProfileImageRepository(okHttpClient);
  }
}
