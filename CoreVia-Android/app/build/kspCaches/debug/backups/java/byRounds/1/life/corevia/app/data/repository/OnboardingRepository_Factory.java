package life.corevia.app.data.repository;

import android.content.SharedPreferences;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;

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
public final class OnboardingRepository_Factory implements Factory<OnboardingRepository> {
  private final Provider<ApiService> apiServiceProvider;

  private final Provider<SharedPreferences> sharedPreferencesProvider;

  public OnboardingRepository_Factory(Provider<ApiService> apiServiceProvider,
      Provider<SharedPreferences> sharedPreferencesProvider) {
    this.apiServiceProvider = apiServiceProvider;
    this.sharedPreferencesProvider = sharedPreferencesProvider;
  }

  @Override
  public OnboardingRepository get() {
    return newInstance(apiServiceProvider.get(), sharedPreferencesProvider.get());
  }

  public static OnboardingRepository_Factory create(Provider<ApiService> apiServiceProvider,
      Provider<SharedPreferences> sharedPreferencesProvider) {
    return new OnboardingRepository_Factory(apiServiceProvider, sharedPreferencesProvider);
  }

  public static OnboardingRepository newInstance(ApiService apiService,
      SharedPreferences sharedPreferences) {
    return new OnboardingRepository(apiService, sharedPreferences);
  }
}
