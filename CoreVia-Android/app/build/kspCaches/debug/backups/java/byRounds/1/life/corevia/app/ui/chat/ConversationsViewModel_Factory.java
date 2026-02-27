package life.corevia.app.ui.chat;

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
public final class ConversationsViewModel_Factory implements Factory<ConversationsViewModel> {
  private final Provider<ChatRepository> chatRepositoryProvider;

  public ConversationsViewModel_Factory(Provider<ChatRepository> chatRepositoryProvider) {
    this.chatRepositoryProvider = chatRepositoryProvider;
  }

  @Override
  public ConversationsViewModel get() {
    return newInstance(chatRepositoryProvider.get());
  }

  public static ConversationsViewModel_Factory create(
      Provider<ChatRepository> chatRepositoryProvider) {
    return new ConversationsViewModel_Factory(chatRepositoryProvider);
  }

  public static ConversationsViewModel newInstance(ChatRepository chatRepository) {
    return new ConversationsViewModel(chatRepository);
  }
}
