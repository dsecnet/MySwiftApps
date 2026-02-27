package life.corevia.app.ui.trainers;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.TrainerRepository;

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
public final class TrainerBrowseViewModel_Factory implements Factory<TrainerBrowseViewModel> {
  private final Provider<TrainerRepository> trainerRepositoryProvider;

  public TrainerBrowseViewModel_Factory(Provider<TrainerRepository> trainerRepositoryProvider) {
    this.trainerRepositoryProvider = trainerRepositoryProvider;
  }

  @Override
  public TrainerBrowseViewModel get() {
    return newInstance(trainerRepositoryProvider.get());
  }

  public static TrainerBrowseViewModel_Factory create(
      Provider<TrainerRepository> trainerRepositoryProvider) {
    return new TrainerBrowseViewModel_Factory(trainerRepositoryProvider);
  }

  public static TrainerBrowseViewModel newInstance(TrainerRepository trainerRepository) {
    return new TrainerBrowseViewModel(trainerRepository);
  }
}
