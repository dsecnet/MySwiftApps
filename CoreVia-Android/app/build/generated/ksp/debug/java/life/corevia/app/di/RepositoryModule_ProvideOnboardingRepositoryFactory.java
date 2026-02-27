package life.corevia.app.di;

import android.content.SharedPreferences;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;
import life.corevia.app.data.repository.OnboardingRepository;

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
public final class RepositoryModule_ProvideOnboardingRepositoryFactory implements Factory<OnboardingRepository> {
  private final Provider<ApiService> apiServiceProvider;

  private final Provider<SharedPreferences> sharedPreferencesProvider;

  public RepositoryModule_ProvideOnboardingRepositoryFactory(
      Provider<ApiService> apiServiceProvider,
      Provider<SharedPreferences> sharedPreferencesProvider) {
    this.apiServiceProvider = apiServiceProvider;
    this.sharedPreferencesProvider = sharedPreferencesProvider;
  }

  @Override
  public OnboardingRepository get() {
    return provideOnboardingRepository(apiServiceProvider.get(), sharedPreferencesProvider.get());
  }

  public static RepositoryModule_ProvideOnboardingRepositoryFactory create(
      Provider<ApiService> apiServiceProvider,
      Provider<SharedPreferences> sharedPreferencesProvider) {
    return new RepositoryModule_ProvideOnboardingRepositoryFactory(apiServiceProvider, sharedPreferencesProvider);
  }

  public static OnboardingRepository provideOnboardingRepository(ApiService apiService,
      SharedPreferences sharedPreferences) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideOnboardingRepository(apiService, sharedPreferences));
  }
}
