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
public final class CreateProductViewModel_Factory implements Factory<CreateProductViewModel> {
  private final Provider<MarketplaceRepository> marketplaceRepositoryProvider;

  public CreateProductViewModel_Factory(
      Provider<MarketplaceRepository> marketplaceRepositoryProvider) {
    this.marketplaceRepositoryProvider = marketplaceRepositoryProvider;
  }

  @Override
  public CreateProductViewModel get() {
    return newInstance(marketplaceRepositoryProvider.get());
  }

  public static CreateProductViewModel_Factory create(
      Provider<MarketplaceRepository> marketplaceRepositoryProvider) {
    return new CreateProductViewModel_Factory(marketplaceRepositoryProvider);
  }

  public static CreateProductViewModel newInstance(MarketplaceRepository marketplaceRepository) {
    return new CreateProductViewModel(marketplaceRepository);
  }
}
