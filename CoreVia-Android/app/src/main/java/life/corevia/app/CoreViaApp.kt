package life.corevia.app

import android.app.Application
import coil.Coil
import coil.ImageLoader
import coil.disk.DiskCache
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

        // ── Coil Image Cache ────────────────────────────────────────────
        // Disk cache ilə şəkil yükləmə optimallaşdırılması
        Coil.setImageLoader(
            ImageLoader.Builder(this)
                .diskCache {
                    DiskCache.Builder()
                        .directory(cacheDir.resolve("image_cache"))
                        .maxSizePercent(0.05) // 5% of available disk space
                        .build()
                }
                .crossfade(true)
                .build()
        )
    }
}
