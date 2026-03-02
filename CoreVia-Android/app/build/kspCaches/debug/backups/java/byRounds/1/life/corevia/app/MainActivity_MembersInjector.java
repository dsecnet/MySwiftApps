package life.corevia.app;

import android.content.SharedPreferences;
import dagger.MembersInjector;
import dagger.internal.DaggerGenerated;
import dagger.internal.InjectedFieldSignature;
import dagger.internal.QualifierMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

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
public final class MainActivity_MembersInjector implements MembersInjector<MainActivity> {
  private final Provider<SharedPreferences> sharedPreferencesProvider;

  public MainActivity_MembersInjector(Provider<SharedPreferences> sharedPreferencesProvider) {
    this.sharedPreferencesProvider = sharedPreferencesProvider;
  }

  public static MembersInjector<MainActivity> create(
      Provider<SharedPreferences> sharedPreferencesProvider) {
    return new MainActivity_MembersInjector(sharedPreferencesProvider);
  }

  @Override
  public void injectMembers(MainActivity instance) {
    injectSharedPreferences(instance, sharedPreferencesProvider.get());
  }

  @InjectedFieldSignature("life.corevia.app.MainActivity.sharedPreferences")
  public static void injectSharedPreferences(MainActivity instance,
      SharedPreferences sharedPreferences) {
    instance.sharedPreferences = sharedPreferences;
  }
}
