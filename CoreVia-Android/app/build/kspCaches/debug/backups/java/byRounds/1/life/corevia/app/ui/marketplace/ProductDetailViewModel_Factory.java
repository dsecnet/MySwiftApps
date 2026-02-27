package life.corevia.app.ui.marketplace;

import androidx.lifecycle.SavedStateHandle;
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
public final class ProductDetailViewModel_Factory implements Factory<ProductDetailViewModel> {
  private final Provider<SavedStateHandle> savedStateHandleProvider;

  private final Provider<MarketplaceRepository> marketplaceRepositoryProvider;

  public ProductDetailViewModel_Factory(Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<MarketplaceRepository> marketplaceRepositoryProvider) {
    this.savedStateHandleProvider = savedStateHandleProvider;
    this.marketplaceRepositoryProvider = marketplaceRepositoryProvider;
  }

  @Override
  public ProductDetailViewModel get() {
    return newInstance(savedStateHandleProvider.get(), marketplaceRepositoryProvider.get());
  }

  public static ProductDetailViewModel_Factory create(
      Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<MarketplaceRepository> marketplaceRepositoryProvider) {
    return new ProductDetailViewModel_Factory(savedStateHandleProvider, marketplaceRepositoryProvider);
  }

  public static ProductDetailViewModel newInstance(SavedStateHandle savedStateHandle,
      MarketplaceRepository marketplaceRepository) {
    return new ProductDetailViewModel(savedStateHandle, marketplaceRepository);
  }
}
