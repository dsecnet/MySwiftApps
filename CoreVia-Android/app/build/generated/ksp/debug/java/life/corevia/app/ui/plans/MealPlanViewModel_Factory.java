package life.corevia.app.ui.plans;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.MealPlanRepository;

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
public final class MealPlanViewModel_Factory implements Factory<MealPlanViewModel> {
  private final Provider<MealPlanRepository> mealPlanRepositoryProvider;

  public MealPlanViewModel_Factory(Provider<MealPlanRepository> mealPlanRepositoryProvider) {
    this.mealPlanRepositoryProvider = mealPlanRepositoryProvider;
  }

  @Override
  public MealPlanViewModel get() {
    return newInstance(mealPlanRepositoryProvider.get());
  }

  public static MealPlanViewModel_Factory create(
      Provider<MealPlanRepository> mealPlanRepositoryProvider) {
    return new MealPlanViewModel_Factory(mealPlanRepositoryProvider);
  }

  public static MealPlanViewModel newInstance(MealPlanRepository mealPlanRepository) {
    return new MealPlanViewModel(mealPlanRepository);
  }
}
