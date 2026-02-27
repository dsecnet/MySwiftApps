package life.corevia.app.ui.premium;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;
import life.corevia.app.data.repository.PremiumRepository;

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
public final class PremiumViewModel_Factory implements Factory<PremiumViewModel> {
  private final Provider<TokenManager> tokenManagerProvider;

  private final Provider<PremiumRepository> premiumRepositoryProvider;

  public PremiumViewModel_Factory(Provider<TokenManager> tokenManagerProvider,
      Provider<PremiumRepository> premiumRepositoryProvider) {
    this.tokenManagerProvider = tokenManagerProvider;
    this.premiumRepositoryProvider = premiumRepositoryProvider;
  }

  @Override
  public PremiumViewModel get() {
    return newInstance(tokenManagerProvider.get(), premiumRepositoryProvider.get());
  }

  public static PremiumViewModel_Factory create(Provider<TokenManager> tokenManagerProvider,
      Provider<PremiumRepository> premiumRepositoryProvider) {
    return new PremiumViewModel_Factory(tokenManagerProvider, premiumRepositoryProvider);
  }

  public static PremiumViewModel newInstance(TokenManager tokenManager,
      PremiumRepository premiumRepository) {
    return new PremiumViewModel(tokenManager, premiumRepository);
  }
}
