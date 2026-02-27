package life.corevia.app.data.local;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata("javax.inject.Singleton")
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
public final class OnDeviceFoodAnalyzer_Factory implements Factory<OnDeviceFoodAnalyzer> {
  private final Provider<FoodDatabaseService> foodDatabaseServiceProvider;

  public OnDeviceFoodAnalyzer_Factory(Provider<FoodDatabaseService> foodDatabaseServiceProvider) {
    this.foodDatabaseServiceProvider = foodDatabaseServiceProvider;
  }

  @Override
  public OnDeviceFoodAnalyzer get() {
    return newInstance(foodDatabaseServiceProvider.get());
  }

  public static OnDeviceFoodAnalyzer_Factory create(
      Provider<FoodDatabaseService> foodDatabaseServiceProvider) {
    return new OnDeviceFoodAnalyzer_Factory(foodDatabaseServiceProvider);
  }

  public static OnDeviceFoodAnalyzer newInstance(FoodDatabaseService foodDatabaseService) {
    return new OnDeviceFoodAnalyzer(foodDatabaseService);
  }
}
