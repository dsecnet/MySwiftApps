package life.corevia.app.data.remote;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;

@ScopeMetadata
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
public final class TokenRefreshAuthenticator_Factory implements Factory<TokenRefreshAuthenticator> {
  private final Provider<TokenManager> tokenManagerProvider;

  public TokenRefreshAuthenticator_Factory(Provider<TokenManager> tokenManagerProvider) {
    this.tokenManagerProvider = tokenManagerProvider;
  }

  @Override
  public TokenRefreshAuthenticator get() {
    return newInstance(tokenManagerProvider.get());
  }

  public static TokenRefreshAuthenticator_Factory create(
      Provider<TokenManager> tokenManagerProvider) {
    return new TokenRefreshAuthenticator_Factory(tokenManagerProvider);
  }

  public static TokenRefreshAuthenticator newInstance(TokenManager tokenManager) {
    return new TokenRefreshAuthenticator(tokenManager);
  }
}
