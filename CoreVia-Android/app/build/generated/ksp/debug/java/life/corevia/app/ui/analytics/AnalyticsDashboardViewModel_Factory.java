package life.corevia.app.ui.analytics;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.AnalyticsRepository;

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
public final class AnalyticsDashboardViewModel_Factory implements Factory<AnalyticsDashboardViewModel> {
  private final Provider<AnalyticsRepository> analyticsRepositoryProvider;

  public AnalyticsDashboardViewModel_Factory(
      Provider<AnalyticsRepository> analyticsRepositoryProvider) {
    this.analyticsRepositoryProvider = analyticsRepositoryProvider;
  }

  @Override
  public AnalyticsDashboardViewModel get() {
    return newInstance(analyticsRepositoryProvider.get());
  }

  public static AnalyticsDashboardViewModel_Factory create(
      Provider<AnalyticsRepository> analyticsRepositoryProvider) {
    return new AnalyticsDashboardViewModel_Factory(analyticsRepositoryProvider);
  }

  public static AnalyticsDashboardViewModel newInstance(AnalyticsRepository analyticsRepository) {
    return new AnalyticsDashboardViewModel(analyticsRepository);
  }
}
