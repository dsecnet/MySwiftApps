package life.corevia.app.ui.onboarding;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.OnboardingRepository;

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
public final class OnboardingViewModel_Factory implements Factory<OnboardingViewModel> {
  private final Provider<OnboardingRepository> onboardingRepositoryProvider;

  public OnboardingViewModel_Factory(Provider<OnboardingRepository> onboardingRepositoryProvider) {
    this.onboardingRepositoryProvider = onboardingRepositoryProvider;
  }

  @Override
  public OnboardingViewModel get() {
    return newInstance(onboardingRepositoryProvider.get());
  }

  public static OnboardingViewModel_Factory create(
      Provider<OnboardingRepository> onboardingRepositoryProvider) {
    return new OnboardingViewModel_Factory(onboardingRepositoryProvider);
  }

  public static OnboardingViewModel newInstance(OnboardingRepository onboardingRepository) {
    return new OnboardingViewModel(onboardingRepository);
  }
}
