package life.corevia.app.data.repository;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.remote.ApiService;

@ScopeMetadata("javax.inject.Singleton")
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
public final class SurveyRepository_Factory implements Factory<SurveyRepository> {
  private final Provider<ApiService> apiServiceProvider;

  public SurveyRepository_Factory(Provider<ApiService> apiServiceProvider) {
    this.apiServiceProvider = apiServiceProvider;
  }

  @Override
  public SurveyRepository get() {
    return newInstance(apiServiceProvider.get());
  }

  public static SurveyRepository_Factory create(Provider<ApiService> apiServiceProvider) {
    return new SurveyRepository_Factory(apiServiceProvider);
  }

  public static SurveyRepository newInstance(ApiService apiService) {
    return new SurveyRepository(apiService);
  }
}
