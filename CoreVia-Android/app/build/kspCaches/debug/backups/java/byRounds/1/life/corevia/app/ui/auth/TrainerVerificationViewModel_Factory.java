package life.corevia.app.ui.auth;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.AuthRepository;

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
public final class TrainerVerificationViewModel_Factory implements Factory<TrainerVerificationViewModel> {
  private final Provider<AuthRepository> authRepositoryProvider;

  public TrainerVerificationViewModel_Factory(Provider<AuthRepository> authRepositoryProvider) {
    this.authRepositoryProvider = authRepositoryProvider;
  }

  @Override
  public TrainerVerificationViewModel get() {
    return newInstance(authRepositoryProvider.get());
  }

  public static TrainerVerificationViewModel_Factory create(
      Provider<AuthRepository> authRepositoryProvider) {
    return new TrainerVerificationViewModel_Factory(authRepositoryProvider);
  }

  public static TrainerVerificationViewModel newInstance(AuthRepository authRepository) {
    return new TrainerVerificationViewModel(authRepository);
  }
}
