package life.corevia.app

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

@HiltAndroidApp
class CoreViaApp : Application() {

    override fun onCreate() {
        super.onCreate()

        // ── Timber Logging ────────────────────────────────────────────
        // Yalnız DEBUG build-da log çap edir, release-da heç nə
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
    }
}
