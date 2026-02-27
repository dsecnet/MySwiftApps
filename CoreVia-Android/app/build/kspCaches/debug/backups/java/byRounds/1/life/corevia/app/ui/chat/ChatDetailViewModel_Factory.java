package life.corevia.app.ui.chat;

import androidx.lifecycle.SavedStateHandle;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.ChatRepository;

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
public final class ChatDetailViewModel_Factory implements Factory<ChatDetailViewModel> {
  private final Provider<SavedStateHandle> savedStateHandleProvider;

  private final Provider<ChatRepository> chatRepositoryProvider;

  public ChatDetailViewModel_Factory(Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<ChatRepository> chatRepositoryProvider) {
    this.savedStateHandleProvider = savedStateHandleProvider;
    this.chatRepositoryProvider = chatRepositoryProvider;
  }

  @Override
  public ChatDetailViewModel get() {
    return newInstance(savedStateHandleProvider.get(), chatRepositoryProvider.get());
  }

  public static ChatDetailViewModel_Factory create(
      Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<ChatRepository> chatRepositoryProvider) {
    return new ChatDetailViewModel_Factory(savedStateHandleProvider, chatRepositoryProvider);
  }

  public static ChatDetailViewModel newInstance(SavedStateHandle savedStateHandle,
      ChatRepository chatRepository) {
    return new ChatDetailViewModel(savedStateHandle, chatRepository);
  }
}
