package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;
import life.corevia.app.data.remote.ApiService;
import life.corevia.app.data.repository.AuthRepository;

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
public final class RepositoryModule_ProvideAuthRepositoryFactory implements Factory<AuthRepository> {
  private final Provider<ApiService> apiServiceProvider;

  private final Provider<TokenManager> tokenManagerProvider;

  public RepositoryModule_ProvideAuthRepositoryFactory(Provider<ApiService> apiServiceProvider,
      Provider<TokenManager> tokenManagerProvider) {
    this.apiServiceProvider = apiServiceProvider;
    this.tokenManagerProvider = tokenManagerProvider;
  }

  @Override
  public AuthRepository get() {
    return provideAuthRepository(apiServiceProvider.get(), tokenManagerProvider.get());
  }

  public static RepositoryModule_ProvideAuthRepositoryFactory create(
      Provider<ApiService> apiServiceProvider, Provider<TokenManager> tokenManagerProvider) {
    return new RepositoryModule_ProvideAuthRepositoryFactory(apiServiceProvider, tokenManagerProvider);
  }

  public static AuthRepository provideAuthRepository(ApiService apiService,
      TokenManager tokenManager) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideAuthRepository(apiService, tokenManager));
  }
}
