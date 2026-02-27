package life.corevia.app.ui.trainerhub;

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
public final class TrainerProductsViewModel_Factory implements Factory<TrainerProductsViewModel> {
  private final Provider<MarketplaceRepository> marketplaceRepositoryProvider;

  public TrainerProductsViewModel_Factory(
      Provider<MarketplaceRepository> marketplaceRepositoryProvider) {
    this.marketplaceRepositoryProvider = marketplaceRepositoryProvider;
  }

  @Override
  public TrainerProductsViewModel get() {
    return newInstance(marketplaceRepositoryProvider.get());
  }

  public static TrainerProductsViewModel_Factory create(
      Provider<MarketplaceRepository> marketplaceRepositoryProvider) {
    return new TrainerProductsViewModel_Factory(marketplaceRepositoryProvider);
  }

  public static TrainerProductsViewModel newInstance(MarketplaceRepository marketplaceRepository) {
    return new TrainerProductsViewModel(marketplaceRepository);
  }
}
