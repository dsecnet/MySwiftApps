package life.corevia.app.ui.plans;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.TrainerRepository;
import life.corevia.app.data.repository.TrainingPlanRepository;

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
public final class TrainingPlanViewModel_Factory implements Factory<TrainingPlanViewModel> {
  private final Provider<TrainingPlanRepository> trainingPlanRepositoryProvider;

  private final Provider<TrainerRepository> trainerRepositoryProvider;

  public TrainingPlanViewModel_Factory(
      Provider<TrainingPlanRepository> trainingPlanRepositoryProvider,
      Provider<TrainerRepository> trainerRepositoryProvider) {
    this.trainingPlanRepositoryProvider = trainingPlanRepositoryProvider;
    this.trainerRepositoryProvider = trainerRepositoryProvider;
  }

  @Override
  public TrainingPlanViewModel get() {
    return newInstance(trainingPlanRepositoryProvider.get(), trainerRepositoryProvider.get());
  }

  public static TrainingPlanViewModel_Factory create(
      Provider<TrainingPlanRepository> trainingPlanRepositoryProvider,
      Provider<TrainerRepository> trainerRepositoryProvider) {
    return new TrainingPlanViewModel_Factory(trainingPlanRepositoryProvider, trainerRepositoryProvider);
  }

  public static TrainingPlanViewModel newInstance(TrainingPlanRepository trainingPlanRepository,
      TrainerRepository trainerRepository) {
    return new TrainingPlanViewModel(trainingPlanRepository, trainerRepository);
  }
}
