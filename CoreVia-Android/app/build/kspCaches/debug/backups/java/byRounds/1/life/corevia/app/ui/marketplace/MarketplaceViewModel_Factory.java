package life.corevia.app.ui.marketplace;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.MarketplaceRepository;

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
public final class MarketplaceViewModel_Factory implements Factory<MarketplaceViewModel> {
  private final Provider<MarketplaceRepository> marketplaceRepositoryProvider;

  public MarketplaceViewModel_Factory(
      Provider<MarketplaceRepository> marketplaceRepositoryProvider) {
    this.marketplaceRepositoryProvider = marketplaceRepositoryProvider;
  }

  @Override
  public MarketplaceViewModel get() {
    return newInstance(marketplaceRepositoryProvider.get());
  }

  public static MarketplaceViewModel_Factory create(
      Provider<MarketplaceRepository> marketplaceRepositoryProvider) {
    return new MarketplaceViewModel_Factory(marketplaceRepositoryProvider);
  }

  public static MarketplaceViewModel newInstance(MarketplaceRepository marketplaceRepository) {
    return new MarketplaceViewModel(marketplaceRepository);
  }
}
