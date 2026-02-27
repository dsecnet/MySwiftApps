package life.corevia.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import kotlinx.serialization.json.Json;
import life.corevia.app.data.local.OnDeviceFoodAnalyzer;
import life.corevia.app.data.remote.ApiService;
import life.corevia.app.data.repository.AICalorieRepository;
import okhttp3.OkHttpClient;

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
public final class RepositoryModule_ProvideAICalorieRepositoryFactory implements Factory<AICalorieRepository> {
  private final Provider<ApiService> apiServiceProvider;

  private final Provider<OkHttpClient> okHttpClientProvider;

  private final Provider<Json> jsonProvider;

  private final Provider<OnDeviceFoodAnalyzer> onDeviceFoodAnalyzerProvider;

  public RepositoryModule_ProvideAICalorieRepositoryFactory(Provider<ApiService> apiServiceProvider,
      Provider<OkHttpClient> okHttpClientProvider, Provider<Json> jsonProvider,
      Provider<OnDeviceFoodAnalyzer> onDeviceFoodAnalyzerProvider) {
    this.apiServiceProvider = apiServiceProvider;
    this.okHttpClientProvider = okHttpClientProvider;
    this.jsonProvider = jsonProvider;
    this.onDeviceFoodAnalyzerProvider = onDeviceFoodAnalyzerProvider;
  }

  @Override
  public AICalorieRepository get() {
    return provideAICalorieRepository(apiServiceProvider.get(), okHttpClientProvider.get(), jsonProvider.get(), onDeviceFoodAnalyzerProvider.get());
  }

  public static RepositoryModule_ProvideAICalorieRepositoryFactory create(
      Provider<ApiService> apiServiceProvider, Provider<OkHttpClient> okHttpClientProvider,
      Provider<Json> jsonProvider, Provider<OnDeviceFoodAnalyzer> onDeviceFoodAnalyzerProvider) {
    return new RepositoryModule_ProvideAICalorieRepositoryFactory(apiServiceProvider, okHttpClientProvider, jsonProvider, onDeviceFoodAnalyzerProvider);
  }

  public static AICalorieRepository provideAICalorieRepository(ApiService apiService,
      OkHttpClient okHttpClient, Json json, OnDeviceFoodAnalyzer onDeviceFoodAnalyzer) {
    return Preconditions.checkNotNullFromProvides(RepositoryModule.INSTANCE.provideAICalorieRepository(apiService, okHttpClient, json, onDeviceFoodAnalyzer));
  }
}
