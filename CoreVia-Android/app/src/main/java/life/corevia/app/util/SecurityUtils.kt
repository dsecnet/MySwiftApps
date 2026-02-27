package life.corevia.app.util

import android.content.pm.PackageManager
import android.os.Build
import timber.log.Timber
import java.io.File

/**
 * Cihaz təhlükəsizlik yardımçıları — Root detection, emulator detection
 * iOS-dakı JailbreakDetection ekvivalenti
 */
object SecurityUtils {

    // ── Root Detection ───────────────────────────────────────────────

    /**
     * Cihazın root edilib-edilmədiyini yoxlayır
     * Birdən çox yoxlama: su binary, root apps, system props
     */
    fun isDeviceRooted(pm: PackageManager? = null): Boolean {
        return checkRootBinaries() || checkRootApps(pm) || checkDangerousProps() || checkRWSystem()
    }

    /** su, busybox kimi root binaryləri yoxla */
    private fun checkRootBinaries(): Boolean {
        val paths = arrayOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
            "/system/app/Superuser.apk",
            "/system/bin/busybox",
            "/system/xbin/busybox"
        )
        return paths.any { File(it).exists() }
    }

    /** Bilinen root app-lar yoxla */
    fun checkRootApps(pm: PackageManager?): Boolean {
        if (pm == null) return false
        val rootPackages = arrayOf(
            "com.topjohnwu.magisk",       // Magisk
            "eu.chainfire.supersu",        // SuperSU
            "com.koushikdutta.superuser",  // Superuser
            "com.noshufou.android.su",     // Superuser (legacy)
            "com.thirdparty.superuser",    // Superuser (third party)
            "com.yellowes.su",             // Another SU
            "com.zachspong.temprootremovejb", // Temp root
            "com.ramdroid.appquarantine"   // App quarantine
        )

        return rootPackages.any { pkg ->
            try {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(pkg, 0)
                true
            } catch (e: PackageManager.NameNotFoundException) {
                false
            }
        }
    }

    /** Təhlükəli system property-lər */
    private fun checkDangerousProps(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("getprop", "ro.debuggable"))
            val result = process.inputStream.bufferedReader().readLine()
            result?.trim() == "1" && !isEmulator()
        } catch (e: Exception) {
            false
        }
    }

    /** /system partition-un yazıla bilənliyini yoxla */
    private fun checkRWSystem(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("mount"))
            val output = process.inputStream.bufferedReader().readText()
            output.contains("/system") && output.contains("rw,")
        } catch (e: Exception) {
            false
        }
    }

    // ── Emulator Detection ───────────────────────────────────────────

    /** Emulator-da işləyib-işləmədiyini yoxla */
    fun isEmulator(): Boolean {
        return (Build.FINGERPRINT.startsWith("google/sdk_gphone")
                || Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")
                || "google_sdk" == Build.PRODUCT
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu"))
    }

    // ── Debugger Detection ───────────────────────────────────────────

    /** Debugger qoşulub-qoşulmadığını yoxla */
    fun isDebuggerAttached(): Boolean {
        return android.os.Debug.isDebuggerConnected() || android.os.Debug.waitingForDebugger()
    }

    /**
     * Tam təhlükəsizlik yoxlaması — app başladıqda çağırılmalı
     * @return Təhlükəsizlik problemlərinin siyahısı (boş = problem yoxdur)
     */
    fun performSecurityCheck(pm: PackageManager? = null): List<String> {
        val issues = mutableListOf<String>()

        if (isDeviceRooted(pm)) {
            issues.add("Cihaz root edilib")
            Timber.w("Security: Cihaz root olunub")
        }

        if (isEmulator()) {
            Timber.d("Security: Emulator aşkar edildi (development rejimi)")
        }

        if (isDebuggerAttached()) {
            issues.add("Debugger qoşulub")
            Timber.w("Security: Debugger bağlıdır")
        }

        return issues
    }
}
