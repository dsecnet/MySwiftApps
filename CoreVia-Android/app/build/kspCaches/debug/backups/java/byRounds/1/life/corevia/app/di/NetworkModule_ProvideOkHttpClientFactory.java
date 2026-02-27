package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;
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
public final class NetworkModule_ProvideOkHttpClientFactory implements Factory<OkHttpClient> {
  private final Provider<TokenManager> tokenManagerProvider;

  public NetworkModule_ProvideOkHttpClientFactory(Provider<TokenManager> tokenManagerProvider) {
    this.tokenManagerProvider = tokenManagerProvider;
  }

  @Override
  public OkHttpClient get() {
    return provideOkHttpClient(tokenManagerProvider.get());
  }

  public static NetworkModule_ProvideOkHttpClientFactory create(
      Provider<TokenManager> tokenManagerProvider) {
    return new NetworkModule_ProvideOkHttpClientFactory(tokenManagerProvider);
  }

  public static OkHttpClient provideOkHttpClient(TokenManager tokenManager) {
    return Preconditions.checkNotNullFromProvides(NetworkModule.INSTANCE.provideOkHttpClient(tokenManager));
  }
}
