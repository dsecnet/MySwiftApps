package life.corevia.app.ui.content;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.ContentRepository;

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
public final class ContentViewModel_Factory implements Factory<ContentViewModel> {
  private final Provider<ContentRepository> contentRepositoryProvider;

  public ContentViewModel_Factory(Provider<ContentRepository> contentRepositoryProvider) {
    this.contentRepositoryProvider = contentRepositoryProvider;
  }

  @Override
  public ContentViewModel get() {
    return newInstance(contentRepositoryProvider.get());
  }

  public static ContentViewModel_Factory create(
      Provider<ContentRepository> contentRepositoryProvider) {
    return new ContentViewModel_Factory(contentRepositoryProvider);
  }

  public static ContentViewModel newInstance(ContentRepository contentRepository) {
    return new ContentViewModel(contentRepository);
  }
}
