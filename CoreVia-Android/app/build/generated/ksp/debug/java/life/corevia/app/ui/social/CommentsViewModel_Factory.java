package life.corevia.app.ui.social;

import androidx.lifecycle.SavedStateHandle;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.SocialRepository;

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
public final class CommentsViewModel_Factory implements Factory<CommentsViewModel> {
  private final Provider<SavedStateHandle> savedStateHandleProvider;

  private final Provider<SocialRepository> socialRepositoryProvider;

  public CommentsViewModel_Factory(Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<SocialRepository> socialRepositoryProvider) {
    this.savedStateHandleProvider = savedStateHandleProvider;
    this.socialRepositoryProvider = socialRepositoryProvider;
  }

  @Override
  public CommentsViewModel get() {
    return newInstance(savedStateHandleProvider.get(), socialRepositoryProvider.get());
  }

  public static CommentsViewModel_Factory create(
      Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<SocialRepository> socialRepositoryProvider) {
    return new CommentsViewModel_Factory(savedStateHandleProvider, socialRepositoryProvider);
  }

  public static CommentsViewModel newInstance(SavedStateHandle savedStateHandle,
      SocialRepository socialRepository) {
    return new CommentsViewModel(savedStateHandle, socialRepository);
  }
}
