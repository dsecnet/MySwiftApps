package life.corevia.app.ui.survey;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.repository.SurveyRepository;

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
public final class DailySurveyViewModel_Factory implements Factory<DailySurveyViewModel> {
  private final Provider<SurveyRepository> surveyRepositoryProvider;

  public DailySurveyViewModel_Factory(Provider<SurveyRepository> surveyRepositoryProvider) {
    this.surveyRepositoryProvider = surveyRepositoryProvider;
  }

  @Override
  public DailySurveyViewModel get() {
    return newInstance(surveyRepositoryProvider.get());
  }

  public static DailySurveyViewModel_Factory create(
      Provider<SurveyRepository> surveyRepositoryProvider) {
    return new DailySurveyViewModel_Factory(surveyRepositoryProvider);
  }

  public static DailySurveyViewModel newInstance(SurveyRepository surveyRepository) {
    return new DailySurveyViewModel(surveyRepository);
  }
}
