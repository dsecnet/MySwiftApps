package life.corevia.app.ui.workout;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.WorkoutRepository;

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
public final class WorkoutViewModel_Factory implements Factory<WorkoutViewModel> {
  private final Provider<WorkoutRepository> workoutRepositoryProvider;

  public WorkoutViewModel_Factory(Provider<WorkoutRepository> workoutRepositoryProvider) {
    this.workoutRepositoryProvider = workoutRepositoryProvider;
  }

  @Override
  public WorkoutViewModel get() {
    return newInstance(workoutRepositoryProvider.get());
  }

  public static WorkoutViewModel_Factory create(
      Provider<WorkoutRepository> workoutRepositoryProvider) {
    return new WorkoutViewModel_Factory(workoutRepositoryProvider);
  }

  public static WorkoutViewModel newInstance(WorkoutRepository workoutRepository) {
    return new WorkoutViewModel(workoutRepository);
  }
}
