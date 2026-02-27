package life.corevia.app.data.repository;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import kotlinx.serialization.json.Json;
import life.corevia.app.data.local.OnDeviceFoodAnalyzer;
import life.corevia.app.data.remote.ApiService;
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
public final class AICalorieRepository_Factory implements Factory<AICalorieRepository> {
  private final Provider<ApiService> apiServiceProvider;

  private final Provider<OkHttpClient> okHttpClientProvider;

  private final Provider<Json> jsonProvider;

  private final Provider<OnDeviceFoodAnalyzer> onDeviceFoodAnalyzerProvider;

  public AICalorieRepository_Factory(Provider<ApiService> apiServiceProvider,
      Provider<OkHttpClient> okHttpClientProvider, Provider<Json> jsonProvider,
      Provider<OnDeviceFoodAnalyzer> onDeviceFoodAnalyzerProvider) {
    this.apiServiceProvider = apiServiceProvider;
    this.okHttpClientProvider = okHttpClientProvider;
    this.jsonProvider = jsonProvider;
    this.onDeviceFoodAnalyzerProvider = onDeviceFoodAnalyzerProvider;
  }

  @Override
  public AICalorieRepository get() {
    return newInstance(apiServiceProvider.get(), okHttpClientProvider.get(), jsonProvider.get(), onDeviceFoodAnalyzerProvider.get());
  }

  public static AICalorieRepository_Factory create(Provider<ApiService> apiServiceProvider,
      Provider<OkHttpClient> okHttpClientProvider, Provider<Json> jsonProvider,
      Provider<OnDeviceFoodAnalyzer> onDeviceFoodAnalyzerProvider) {
    return new AICalorieRepository_Factory(apiServiceProvider, okHttpClientProvider, jsonProvider, onDeviceFoodAnalyzerProvider);
  }

  public static AICalorieRepository newInstance(ApiService apiService, OkHttpClient okHttpClient,
      Json json, OnDeviceFoodAnalyzer onDeviceFoodAnalyzer) {
    return new AICalorieRepository(apiService, okHttpClient, json, onDeviceFoodAnalyzer);
  }
}
