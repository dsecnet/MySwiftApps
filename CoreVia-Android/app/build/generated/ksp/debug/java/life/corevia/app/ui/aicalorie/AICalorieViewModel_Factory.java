package life.corevia.app.ui.aicalorie;

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
public final class AICalorieViewModel_Factory implements Factory<AICalorieViewModel> {
  private final Provider<AICalorieRepository> aiCalorieRepositoryProvider;

  public AICalorieViewModel_Factory(Provider<AICalorieRepository> aiCalorieRepositoryProvider) {
    this.aiCalorieRepositoryProvider = aiCalorieRepositoryProvider;
  }

  @Override
  public AICalorieViewModel get() {
    return newInstance(aiCalorieRepositoryProvider.get());
  }

  public static AICalorieViewModel_Factory create(
      Provider<AICalorieRepository> aiCalorieRepositoryProvider) {
    return new AICalorieViewModel_Factory(aiCalorieRepositoryProvider);
  }

  public static AICalorieViewModel newInstance(AICalorieRepository aiCalorieRepository) {
    return new AICalorieViewModel(aiCalorieRepository);
  }
}
