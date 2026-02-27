package life.corevia.app.ui.route;

import android.content.Context;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.AuthRepository;
import life.corevia.app.data.repository.RouteRepository;
import life.corevia.app.data.repository.WorkoutRepository;

@ScopeMetadata
@QualifierMetadata("dagger.hilt.android.qualifiers.ApplicationContext")
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
public final class RouteViewModel_Factory implements Factory<RouteViewModel> {
  private final Provider<RouteRepository> routeRepositoryProvider;

  private final Provider<WorkoutRepository> workoutRepositoryProvider;

  private final Provider<AuthRepository> authRepositoryProvider;

  private final Provider<Context> contextProvider;

  public RouteViewModel_Factory(Provider<RouteRepository> routeRepositoryProvider,
      Provider<WorkoutRepository> workoutRepositoryProvider,
      Provider<AuthRepository> authRepositoryProvider, Provider<Context> contextProvider) {
    this.routeRepositoryProvider = routeRepositoryProvider;
    this.workoutRepositoryProvider = workoutRepositoryProvider;
    this.authRepositoryProvider = authRepositoryProvider;
    this.contextProvider = contextProvider;
  }

  @Override
  public RouteViewModel get() {
    return newInstance(routeRepositoryProvider.get(), workoutRepositoryProvider.get(), authRepositoryProvider.get(), contextProvider.get());
  }

  public static RouteViewModel_Factory create(Provider<RouteRepository> routeRepositoryProvider,
      Provider<WorkoutRepository> workoutRepositoryProvider,
      Provider<AuthRepository> authRepositoryProvider, Provider<Context> contextProvider) {
    return new RouteViewModel_Factory(routeRepositoryProvider, workoutRepositoryProvider, authRepositoryProvider, contextProvider);
  }

  public static RouteViewModel newInstance(RouteRepository routeRepository,
      WorkoutRepository workoutRepository, AuthRepository authRepository, Context context) {
    return new RouteViewModel(routeRepository, workoutRepository, authRepository, context);
  }
}
