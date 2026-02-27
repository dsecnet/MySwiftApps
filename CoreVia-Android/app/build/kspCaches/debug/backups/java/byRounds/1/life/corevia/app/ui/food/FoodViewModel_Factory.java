package life.corevia.app.ui.food;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.FoodRepository;

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
public final class FoodViewModel_Factory implements Factory<FoodViewModel> {
  private final Provider<FoodRepository> foodRepositoryProvider;

  public FoodViewModel_Factory(Provider<FoodRepository> foodRepositoryProvider) {
    this.foodRepositoryProvider = foodRepositoryProvider;
  }

  @Override
  public FoodViewModel get() {
    return newInstance(foodRepositoryProvider.get());
  }

  public static FoodViewModel_Factory create(Provider<FoodRepository> foodRepositoryProvider) {
    return new FoodViewModel_Factory(foodRepositoryProvider);
  }

  public static FoodViewModel newInstance(FoodRepository foodRepository) {
    return new FoodViewModel(foodRepository);
  }
}
