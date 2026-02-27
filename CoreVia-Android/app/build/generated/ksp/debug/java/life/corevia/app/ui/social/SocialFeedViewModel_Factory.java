package life.corevia.app.ui.social;

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
public final class SocialFeedViewModel_Factory implements Factory<SocialFeedViewModel> {
  private final Provider<SocialRepository> socialRepositoryProvider;

  public SocialFeedViewModel_Factory(Provider<SocialRepository> socialRepositoryProvider) {
    this.socialRepositoryProvider = socialRepositoryProvider;
  }

  @Override
  public SocialFeedViewModel get() {
    return newInstance(socialRepositoryProvider.get());
  }

  public static SocialFeedViewModel_Factory create(
      Provider<SocialRepository> socialRepositoryProvider) {
    return new SocialFeedViewModel_Factory(socialRepositoryProvider);
  }

  public static SocialFeedViewModel newInstance(SocialRepository socialRepository) {
    return new SocialFeedViewModel(socialRepository);
  }
}
