package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.ProfileImageRepository;
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
public final class RepositoryModule_ProvideProfileImageRepositoryFactory implements Factory<ProfileImageRepository> {
  private final Provider<OkHttpClient> okHttpClientProvider;

  public RepositoryModule_ProvideProfileImageRepositoryFactory(
      Provider<OkHttpClient> okHttpClientProvider) {
    this.okHttpClientProvider = okHttpClientProvider;
  }

  @Override
  public ProfileImageRepository get() {
    return provideProfileImageRepository(okHttpClientProvider.get());
  }

  public static RepositoryModule_ProvideProfileImageRepositoryFactory create(
      Provider<OkHttpClient> okHttpClientProvider) {
    return new RepositoryModule_ProvideProfileImageRepositoryFactory(okHttpClientProvider);
  }

  public static ProfileImageRepository provideProfileImageRepository(OkHttpClient okHttpClient) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideProfileImageRepository(okHttpClient));
  }
}
