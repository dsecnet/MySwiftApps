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
public final class AddFoodViewModel_Factory implements Factory<AddFoodViewModel> {
  private final Provider<FoodRepository> foodRepositoryProvider;

  public AddFoodViewModel_Factory(Provider<FoodRepository> foodRepositoryProvider) {
    this.foodRepositoryProvider = foodRepositoryProvider;
  }

  @Override
  public AddFoodViewModel get() {
    return newInstance(foodRepositoryProvider.get());
  }

  public static AddFoodViewModel_Factory create(Provider<FoodRepository> foodRepositoryProvider) {
    return new AddFoodViewModel_Factory(foodRepositoryProvider);
  }

  public static AddFoodViewModel newInstance(FoodRepository foodRepository) {
    return new AddFoodViewModel(foodRepository);
  }
}
