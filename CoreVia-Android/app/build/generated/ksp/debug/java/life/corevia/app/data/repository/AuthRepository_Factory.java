package life.corevia.app.data.repository;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;
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
public final class AuthRepository_Factory implements Factory<AuthRepository> {
  private final Provider<ApiService> apiServiceProvider;

  private final Provider<TokenManager> tokenManagerProvider;

  public AuthRepository_Factory(Provider<ApiService> apiServiceProvider,
      Provider<TokenManager> tokenManagerProvider) {
    this.apiServiceProvider = apiServiceProvider;
    this.tokenManagerProvider = tokenManagerProvider;
  }

  @Override
  public AuthRepository get() {
    return newInstance(apiServiceProvider.get(), tokenManagerProvider.get());
  }

  public static AuthRepository_Factory create(Provider<ApiService> apiServiceProvider,
      Provider<TokenManager> tokenManagerProvider) {
    return new AuthRepository_Factory(apiServiceProvider, tokenManagerProvider);
  }

  public static AuthRepository newInstance(ApiService apiService, TokenManager tokenManager) {
    return new AuthRepository(apiService, tokenManager);
  }
}
