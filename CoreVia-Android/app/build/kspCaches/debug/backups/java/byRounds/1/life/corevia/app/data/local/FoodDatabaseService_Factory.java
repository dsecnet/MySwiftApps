package life.corevia.app.data.local;

import android.content.Context;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata("dagger.hilt.android.qualifiers.ApplicationContext")
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
public final class FoodDatabaseService_Factory implements Factory<FoodDatabaseService> {
  private final Provider<Context> contextProvider;

  public FoodDatabaseService_Factory(Provider<Context> contextProvider) {
    this.contextProvider = contextProvider;
  }

  @Override
  public FoodDatabaseService get() {
    return newInstance(contextProvider.get());
  }

  public static FoodDatabaseService_Factory create(Provider<Context> contextProvider) {
    return new FoodDatabaseService_Factory(contextProvider);
  }

  public static FoodDatabaseService newInstance(Context context) {
    return new FoodDatabaseService(context);
  }
}
