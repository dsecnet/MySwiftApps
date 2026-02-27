package life.corevia.app.ui.food;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.AICalorieRepository;

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
public final class FoodAICalorieViewModel_Factory implements Factory<FoodAICalorieViewModel> {
  private final Provider<AICalorieRepository> aiCalorieRepositoryProvider;

  public FoodAICalorieViewModel_Factory(Provider<AICalorieRepository> aiCalorieRepositoryProvider) {
    this.aiCalorieRepositoryProvider = aiCalorieRepositoryProvider;
  }

  @Override
  public FoodAICalorieViewModel get() {
    return newInstance(aiCalorieRepositoryProvider.get());
  }

  public static FoodAICalorieViewModel_Factory create(
      Provider<AICalorieRepository> aiCalorieRepositoryProvider) {
    return new FoodAICalorieViewModel_Factory(aiCalorieRepositoryProvider);
  }

  public static FoodAICalorieViewModel newInstance(AICalorieRepository aiCalorieRepository) {
    return new FoodAICalorieViewModel(aiCalorieRepository);
  }
}
