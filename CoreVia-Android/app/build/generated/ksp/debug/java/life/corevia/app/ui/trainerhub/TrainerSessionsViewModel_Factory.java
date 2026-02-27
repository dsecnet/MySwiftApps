package life.corevia.app.ui.trainerhub;

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
public final class TrainerSessionsViewModel_Factory implements Factory<TrainerSessionsViewModel> {
  private final Provider<LiveSessionRepository> liveSessionRepositoryProvider;

  public TrainerSessionsViewModel_Factory(
      Provider<LiveSessionRepository> liveSessionRepositoryProvider) {
    this.liveSessionRepositoryProvider = liveSessionRepositoryProvider;
  }

  @Override
  public TrainerSessionsViewModel get() {
    return newInstance(liveSessionRepositoryProvider.get());
  }

  public static TrainerSessionsViewModel_Factory create(
      Provider<LiveSessionRepository> liveSessionRepositoryProvider) {
    return new TrainerSessionsViewModel_Factory(liveSessionRepositoryProvider);
  }

  public static TrainerSessionsViewModel newInstance(LiveSessionRepository liveSessionRepository) {
    return new TrainerSessionsViewModel(liveSessionRepository);
  }
}
