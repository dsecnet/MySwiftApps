package life.corevia.app.ui.settings;

import android.content.Context;
import android.content.SharedPreferences;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;
import life.corevia.app.data.local.TokenManager;

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
public final class SettingsViewModel_Factory implements Factory<SettingsViewModel> {
  private final Provider<Context> contextProvider;

  private final Provider<TokenManager> tokenManagerProvider;

  private final Provider<SharedPreferences> sharedPreferencesProvider;

  public SettingsViewModel_Factory(Provider<Context> contextProvider,
      Provider<TokenManager> tokenManagerProvider,
      Provider<SharedPreferences> sharedPreferencesProvider) {
    this.contextProvider = contextProvider;
    this.tokenManagerProvider = tokenManagerProvider;
    this.sharedPreferencesProvider = sharedPreferencesProvider;
  }

  @Override
  public SettingsViewModel get() {
    return newInstance(contextProvider.get(), tokenManagerProvider.get(), sharedPreferencesProvider.get());
  }

  public static SettingsViewModel_Factory create(Provider<Context> contextProvider,
      Provider<TokenManager> tokenManagerProvider,
      Provider<SharedPreferences> sharedPreferencesProvider) {
    return new SettingsViewModel_Factory(contextProvider, tokenManagerProvider, sharedPreferencesProvider);
  }

  public static SettingsViewModel newInstance(Context context, TokenManager tokenManager,
      SharedPreferences sharedPreferences) {
    return new SettingsViewModel(context, tokenManager, sharedPreferences);
  }
}
