package life.corevia.app.ui.livesession;

import androidx.lifecycle.SavedStateHandle;
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
public final class LiveSessionDetailViewModel_Factory implements Factory<LiveSessionDetailViewModel> {
  private final Provider<SavedStateHandle> savedStateHandleProvider;

  private final Provider<LiveSessionRepository> repositoryProvider;

  public LiveSessionDetailViewModel_Factory(Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<LiveSessionRepository> repositoryProvider) {
    this.savedStateHandleProvider = savedStateHandleProvider;
    this.repositoryProvider = repositoryProvider;
  }

  @Override
  public LiveSessionDetailViewModel get() {
    return newInstance(savedStateHandleProvider.get(), repositoryProvider.get());
  }

  public static LiveSessionDetailViewModel_Factory create(
      Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<LiveSessionRepository> repositoryProvider) {
    return new LiveSessionDetailViewModel_Factory(savedStateHandleProvider, repositoryProvider);
  }

  public static LiveSessionDetailViewModel newInstance(SavedStateHandle savedStateHandle,
      LiveSessionRepository repository) {
    return new LiveSessionDetailViewModel(savedStateHandle, repository);
  }
}
