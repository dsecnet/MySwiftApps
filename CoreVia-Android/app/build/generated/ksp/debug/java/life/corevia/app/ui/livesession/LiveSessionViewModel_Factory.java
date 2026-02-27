package life.corevia.app.ui.livesession;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.LiveSessionRepository;

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
public final class LiveSessionViewModel_Factory implements Factory<LiveSessionViewModel> {
  private final Provider<LiveSessionRepository> repositoryProvider;

  public LiveSessionViewModel_Factory(Provider<LiveSessionRepository> repositoryProvider) {
    this.repositoryProvider = repositoryProvider;
  }

  @Override
  public LiveSessionViewModel get() {
    return newInstance(repositoryProvider.get());
  }

  public static LiveSessionViewModel_Factory create(
      Provider<LiveSessionRepository> repositoryProvider) {
    return new LiveSessionViewModel_Factory(repositoryProvider);
  }

  public static LiveSessionViewModel newInstance(LiveSessionRepository repository) {
    return new LiveSessionViewModel(repository);
  }
}
